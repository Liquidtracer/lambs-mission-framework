/*
	Spawn garrison
	Spawns a group of infantry that garrisons buildings.
	Author: nkenny. Contributor: Drgn V4karian, Alex2k.

	Server only, after LMF preInit. Scheduled execution required (Arma 3 2.22+).

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Group type or soldier count <STRING or NUMBER> (default: "TEAM"; "SQUAD", "TEAM", "SENTRY", "ATTEAM", "AATEAM" or "MGTEAM")
		2: Garrison radius in meters <NUMBER> (default: 100)
		3: Distribution <NUMBER> (default: 1; 0 = evenly, 1 = building by building, 2 = random)
		4: Fill from the roof down <BOOLEAN> (default: false; applies to distribution 0 and 1)

	Example:
		private _handle = [garrison_1, "TEAM", 100, 1, false] spawn lmf_ai_fnc_spawnGarrison;

	Returns: Spawned group <GROUP>; grpNull on failed/unscheduled/non-server calls.
	The one-shot promise completes after InitPost/gear attempts and initial group setup.
*/

private _spawner = [] call lmf_ai_fnc_isSpawner;
if (!_spawner || {!canSuspend}) exitWith {grpNull};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_grpType", "TEAM"], ["_garrisonRadius", 100], ["_distribution", 1], ["_topDown", false]];
_spawnPos = _spawnPos call CBA_fnc_getPos;

private _type = [_grpType] call _typeMaker;
private _grp = [_spawnPos, lmf_enemySide, _type] call lmf_ai_fnc_spawnGroup;
if (isNull _grp) exitWith {grpNull};
_grp deleteGroupWhenEmpty true;
_grp setGroupIdGlobal [format ["Infantry Garrison (%1)", groupId _grp]];
_grp setFormation "DIAMOND";
_grp enableIRLasers false;
_grp enableGunLights "ForceOff";
_grp setVariable ["lmf_ai_joinableGroup", true];
_grp setVariable ["lmf_ai_garrisonGroup", true];
_grp enableAttack false;

private _units = units _grp;
{
	if (_x emptyPositions "gunner" > 0 && {_units isNotEqualTo []}) then {
		private _unit = _units deleteAt (count _units - 1);
		_unit assignAsGunner _x;
		_unit moveInGunner _x;
	};
} forEach (_spawnPos nearObjects ["LandVehicle", _garrisonRadius]);

[_spawnPos, nil, _units, _garrisonRadius, _distribution, _topDown, true] call ace_ai_fnc_garrison;
{
	if (alive _x && {local _x} && {vehicle _x == _x} && {_x getVariable ["ace_ai_garrisonned", false]}) then {
		_x setUnitPos selectRandom ["UP", "MIDDLE", "DOWN"];
	};
} forEach _units;

_grp addEventHandler ["EnemyDetected", {
	params ["_group", "_newTarget"];
	if (!local _group || {isNull _newTarget}) exitWith {};

	{
		if (alive _x && {local _x} && {vehicle _x == _x} && {!captive _x} &&
			{_x getVariable ["ace_ai_garrisonned", false]} && {!(_x checkAIFeature "PATH")}) then {
			_x setUnitPos selectRandom ["UP", "MIDDLE"];
			if (_x distance _newTarget < 75 && {random 1 < 0.1}) then {
				[[_x]] call ace_ai_fnc_unGarrison;
				_x setUnitPos "AUTO";
			};
		};
	} forEach units _group;

	if (leader _group distance _newTarget >= 75) exitWith {};
	if (random 1 < 0.3) then {_group enableGunLights "Auto"};
	{
		if (alive _x && {local _x} && {_x distance _newTarget < 75} && {random 1 < 0.25}) then {_x enableIRLasers true};
	} forEach units _group;
}];

_grp addEventHandler ["UnitKilled", {
	params ["_group", "_unit"];
	if (!local _group) exitWith {};
	private _aliveUnits = units _group select {alive _x};
	if (_aliveUnits isNotEqualTo [] && {_unit == leader _group}) then {_group selectLeader (_aliveUnits # 0)};
	if (count _aliveUnits != 1) exitWith {};
	[_aliveUnits # 0] spawn lmf_ai_fnc_reassignSurvivor;
	_group removeEventHandler [_thisEvent, _thisEventHandler];
}];

_grp enableDynamicSimulation true;

_grp setVariable ["lmf_ai_spawning", nil];
_grp
