/*
	Spawn infantry QRF
	Spawns an infantry QRF.
	Author: nkenny. Contributors: Drgn V4karian, Alex2k.
	Player proximity is checked before every spawn, including when only one ticket is configured.

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Group type or soldier count <STRING or NUMBER> (default: "TEAM"; "SQUAD", "TEAM", "SENTRY", "ATTEAM", "AATEAM" or "MGTEAM")
		2: Spawn tickets <NUMBER> (default: 1)

	Example:
		[spawn_1, "TEAM", 1] spawn lmf_ai_fnc_spawnInfantryQrf;
*/

waitUntil {sleep 1; CBA_missionTime > 0};
private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_grpType", "TEAM"], ["_tickets", 1]];
private _dir = random 360;
if !(_spawnPos isEqualType []) then {_dir = getDir _spawnPos;};
_spawnPos = _spawnPos call CBA_fnc_getPos;
private _range = 500;

// Prepare and spawn the group
private _initTickets = _tickets;

while {_initTickets > 0} do {

	if ([_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState isEqualTo "airClose") then {

		waitUntil {sleep 10; ([_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState) in ["airDistance", "groundClose"]};
	};

	if ([_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState isEqualTo "groundClose") exitWith {};

	// Spawn and configure the group.
	private _type = [_grpType] call _typeMaker;
	private _grp = [_spawnPos, var_enemySide, _type] call BIS_fnc_spawnGroup;
	[_spawnPos, _grp, selectRandom _boat] call lmf_ai_fnc_spawnBoatForGroup;
	_grp setGroupIdGlobal [format ["Infantry QRF (%1)", groupId _grp]];
	_grp deleteGroupWhenEmpty true;
	_grp setVariable ["lmf_ai_joinableGroup", true];
	_grp setFormation "DIAMOND";
	_grp setSpeedMode "FULL";
	_grp setCombatMode "RED";

	private _wp = _grp addWaypoint [getPosASL (vehicle (leader _grp)), -1];
	_wp setWaypointType "GUARD";

	_grp addEventHandler ["EnemyDetected", {
		params ["_group", "_newTarget"];

		private _leader = leader _group;
		private _veh = vehicle _leader;

		if (
			(_group getVariable ["lmf_taskConverge_active", false]) ||
			{_veh isKindOf "Ship"} ||
			{!isTouchingGround (vehicle _newTarget)} ||
			{_veh distance2D _newTarget > 300} ||
			{surfaceIsWater (getPos _leader)}
		) exitWith {};

		{_x setWaypointPosition [getPosASL _newTarget, -1]} forEach (waypoints _group);
		_group enableIRLasers true;
		_group enableGunLights "Auto";
		_group removeEventHandler [_thisEvent, _thisEventHandler];
	}];

	_grp addEventHandler ["UnitKilled", {
		params ["_group", "_unit", "_killer", "_instigator", "_useEffects"];
		_aliveUnits = ((units _group) select {alive _x});
		if (count _aliveUnits != 1) exitWith {};
		[_aliveUnits#0] spawn lmf_ai_fnc_reassignSurvivor;
		_group removeEventHandler [_thisEvent, _thisEventHandler];
	}];

	if (_tickets > 1) then {

		waitUntil {sleep 10; {alive _x} count units _grp < 1 || {[_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState isEqualTo "groundClose"}};
	};

	_initTickets = _initTickets - 1;
};
