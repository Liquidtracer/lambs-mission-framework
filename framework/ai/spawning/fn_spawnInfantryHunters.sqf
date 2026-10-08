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
	_grp setVariable ["lmf_ai_joinableGroupHunter", true];
	_grp setVariable ["lambs_danger_dangerAI", "disabled"];
	_grp setVariable ["lambs_danger_disableGroupAI", true];
	{_x setVariable ["lambs_danger_disableAI", true]} forEach (units _grp);
	// {_x disableAI "AUTOCOMBAT"} forEach (units _grp);
	_grp enableAttack false;
	_grp setBehaviour "SAFE";
	_grp allowFleeing 0;

	// Store the script handle before casualty handling can interrupt startup.
	isNil {
		_grp addEventHandler ["UnitKilled", {
			params ["_group", "_unit", "_killer", "_instigator", "_useEffects"];
			private _aliveUnits = units _group select {alive _x};
			if (count _aliveUnits > 1) exitWith {};
			// Stop even a suspended hunt before issuing GUARD or transferring the survivor.
			terminate (_group getVariable ["lmf_ai_huntScript", scriptNull]);
			_group setVariable ["lmf_ai_huntScript", nil];
			_group setVariable ["lambs_danger_dangerAI", nil];
			_group setVariable ["lambs_danger_disableGroupAI", nil];
			if (_aliveUnits isNotEqualTo []) then {
				private _survivor = _aliveUnits # 0;
				_survivor setVariable ["lambs_danger_disableAI", nil];
				[_survivor, _group] spawn {
					params ["_survivor", "_oldGroup"];
					if (!alive _survivor) exitWith {};
					_survivor doMove getPosATL _survivor;
					[_survivor] call lmf_ai_fnc_reassignSurvivor;
					if (group _survivor != _oldGroup) then {
						_survivor doFollow leader group _survivor;
					};
				};
			};
			_group removeEventHandler [_thisEvent, _thisEventHandler];
		}];

		_grp setVariable ["lmf_ai_huntScript", [_grp, _radius] spawn lmf_ai_fnc_taskHunt];
	};

	_grp
};

if (_managed) exitWith {
	[_spawnOnce, _tickets, 0, _spawnPos, 500, 5] call lmf_ai_fnc_runWaves;
};

call _spawnOnce
