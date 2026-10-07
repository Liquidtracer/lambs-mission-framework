/*
	AI convergence
	Makes AI groups converge on a position.
	Groups are selected by keywords in groupId.
	Author: Alex2k.

	Arguments:
		0: Target position <OBJECT or ARRAY>
		1: Group ID keywords <ARRAY or STRING> ("ALL" selects all eligible groups)
		2: Shoreline waypoint radius for boats in meters <NUMBER> (default: 2000)

	Examples:
		[objective_1, ["ALL"], 650] call lmf_ai_fnc_taskConverge;
		[objective_1, ["QRF", "Car"]] call lmf_ai_fnc_taskConverge;
*/

params ["_targetPos", "_typeArray", ["_radius", 2000]];

if (isNil "_targetPos") exitWith {};

private _position = _targetPos call CBA_fnc_getPos;

if (_position isEqualTo [] || {_position isEqualTo [0, 0, 0]} || {count _position < 3}) exitWith {};

if (_typeArray isEqualType "") then {
	_typeArray = [_typeArray];
};

private _isAll = "ALL" in (_typeArray apply {toUpper _x});
private _typesLower = _typeArray apply {toLower _x};

private _transportAllowsTask = {
	params ["_group"];
	if (_group getVariable ["lmf_heliTransport_active", false]) exitWith {false};
	private _transport = _group getVariable ["lmf_heliTransport_vehicle", objNull];
	isNull _transport || {(units _group) findIf {alive _x && {objectParent _x == _transport}} == -1}
};

// Find eligible groups
private _groups = allGroups select {
	local _x &&
	{side _x == lmf_enemySide} &&
	{!(_x getVariable ["lmf_taskConverge_active", false])} &&
	{[_x] call _transportAllowsTask} &&
	{
		private _gId = toLower groupId _x;
		_isAll || {_typesLower findIf {_gId find _x > -1} > -1}
	} &&
	{(units _x) findIf {alive _x} > -1} &&
	{
		private _leader = leader _x;
		private _vehicle = vehicle _leader;

		!(_vehicle isKindOf "StaticWeapon") &&
		{_vehicle == _leader || {!isNull driver _vehicle}}
	}
};

// Assign task
{
	private _group = _x;
	private _leader = leader _group;
	private _vehicle = vehicle _leader;

	// The group may have started landing or dismounting after selection.
	if !(_group getVariable ["lmf_taskConverge_active", false]) then {

		// Reserve boat tasking before any waypoint changes, without scheduler suspension.
		if (_vehicle isKindOf "Ship") then {
			isNil {
				if (!local _group || {_group getVariable ["lmf_taskConverge_active", false]}) exitWith {};
				_group setVariable ["lmf_taskConverge_active", true];
				[_group, _vehicle, _position, _radius] spawn lmf_ai_fnc_landBoatGroup;
			};
		} else {
			if (_vehicle isKindOf "Air") then {
				// EnemyDetected can start landing after selection. Recheck and assign
				// aircraft orders together, without changing other tasking's execution context.
				isNil {
					if (!local _group || {!([_group] call _transportAllowsTask)}) exitWith {};
					{deleteWaypoint _x} forEachReversed waypoints _group;
					private _wp = _group addWaypoint [_position, 0];
					_wp setWaypointType "GUARD";
				};
			} else {

				{deleteWaypoint _x} forEachReversed waypoints _group;

				// Infantry
				if (_vehicle == _leader) then {

					if ((toLower groupId _group) find "garrison" > -1) then {
						{[_x] call lmf_ai_fnc_clearGarrisonStance} forEach units _group;
						[units _group] call ace_ai_fnc_unGarrison;
					};

					{
						_x setUnitPos "AUTO";
						_x enableAI "PATH";
						_x enableAI "MOVE";
					} forEach units _group;

					private _wp = _group addWaypoint [_position, 0];
					_wp setWaypointType "GUARD";

					_group setBehaviour "AWARE";
					_group setSpeedMode "NORMAL";

				// Land vehicles
				} else {
					private _wp = _group addWaypoint [_position, 0];
					_wp setWaypointType "GUARD";
				};
			};
		};
	};
} forEach _groups;
