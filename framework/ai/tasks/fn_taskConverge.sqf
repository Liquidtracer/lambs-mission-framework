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

// Cancel old tasking and assign new orders without scheduler interleaving.
{
	isNil {
		private _group = _x;
		if (!local _group || {_group getVariable ["lmf_taskConverge_active", false]} ||
			{!([_group] call _transportAllowsTask)}) exitWith {};
		private _leader = leader _group;
		private _vehicle = vehicle _leader;

		if (!isNil {_group getVariable "lmf_ai_huntScript"}) then {
			terminate (_group getVariable "lmf_ai_huntScript");
			_group setVariable ["lmf_ai_huntScript", nil];
			_group setVariable ["lambs_danger_disableGroupAI", nil];
			_group enableAttack true;
			_group allowFleeing 1;
			{
				if (local _x) then {
					_x setVariable ["lambs_danger_disableAI", nil];
					_x forceSpeed -1;
				};
			} forEach units _group;
		};
		private _patrolEh = _group getVariable ["lmf_ai_patrolContactEh", -1];
		if (_patrolEh >= 0) then {
			_group removeEventHandler ["EnemyDetected", _patrolEh];
			_group setVariable ["lmf_ai_patrolContactEh", nil];
		};

		// Only boats reserve this flag; land groups remain available for later calls.
		if (_vehicle isKindOf "Ship") exitWith {
			_group setVariable ["lmf_taskConverge_active", true];
			[_group, _vehicle, _position, _radius] spawn lmf_ai_fnc_landBoatGroup;
		};

		{deleteWaypoint _x} forEachReversed waypoints _group;
		if (_vehicle == _leader) then {
			private _garrisoned = units _group select {_x getVariable ["ace_ai_garrisonned", false]};
			[_garrisoned] call ace_ai_fnc_unGarrison;
			{
				_x setUnitPos "AUTO";
				_x enableAI "PATH";
				_x enableAI "MOVE";
			} forEach units _group;
			// Replace individual hunt/ACE orders before following the new waypoint.
			(units _group) doFollow _leader;
			_group setBehaviour "AWARE";
			_group setSpeedMode "NORMAL";
		};

		private _wp = _group addWaypoint [_position, 0];
		_wp setWaypointType "GUARD";
	};
} forEach _groups;
