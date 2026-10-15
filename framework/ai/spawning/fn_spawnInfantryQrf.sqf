/*
	Spawn infantry QRF
	Spawns infantry with GUARD behavior.
	Author: nkenny. Contributors: Drgn V4karian, Alex2k.

	Server only, after LMF preInit. Scheduled execution required for all calls (Arma 3 2.22+).

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Group type or soldier count <STRING or NUMBER> (default: "TEAM"; "SQUAD", "TEAM", "SENTRY", "ATTEAM", "AATEAM" or "MGTEAM")
		2: Total tickets <NUMBER> (optional; omitted = one-shot, supplied = managed, including 1)
		3: Optional ZEN feedback [player object, label] <ARRAY> (default: [])

	Example:
		private _handle = [spawn_1, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf;

	Returns (one-shot): Spawned GROUP; grpNull on failed/unscheduled/non-server calls.
	The one-shot promise completes after InitPost/gear attempts and initial group setup.
	Managed scripts finish after the final preparation or cancellation, without a combined result.
*/

private _feedback = _this param [3, [], [[]]];
private _spawner = [] call lmf_ai_fnc_isSpawner;
if (!_spawner || {!canSuspend}) exitWith {
	[_feedback, "Failed", "Scheduled server execution is required."] call lmf_ai_fnc_reportSpawn;
	grpNull
};

private _managed = count _this > 2;
if (_managed) then {waitUntil {sleep 1; CBA_missionTime > 0};};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_grpType", "TEAM"], ["_tickets", 1]];
_spawnPos = _spawnPos call CBA_fnc_getPos;

private _spawnOnce = {
	private _type = [_grpType] call _typeMaker;
	private _grp = [_spawnPos, lmf_enemySide, _type] call lmf_ai_fnc_spawnGroup;
	if (isNull _grp) exitWith {grpNull};
	[_grp, ["QRF", "INFANTRY"], "LMF Infantry QRF"] call lmf_ai_fnc_initGroup;
	[_spawnPos, _grp, selectRandom _boat] call lmf_ai_fnc_spawnBoatForGroup;
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

	_grp setVariable ["lmf_ai_spawning", nil];
	_grp
};

if (_managed) exitWith {
	[_spawnOnce, _tickets, 0, _spawnPos, 500, 10, _feedback] call lmf_ai_fnc_runWaves;
};

call _spawnOnce
