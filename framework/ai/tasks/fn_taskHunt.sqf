/*
	AI hunting
	Directs each soldier towards the nearest living non-civilian player every 13–17 seconds.
	Run scheduled where the group is local. Boat groups use the shared landing helper.
	Author: nkenny. Contributors: Alex2k, Diwako, Drgn V4karian.

	Arguments:
		0: Group <GROUP>
		1: Hunting radius in meters <NUMBER> (default: 500)

	Example:
		[grp1, 500] spawn lmf_ai_fnc_taskHunt;
*/

params [["_grp", grpNull, [grpNull]], ["_radius", 500, [0]]];
if (!canSuspend || {!local _grp}) exitWith {};
private _wasInBoat = vehicle leader _grp isKindOf "Ship";
private _hasLanded = false;

while {local _grp && {units _grp findIf {alive _x} != -1}} do {
	private _tracker = leader _grp;
	private _nearestDist = _radius;
	private _availableTargets = allPlayers - entities "HeadlessClient_F";
	private _nearest = objNull;

	{
		private _dist = vehicle _x distance2D _tracker;
		// Foot soldiers remain targets on upper floors; only airborne aircraft are excluded.
		if (_dist < _nearestDist && {alive _x} && {isPlayer _x} && {side _x != civilian} &&
			{!(vehicle _x isKindOf "Air") || {isTouchingGround vehicle _x}}) then {
			_nearest = _x;
			_nearestDist = _dist;
		};
	} forEach _availableTargets;

	// Reserve landing without yielding to the boat's detection handler.
	isNil {
		if (!local _grp || {units _grp findIf {alive _x} == -1}) exitWith {};
		private _veh = vehicle leader _grp;
		private _inBoat = _veh isKindOf "Ship";
		if (_inBoat) then {_wasInBoat = true};
		if (_grp getVariable ["lmf_taskConverge_active", false]) exitWith {};

		// Clear landing orders even when the tracking target has left the radius.
		if (_wasInBoat && {!_inBoat}) then {
			{deleteWaypoint _x} forEachReversed (waypoints _grp);
			_wasInBoat = false;
			_hasLanded = true;
			if (isNull _nearest) then {
				{_x doMove getPosATL _x} forEach (units _grp);
			};
		};

		if !(isNull _nearest) then {
			if (_inBoat) exitWith {
				_grp setVariable ["lmf_taskConverge_active", true];
				[_grp, _veh, getPosASL _nearest, _radius] spawn lmf_ai_fnc_landBoatGroup;
			};

			// Drop any no-target GUARD fallback before resuming individual pursuit.
			{deleteWaypoint _x} forEachReversed waypoints _grp;
			private _targetPos = getPosATL _nearest;
			{
				if (alive _x && {local _x}) then {
					_x forceSpeed -1;
					_x doMove _targetPos;
				};
			} forEach (units _grp);
			_grp setSpeedMode "FULL";
		} else {
			if (!_hasLanded && {waypoints _grp isEqualTo []}) then {
				private _wp =_grp addWaypoint [getPos leader _grp, 0];
				_wp setWaypointType "GUARD";
			};
		};
	};

	sleep (13 + random 4);
};
