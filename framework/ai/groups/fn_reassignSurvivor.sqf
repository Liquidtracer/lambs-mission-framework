/*
	Reassign survivor
	Reassigns the supplied survivor to the nearest eligible group, or gives its group a GUARD waypoint.
	Author: Alex2k.
*/

params ["_unit"];

if (!alive _unit) exitWith {};

private _joinableGroups = [_unit] call lmf_ai_fnc_findJoinableGroups;
[_unit] call lmf_ai_fnc_clearGarrisonStance;
[[_unit]] call ace_ai_fnc_unGarrison;

if (_joinableGroups isEqualTo []) exitWith {
	private _group = group _unit;
	[_group] call CBA_fnc_clearWaypoints;
	_unit setUnitPos "AUTO";
	_unit enableAI "PATH";
	_unit enableAI "MOVE";
	_group enableAttack true;
	_group setBehaviour "AWARE";
	_group setCombatMode "RED";

	private _wp = _group addWaypoint [getPosASL _unit, -1];
	_wp setWaypointType "GUARD";
};

[_unit] joinSilent ((_joinableGroups # 0) # 1);
