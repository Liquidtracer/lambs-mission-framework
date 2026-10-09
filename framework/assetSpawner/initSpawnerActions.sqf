/*
	Asset-spawner actions
	Adds ACE actions to framework supply and vehicle spawners.
	Included in the scheduled action initialization in XEH_postInit.sqf.
	Relevant variable names are:
		ammoSpawner (object the action is added to)
		groundSpawner (object the action is added to)
		airSpawner (object the action is added to)
		ammoPad (object item is spawned on)
		groundPad (object item is spawned on)
		airPad (object item is spawned on)
*/

// Supply spawner
if !(isNil "ammoSpawner") then {
	{
		_x params ["_category", "_classname", "_displayName"];
		if (_classname != "") then {
			private _icon = switch (_category) do {
				case "EXPLOSIVES": {"\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa"};
				case "MEDICAL": {"\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\heal_ca.paa"};
				default {"\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa"};
			};
			private _action = [format ["lmf_assetSpawner_supply%1", _category], _displayName, _icon, {
				params ["_target", "_player", "_params"];
				["", ammoPad, _params select 0] call lmf_assetSpawner_fnc_spawnObjectAtPad;
			}, {true}, {}, [_category]] call ace_interact_menu_fnc_createAction;
			[ammoSpawner, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
		};
	} forEach lmf_supplyCrates_definitions;
	private _spareWheel = ["lmf_assetSpawner_spareWheel", "Spare Wheel", "", {["ACE_Wheel", ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;}, {true}] call ace_interact_menu_fnc_createAction;
	private _spareTrack = ["lmf_assetSpawner_spareTrack", "Spare Track", "", {["ACE_Track", ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;}, {true}] call ace_interact_menu_fnc_createAction;

	[ammoSpawner, 0, ["ACE_MainActions"], _spareWheel] call ace_interact_menu_fnc_addActionToObject;
	[ammoSpawner, 0, ["ACE_MainActions"], _spareTrack] call ace_interact_menu_fnc_addActionToObject;
};

// Ground vehicle spawner
if !(isNil "groundSpawner") then {
	{
		if (_x != "" && {isClass (configFile >> "CfgVehicles" >> _x)}) then {
			private _displayName = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
			private _action = [format ["lmf_assetSpawner_ground%1", _forEachIndex], _displayName, "", {
				params ["_target", "_player", "_params"];
				[_params select 0, groundPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;
			}, {true}, {}, [_x]] call ace_interact_menu_fnc_createAction;
			[groundSpawner, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
		};
	} forEach lmf_groundVehicles;
};

// Air vehicle spawner
if !(isNil "airSpawner") then {
	{
		if (_x != "" && {isClass (configFile >> "CfgVehicles" >> _x)}) then {
			private _displayName = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
			private _action = [format ["lmf_assetSpawner_air%1", _forEachIndex], _displayName, "", {
				params ["_target", "_player", "_params"];
				[_params select 0, airPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;
			}, {true}, {}, [_x]] call ace_interact_menu_fnc_createAction;
			[airSpawner, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
		};
	} forEach lmf_airVehicles;
};

