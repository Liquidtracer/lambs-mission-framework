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
	private _ammoSquad = ["lmf_assetSpawner_ammoSmall", "Squad Box", "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa", {[lmf_supSquad, ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;}, {true}] call ace_interact_menu_fnc_createAction;
	private _ammoExplosive = ["lmf_assetSpawner_ammoExplosive", "Explosives", "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa", {[lmf_supExplosives, ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;}, {true}] call ace_interact_menu_fnc_createAction;
	private _ammoMedic = ["lmf_assetSpawner_ammoMedic", "Medical", "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\heal_ca.paa", {[lmf_supMedical, ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;}, {true}] call ace_interact_menu_fnc_createAction;
	private _spareWheel = ["lmf_assetSpawner_spareWheel", "Spare Wheel", "", {["ACE_Wheel", ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;}, {true}] call ace_interact_menu_fnc_createAction;
	private _spareTrack = ["lmf_assetSpawner_spareTrack", "Spare Track", "", {["ACE_Track", ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;}, {true}] call ace_interact_menu_fnc_createAction;

	if (lmf_supSquad != "") then {[ammoSpawner, 0, ["ACE_MainActions"], _ammoSquad] call ace_interact_menu_fnc_addActionToObject;};
	if (lmf_supExplosives != "") then {[ammoSpawner, 0, ["ACE_MainActions"], _ammoExplosive] call ace_interact_menu_fnc_addActionToObject;};
	if (lmf_supMedical != "") then {[ammoSpawner, 0, ["ACE_MainActions"], _ammoMedic] call ace_interact_menu_fnc_addActionToObject;};
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

