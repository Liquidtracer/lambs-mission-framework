/*
	Spawn infantry hunters
	Spawns infantry that hunts targets within the configured radius.
	Author: nkenny. Contributors: Drgn V4karian, Alex2k.
	Player proximity is checked before every spawn, including when only one ticket is configured.

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Group type or soldier count <STRING or NUMBER> (default: "TEAM"; "SQUAD", "TEAM", "SENTRY", "ATTEAM", "AATEAM" or "MGTEAM")
		2: Hunting radius in meters <NUMBER> (default: 500)
		3: Spawn tickets <NUMBER> (default: 1)

	Example:
		[spawn_1, "TEAM", 500, 1] spawn lmf_ai_fnc_spawnInfantryHunters;
*/

waitUntil {sleep 1; CBA_missionTime > 0};
private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_grpType", "TEAM"], ["_radius", 500], ["_tickets", 1]];
_spawnPos = _spawnPos call CBA_fnc_getPos;
private _range = 500;

// Prepare and spawn the group
private _initTickets = _tickets;

while {_initTickets > 0} do {

	if ([_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState isEqualTo "airClose") then {

		waitUntil {sleep 5; ([_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState) in ["airDistance", "groundClose"]};
	};

	if ([_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState isEqualTo "groundClose") exitWith {};

	// Spawn and configure the group.
	private _type = [_grpType] call _typeMaker;
	private _grp = [_spawnPos, var_enemySide, _type] call BIS_fnc_spawnGroup;
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

	if (_tickets > 1) then {

		waitUntil {sleep 5; {alive _x} count units _grp < 1 || {[_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState isEqualTo "groundClose"}};
	};

	_initTickets = _initTickets - 1;
};
