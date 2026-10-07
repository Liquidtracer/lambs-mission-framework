/*
	Spawn garrison
	Spawns a group of infantry that garrisons buildings.
	Runs scheduled on the server. Covered defenders reconsider stance on fire and detection events.
	Suppression and group losses reduce exposure; releasing a defender ends stance control.
	Author: nkenny. Contributor: Drgn V4karian, Alex2k.

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Group type or soldier count <STRING or NUMBER> (default: "TEAM"; "SQUAD", "TEAM", "SENTRY", "ATTEAM", "AATEAM" or "MGTEAM")
		2: Garrison radius in meters <NUMBER> (default: 100)
		3: Distribution <NUMBER> (default: 1; 0 = evenly, 1 = building by building)
		4: Fill from the roof down <BOOLEAN> (default: false; false = random garrison)

	Example:
		[garrison_1, "TEAM", 100, 1, false] spawn lmf_ai_fnc_spawnGarrison;
*/

waitUntil {sleep 1; CBA_missionTime > 0};
private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_grpType", "TEAM"], ["_garrisonRadius", 100], ["_distribution", 1], ["_topDown", false]];
_spawnPos = _spawnPos call CBA_fnc_getPos;

// Prepare and spawn the group
private _type = [_grpType] call _typeMaker;
private _grp = [_spawnPos, var_enemySide, _type] call BIS_fnc_spawnGroup;
_grp deleteGroupWhenEmpty true;
_grp setGroupIdGlobal [format ["Infantry Garrison (%1)", groupId _grp]];
_grp setFormation "DIAMOND";
_grp enableIRLasers false;
_grp enableGunLights "ForceOff";
_grp setVariable ["lmf_ai_joinableGroup", true];
_grp enableAttack false;
_grp setVariable ["lmf_ai_garrisonInitialCount", count units _grp];
_grp setVariable ["lmf_ai_garrisonHeavyLosses", false];

// Man nearby vehicle turrets and static weapons
private ["_list", "_units"];
_list = _spawnPos nearObjects ["LandVehicle", _garrisonRadius];
_units = (units _grp) select {typeOf _x != _matGunner};
_unitsAt = (units _grp) select {typeOf _x == _matGunner};
_staticWeapons = [];

// Find available static weapons
{
	if ((_x emptyPositions "gunner") > 0) then {
		_staticWeapons = _staticWeapons + [_x];
	};
} forEach _list;

// Man the weapons
{
	if ((count _units) > 0) then {
		private ["_unit"];
		_unit = (_units select ((count _units) - 1));
		_unit assignAsGunner _x;
		_unit moveInGunner _x;
		(group _unit) addVehicle _x;
		_units resize ((count _units) - 1);
	};
} forEach _staticWeapons;

// Garrison
[_spawnPos, nil, _units + _unitsAt, _garrisonRadius, _distribution, _topDown, true] call ace_ai_fnc_garrison;
{
	_x setVariable ["lmf_ai_garrisonGroup", _grp];
} forEach (_units + _unitsAt);

// Unit behavior on getting hit
lmf_ai_fnc_onGarrisonHit = {
	params ["_unit", "_source", "_damage", "_instigator"];
	if (!alive _unit) exitWith {};
	[_unit] call lmf_ai_fnc_clearGarrisonStance;
	_unit setUnitPos "AUTO";
	_unit enableAI "PATH";
	_posArray = [_unit, 10, true, true] call lambs_main_fnc_findBuildings;
	if (_posArray isNotEqualTo []) then {_unit doMove selectRandom _posArray};
};
{
	_x addEventHandler ["Hit", {
		params ["_unit", "_source", "_damage", "_instigator"];
		if (50 > random 100) then {
			[_unit, _instigator] call lmf_ai_fnc_onGarrisonHit;
			_unit removeEventHandler ["Hit", _thisEventHandler];
		};
	}];
} forEach (units _grp) - [leader _grp];

// Unit behavior on nearby fire
// Short overhead fallback for cover not recognized by insideBuilding (e.g. camo nets).
lmf_ai_fnc_hasOverheadCover = {
	params ["_unit"];
	private _start = eyePos _unit;
	private _end = _start vectorAdd [0, 0, 5];
	// LOD2 only handles a missing LOD, so explicitly check FIRE when VIEW misses.
	(lineIntersectsSurfaces [_start, _end, _unit, objNull, true, 1, "VIEW", "FIRE"]) isNotEqualTo [] || {
		(lineIntersectsSurfaces [_start, _end, _unit, objNull, true, 1, "FIRE", "NONE"]) isNotEqualTo []
	}
};

// Call only for living, local defenders in covered positions.
lmf_ai_fnc_setGarrisonCoveredStance = {
	params ["_unit"];
	private _standChance = [0.5, 0.25] select ((group _unit) getVariable ["lmf_ai_garrisonHeavyLosses", false]);
	// Unavailable suppression (-1) leaves the casualty-based probability unchanged.
	if (getSuppression _unit >= 0.5) then {_standChance = 0.15};
	_unit setUnitPos (["MIDDLE", "UP"] select (random 1 < _standChance));
};

lmf_ai_fnc_onGarrisonFiredNear = {
	params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
	if (!local _unit || {!alive _unit} || {vehicle _unit != _unit} || {captive _unit} ||
		{(_unit getVariable ["lmf_ai_garrisonGroup", grpNull]) != group _unit} ||
		{_unit checkAIFeature "PATH"}) exitWith {
		[_unit] call lmf_ai_fnc_clearGarrisonStance;
	};
	if ((group _unit) getVariable ["lmf_isSurrendering", false]) exitWith {};

	// Close hostile shots can release the defender on every event, independently of stance cooldown.
	private _shooter = [_gunner, _firer] select (isNull _gunner);
	if (_distance < 15 && {[side group _unit, side _shooter] call BIS_fnc_sideIsEnemy} && {random 1 < 0.05}) exitWith {
		[_unit] call lmf_ai_fnc_clearGarrisonStance;
		_unit enableAI "PATH";
		private _posArray = [_unit, 10, true, true] call lambs_main_fnc_findBuildings;
		if (_posArray isNotEqualTo []) then {_unit doMove selectRandom _posArray};
	};

	private _nextStanceTime = _unit getVariable ["lmf_ai_garrisonNextStanceTime", -1];
	if (diag_tickTime < _nextStanceTime) exitWith {};
	_unit setVariable ["lmf_ai_garrisonNextStanceTime", diag_tickTime + 6 + random 9];

	if (insideBuilding _unit == 1 || {[_unit] call lmf_ai_fnc_hasOverheadCover}) then {
		[_unit] call lmf_ai_fnc_setGarrisonCoveredStance;
	} else {
		// Preserve the first-fire outdoor reaction without repeatedly changing outdoor stance.
		if (_nextStanceTime < 0) then {_unit setUnitPos selectRandom ["DOWN", "MIDDLE"]};
	};
};
{
	private _firedEh = _x addEventHandler ["FiredNear", {
		_this call lmf_ai_fnc_onGarrisonFiredNear;
	}];
	_x setVariable ["lmf_ai_garrisonFiredEh", _firedEh];
} forEach ((_units + _unitsAt) - [leader _grp]);

// Group behavior on detecting enemy
_grp addEventHandler ["EnemyDetected", {
	params ["_group", "_newTarget"];
	private _distance = (getPos leader _group) distance2D _newTarget;

	{
		if (alive _x && {local _x} && {!captive _x} && {vehicle _x == _x} &&
			{(_x getVariable ["lmf_ai_garrisonGroup", grpNull]) == _group} &&
			{!(_group getVariable ["lmf_isSurrendering", false])}) then {
			if (_x checkAIFeature "PATH") then {
				[_x] call lmf_ai_fnc_clearGarrisonStance;
			} else {
				if (insideBuilding _x == 1 || {[_x] call lmf_ai_fnc_hasOverheadCover}) then {
					[_x] call lmf_ai_fnc_setGarrisonCoveredStance;
				} else {
					_x setUnitPos selectRandom ["DOWN", "DOWN", "MIDDLE"];
				};
			};
		};
	} forEach (units _group);

	if (_distance > 150) exitWith {};

	_group enableIRLasers true;

	{
		if (5 > random 100 && {getSuppression _x < 0.5}) then {
			[_x] call lmf_ai_fnc_clearGarrisonStance;
			_x enableAI "PATH";
			_posArray = [_x, 10, true, true] call lambs_main_fnc_findBuildings;
			if (_posArray isNotEqualTo []) then {_x doMove selectRandom _posArray};
		};
	} forEach (units _group) - [leader _group];

	if (_distance <= 50) then {
		_group setBehaviourStrong "STEALTH";
		_group enableGunLights "Auto";
		{
			if (50 > random 100) then {
				[_x] call lmf_ai_fnc_clearGarrisonStance;
				_x enableAI "PATH";
				_posArray = [_x, 10, true, true] call lambs_main_fnc_findBuildings;
				if (_posArray isNotEqualTo []) then {_x doMove selectRandom _posArray};
			};
		} forEach (units _group) - [leader _group];
		_group removeEventHandler [_thisEvent, _thisEventHandler];
	};
}];

_grp addEventHandler ["UnitKilled", {
	params ["_group", "_unit", "_killer", "_instigator", "_useEffects"];

	private _aliveUnits = units _group select {alive _x};
	private _unitCount = count _aliveUnits;
	[_unit] call lmf_ai_fnc_clearGarrisonStance;
	_group setVariable ["lmf_ai_garrisonHeavyLosses", _unitCount <= ((_group getVariable ["lmf_ai_garrisonInitialCount", 0]) / 2)];

	if (_unitCount > 0 && {_unit isEqualTo leader _group}) then {
		_group selectLeader (_aliveUnits # 0);
	};

	if (_unitCount > 2) exitWith {};

	if (_unitCount == 0) exitWith {_group removeEventHandler [_thisEvent, _thisEventHandler];};

	if (_group getVariable ["lmf_isSurrendering", false]) exitWith {};

	private _hasHelp = (getPosATL _unit nearEntities ["Man", 30]) findIf {side _x == side _group && group _x != _group} != -1;
	private _hasNearbyEnemy = {
		params ["_survivor"];
		private _side = side group _survivor;
		// Keep the 30 m horizontal radius and include soldiers inside vehicles.
		private _nearbyUnits = [getPosATL _survivor, 30, 30, 0, false, -1] nearEntities [["Man"], false, true, true];
		_nearbyUnits findIf {
			alive _x && {_x isNotEqualTo _survivor} && {!captive _x} && {[_side, side _x] call BIS_fnc_sideIsEnemy}
		} != -1
	};
	private _surrenderCandidates = _aliveUnits select {[_x] call _hasNearbyEnemy};
	private _isIsolated = (_unitCount <= 2 && {_surrenderCandidates isNotEqualTo []} && {!_hasHelp});

	// Surrender chance
	if (_isIsolated && {random 1 < 0.25}) exitWith {

		_group setVariable ["lmf_isSurrendering", true];
		_group enableIRLasers false;
		_group enableGunLights "ForceOff";

		// Shared slots keep a rejected candidate from clearing another survivor's state.
		private _surrenderingUnits = +_surrenderCandidates;
		{
			[_x, _group, _thisEventHandler, _thisEvent, _hasNearbyEnemy, _surrenderingUnits, _forEachIndex] spawn {
				params ["_survivor", "_group", "_ehId", "_ehName", "_hasNearbyEnemy", "_surrenderingUnits", "_surrenderIndex"];

				private _releaseSurrender = {
					_surrenderingUnits set [_surrenderIndex, objNull];
					_group setVariable ["lmf_isSurrendering", _surrenderingUnits findIf {alive _x} != -1];
				};

				sleep (random 3);
				if (!alive _survivor) exitWith {call _releaseSurrender;};
				if !([_survivor] call _hasNearbyEnemy) exitWith {
					call _releaseSurrender;
					if (count (units _group select {alive _x}) == 1) then {
						_group removeEventHandler [_ehName, _ehId];
						[_survivor] spawn lmf_ai_fnc_reassignSurvivor;
					};
				};

				_survivor actionNow ["IRLaserOff", _survivor];
				_survivor actionNow ["GunLightOff", _survivor];
				[_survivor] call lmf_ai_fnc_clearGarrisonStance;
				[_survivor, true] call ace_captives_fnc_setSurrendered;

				sleep (15 + random 45);
				if (!alive _survivor) exitWith {call _releaseSurrender;};

				// Chance to end surrender
				if (random 1 < 0.5) then {
					[_survivor, false] call ace_captives_fnc_setSurrendered;

					call _releaseSurrender;
					_group enableIRLasers true;
					_group enableGunLights "Auto";

					if (count (units _group select {alive _x}) == 1) then {
						_group removeEventHandler [_ehName, _ehId];
						[_survivor] spawn lmf_ai_fnc_reassignSurvivor;
					};
				};
			};
		} forEach _surrenderCandidates;
	};

	// Merge with another group
	if (_unitCount == 1) exitWith {
		_group removeEventHandler [_thisEvent, _thisEventHandler];
		[_aliveUnits # 0] spawn lmf_ai_fnc_reassignSurvivor;
	};
}];

// Set unit stance and enable dynamic simulation.
{
	if ((insideBuilding _x) > 0 || {[_x] call lmf_ai_fnc_hasOverheadCover}) then {
		_x setUnitPos selectRandom ["MIDDLE", "UP"];
	} else {
		_x setUnitPos selectRandom ["MIDDLE", "DOWN"];
	};
} forEach (units _grp);

_grp enableDynamicSimulation true;
