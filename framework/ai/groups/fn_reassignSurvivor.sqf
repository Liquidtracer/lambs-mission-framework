/*
	Reassign survivor
	Reassigns the supplied survivor to the nearest eligible group, or gives its group a GUARD waypoint.
	Author: Alex2k.
*/

params ["_unit"];

if (!alive _unit || {!local _unit}) exitWith {};

private _joinableGroups = [_unit] call lmf_ai_fnc_findJoinableGroups;
if (_unit getVariable ["ace_ai_garrisonned", false]) then {
	[[_unit]] call ace_ai_fnc_unGarrison;
};
_unit setUnitPos "AUTO";

if (_joinableGroups isEqualTo []) exitWith {
	private _group = group _unit;
	if (!local _group) exitWith {};
	// Preserve completed waypoint 0; remove old tasks without CBA's temporary MOVE.
	private _firstWaypoint = if (currentWaypoint _group > 0) then {1} else {0};
	for "_i" from (count waypoints _group - 1) to _firstWaypoint step -1 do {
		deleteWaypoint [_group, _i];
	};
	_unit enableAI "PATH";
	_unit enableAI "MOVE";
	_unit doFollow leader _group;
	_group enableAttack true;
	_group setBehaviour "AWARE";
	_group setCombatMode "RED";

	private _wp = _group addWaypoint [getPosASL _unit, -1];
	_wp setWaypointType "GUARD";
	_group setCurrentWaypoint _wp;
};

[_unit] joinSilent ((_joinableGroups # 0) # 1);
