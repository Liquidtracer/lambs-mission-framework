/*
	AI hunting
	Directs AI towards player positions without requiring prior detection.
	Run scheduled where the group is local. Boat groups use the shared landing helper.
	Author: nkenny. Contributors: Alex2k, Diwako, Drgn V4karian.

	Arguments:
		0: Group <GROUP>
		1: Hunting radius in meters <NUMBER> (default: 500)

	Example:
		[grp1, 500] spawn lmf_ai_fnc_taskHunt;
*/

params [["_grp", grpNull, [grpNull]], ["_radius", 500, [0]]];
private _cycle = 30;
private _wasInBoat = vehicle leader _grp isKindOf "Ship";
private _hasLanded = false;

while {{alive _x} count (units _grp) > 1} do {
	private _tracker = leader _grp;
	private _nearestDist = _radius;
	private _availableTargets = (switchableUnits + playableUnits - entities "HeadlessClient_F");
	private _nearest = objNull;

	{
		private _dist = vehicle _x distance2D _tracker;
		if ((_dist < _nearestDist) && {(side _x != civilian) && {isTouchingGround (vehicle _x) && {isPlayer _x}}}) then {
			_nearest = _x;
			_nearestDist = _dist;
		};
	} forEach _availableTargets;

	// Reserve landing without yielding to the boat's detection handler.
	isNil {
		if (!local _grp || {{alive _x} count units _grp <= 1}) exitWith {};
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

			_grp setBehaviour "AWARE";
			{
				private _targetPos = getPosATL _nearest;
				_x doMove _targetPos;
			} forEach (units _grp);
		} else {
			if (!_hasLanded && {waypoints _grp isEqualTo []}) then {
				private _wp =_grp addWaypoint [getPos leader _grp, 0];
				_wp setWaypointType "GUARD";
			};
		};
	};

	sleep _cycle;
};
