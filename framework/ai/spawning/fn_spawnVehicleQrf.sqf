/*
	Spawn vehicle QRF
	Spawns a vehicle QRF with additional infantry where configured.
	Author: nkenny. Contributors: Drgn V4karian, Alex2k.
	Player proximity is checked before every spawn, including when only one ticket is configured.

	Arguments:
		0: Spawn position <OBJECT or ARRAY> (default: [0, 0, 0])
		1: Vehicle type <STRING> (default: "TRUCK"; "CAR", "CARARMED", "TRUCK", "APC", "TANK", "HELITRANSPORT" or "HELIATTACK")
		2: Spawn tickets <NUMBER> (default: 1)
		3: Respawn delay in seconds <NUMBER> (default: 300)

	Example:
		[spawn_1, "TRUCK", 1, 300] spawn lmf_ai_fnc_spawnVehicleQrf;
*/

waitUntil {sleep 1; CBA_missionTime > 0};
private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {};

#include "spawnDefinitions.sqf"

params [["_spawnPos", [0, 0, 0]], ["_vicType", "TRUCK"], ["_tickets", 1], ["_respawnTime", 300]];
private _range = 1000;
private _dir = random 360;
if !(_spawnPos isEqualType []) then {_dir = getDir _spawnPos;};
_spawnPos = _spawnPos call CBA_fnc_getPos;
_vicType = toUpper _vicType;

// Local functions for event handlers
private _fncUnitKilledEh = {
	params ["_group"];
	private _aliveUnits = (units _group) select {alive _x};
	if (count _aliveUnits != 1) exitWith {};
	[_aliveUnits # 0] spawn lmf_ai_fnc_reassignSurvivor;
	_group removeEventHandler ["UnitKilled", _thisEventHandler];
};

private _fncDismountEh = {
	params ["_group", "_newTarget"];
	private _leader = leader _group;
	if (!isTouchingGround (vehicle _newTarget) || {(_leader distance2D _newTarget) > 500}) exitWith {};
	_group removeEventHandler ["EnemyDetected", _thisEventHandler];
	_group leaveVehicle (vehicle _leader);
	doGetOut (units _group);
	_group setVariable ["lmf_ai_joinableGroup", true];
	_group enableIRLasers true;
	_group enableGunLights "Auto";
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
		diag_log format ["[LMF HELITRANSPORT] %1: searching for LZ within 500 m of %2", _veh, _targetPos];

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
		private _retreatPos = _veh getPos [25000, (_veh getDir _targetPos) + 180];
		_retreatPos set [2, 0];
		// Build and activate the complete route without scheduler interruption.
		isNil {
			if (!local _group || {_group getVariable ["lmf_heliTransport_abandoned", false]}) exitWith {};
			{
				{deleteWaypoint _x} forEachReversed waypoints _x;
			} forEach ([_group, _grp2] select {!isNull _x});
			_group addVehicle _veh;

			// Let the engine coordinate landing, passenger dismount and departure.
			_pad = createVehicle ["Land_HelipadEmpty_F", _landingPos, [], 0, "CAN_COLLIDE"];
			// Use the exact pad position without an object-attached waypoint.
			private _unload = _group addWaypoint [getPosASL _pad, -1];
			_unload setWaypointType "TR UNLOAD";
			/* private _getOut = _grp2 addWaypoint [_pad, 0];
			_getOut setWaypointType "GETOUT";
			_getOut waypointAttachObject _pad;
			_unload synchronizeWaypoint [_getOut]; */
			if (!isNull _grp2) then {
				(_grp2 addWaypoint [ATLToASL _targetPos, -1]) setWaypointType "GUARD";
			};
			// _grp2 setCurrentWaypoint _getOut;
			diag_log format ["[LMF HELITRANSPORT] %1: TR UNLOAD assigned at %2", _veh, _landingPos];

			private _retreat = _group addWaypoint [_retreatPos, 0];
			_retreat setWaypointType "MOVE";
			_retreat setWaypointBehaviour "CARELESS";
			_retreat setWaypointCombatMode "BLUE";
			_group setCurrentWaypoint _unload;
		};

		// Never delete a transport with living registered passengers still aboard.
		waitUntil {
			sleep 5;
			!alive _veh || {!local _veh}
			|| {
				_troops findIf {alive _x && {objectParent _x == _veh}} == -1
				&& {(allPlayers - entities "HeadlessClient_F") findIf {_x distance2D _veh < 5000} == -1}
			}
		};
		deleteVehicle _pad;
		_group setVariable ["lmf_heliTransport_active", false];
		if (!alive _veh || {!local _veh}) exitWith {};
		{_veh deleteVehicleCrew _x} forEach crew _veh;
		deleteVehicle _veh;
	};
};

// Prepare and spawn
private _initTickets = _tickets;

while {_initTickets > 0} do {

	if ([_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState isEqualTo "airClose") then {
		waitUntil {sleep 5; ([_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState) in ["airDistance", "groundClose"]};
	};

	if ([_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState isEqualTo "groundClose") exitWith {};

	private _veh = objNull;
	private _grp = grpNull;
	private _grp2 = grpNull;
	private _wp = [];
	private _transportCrew = [];

	switch (_vicType) do {
		case "CAR": {
			_veh = createVehicle [selectRandom _car, _spawnPos, [], 0, "NONE"];
			_veh setDir _dir;
			private _vehType = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

			private _type = (selectRandom _team) + (selectRandom _sentry);
			_grp = [_spawnPos, lmf_enemySide, _type] call BIS_fnc_spawnGroup;
			_grp deleteGroupWhenEmpty true;
			_grp setGroupIdGlobal [format ["Car: %1 (%2)", _vehType, groupId _grp]];
			_grp setSpeedMode "FULL";
			_grp setCombatMode "RED";

			{_x moveInAny _veh} forEach units _grp;
			{deleteVehicle _x} forEach ((units _grp) select {isNull objectParent _x});

			_wp = _grp addWaypoint [ATLToASL (getPos _veh), -1];
			_wp setWaypointType "GUARD";

			_grp addEventHandler ["EnemyDetected", _fncDismountEh];
			_grp addEventHandler ["UnitKilled", _fncUnitKilledEh];
		};

		case "CARARMED": {
			_veh = createVehicle [selectRandom _carArmed, _spawnPos, [], 0, "NONE"];
			_veh setDir _dir;
			_veh setUnloadInCombat [false, false];
			private _vehType = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

			_grp = createGroup lmf_enemySide;
			[_veh, _grp, false, "", _rifleman] call BIS_fnc_spawnCrew;
			_grp deleteGroupWhenEmpty true;
			_grp setGroupIdGlobal [format ["Armed Car: %1 (%2)", _vehType, groupId _grp]];

			_wp = _grp addWaypoint [ATLToASL (getPos _veh), -1];
			_wp setWaypointType "GUARD";

			_grp addEventHandler ["UnitKilled", _fncUnitKilledEh];
		};

		case "TRUCK": {
			_veh = createVehicle [selectRandom _truck, _spawnPos, [], 0, "NONE"];
			_veh setDir _dir;
			private _vehType = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

			private _randomTeam = selectRandom [_team, _mgTeam, _atTeam];
			private _type = (selectRandom _squad) + (selectRandom _randomTeam);
			_grp = [_spawnPos, lmf_enemySide, _type] call BIS_fnc_spawnGroup;
			_grp deleteGroupWhenEmpty true;
			_grp setGroupIdGlobal [format ["Truck: %1 (%2)", _vehType, groupId _grp]];
			_grp setSpeedMode "FULL";
			_grp setCombatMode "RED";

			{_x moveInAny _veh} forEach units _grp;
			{deleteVehicle _x} forEach ((units _grp) select {isNull objectParent _x});

			_wp = _grp addWaypoint [ATLToASL (getPos _veh), -1];
			_wp setWaypointType "GUARD";

			_grp addEventHandler ["EnemyDetected", _fncDismountEh];
			_grp addEventHandler ["UnitKilled", _fncUnitKilledEh];
		};

		case "APC": {
			_veh = createVehicle [selectRandom _apc, _spawnPos, [], 0, "NONE"];
			_veh setDir _dir;
			private _vehType = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

			_grp = createGroup lmf_enemySide;
			[_veh, _grp, false, "", _crew] call BIS_fnc_spawnCrew;
			_grp deleteGroupWhenEmpty true;
			_grp setGroupIdGlobal [format ["APC: %1 (%2)", _vehType, groupId _grp]];
			private _notCrew = (units _grp) select {_x != (driver _veh) && _x != (gunner _veh) && _x != (commander _veh)};
			{_veh deleteVehicleCrew _x} forEach _notCrew;

			private _type = (selectRandom _mgTeam) + (selectRandom _atTeam);
			_grp2 = [_spawnPos, lmf_enemySide, _type] call BIS_fnc_spawnGroup;
			_grp2 deleteGroupWhenEmpty true;
			_grp2 setGroupIdGlobal [format ["Infantry QRF (%1)", groupId _grp2]];
			_grp2 setSpeedMode "FULL";
			_grp2 setCombatMode "RED";

			{_x moveInAny _veh} forEach units _grp2;
			{deleteVehicle _x} forEach ((units _grp2) select {isNull objectParent _x});

			_wp = _grp addWaypoint [ATLToASL (getPos _veh), -1];
			_wp setWaypointType "GUARD";
			private _wp2 = _grp2 addWaypoint [ATLToASL (getPos _veh), -1];
			_wp2 setWaypointType "GUARD";

			_grp addEventHandler ["UnitKilled", _fncUnitKilledEh];
			_grp2 addEventHandler ["UnitKilled", _fncUnitKilledEh];
			_grp2 addEventHandler ["EnemyDetected", _fncDismountEh];
		};

		case "TANK": {
			_veh = createVehicle [selectRandom _tank, _spawnPos, [], 0, "NONE"];
			_veh setDir _dir;
			_veh setUnloadInCombat [false, false];
			private _vehType = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

			_grp = createGroup lmf_enemySide;
			[_veh, _grp, false, "", _crew] call BIS_fnc_spawnCrew;
			_grp deleteGroupWhenEmpty true;
			_grp setGroupIdGlobal [format ["Tank: %1 (%2)", _vehType, groupId _grp]];
			private _notCrew = (units _grp) select {_x != (driver _veh) && _x != (gunner _veh) && _x != (commander _veh)};
			{_veh deleteVehicleCrew _x} forEach _notCrew;

			_wp = _grp addWaypoint [ATLToASL (getPos _veh), -1];
			_wp setWaypointType "GUARD";

			_grp addEventHandler ["UnitKilled", _fncUnitKilledEh];
		};

		case "HELITRANSPORT": {
			_veh = createVehicle [selectRandom _heliTransport, _spawnPos, [], 0, if (surfaceIsWater _spawnPos) then {"FLY"} else {"NONE"}];
			_veh setDir _dir;
			_veh setUnloadInCombat [false, false];
			private _vehType = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

			_grp = createGroup lmf_enemySide;
			[_veh, _grp, false, "", _pilot] call BIS_fnc_spawnCrew;
			_grp deleteGroupWhenEmpty true;
			_grp setGroupIdGlobal [format ["Transport Heli: %1 (%2)", _vehType, groupId _grp]];
			_transportCrew = units _grp;

			_wp = _grp addWaypoint [getPosASL _veh, -1];
			_wp setWaypointType "GUARD";

			private _type = selectRandom _squad;
			_grp2 = [_spawnPos, lmf_enemySide, _type] call BIS_fnc_spawnGroup;
			_grp2 deleteGroupWhenEmpty true;
			_grp2 setGroupIdGlobal [format ["Infantry QRF (%1)", groupId _grp2]];

			{_x assignAsCargo _veh; _x moveInCargo _veh} forEach units _grp2;
			{deleteVehicle _x} forEach ((units _grp2) select {isNull objectParent _x});

			_grp setVariable ["lmf_heliTransport_cargo", [_grp2, units _grp2]];
			_grp2 setVariable ["lmf_heliTransport_vehicle", _veh];
			_grp2 setVariable ["lmf_ai_joinableGroup", true];
			private _transportEh = _grp addEventHandler ["EnemyDetected", _fncHeliTransportEh];

			// Recover stalled transport planning and evacuate disabled transports.
			[_grp, _veh, _transportEh, _grp2] spawn {
				params ["_group", "_veh", "_transportEh", "_cargoGroup"];
				private _waitingForPlan = false;
				waitUntil {
					sleep 10;
					private _done = false;
					isNil {
						if (!local _group) exitWith {_done = true;};
						private _crew = (units _group) select {alive _x};
						if (_crew isEqualTo []) exitWith {_done = true;};
						private _onFoot = _crew findIf {!isNull objectParent _x} == -1;
						private _abandoned = _group getVariable ["lmf_heliTransport_abandoned", false];

						// Two idle samples; exclude reported landings and low-altitude unloading.
						private _wp = [_group, currentWaypoint _group];
						private _waiting = !_onFoot && {!_abandoned}
							&& {_group getVariable ["lmf_heliTransport_active", false]}
							&& {local _veh && {canMove _veh} && {!isTouchingGround _veh}}
							&& {_wp in waypoints _group && {waypointType _wp == "TR UNLOAD"}}
							&& {alive driver _veh && {local driver _veh}}
							&& {getUnitState (driver _veh) == "WAIT"}
							&& {(getPosATL _veh) # 2 > 10 && {vectorMagnitude velocity _veh < 1}}
							&& {(landAt _veh) # 0 in ["None", ""]};
						if (_waiting && {_waitingForPlan}) then {
							_wp setWaypointPosition [AGLToASL (waypointPosition _wp), -1];
							_waitingForPlan = false;
						} else {
							_waitingForPlan = _waiting;
						};

						if (!_onFoot && {!_abandoned} && {
							!(local _veh && {!canMove _veh} && {isTouchingGround _veh}
								&& {vectorMagnitude velocity _veh < 1})
						}) exitWith {};

						if (!_abandoned) then {
							// Cancel flight orders once; let normal get-out animations finish.
							_group setVariable ["lmf_heliTransport_abandoned", true];
							_group setVariable ["lmf_heliTransport_active", true];
							_group removeEventHandler ["EnemyDetected", _transportEh];
							{deleteWaypoint _x} forEachReversed waypoints _group;
							_group leaveVehicle _veh;
							{unassignVehicle _x} forEach _crew;
							if (!_onFoot) then {doGetOut _crew;};
							_group setBehaviourStrong "AWARE";
							_group setCombatMode "RED";

							// A grounded, abandoned transport must not strand its passengers.
							if (local _veh && {isTouchingGround _veh}
								&& {vectorMagnitude velocity _veh < 1} && {local _cargoGroup}) then {
								private _passengers = (units _cargoGroup) select {alive _x && {objectParent _x == _veh}};
								if !(_passengers isEqualTo []) then {
									_cargoGroup leaveVehicle _veh;
									doGetOut _passengers;
									if ((waypoints _cargoGroup) findIf {waypointType _x == "GUARD"} == -1) then {
										private _guard = _cargoGroup addWaypoint [getPosASL _veh, -1];
										_guard setWaypointType "GUARD";
										_cargoGroup setCurrentWaypoint _guard;
									};
								};
							};
						};

						if (!_onFoot) exitWith {};
						_done = true;
						_group setVariable ["lmf_heliTransport_active", false];

						private _joinableGroups = [_crew # 0] call lmf_ai_fnc_findJoinableGroups;
						if (_joinableGroups isEqualTo []) then {
							private _guard = _group addWaypoint [getPosASL (_crew # 0), -1];
							_guard setWaypointType "GUARD";
							_group setCurrentWaypoint _guard;
						} else {
							_crew joinSilent ((_joinableGroups # 0) # 1);
						};
					};
					_done
				};
			};
		};

		case "HELIATTACK": {
			_veh = createVehicle [selectRandom _heliAttack, _spawnPos, [], 0, if (surfaceIsWater _spawnPos) then {"FLY"} else {"NONE"}];
			_veh setDir _dir;
			_veh setUnloadInCombat [false, false];
			private _vehType = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

			_grp = createGroup lmf_enemySide;
			[_veh, _grp, false, "", _pilot] call BIS_fnc_spawnCrew;
			_grp deleteGroupWhenEmpty true;
			_grp setGroupIdGlobal [format ["Attack Heli: %1 (%2)", _vehType, groupId _grp]];

			_wp = _grp addWaypoint [getPosASL _veh, -1];
			_wp setWaypointType "GUARD";

			_grp addEventHandler ["UnitKilled", _fncUnitKilledEh];
		};

		case "UAV": {
			_veh = createVehicle [selectRandom _uav, _spawnPos, [], 0, if (surfaceIsWater _spawnPos) then {"FLY"} else {"NONE"}];
			_veh setDir _dir;
			private _vehType = getText (configFile >> "CfgVehicles" >> typeOf _veh >> "displayName");

			createVehicleCrew _veh;
			_grp = group (crew _veh # 0);
			_grp deleteGroupWhenEmpty true;
			_grp setGroupIdGlobal [format ["UAV: %1 (%2)", _vehType, groupId _grp]];

			_wp = _grp addWaypoint [getPosASL _veh, -1];
			_wp setWaypointType "GUARD";

			_veh flyInHeight [selectRandom [100, 115, 125], true];

			_grp addEventHandler ["EnemyDetected", {
				params ["_group", "_newTarget"];
				if (!isTouchingGround (vehicle _newTarget)) exitWith {};
				[vehicle (leader _group), _newTarget] spawn lmf_ai_fnc_taskUavAttack;
				_group removeEventHandler ["EnemyDetected", _thisEventHandler];
			}];
		};
	};

	if (_tickets > 1) then {
		waitUntil {
			sleep 5;
			(!alive _veh && {{alive _x} count (if (_vicType == "HELITRANSPORT") then {_transportCrew} else {units _grp}) == 0})
			|| {[_spawnPos, _range] call lmf_ai_fnc_getPlayerProximityState isEqualTo "groundClose"}
		};
		sleep _respawnTime;
	};

	_initTickets = _initTickets - 1;
};
