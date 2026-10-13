/*
	Spawn paradrop QRF
	Spawns an aircraft that drops AI infantry or a vehicle, then leaves and despawns.
	Author: Alex2k. Contributor: Drgn V4karian.

	Server only, after LMF preInit. Scheduled execution required for all calls (Arma 3 2.22+).

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0]; object direction is used in autonomous mode)
		1: Drop zone <STRING, OBJECT, LOCATION or ARRAY> (default: [0, 0, 0] = autonomous; otherwise marker, trigger or location)
		2: Flying height in meters <NUMBER> (default: 200)
		3: Vehicle classname or CAR/CARARMED/TRUCK/APC/TANK category to drop <STRING> (default: "" for infantry)
		4: Total tickets <NUMBER> (optional; omitted = one-shot, supplied = managed, including 1)
		5: Respawn delay in seconds <NUMBER> (default: 300; managed replacements only)

	Example:
		private _handle = [spawn_1, "mrk_dropZone", 200, "TANK"] spawn lmf_ai_fnc_spawnParadropQrf;

	Returns (one-shot): Prepared infantry GROUP or vehicle OBJECT; delivery continues asynchronously.
	Returns a null delivery on preparation failure; objNull on unscheduled/non-server calls.
	The one-shot promise waits for InitPost/gear attempts and initial setup, not landing.
	Vehicle occupants are staged before flight and seated at release.
	Managed scripts finish after the final preparation or cancellation, without a combined result.
*/

private _spawner = [] call lmf_ai_fnc_isSpawner;
if (!_spawner || {!canSuspend}) exitWith {objNull};

private _managed = count _this > 4;
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

	private _veh = objNull;
	private _simulation = true;
	isNil {
		_veh = createVehicle [selectRandom _paraVehicle, _spawnPos, [], 0, _spawnType];
		_simulation = simulationEnabled _veh;
		_veh enableSimulationGlobal false;
	};
	if (isNull _veh) exitWith {if (_isVehicleDrop) then {objNull} else {grpNull}};
	_veh setDir (
		if (_isAutonomous) then {_dir} else {_spawnPos getDir _dzPos}
	);

	if (_isAirSpawn) then {
		_veh setPos [_spawnPos#0, _spawnPos#1, _flyInHeight];
		_veh setVelocityModelSpace [0, 55, 0];
	};

	// Crew
	private _grp = [_spawnPos, lmf_enemySide, _heliCrew, _veh, "ANY"] call lmf_ai_fnc_spawnGroup;
	_grp deleteGroupWhenEmpty true;
	_grp addVehicle _veh;
	_grp setGroupIdGlobal [format ["Paradrop Aircraft (%1)", groupId _grp]];

	// Payload preparation
	private _grp2 = grpNull;
	private _droppedObj = objNull;
	private _cargoSize = 0;
	private _payloadReady = false;
	private _vicType = "";
	private _vehicleSetup = [];
	private _crewGroup = grpNull;
	private _infantryGroup = grpNull;

	if (!_isVehicleDrop) then {
		_grp2 = [_spawnPos, lmf_enemySide, (selectRandom _mgTeam) + (selectRandom _atTeam), _veh, "CARGO"] call lmf_ai_fnc_spawnGroup;
		_grp2 deleteGroupWhenEmpty true;
		{
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
		private _categories = ["CAR", "CARARMED", "TRUCK", "APC", "TANK"];
		_vicType = toUpper _dropVehicle;
		if (_vicType in _categories) then {
			_class = selectRandom (_vehicles get _vicType);
		} else {
			_vicType = (lmf_ai_config get "VEHICLE_BY_CLASS") getOrDefault [toLower _class, ""];
			if !(_vicType in _categories) then {_vicType = ""};
		};
		// Match Vehicle QRF categories; unregistered classnames receive seat-based crew only.
		_vehicleSetup = switch (_vicType) do {
			case "CAR": {["Car", "", (selectRandom _team) + (selectRandom _sentry)]};
			case "CARARMED": {["Armed Car", _rifleman, []]};
			case "TRUCK": {["Truck", "", (selectRandom _squad) + (selectRandom (selectRandom [_team, _mgTeam, _atTeam]))]};
			case "APC": {["APC", _crew, (selectRandom _mgTeam) + (selectRandom _atTeam)]};
			case "TANK": {["Tank", _crew, []]};
			default {["Vehicle", _crew, []]};
		};

		_droppedObj = createVehicle [_class, [0, 0, 1000], [], 0, "NONE"];
		_droppedObj allowDamage false;
		[_veh, 1000] call ace_cargo_fnc_setSpace;
		_cargoSize = [_droppedObj] call ace_cargo_fnc_getSizeItem;
		[_droppedObj, 1] call ace_cargo_fnc_setSize;
		_payloadReady = alive _droppedObj && {[_droppedObj, _veh, true] call ace_cargo_fnc_loadItem};
		if (_payloadReady) then {
			// Prepare hidden, inactive occupants before flight; queue pressure must not outlast descent.
			_vehicleSetup params ["_name", "_crewClass", "_infantryType"];
			if (_vicType in ["CAR", "TRUCK"]) then {
				_crewGroup = [_spawnPos, lmf_enemySide, _infantryType, _droppedObj, "ANY", true] call lmf_ai_fnc_spawnGroup;
				_infantryGroup = _crewGroup;
			} else {
				_crewGroup = createGroup lmf_enemySide;
				[_droppedObj, _crewGroup, _crewClass, true] call lmf_ai_fnc_spawnCrew;
				if (_infantryType isNotEqualTo []) then {
					_infantryGroup = [_spawnPos, lmf_enemySide, _infantryType, _droppedObj, "ANY", true] call lmf_ai_fnc_spawnGroup;
				};
			};
			_payloadReady = units _crewGroup findIf {alive _x} != -1
				&& {_infantryType isEqualTo [] || {units _infantryGroup findIf {alive _x} != -1}};
		};
	};

	// Do not leave a prepared payload or transport behind after a failed setup.
	if (!_payloadReady || {!alive driver _veh}) exitWith {
		{
			private _parent = objectParent _x;
			if (isNull _parent) then {deleteVehicle _x} else {_parent deleteVehicleCrew _x};
		} forEach (units _grp + units _grp2 + units _crewGroup + units _infantryGroup);
		{deleteGroup _x} forEach ([_grp, _grp2, _crewGroup, _infantryGroup] arrayIntersect [_grp, _grp2, _crewGroup, _infantryGroup]);
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

	// Release the aircraft only after its crew and payload preparation are complete.
	{_x setVariable ["lmf_ai_spawning", nil]} forEach ([_grp, _grp2] select {!isNull _x});
	_veh enableSimulationGlobal _simulation;
	if (_isAirSpawn) then {_veh setVelocityModelSpace [0, 55, 0]};

	// Pass flight state explicitly to the scheduled continuation.
	[_veh, _grp, _grp2, _droppedObj, _cargoSize, _isAutonomous, _dropZone, _isVehicleDrop, _spawnPos, _vicType, _vehicleSetup, _crewGroup, _infantryGroup] spawn {
		params ["_veh", "_grp", "_grp2", "_droppedObj", "_cargoSize", "_isAutonomous", "_dropZone", "_isVehicleDrop", "_spawnPos", "_vicType", "_vehicleSetup", "_crewGroup", "_infantryGroup"];

		// Wait for the drop.
		waitUntil {
			sleep 3;
			private _triggered = if (_isAutonomous) then {
				(allPlayers - entities "HeadlessClient_F") findIf {_x distance2D _veh < 600 + (random 600)} != -1
			} else {
				_veh inArea _dropZone;
			};
			_triggered || {!alive _veh} || {{alive _x} count units _grp < 1}
			|| {_isVehicleDrop && {!alive _droppedObj}}
		};

		// Payload deployment
		if (alive _veh && {{alive _x} count units _grp > 0}) then {
			[_grp] call CBA_fnc_clearWaypoints;
			_veh doMove (_veh getRelPos [5000, 0]);

			if (_isVehicleDrop) then {
				// Vehicle deployment
				if (!local _veh || {!alive _droppedObj} || {!local _droppedObj}) exitWith {};
				_vehicleSetup params ["_name", "_crewClass", "_infantryType"];
				private _dropped = false;
				// Release and seat prepared occupants together; no creation or queue waits during descent.
				isNil {
					// Recheck after scheduled flight work, before release and seating become atomic.
					if (!alive _veh || {!local _veh} || {!alive _droppedObj} || {!local _droppedObj}
						|| {units _grp findIf {alive _x} == -1}) exitWith {};
					private _collisionEnabled = (getPhysicsCollisionFlag _veh) # 0;
					_veh setPhysicsCollisionFlag false;
					[{
						params ["_aircraft", "_collisionEnabled"];
						if (!isNull _aircraft) then {_aircraft setPhysicsCollisionFlag _collisionEnabled};
					}, [_veh, _collisionEnabled], 3] call CBA_fnc_waitAndExecute;
					_veh allowDamage false;
					_dropped = [_droppedObj, "ACE_CARGO", [_veh, _cargoSize, 1.5, 0.5, false]] call lmf_paradrop_fnc_dropObject;
					_veh allowDamage true;
					if (!_dropped) exitWith {
						_veh setPhysicsCollisionFlag _collisionEnabled;
						deleteVehicle _droppedObj;
					};
					_droppedObj setUnloadInCombat [false, false];
					private _seatUnit = {
						params ["_unit"];
						if !([_unit] call lmf_ai_fnc_seatSpawnedUnit) exitWith {
							private _parent = objectParent _unit;
							if (isNull _parent) then {deleteVehicle _unit} else {_parent deleteVehicleCrew _unit};
						};
						_unit enableSimulationGlobal true;
						_unit hideObjectGlobal false;
						_unit allowDamage true;
					};
					{[_x] call _seatUnit} forEach units _crewGroup;
					if !(_vicType in ["CAR", "TRUCK"]) then {[_droppedObj, "LIEUTENANT"] call BIS_fnc_setRank};
					if (_vicType in ["APC", "TANK"]) then {
						{_droppedObj deleteVehicleCrew _x} forEach (units _crewGroup select {!(_x in [driver _droppedObj, gunner _droppedObj, commander _droppedObj])});
					};
					private _commander = commander _droppedObj;
					if (_vicType in ["APC", "TANK", ""] && {local _crewGroup} && {!isNull _commander} && {alive _commander} && {group _commander == _crewGroup}) then {
						_crewGroup selectLeader _commander;
					};
					if (_infantryGroup != _crewGroup && {!isNull _infantryGroup}) then {
						{[_x] call _seatUnit} forEach units _infantryGroup;
						_infantryGroup setGroupIdGlobal [format ["Infantry QRF (%1)", groupId _infantryGroup]];
					};
					{deleteVehicle _x} forEach (units _infantryGroup select {isNull objectParent _x});
					_crewGroup setGroupIdGlobal [format ["%1: %2 (%3)", _name, getText (configFile >> "CfgVehicles" >> typeOf _droppedObj >> "displayName"), groupId _crewGroup]];
					{
						_x deleteGroupWhenEmpty true;
						_x setBehaviourStrong "CARELESS";
						_x setCombatMode "BLUE";
						{_x disableAI "AUTOCOMBAT"; _x disableAI "FSM"} forEach units _x;
					} forEach (([_crewGroup, _infantryGroup] arrayIntersect [_crewGroup, _infantryGroup]) select {!isNull _x});
					if (!isNull _infantryGroup) then {
						_infantryGroup enableIRLasers false;
						_infantryGroup enableGunLights "ForceOff";
					};
				};
				if (!_dropped) exitWith {deleteVehicle _droppedObj};

				[_droppedObj, _crewGroup, _infantryGroup] spawn {
					params ["_v", "_g", "_infantry"];
					waitUntil {
						sleep 0.5;
						!alive _v || {!local _v} || {isNull attachedTo _v && {isTouchingGround _v || {getPos _v # 2 < 0.5}}}
					};
					sleep 1;
					if (!isNull _v && {!local _v}) exitWith {};
					// Restore survivors' AI even if the vehicle was destroyed during insertion.
					{
						if (local _x) then {
							_x setBehaviourStrong "AWARE";
							_x setCombatMode (if (_x == _infantry) then {"RED"} else {"YELLOW"});
							{_x enableAI "AUTOCOMBAT"; _x enableAI "FSM"} forEach (units _x select {local _x});
							(_x addWaypoint [getPosASL leader _x, -1]) setWaypointType "GUARD";
						};
					} forEach (([_g, _infantry] arrayIntersect [_g, _infantry]) select {!isNull _x});
					{_x setVariable ["lmf_ai_spawning", nil]} forEach ([_g, _infantry] select {!isNull _x});
					if (isNull _infantry || {!local _infantry}) exitWith {};
					_infantry setVariable ["lmf_ai_transportVehicle", _v];
					_infantry setFormation "DIAMOND";
					_infantry setSpeedMode "FULL";
					_infantry setCombatMode "RED";
					_infantry addEventHandler ["EnemyDetected", {
						params ["_group", "_newTarget"];
						if (!local _group || {isNull _newTarget} || {!isNull objectParent leader _group}
							|| {leader _group distance _newTarget >= 75}) exitWith {};
						if (random 1 < 0.3) then {_group enableGunLights "Auto"};
						{
							if (alive _x && {local _x} && {_x distance _newTarget < 75} && {random 1 < 0.25}) then {_x enableIRLasers true};
						} forEach units _group;
					}];
					_infantry addEventHandler ["UnitKilled", {
						params ["_group"];
						if (!local _group) exitWith {};
						private _aliveUnits = units _group select {alive _x};
						if (count _aliveUnits != 1 || {!isNull objectParent (_aliveUnits # 0)}) exitWith {};
						[_aliveUnits # 0] spawn lmf_ai_fnc_reassignSurvivor;
						_group removeEventHandler [_thisEvent, _thisEventHandler];
					}];
					_infantry addEventHandler ["EnemyDetected", {
						params ["_group", "_newTarget"];
						if (!local _group || {isNull _newTarget}) exitWith {};
						private _leader = leader _group;
						if (!isTouchingGround (vehicle _newTarget) || {(_leader distance2D _newTarget) > 500}) exitWith {};
						_group removeEventHandler ["EnemyDetected", _thisEventHandler];
						_group leaveVehicle (_group getVariable ["lmf_ai_transportVehicle", objNull]);
						doGetOut (units _group);
						_group setVariable ["lmf_ai_joinableGroup", true];
						_group setGroupIdGlobal [format ["Infantry QRF: (T-%1-%2-%3)", round (random 999), round (random 999), round (random 99)]];
						{
							if (waypointType _x == "GUARD") then {
								_x setWaypointPosition [getPosASL _newTarget, -1];
							};
						} forEach (waypoints _group);
					}];
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

			// A failed release leaves hidden occupants; successful seating removes spawnSeat.
			{
				if (!isNil {_x getVariable "lmf_ai_spawnSeat"}) then {
					private _parent = objectParent _x;
					if (isNull _parent) then {deleteVehicle _x} else {_parent deleteVehicleCrew _x};
				};
			} forEach (units _crewGroup + units _infantryGroup);
			{if (units _x isEqualTo []) then {deleteGroup _x}} forEach ([_crewGroup, _infantryGroup] arrayIntersect [_crewGroup, _infantryGroup]);
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
			if (_isVehicleDrop) then {
				{
					private _parent = objectParent _x;
					if (isNull _parent) then {deleteVehicle _x} else {_parent deleteVehicleCrew _x};
				} forEach (units _crewGroup + units _infantryGroup);
				{deleteGroup _x} forEach ([_crewGroup, _infantryGroup] arrayIntersect [_crewGroup, _infantryGroup]);
				deleteVehicle _droppedObj;
			} else {
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
