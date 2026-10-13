/*
	Spawn vehicle QRF
	Spawns a vehicle QRF with additional infantry where configured.
	Author: nkenny. Contributors: Drgn V4karian, Alex2k.

	Server only, after LMF preInit. One-shot call does not suspend; use spawn for managed waves.

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Vehicle type <STRING> (default: "TRUCK"; "CAR", "CARARMED", "TRUCK", "APC", "TANK", "HELITRANSPORT", "HELIATTACK" or "DRONE")
		2: Total tickets <NUMBER> (optional; omitted = one-shot, supplied = managed, including 1)
		3: Respawn delay in seconds <NUMBER> (default: 300)

	Example:
		private _delivery = [spawn_1, "TANK"] call lmf_ai_fnc_spawnVehicleQrf;

	Returns (one-shot): Infantry GROUP for CAR/TRUCK/APC/HELITRANSPORT;
	vehicle OBJECT for CARARMED/TANK/HELIATTACK/DRONE. objNull for no spawn/non-spawner.
*/

private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {objNull};

private _managed = count _this > 2;
if (_managed && {!canSuspend}) exitWith {};
if (_managed) then {waitUntil {sleep 1; CBA_missionTime > 0};};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_vicType", "TRUCK"], ["_tickets", 1], ["_respawnTime", 300]];
private _dir = random 360;
if !(_spawnPos isEqualType []) then {_dir = getDir _spawnPos;};
_spawnPos = _spawnPos call CBA_fnc_getPos;
_vicType = toUpper _vicType;
if (_vicType == "DRONE" && {_drones isEqualTo []}) exitWith {objNull};

private _fncDismountEh = {
	params ["_group", "_newTarget"];
	if (!local _group || {isNull _newTarget}) exitWith {};
	private _leader = leader _group;
	if (!isTouchingGround (vehicle _newTarget) || {(_leader distance2D _newTarget) > 500}) exitWith {};
	_group removeEventHandler ["EnemyDetected", _thisEventHandler];
	_group leaveVehicle (vehicle _leader);
	doGetOut (units _group);
	_group setVariable ["lmf_ai_joinableGroup", true];
	_group setGroupIdGlobal [format ["Infantry QRF: (T-%1-%2-%3)", round (random 999), round (random 999), round (random 99)]];
	{
		if (waypointType _x == "GUARD") then {
			_x setWaypointPosition [getPosASL _newTarget, -1];
		};
	} forEach (waypoints _group);
};

private _fncHeliTransportEh = {
	params ["_group", "_newTarget"];
	if (!local _group || {_group getVariable ["lmf_heliTransport_abandoned", false]}) exitWith {};
	if (!isTouchingGround (vehicle _newTarget) || {surfaceIsWater (getPos _newTarget)}) exitWith {};

	private _veh = objectParent (leader _group);
	if (!alive _veh || {!local _veh}) exitWith {};
	(_group getVariable ["lmf_heliTransport_cargo", [grpNull, []]]) params ["_grp2", "_troops"];
	if (isNull _grp2 || {!local _grp2}) exitWith {};

	_group removeEventHandler ["EnemyDetected", _thisEventHandler];
	_group setVariable ["lmf_heliTransport_active", true];

	[_group, _veh, _grp2, _troops, getPosATL _newTarget] spawn {
		params ["_group", "_veh", "_grp2", "_troops", "_targetPos"];
		private _landingPos = [];

		// Rank openness first; allow moderate slopes with extra obstacle clearance.
		while {_landingPos isEqualTo [] && {alive _veh} && {local _veh} && {local _group}
			&& {!(_group getVariable ["lmf_heliTransport_abandoned", false])}} do {
			// Rank one coarse 500 m search; refine by vehicle type before the final safety check.
			private _places = selectBestPlaces [_targetPos, 500, "(1 - sea) * (1 - forest) * (1 - trees) * (1 - houses)", 50, 400];
			{
				if (!local _group || {_group getVariable ["lmf_heliTransport_abandoned", false]}) exitWith {};
				private _candidate = (_x # 0) findEmptyPosition [0, 20, typeOf _veh];
				if !(_candidate isEqualTo []) then {
					_candidate set [2, 0];
					if (_candidate distance2D _targetPos >= 150 && {_candidate distance2D _targetPos <= 500}
						&& {!((_candidate isFlatEmpty [12, -1, 0.25, 8, 0, false]) isEqualTo [])}) then {
						_landingPos = _candidate;
					};
				};
				if !(_landingPos isEqualTo []) exitWith {};
				sleep 0.01;
			} forEach _places;
			if (_landingPos isEqualTo []) then {sleep 5;};
		};

		if (!alive _veh || {!local _veh} || {!local _group}
			|| {_group getVariable ["lmf_heliTransport_abandoned", false]}) exitWith {
			// The crew monitor keeps tasking blocked until evacuation is complete.
			if !(_group getVariable ["lmf_heliTransport_abandoned", false]) then {
				_group setVariable ["lmf_heliTransport_active", false];
			};
		};
		private _pad = objNull;
		private _retreat = [];
		private _retreatPos = _veh getPos [25000, (_veh getDir _targetPos) + 180];
		_retreatPos set [2, 0];
		// Build and activate the complete route without scheduler interruption.
		isNil {
			if (!local _group || {_group getVariable ["lmf_heliTransport_abandoned", false]}) exitWith {};
			{
				{deleteWaypoint _x} forEachReversed waypoints _x;
			} forEach ([_group, _grp2] select {!isNull _x});

			// Let the engine coordinate landing, passenger dismount and departure.
			_pad = createVehicle ["Land_HelipadEmpty_F", _landingPos, [], 0, "CAN_COLLIDE"];
			// Synchronize pilot unloading with the separate cargo group getting out.
			private _unload = _group addWaypoint [getPosASL _pad, -1];
			_unload setWaypointType "TR UNLOAD";
			_unload setWaypointBehaviour "CARELESS";
			_unload setWaypointForceBehaviour true;
			_unload waypointAttachObject _pad;
			if (!isNull _grp2) then {
				private _getOut = _grp2 addWaypoint [getPosASL _pad, -1];
				_getOut setWaypointType "GETOUT";
				_unload synchronizeWaypoint [_getOut];
				(_grp2 addWaypoint [ATLToASL _targetPos, -1]) setWaypointType "GUARD";
				_grp2 setCurrentWaypoint _getOut;
			};

			_retreat = _group addWaypoint [_retreatPos, 0];
			_retreat setWaypointType "MOVE";
			_retreat setWaypointBehaviour "CARELESS";
			_retreat setWaypointCombatMode "BLUE";
			_group setCurrentWaypoint _unload;
		};

		// Never delete a transport with living passengers still aboard.
		waitUntil {
			sleep 5;
			// Release a completed insertion once; player distance only controls cleanup.
			isNil {
				if (!alive _veh || {!local _veh} || {!local _group} || {!canMove _veh}
					|| {!alive driver _veh} || {!isTouchingGround _veh}
					|| {_group getVariable ["lmf_heliTransport_abandoned", false]}
					|| {!(_retreat in waypoints _group)}) exitWith {};
				private _current = [_group, currentWaypoint _group];
				if (waypointType _current != "TR UNLOAD") exitWith {};
				if (_troops findIf {alive _x && {objectParent _x == _veh}} != -1
					|| {(fullCrew _veh) findIf {
						alive (_x # 0) && {!((_x # 0) in units _group) || {_x # 1 == "cargo"} || {_x # 4}}
					} != -1}) exitWith {};
				_current synchronizeWaypoint [];
				_group setCurrentWaypoint _retreat;
				_retreat = [];
			};
			!alive _veh || {!local _veh} || {!local _group}
			|| {_group getVariable ["lmf_heliTransport_abandoned", false]}
			|| {
				_troops findIf {alive _x && {objectParent _x == _veh}} == -1
				&& {(crew _veh) findIf {alive _x && {!(_x in units _group)}} == -1}
				&& {(allPlayers - entities "HeadlessClient_F") findIf {_x distance2D _veh < 5000} == -1}
			}
		};
		deleteVehicle _pad;
		if (_group getVariable ["lmf_heliTransport_abandoned", false]) exitWith {};
		_group setVariable ["lmf_heliTransport_active", false];
		if (!alive _veh || {!local _veh} || {!local _group}) exitWith {};
		{_veh deleteVehicleCrew _x} forEach crew _veh;
		deleteVehicle _veh;
	};
};

private _spawnOnce = {
	private _setup = switch (_vicType) do {
		case "CAR": {["Car", "", (selectRandom _team) + (selectRandom _sentry)]};
		case "CARARMED": {["Armed Car", _rifleman, []]};
		case "TRUCK": {["Truck", "", (selectRandom _squad) + (selectRandom (selectRandom [_team, _mgTeam, _atTeam]))]};
		case "APC": {["APC", _crew, (selectRandom _mgTeam) + (selectRandom _atTeam)]};
		case "TANK": {["Tank", _crew, []]};
		case "HELITRANSPORT": {["Transport Heli", _pilot, selectRandom _squad]};
		case "HELIATTACK": {["Attack Heli", _pilot, []]};
		case "DRONE": {["Drone", "", []]};
		default {[]};
	};
	if (_setup isEqualTo []) exitWith {objNull};
	_setup params ["_name", "_crewClass", "_infantryType"];
	private _class = selectRandom (_vehicles get _vicType);
	private _isAir = _class isKindOf "Air";
	private _veh = createVehicle [_class, _spawnPos, [], 0, if (_isAir && {surfaceIsWater _spawnPos}) then {"FLY"} else {"NONE"}];
	_veh setDir _dir;
	if (_vicType in ["CARARMED", "TANK", "HELITRANSPORT", "HELIATTACK"]) then {_veh setUnloadInCombat [false, false]};

	private _grp = grpNull;
	private _grp2 = grpNull;
	if (_vicType in ["CAR", "TRUCK"]) then {
		_grp = [_spawnPos, lmf_enemySide, _infantryType] call BIS_fnc_spawnGroup;
		{_x moveInAny _veh} forEach units _grp;
		{deleteVehicle _x} forEach (units _grp select {isNull objectParent _x});
		_grp2 = _grp;
	} else {
		if (_vicType == "DRONE") then {
			createVehicleCrew _veh;
			_grp = group (crew _veh # 0);
		} else {
			_grp = createGroup lmf_enemySide;
			[_veh, _grp, false, "", _crewClass] call BIS_fnc_spawnCrew;
		};
		if (_vicType in ["APC", "TANK"]) then {
			{_veh deleteVehicleCrew _x} forEach (units _grp select {!(_x in [driver _veh, gunner _veh, commander _veh])});
			// Use the TANK commander as group leader so the crew follows normal waypoint orders.
			if (_vicType == "TANK" && {local _grp}) then {
				private _commander = commander _veh;
				if (!isNull _commander && {alive _commander} && {group _commander == _grp}) then {
					_grp selectLeader _commander;
				};
			};
		};
		if (_infantryType isNotEqualTo []) then {
			_grp2 = [_spawnPos, lmf_enemySide, _infantryType] call BIS_fnc_spawnGroup;
			_grp2 setGroupIdGlobal [format ["Infantry QRF (%1)", groupId _grp2]];
			if (_vicType == "HELITRANSPORT") then {
				{_x assignAsCargo _veh; _x moveInCargo _veh} forEach units _grp2;
			} else {
				{_x moveInAny _veh} forEach units _grp2;
			};
			{deleteVehicle _x} forEach (units _grp2 select {isNull objectParent _x});
		};
	};
	_grp setGroupIdGlobal [format ["%1: %2 (%3)", _name, getText (configFile >> "CfgVehicles" >> _class >> "displayName"), groupId _grp]];
	{
		_x deleteGroupWhenEmpty true;
		if (_vicType != "HELITRANSPORT" || {_x == _grp}) then {
			(_x addWaypoint [getPosASL _veh, -1]) setWaypointType "GUARD";
		};
	} forEach (([_grp, _grp2] arrayIntersect [_grp, _grp2]) select {!isNull _x});

	// Match Infantry QRF, but leave mounted survivors under normal vehicle AI.
	if (!isNull _grp2) then {
		_grp2 setFormation "DIAMOND";
		_grp2 setSpeedMode "FULL";
		_grp2 setCombatMode "RED";
		_grp2 enableIRLasers false;
		_grp2 enableGunLights "ForceOff";
		_grp2 addEventHandler ["EnemyDetected", {
			params ["_group", "_newTarget"];
			if (!local _group || {isNull _newTarget} || {!isNull objectParent leader _group}
				|| {leader _group distance _newTarget >= 75}) exitWith {};
			if (random 1 < 0.3) then {_group enableGunLights "Auto"};
			{
				if (alive _x && {local _x} && {_x distance _newTarget < 75} && {random 1 < 0.25}) then {_x enableIRLasers true};
			} forEach units _group;
		}];
		_grp2 addEventHandler ["UnitKilled", {
			params ["_group"];
			if (!local _group) exitWith {};
			private _aliveUnits = units _group select {alive _x};
			if (count _aliveUnits != 1 || {!isNull objectParent (_aliveUnits # 0)}) exitWith {};
			[_aliveUnits # 0] spawn lmf_ai_fnc_reassignSurvivor;
			_group removeEventHandler [_thisEvent, _thisEventHandler];
		}];
		if (_vicType != "HELITRANSPORT") then {_grp2 addEventHandler ["EnemyDetected", _fncDismountEh]};
	};

	if (_vicType == "HELITRANSPORT") then {
		_grp addVehicle _veh;
		_grp setVariable ["lmf_heliTransport_cargo", [_grp2, units _grp2]];
		_grp2 setVariable ["lmf_heliTransport_vehicle", _veh];
		_grp2 setVariable ["lmf_ai_joinableGroup", true];
		private _transportEh = _grp addEventHandler ["EnemyDetected", _fncHeliTransportEh];
		// Evacuate grounded disabled transports.
		[_grp, _veh, _transportEh, _grp2] spawn {
			params ["_group", "_veh", "_transportEh", "_cargoGroup"];
			private _evacuated = false;
			waitUntil {
				sleep 10;
				private _done = false;
				isNil {
					if (isNull _veh || {!local _veh} || {!isNull _group && {!local _group}}
						|| {!isNull _cargoGroup && {!local _cargoGroup}}) exitWith {_done = true};
					private _crew = units _group select {alive _x};
					private _onFoot = _crew findIf {!isNull objectParent _x} == -1;
					private _passengers = units _cargoGroup select {alive _x && {objectParent _x == _veh}};
					if (_crew isEqualTo [] && {_passengers isEqualTo []}) exitWith {_done = true};
					if (!_evacuated) then {
						if (!(isTouchingGround _veh && {vectorMagnitude velocity _veh < 1}
							&& {_onFoot || {!canMove _veh} || {!alive driver _veh}})) exitWith {};
						_evacuated = true;
						_group setVariable ["lmf_heliTransport_abandoned", true];
						_group setVariable ["lmf_heliTransport_active", true];
						_group removeEventHandler ["EnemyDetected", _transportEh];
						// Do not retask infantry that has already left the transport.
						private _groups = [_group];
						if (_passengers isNotEqualTo []) then {_groups pushBack _cargoGroup};
						{
							if (local _x) then {
								{_x synchronizeWaypoint []; deleteWaypoint _x} forEachReversed waypoints _x;
								_x leaveVehicle _veh;
								private _survivors = units _x select {alive _x && {local _x}};
								{unassignVehicle _x} forEach _survivors;
								doGetOut _survivors;
								_x setBehaviourStrong "AWARE";
								_x setCombatMode "RED";
								private _guard = _x addWaypoint [getPosASL _veh, -1];
								_guard setWaypointType "GUARD";
								_x setCurrentWaypoint _guard;
							};
						} forEach _groups;
					};
					if (_evacuated && {_onFoot} && {_passengers isEqualTo []}) then {
						_group setVariable ["lmf_heliTransport_active", false];
						_done = true;
					};
				};
				_done
			};
		};
	};

	if (_vicType == "DRONE") then {
		if (_isAir) then {_veh flyInHeight [selectRandom [100, 115, 125], true];};

		private _iedPylons = configProperties [configFile >> "CfgVehicles" >> typeOf _veh >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x && {'LXWS_IED_DRONE_PYLON' in getArray (_x >> 'hardpoints')}", true];
		if (_isAir && {!(_iedPylons isEqualTo [])}) then {
			_grp addEventHandler ["EnemyDetected", {
				params ["_group", "_newTarget"];
				private _veh = vehicle (leader _group);
				if (!local _group || {!local _veh} || {!alive _veh} || {!alive _newTarget} || {!isTouchingGround (vehicle _newTarget)}) exitWith {};
				_group removeEventHandler ["EnemyDetected", _thisEventHandler];
				[_veh, _newTarget] spawn lmf_ai_fnc_taskUavAttack;
			}];
		} else {
			if (_isAir && {"FakeDetonator_RF" in weapons _veh} && {!isNil "lxRF_fnc_RC40_attack"}) then {
				_grp addEventHandler ["EnemyDetected", {
					params ["_group", "_newTarget"];
					private _veh = vehicle (leader _group);
					if (!local _group || {!local _veh} || {!alive _veh} || {!alive _newTarget} || {!isTouchingGround (vehicle _newTarget)}) exitWith {};
					// Reserve once before scheduling the takeoff wait.
					_group removeEventHandler ["EnemyDetected", _thisEventHandler];
					[_veh, _group, _newTarget] spawn {
						params ["_veh", "_group", "_target"];
						waitUntil {
							sleep 1;
							!alive _veh || {!local _veh} || {!local _group} || {!alive _target}
							|| {isEngineOn _veh && {!isTouchingGround _veh}};
						};
						if (!alive _veh || {!local _veh} || {!local _group} || {!isEngineOn _veh} || {isTouchingGround _veh}
							|| {!alive _target} || {!isTouchingGround (vehicle _target)}) exitWith {};
						[_veh, _target] call lxRF_fnc_RC40_attack;
					};
				}];
			};
		};
	};

	if (_vicType in ["CAR", "TRUCK", "APC", "HELITRANSPORT"]) then {_grp2} else {_veh}
};

if (_managed) exitWith {
	[_spawnOnce, _tickets, _respawnTime, _spawnPos, 1000, 5] call lmf_ai_fnc_runWaves;
};

call _spawnOnce
