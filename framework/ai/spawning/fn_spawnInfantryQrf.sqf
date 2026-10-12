/*
	Spawn infantry QRF
	Spawns infantry with GUARD behavior.
	Author: nkenny. Contributors: Drgn V4karian, Alex2k.

	Server only, after LMF preInit. One-shot call does not suspend; use spawn for managed waves.

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Group type or soldier count <STRING or NUMBER> (default: "TEAM"; "SQUAD", "TEAM", "SENTRY", "ATTEAM", "AATEAM" or "MGTEAM")
		2: Total tickets <NUMBER> (optional; omitted = one-shot, supplied = managed, including 1)

	Example:
		private _grp = [spawn_1, "TEAM"] call lmf_ai_fnc_spawnInfantryQrf;

	Returns (one-shot): Spawned GROUP; grpNull on a non-spawner machine.
*/

private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {grpNull};

private _managed = count _this > 2;
if (_managed && {!canSuspend}) exitWith {};
if (_managed) then {waitUntil {sleep 1; CBA_missionTime > 0};};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_grpType", "TEAM"], ["_tickets", 1]];
_spawnPos = _spawnPos call CBA_fnc_getPos;

private _spawnOnce = {
	private _type = [_grpType] call _typeMaker;
	private _grp = [_spawnPos, lmf_enemySide, _type] call BIS_fnc_spawnGroup;
	[_spawnPos, _grp, selectRandom _boat] call lmf_ai_fnc_spawnBoatForGroup;
	_grp setGroupIdGlobal [format ["Infantry QRF (%1)", groupId _grp]];
	_grp deleteGroupWhenEmpty true;
	_grp setVariable ["lmf_ai_joinableGroup", true];
	_grp setFormation "DIAMOND";
	_grp setSpeedMode "FULL";
	_grp setCombatMode "RED";

	private _wp = _grp addWaypoint [getPosASL (vehicle (leader _grp)), -1];
	_wp setWaypointType "GUARD";

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

	_grp addEventHandler ["UnitKilled", {
		params ["_group", "_unit", "_killer", "_instigator", "_useEffects"];
		if (!local _group) exitWith {};
		private _aliveUnits = units _group select {alive _x};
		if (count _aliveUnits != 1) exitWith {};
		[_aliveUnits#0] spawn lmf_ai_fnc_reassignSurvivor;
		_group removeEventHandler [_thisEvent, _thisEventHandler];
	}];

	_grp
};

if (_managed) exitWith {
	[_spawnOnce, _tickets, 0, _spawnPos, 500, 10] call lmf_ai_fnc_runWaves;
};

call _spawnOnce
