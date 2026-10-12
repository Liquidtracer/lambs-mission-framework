/*
	Spawn infantry hunters
	Spawns infantry that hunts targets within the configured radius.
	Author: nkenny. Contributors: Drgn V4karian, Alex2k.

	Server only, after LMF preInit. One-shot call does not suspend; use spawn for managed waves.

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Group type or soldier count <STRING or NUMBER> (default: "TEAM"; "SQUAD", "TEAM", "SENTRY", "ATTEAM", "AATEAM" or "MGTEAM")
		2: Hunting radius in meters <NUMBER> (default: 500)
		3: Total tickets <NUMBER> (optional; omitted = one-shot, supplied = managed, including 1)

	Example:
		private _grp = [spawn_1, "TEAM", 1500] call lmf_ai_fnc_spawnInfantryHunters;

	Returns (one-shot): Spawned GROUP; grpNull on a non-spawner machine.
*/

private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {grpNull};

private _managed = count _this > 3;
if (_managed && {!canSuspend}) exitWith {};
if (_managed) then {waitUntil {sleep 1; CBA_missionTime > 0};};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_grpType", "TEAM"], ["_radius", 500], ["_tickets", 1]];
_spawnPos = _spawnPos call CBA_fnc_getPos;

private _spawnOnce = {
	private _type = [_grpType] call _typeMaker;
	private _grp = [_spawnPos, lmf_enemySide, _type] call BIS_fnc_spawnGroup;
	[_spawnPos, _grp, selectRandom _boat] call lmf_ai_fnc_spawnBoatForGroup;
	_grp deleteGroupWhenEmpty true;
	_grp setGroupIdGlobal [format ["Infantry Hunter (%1)", groupId _grp]];
	// Keep Arma combat AI active; LAMBS movement reactions must not interrupt pursuit.
	_grp setVariable ["lambs_danger_disableGroupAI", true];
	{_x setVariable ["lambs_danger_disableAI", true]} forEach units _grp;
	_grp enableAttack false;
	_grp setBehaviour "AWARE";
	_grp setSpeedMode "FULL";
	_grp allowFleeing 0;
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

	// Install casualty handling and store the handle before scheduled hunting can run.
	isNil {
		_grp addEventHandler ["UnitKilled", {
			params ["_group"];
			if (!local _group) exitWith {};
			private _aliveUnits = units _group select {alive _x};
			if (count _aliveUnits > 1) exitWith {};
			terminate (_group getVariable ["lmf_ai_huntScript", scriptNull]);
			_group setVariable ["lmf_ai_huntScript", nil];
			_group setVariable ["lambs_danger_disableGroupAI", nil];
			{if (local _x) then {_x setVariable ["lambs_danger_disableAI", nil]}} forEach units _group;
			_group enableAttack true;
			_group allowFleeing 1;
			_group setBehaviour "AWARE";
			_group setSpeedMode "NORMAL";
			_group setCombatMode "RED";
			_group removeEventHandler [_thisEvent, _thisEventHandler];
			if (_aliveUnits isEqualTo []) exitWith {};
			private _survivor = _aliveUnits # 0;
			if (!local _survivor) exitWith {};
			_group selectLeader _survivor;
			_survivor forceSpeed -1;
			_survivor setUnitPos "AUTO";
			_survivor doFollow leader _group;
			[_survivor] call lmf_ai_fnc_reassignSurvivor;
			_survivor doFollow leader group _survivor;
		}];
		_grp setVariable ["lmf_ai_huntScript", [_grp, _radius] spawn lmf_ai_fnc_taskHunt];
	};

	_grp
};

if (_managed) exitWith {
	[_spawnOnce, _tickets, 0, _spawnPos, 500, 5] call lmf_ai_fnc_runWaves;
};

call _spawnOnce
