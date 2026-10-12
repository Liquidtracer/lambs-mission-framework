/*
	Spawn patrol
	Spawns infantry and assigns a patrol task.
	Author: nkenny. Contributor: Drgn V4karian, Alex2k.

	Server only, after LMF preInit. One-shot call; no suspension required.

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Patrol target <OBJECT, STRING or ARRAY> (default: [0, 0, 0])
		2: Group type or soldier count <STRING or NUMBER> (default: "TEAM"; "SQUAD", "TEAM", "SENTRY", "ATTEAM", "AATEAM" or "MGTEAM")
		3: Patrol radius in meters <NUMBER> (default: 200)
		4: Patrol speed preset <STRING> (default: "SLOW"; "FAST", "SLOW" or "ATTACK")
		5: Patrol formation <STRING> (default: "STAG COLUMN")

	Example:
		private _grp = [spawn_1, "mrk_patrol", "TEAM", 200, "SLOW", "STAG COLUMN"] call lmf_ai_fnc_spawnPatrol;

	Returns: Spawned group <GROUP>; grpNull on a non-spawner machine.
*/

private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {grpNull};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_patrolTarget", [0, 0, 0]], ["_grpType", "TEAM"], ["_patrolRadius", 200], ["_patrolSpeed", "SLOW"], ["_formation", "STAG COLUMN"]];
_spawnPos = _spawnPos call CBA_fnc_getPos;
_patrolTarget = _patrolTarget call CBA_fnc_getPos;
private _behaviour = "";
private _speed = "";

if (_patrolSpeed == "SLOW") then {
	_behaviour = "SAFE";
	_speed = "LIMITED";
};
if (_patrolSpeed == "FAST") then {
	_behaviour = "AWARE";
	_speed = "NORMAL";
};
if (_patrolSpeed == "ATTACK") then {
	_behaviour = "AWARE";
	_speed = "LIMITED";
};

private _type = [_grpType] call _typeMaker;
private _grp = [_spawnPos, lmf_enemySide, _type] call BIS_fnc_spawnGroup;
[_spawnPos, _grp, selectRandom _boat] call lmf_ai_fnc_spawnBoatForGroup;
_grp deleteGroupWhenEmpty true;
_grp setGroupIdGlobal [format ["Infantry Patrol (%1)", groupId _grp]];
_grp setVariable ["lmf_ai_joinableGroup", true];
_grp setSpeedMode "FULL";
_grp setCombatMode "RED";

[_grp, _patrolTarget, _patrolRadius, _behaviour, _speed, _formation] call lmf_ai_fnc_taskPatrol;

_grp enableIRLasers false;
_grp enableGunLights "ForceOff";
_grp addEventHandler ["EnemyDetected", {
	params ["_group", "_newTarget"];
	if (!local _group || {isNull _newTarget} || {leader _group distance _newTarget >= 75}) exitWith {};
	if (random 1 < 0.3) then {_group enableGunLights "Auto"};
	{
		if (alive _x && {local _x} && {_x distance _newTarget < 75} && {random 1 < 0.25}) then {_x enableIRLasers true};
	} forEach units _group;
}];

private _contactEh = _grp addEventHandler ["EnemyDetected", {
	params ["_group", "_newTarget"];
	if (!local _group || {isNull _newTarget}) exitWith {};
	if (_group getVariable ["lmf_taskConverge_active", false] ||
		{vehicle leader _group isKindOf "Ship"} ||
		{!isTouchingGround (vehicle _newTarget)} || {surfaceIsWater getPos leader _group}) exitWith {};
	{deleteWaypoint _x} forEachReversed waypoints _group;
	(_group addWaypoint [getPosASL _newTarget, -1]) setWaypointType "GUARD";
	_group setBehaviour "AWARE";
	_group setSpeedMode "FULL";
	_group setGroupIdGlobal [format ["Infantry QRF: (T-%1-%2-%3)", round (random 999), round (random 999), round (random 99)]];
	_group removeEventHandler [_thisEvent, _thisEventHandler];
	_group setVariable ["lmf_ai_patrolContactEh", nil];
}];
_grp setVariable ["lmf_ai_patrolContactEh", _contactEh];

_grp addEventHandler ["UnitKilled", {
	params ["_group", "_unit", "_killer", "_instigator", "_useEffects"];
	if (!local _group) exitWith {};
	private _aliveUnits = units _group select {alive _x};
	if (count _aliveUnits != 1) exitWith {};
	[_aliveUnits#0] spawn lmf_ai_fnc_reassignSurvivor;
	_group removeEventHandler [_thisEvent, _thisEventHandler];
}];

_grp
