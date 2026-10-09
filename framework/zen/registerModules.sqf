/*
	ZEN modules
	Registers LMF Zeus modules when ZEN is enabled.
*/

lmf_zen_groupTypes = ["TEAM", "SQUAD", "SENTRY", "ATTEAM", "AATEAM", "MGTEAM", "CUSTOM AMOUNT"];
lmf_zen_formationTypes = ["STAG COLUMN", "LINE", "DIAMOND", "FILE"];
lmf_zen_speedMode = ["SLOW", "FAST", "ATTACK"];

// Reapply loadout
["LMF Utility", "Reload Original Loadout", {

	params ["", "_obj"];

	if (isNull _obj) exitWith {["Error: no unit"] call zen_common_fnc_showMessage};

	[_obj] remoteExec ["lmf_equipment_fnc_applyRoleFromClass"];
	["Loadout reloaded for %1", name _obj] call zen_common_fnc_showMessage;

}, "\A3\ui_f\data\igui\cfg\actions\reammo_ca.paa"] call zen_custom_modules_fnc_register;

// Respawn one player
["LMF Utility", "Respawn Single Player", {
	private _players = [] call ace_spectator_fnc_players;
	if (count _players == 0) exitWith {["Error: no dead players"] call zen_common_fnc_showMessage};
	private _names = _players apply {name _x};
	["Respawn Single Player", [

		["COMBO", "Player", [_players, _names]]
	], {

		params ["_dialog"];
		_dialog params [["_plr", objNull, [objNull]]];
		if (isNull _plr) exitWith {["Error: unable to find player"] call zen_common_fnc_showMessage};

		// Respawn the player and show feedback.
		[5] remoteExec ["setPlayerRespawnTime", _plr];
		["Respawned %1", name _plr] call zen_common_fnc_showMessage;
	}, {}, []] call zen_dialog_fnc_create;
}, "\A3\modules_f\data\portraitrespawn_ca.paa"] call zen_custom_modules_fnc_register;

// AI infantry garrison
["LMF AI", "Infantry Garrison", {
	["Infantry Garrison", [

		["COMBO", "Group Type", [lmf_zen_groupTypes, lmf_zen_groupTypes, 0]],
		["SLIDER", "Custom Amount", [1, 60, 4, 0]],
		["EDIT", "Garrison Radius", ["100"]],
		["CHECKBOX", "Fill Evenly", false],
		["CHECKBOX", "Fill From Top Down", false]
	], {

		params ["_dialog", "_pos"];
		_dialog params ["_type", "_amount", "_radius", "_distrib", "_topDown"];

		_pos = ASLToATL _pos;
		_radius = parseNumber _radius;
		_distrib = [0, 1] select !_distrib;
		if (_type == "CUSTOM AMOUNT") then {
			_type = round _amount;
		};

		[_pos, _type, _radius, _distrib, _topDown] remoteExec ["lmf_ai_fnc_spawnGarrison"];
		["Garrisoning %1 at %2m radius", _type, _radius] call zen_common_fnc_showMessage;

	}, {}, _this#0] call zen_dialog_fnc_create;
}, "\A3\modules_f_bootcamp\data\portraitbootcampstage.paa"] call zen_custom_modules_fnc_register;

// AI infantry patrol
["LMF AI", "Infantry Patrol", {
	private _players = (allPlayers - entities "HeadlessClient_F") select {alive _x};
	private _names = _players apply {name _x};
	["Infantry Patrol", [

		["COMBO", "Group Type", [lmf_zen_groupTypes, lmf_zen_groupTypes, 0]],
		["SLIDER", "Custom Amount", [1, 60, 4, 0]],
		["EDIT", "Patrol Radius", ["100"]],
		["COMBO", "Speed", [lmf_zen_speedMode, lmf_zen_speedMode, 0]],
		["COMBO", "Formation", [lmf_zen_formationTypes, lmf_zen_formationTypes, 0]],
		["COMBO", "Target", [[objNull] + _players, ["Clicked Position"] + _names, 0], true]
	], {

		params ["_dialog", "_pos"];
		_dialog params ["_type", "_amount", "_radius", "_speed", "_formation", "_target"];

		_pos = ASLToATL _pos;
		// Snapshot the player position on confirmation; stale selections use the clicked position.
		private _patrolTarget = _pos;
		if (!isNull _target && {alive _target} && {isPlayer _target}) then {
			_patrolTarget = getPosATL _target;
		};
		_radius = parseNumber _radius;
		if (_type == "CUSTOM AMOUNT") then {
			_type = round _amount;
		};

		[_pos, _patrolTarget, _type, _radius, _speed, _formation] remoteExec ["lmf_ai_fnc_spawnPatrol"];
		["Patrol started: %1 (%2m radius)", _type, _radius] call zen_common_fnc_showMessage;

	}, {}, _this#0] call zen_dialog_fnc_create;
}, "\A3\modules_f_bootcamp\data\portraitbootcampstage.paa"] call zen_custom_modules_fnc_register;

// AI infantry QRF
["LMF AI", "Infantry QRF", {
	["Infantry QRF", [

		["COMBO", "Group Type", [lmf_zen_groupTypes, lmf_zen_groupTypes, 0]],
		["SLIDER", "Custom Amount", [1, 60, 4, 0]]
	], {

		params ["_dialog", "_pos"];
		_dialog params ["_type", "_amount"];

		_pos = ASLToATL _pos;
		if (_type == "CUSTOM AMOUNT") then {
			_type = round _amount;
		};

		[_pos, _type, 1] remoteExec ["lmf_ai_fnc_spawnInfantryQrf"];
		["Infantry QRF spawned: %1", _type] call zen_common_fnc_showMessage;

	}, {}, _this#0] call zen_dialog_fnc_create;
}, "\A3\modules_f_bootcamp\data\portraitbootcampstage.paa"] call zen_custom_modules_fnc_register;

// AI infantry hunter
["LMF AI", "Infantry Hunter", {
	["Infantry Hunter", [

		["COMBO", "Group Type", [lmf_zen_groupTypes, lmf_zen_groupTypes, 0]],
		["SLIDER", "Custom Amount", [1, 60, 4, 0]],
		["EDIT", "Hunting Radius", ["3000"]]
	], {

		params ["_dialog", "_pos"];
		_dialog params ["_type", "_amount", "_radius"];

		_pos = ASLToATL _pos;
		_radius = parseNumber _radius;
		if (_type == "CUSTOM AMOUNT") then {
			_type = round _amount;
		};

		[_pos, _type, _radius, 1] remoteExec ["lmf_ai_fnc_spawnInfantryHunters"];
		["Hunter group spawned: %1 (%2m radius)", _type, _radius] call zen_common_fnc_showMessage;

	}, {}, _this#0] call zen_dialog_fnc_create;
}, "\A3\modules_f_bootcamp\data\portraitbootcampstage.paa"] call zen_custom_modules_fnc_register;

// Vehicle QRF
["LMF AI", "Vehicle QRF", {
	private _options = ["CAR", "CARARMED", "TRUCK", "APC", "TANK", "HELITRANSPORT", "HELIATTACK", "DRONE"];
	["Vehicle QRF", [

		["COMBO", "Vehicle Type", [_options, _options, 2]]
	], {

		params ["_dialog", "_pos"];
		_dialog params ["_type"];

		_pos = ASLToATL _pos;

		[_pos, _type, 1] remoteExec ["lmf_ai_fnc_spawnVehicleQrf"];
		["Vehicle QRF spawned: %1", _type] call zen_common_fnc_showMessage;

	}, {}, _this#0] call zen_dialog_fnc_create;
}, "\A3\ui_f\data\map\vehicleicons\iconcar_ca.paa"] call zen_custom_modules_fnc_register;

// Paradrop QRF
["LMF AI", "Paradrop QRF", {
	params ["_pos"];

	private _options = ["INFANTRY", "CAR", "CARARMED", "TRUCK", "APC", "TANK"];

	["Paradrop QRF", [
		["COMBO", "Payload Type", [_options, _options, 0]],
		["SLIDER", "Tickets", [1, 20, 1, 0]],
		["EDIT", "Fly-in Height", ["250"]],
		["EDIT", "Respawn Timer", ["300"]]
	], {
		params ["_dialog", "_pos"];
		_dialog params ["_type", "_tickets", "_height", "_timer"];

		// Resolve the clicked position and apply altitude.
		private _clickPos = ASLToATL _pos;
		private _flyHeight = parseNumber _height;
		private _spawnPos = [_clickPos#0, _clickPos#1, _flyHeight];

		// Payload selection
		private _dropVehicle = "";
		if (_type != "INFANTRY") then {
			_dropVehicle = _type;
		};

		[
			_spawnPos,
			[0, 0, 0],
			_flyHeight,
			_dropVehicle,
			_tickets,
			parseNumber _timer
		] remoteExec ["lmf_ai_fnc_spawnParadropQrf"];

		["Para QRF spawned at %1m altitude (%2)", _flyHeight, _type] call zen_common_fnc_showMessage;

	}, {}, _pos] call zen_dialog_fnc_create;
}, "\A3\ui_f\data\map\vehicleicons\iconparachute_ca.paa"] call zen_custom_modules_fnc_register;

// Supply drop
["LMF Utility", "Supply Drop", {

	private _boxes = [
		[lmf_supSquad, "Small Ammo Crate"],
		[lmf_supLarge, "Large Ammo Crate"],
		[lmf_supExplosives, "Explosives Crate"],
		[lmf_supMedical, "Medical Crate"],
		[lmf_supVehicle, "Vehicle Supplies (RRR)"]
	];
	_boxes = _boxes select {_x#0 != ""};
	private _groundVehicles = lmf_groundVehicles select {_x != "" && {isClass (configFile >> "CfgVehicles" >> _x)}};
	if (count _boxes > 0 && {count _groundVehicles > 0}) then {
		_boxes pushBack ["", "--- Vehicles ---"];
	};
	{
		_boxes pushBack [_x, getText (configFile >> "CfgVehicles" >> _x >> "displayName")];
	} forEach _groundVehicles;
	if (_boxes isEqualTo []) exitWith {["No supplies or ground vehicles configured."] call zen_common_fnc_showMessage;};

	private _comboOptions = [];
	for "_i" from 0 to (count _boxes) - 1 do {
		_comboOptions pushBack ((_boxes select _i) select 1);
	};

	["Supply Drop", [

		["COMBO", "Box Type", [_boxes, _comboOptions, 0]]
	], {

		params ["_dialog", "_pos"];
		_dialog params ["_type"];
		if (_type#0 isEqualTo "") exitWith {};

		_pos = ASLToATL _pos;
		_dropPos = _pos;

		// Calculate the spawn position.
		lmf_supplyDropPos = getMarkerPos "respawn";
		private _initPos = lmf_supplyDropPos;
		private _dir = _dropPos getDir _initPos;
		_spawnPos = _initPos getPos [random 5000, _dir];
		if (_spawnPos distance2D _dropPos < 5000) then {
			_spawnPos = _initPos getPos [5000, _dir];
		};

		[_spawnPos, _pos, lmf_supplyDropAircraft, _type#0] remoteExec ["lmf_supplyDrop_fnc_deliverSupplies"];
		["Supply Drop spawned: %1", _type#1] call zen_common_fnc_showMessage;

	}, {}, _this#0] call zen_dialog_fnc_create;
}, "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa"] call zen_custom_modules_fnc_register;

// Apply new loadout
["LMF Utility", "Apply New Loadout", {

	private _config = call lmf_equipment_fnc_getPlayerConfig;
	private _roleConfig = _config get "ROLES";

	private _infCommanderIcon = "\A3\ui_f\data\map\vehicleicons\iconmancommander_ca.paa";
	private _infLeaderIcon = "\A3\ui_f\data\map\vehicleicons\iconmanleader_ca.paa";
	private _infMedicIcon = "\A3\ui_f\data\map\vehicleicons\iconmanmedic_ca.paa";
	private _infMgIcon = "\A3\ui_f\data\map\vehicleicons\iconmanmg_ca.paa";
	private _infAtIcon = "\A3\ui_f\data\map\vehicleicons\iconmanat_ca.paa";
	private _infDefaultIcon = "\A3\ui_f\data\map\vehicleicons\iconman_ca.paa";
	private _vehCommanderIcon = "\A3\ui_f\data\map\vehicleicons\iconmancommander2_ca.paa";

	private _roles = [
		["", ""],
		["PLATOON_LEADER", _infCommanderIcon],
		["PLATOON_SERGEANT", _infLeaderIcon],
		["MEDIC", _infMedicIcon],
		["RTO", _infDefaultIcon],
		["JTAC", _infDefaultIcon],
		["", ""],
		["SQUAD_LEADER", _infLeaderIcon],
		["TEAM_LEADER", _infLeaderIcon],
		["AUTORIFLEMAN", _infMgIcon],
		["GRENADIER" , _infDefaultIcon],
		["RIFLEMAN", _infDefaultIcon],
		["", ""],
		["ANTI_TANK_GUNNER", _infAtIcon],
		["ANTI_TANK_ASSISTANT", _infAtIcon],
		["MACHINE_GUNNER", _infMgIcon],
		["MACHINE_GUNNER_ASSISTANT", _infMgIcon],
		["", ""],
		["VEHICLE_PLATOON_LEADER", _vehCommanderIcon],
		["VEHICLE_COMMANDER", _infLeaderIcon],
		["VEHICLE_CREW", _infDefaultIcon],
		["", ""],
		["HELICOPTER_PILOT", _infDefaultIcon],
		["HELICOPTER_CREW", _infDefaultIcon],
		["PILOT", _infDefaultIcon]
	];

	private _comboOptions = [];
	for "_i" from 0 to (count _roles) - 1 do {
		private _roleKey = (_roles select _i) select 0;
		private _displayName = if (_roleKey isEqualTo "") then {""} else {(_roleConfig get _roleKey) get "DISPLAY_NAME"};
		_comboOptions pushBack ([_displayName, "", (_roles select _i) select 1]);
	};

	["Apply New Loadout", [

		["COMBO", "Loadout Type", [_roles, _comboOptions, 0]]
	], {

		params ["_dialog", "_obj"];
		_dialog params ["_type"];

		// Exit if the selected object is not a player.
		if (isNull _obj) exitWith {["Error: no unit"] call zen_common_fnc_showMessage};
		if !(_obj isKindOf "Man") exitWith {["Error: not a soldier"] call zen_common_fnc_showMessage};

		// Role selection
		if (_type#0 isEqualTo "PLATOON_LEADER") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyPlatoonLeader", _obj]; ["Applied: Platoon Leader"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "PLATOON_SERGEANT") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyPlatoonSergeant", _obj]; ["Applied: Platoon Sergeant"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "MEDIC") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyMedic", _obj]; ["Applied: Medic"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "RTO") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyRadioOperator", _obj]; ["Applied: RTO"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "JTAC") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyJtac", _obj]; ["Applied: JTAC"] call zen_common_fnc_showMessage;};

		if (_type#0 isEqualTo "SQUAD_LEADER") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applySquadLeader", _obj]; ["Applied: Squad Leader"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "TEAM_LEADER") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyTeamLeader", _obj]; ["Applied: Team Leader"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "AUTORIFLEMAN") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyAutorifleman", _obj]; ["Applied: Autorifleman"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "GRENADIER") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyGrenadier", _obj]; ["Applied: Grenadier"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "RIFLEMAN") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyRifleman", _obj]; ["Applied: Rifleman"] call zen_common_fnc_showMessage;};

		if (_type#0 isEqualTo "ANTI_TANK_GUNNER") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyAntiTankGunner", _obj]; ["Applied: AT Gunner"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "ANTI_TANK_ASSISTANT") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyAntiTankAssistant", _obj]; ["Applied: AT Assistant"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "MACHINE_GUNNER") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyMachineGunner", _obj]; ["Applied: Machine Gunner"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "MACHINE_GUNNER_ASSISTANT") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyMachineGunnerAssistant", _obj]; ["Applied: MG Assistant"] call zen_common_fnc_showMessage;};

		if (_type#0 isEqualTo "VEHICLE_PLATOON_LEADER") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyVehiclePlatoonLeader", _obj]; ["Applied: Crew Leader"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "VEHICLE_COMMANDER") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyVehicleCommander", _obj]; ["Applied: Crew Sergeant"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "VEHICLE_CREW") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyVehicleCrew", _obj]; ["Applied: Crewman"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "HELICOPTER_PILOT") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyHelicopterPilot", _obj]; ["Applied: Helo Pilot"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "HELICOPTER_CREW") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyHelicopterCrew", _obj]; ["Applied: Helo Crew"] call zen_common_fnc_showMessage;};
		if (_type#0 isEqualTo "PILOT") exitWith {[_obj] remoteExec ["lmf_equipment_fnc_applyPilot", _obj]; ["Applied: Pilot"] call zen_common_fnc_showMessage;};

	}, {}, _this#1] call zen_dialog_fnc_create;
}, "\A3\ui_f\data\igui\cfg\actions\gear_ca.paa"] call zen_custom_modules_fnc_register;

// Spawn vehicles
["LMF Utility", "Vehicle Spawn", {

	private _groundVehicles = lmf_groundVehicles select {_x != "" && {isClass (configFile >> "CfgVehicles" >> _x)}};
	private _airVehicles = lmf_airVehicles select {_x != "" && {isClass (configFile >> "CfgVehicles" >> _x)}};
	private _vehicles = [];
	{
		_vehicles pushBack [_x, getText (configFile >> "CfgVehicles" >> _x >> "displayName")];
	} forEach _groundVehicles;
	if (count _groundVehicles > 0 && {count _airVehicles > 0}) then {
		_vehicles pushBack ["", "--- Aircraft ---"];
	};
	{
		_vehicles pushBack [_x, getText (configFile >> "CfgVehicles" >> _x >> "displayName")];
	} forEach _airVehicles;
	if (_vehicles isEqualTo []) exitWith {["No vehicles configured."] call zen_common_fnc_showMessage;};

	private _comboOptions = [];
	for "_i" from 0 to (count _vehicles) - 1 do {
		_comboOptions pushBack ([(_vehicles select _i) select 1]);
	};

	["Vehicle Spawn", [

		["COMBO", "Vehicle Type", [_vehicles, _comboOptions, 0]]
	], {

		params ["_dialog", "_pos"];
		_dialog params ["_type"];
		if (_type#0 isEqualTo "") exitWith {};

		_pos = ASLToATL _pos;
		private _vehicle = _type#0 createVehicle _pos;
		["Vehicle spawned: %1", getText (configFile >> "CfgVehicles" >> typeOf _vehicle >> "displayName")] call zen_common_fnc_showMessage;

	}, {}, _this#0] call zen_dialog_fnc_create;
}, "\A3\ui_f\data\map\vehicleicons\iconcar_ca.paa"] call zen_custom_modules_fnc_register;
