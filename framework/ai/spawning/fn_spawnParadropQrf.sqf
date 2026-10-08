/*
	Spawn paradrop QRF
	Spawns an aircraft that drops AI infantry or a vehicle, then leaves and despawns.
	Author: Alex2k. Contributor: Drgn V4karian.

	Server only, after LMF preInit. One-shot call does not suspend; use spawn for managed waves.

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0]; object direction is used in autonomous mode)
		1: Drop zone <STRING, OBJECT, LOCATION or ARRAY> (default: [0, 0, 0] = autonomous; otherwise marker, trigger or location)
		2: Flying height in meters <NUMBER> (default: 200)
		3: Vehicle classname or CAR/CARARMED/TRUCK/APC/TANK category to drop <STRING> (default: "" for infantry)
		4: Total tickets <NUMBER> (optional; omitted = one-shot, supplied = managed, including 1)
		5: Respawn delay in seconds <NUMBER> (default: 300; managed replacements only)

	Example:
		private _delivery = [spawn_1, "mrk_dropZone", 200, "TANK"] call lmf_ai_fnc_spawnParadropQrf;

	Returns (one-shot): Prepared infantry GROUP or vehicle OBJECT; delivery continues asynchronously.
	Returns a null delivery on preparation failure; objNull on a non-spawner machine.
*/

private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {objNull};

private _managed = count _this > 4;
if (_managed && {!canSuspend}) exitWith {};
if (_managed) then {waitUntil {sleep 1; CBA_missionTime > 0};};

#include "spawnDefinitions.sqf"

params [
	["_spawnPos", [0, 0, 0]],
	["_dropZone", [0, 0, 0]],
	["_flyInHeight", 200],
	["_dropVehicle", ""],
	["_tickets", 1],
	["_respawnTime", 300]
];

private _dir = if (_spawnPos isEqualType objNull) then {getDir _spawnPos} else {random 360};
_spawnPos = _spawnPos call CBA_fnc_getPos;
private _isAutonomous = _dropZone isEqualTo [0, 0, 0];
private _dzPos = if (_dropZone isEqualType []) then {_dropZone} else {_dropZone call BIS_fnc_randomPosTrigger};
private _isVehicleDrop = _dropVehicle != "";

private _spawnOnce = {
	// Aircraft spawning
	if (_paraVehicle isEqualTo []) exitWith {if (_isVehicleDrop) then {objNull} else {grpNull}};
	private _isAirSpawn = (_spawnPos # 2) > 20 || surfaceIsWater _spawnPos;
	private _spawnType = if (_isAirSpawn) then {"FLY"} else {"NONE"};

	private _veh = createVehicle [selectRandom _paraVehicle, _spawnPos, [], 0, _spawnType];
	if (isNull _veh) exitWith {if (_isVehicleDrop) then {objNull} else {grpNull}};
	_veh setDir (
		if (_isAutonomous) then {_dir} else {_spawnPos getDir _dzPos}
	);

	if (_isAirSpawn) then {
		_veh setPos [_spawnPos#0, _spawnPos#1, _flyInHeight];
		_veh setVelocityModelSpace [0, 55, 0];
	};

	// Crew
	private _grp = [_spawnPos, lmf_enemySide, _heliCrew] call BIS_fnc_spawnGroup;
	_grp deleteGroupWhenEmpty true;
	_grp addVehicle _veh;
	{_x moveInAny _veh} forEach units _grp;
	_grp setGroupIdGlobal [format ["Paradrop Aircraft (%1)", groupId _grp]];

	// Payload preparation
	private _grp2 = grpNull;
	private _droppedObj = objNull;
	private _cargoSize = 0;
	private _payloadReady = false;

	if (!_isVehicleDrop) then {
		_grp2 = [_spawnPos, lmf_enemySide, (selectRandom _mgTeam) + (selectRandom _atTeam)] call BIS_fnc_spawnGroup;
		_grp2 deleteGroupWhenEmpty true;
		{
			_x assignAsCargo _veh;
			_x moveInCargo _veh;
			_x setSkill ((skill _x)*1.25);
		} forEach units _grp2;
		// Unseated infantry cannot be delivered by this aircraft.
		{deleteVehicle _x} forEach (units _grp2 select {objectParent _x != _veh});
		_payloadReady = units _grp2 findIf {alive _x} != -1;
		_grp2 enableIRLasers false;
		_grp2 enableGunLights "ForceOff";
		_grp2 setSpeedMode "FULL";
		_grp2 setCombatMode "RED";

		_grp2 addEventHandler ["EnemyDetected", {
			params ["_group", "_newTarget"];
			if (!isTouchingGround (vehicle _newTarget)) exitWith {};
			_group enableIRLasers true;
			_group enableGunLights "Auto";
			_group removeEventHandler [_thisEvent, _thisEventHandler];
		}];
	} else {
		private _class = _dropVehicle;
		private _map = [["CAR", _car], ["CARARMED", _carArmed], ["TRUCK", _truck], ["APC", _apc], ["TANK", _tank]];
		{if (toUpper _class == _x#0) exitWith {_class = selectRandom (_x#1)}} forEach _map;

		_droppedObj = createVehicle [_class, [0, 0, 1000], [], 0, "NONE"];
		_droppedObj allowDamage false;
		[_veh, 1000] call ace_cargo_fnc_setSpace;
		_cargoSize = [_droppedObj] call ace_cargo_fnc_getSizeItem;
		[_droppedObj, 1] call ace_cargo_fnc_setSize;
		_payloadReady = alive _droppedObj && {[_droppedObj, _veh, true] call ace_cargo_fnc_loadItem};
	};

	// Do not leave a prepared payload or transport behind after a failed setup.
	if (!_payloadReady || {!alive driver _veh}) exitWith {
		{
			private _parent = objectParent _x;
			if (isNull _parent) then {deleteVehicle _x} else {_parent deleteVehicleCrew _x};
		} forEach (units _grp + units _grp2);
		deleteVehicle _droppedObj;
		deleteVehicle _veh;
		if (_isVehicleDrop) then {objNull} else {grpNull}
	};

	// Flight orders
	private _wpType = if (_isAutonomous) then {"GUARD"} else {"MOVE"};
	private _wpPos = if (_isAutonomous) then {getPosASL _veh} else {_dzPos};
	private _wp = _grp addWaypoint [_wpPos, 0];
	_wp setWaypointType _wpType;

	{_x disableAI "AUTOCOMBAT"; _x disableAI "FSM"} forEach units _grp;
	_grp setBehaviourStrong "CARELESS";
	_veh flyInHeight _flyInHeight;
	_veh limitSpeed 200;

	// Pass flight state explicitly to the scheduled continuation.
	[_veh, _grp, _grp2, _droppedObj, _cargoSize, _isAutonomous, _dropZone, _isVehicleDrop, _spawnPos, _vehicleCrew, _sentry, _team] spawn {
		params ["_veh", "_grp", "_grp2", "_droppedObj", "_cargoSize", "_isAutonomous", "_dropZone", "_isVehicleDrop", "_spawnPos", "_vehicleCrew", "_sentry", "_team"];

		// Wait for the drop.
		waitUntil {
			sleep 3;
			private _triggered = if (_isAutonomous) then {
				(allPlayers - entities "HeadlessClient_F") findIf {_x distance2D _veh < 600 + (random 600)} != -1
			} else {
				_veh inArea _dropZone;
			};
			_triggered || {!alive _veh} || {{alive _x} count units _grp < 1}
		};

		// Payload deployment
		if (alive _veh && {{alive _x} count units _grp > 0}) then {
			[_grp] call CBA_fnc_clearWaypoints;
			_veh doMove (_veh getRelPos [5000, 0]);

			if (_isVehicleDrop) then {
				// Vehicle deployment
				_veh allowDamage false;
				private _dropped = [_droppedObj, "ACE_CARGO", [_veh, _cargoSize, 1.5, 0.5, false]] call lmf_paradrop_fnc_dropObject;
				if (!_dropped) exitWith {
					_veh allowDamage true;
					deleteVehicle _droppedObj;
				};

				private _crewType = _vehicleCrew;
				if (_droppedObj isKindOf "Car") then {
					_crewType = if (count (allTurrets [_droppedObj, false]) > 0) then {selectRandom _sentry} else {(selectRandom _team) + (selectRandom _sentry)};
				};

				_veh allowDamage true;

				[_droppedObj, _crewType, lmf_enemySide] spawn {
					params ["_v", "_crew", "_side"];
					sleep 1;
					if (!alive _v) exitWith {};
					private _g = [getPos _v, _side, _crew] call BIS_fnc_spawnGroup;
					_g deleteGroupWhenEmpty true;

					if (_v isKindOf "Tank" || _v isKindOf "APC") then {
						((units _g)#0) moveInDriver _v;
						if (count units _g > 1) then {((units _g)#1) moveInGunner _v};
						if (count units _g > 2) then {((units _g)#2) moveInCommander _v};
					} else {
						{_x moveInAny _v} forEach units _g;
					};
					{deleteVehicle _x} forEach (units _g select {vehicle _x == _x});

					waitUntil {sleep 0.5; !alive _v || {isTouchingGround _v}};
					sleep 1;
					if (!alive _v) exitWith {};

					private _wp = _g addWaypoint [getPosATL _v, 0];
					_wp setWaypointType "GUARD";
					// _g setVariable ["lmf_ai_joinableGroup", true];
				};

			} else {
				// Infantry deployment
				{
					if !(alive _veh) exitWith {};
					[_x, "BACKPACK", [_veh, 1.5, "ACE_NonSteerableParachute"]] call lmf_paradrop_fnc_dropUnit;
				} forEach units _grp2;

				_grp2 leaveVehicle _veh;
				[
					{isTouchingGround (leader (_this#0)) || !alive (leader (_this#0))},
					{
						params ["_g2"];
						private _wp = _g2 addWaypoint [getPosATL leader _g2, 0];
						_wp setWaypointType "GUARD";
						_g2 setVariable ["lmf_ai_joinableGroup", true];
					}, [_grp2]
				] call CBA_fnc_waitUntilAndExecute;
			};

			// Retreat
			sleep 20;
			if (alive _veh) then {
				{deleteWaypoint _x} forEachReversed waypoints _grp;
				_veh limitSpeed 999;
				_veh doMove (_veh getRelPos [25000, _veh getRelDir _spawnPos]);
				waitUntil {sleep 5; (allPlayers findIf {_x distance2D _veh < 5000} == -1) || !alive _veh};
				if (alive _veh) then {{_veh deleteVehicleCrew _x} forEach crew _veh; deleteVehicle _veh};
			};
		} else {
			if (_isVehicleDrop) then {deleteVehicle _droppedObj} else {
				{
					private _parent = objectParent _x;
					if (isNull _parent) then {
						deleteVehicle _x;
					} else {
						_parent deleteVehicleCrew _x;
					};
				} forEach units _grp2;
			};
		};
	};

	if (_isVehicleDrop) then {_droppedObj} else {_grp2}
};

if (_managed) exitWith {
	[_spawnOnce, _tickets, _respawnTime, _spawnPos, 1000, 5] call lmf_ai_fnc_runWaves;
};

call _spawnOnce
