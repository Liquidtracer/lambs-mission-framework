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
	private _ammoSquad = ["ammoSmall","Squad Box","\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa",{[var_supSquad, ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _ammoExplosive = ["ammoExplosive","Explosives","\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\destroy_ca.paa",{[var_supExplosives, ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _ammoMedic = ["ammoMedic","Medical","\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\heal_ca.paa",{[var_supMedical, ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _spareWheel = ["spareWheel","Spare Wheel","",{["ACE_Wheel", ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _spareTrack = ["spareTrack","Spare Track","",{["ACE_Track", ammoPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;

	if (var_supSquad != "") then {[ammoSpawner, 0, ["ACE_MainActions"], _ammoSquad] call ace_interact_menu_fnc_addActionToObject;};
	if (var_supExplosives != "") then {[ammoSpawner, 0, ["ACE_MainActions"], _ammoExplosive] call ace_interact_menu_fnc_addActionToObject;};
	if (var_supMedical != "") then {[ammoSpawner, 0, ["ACE_MainActions"], _ammoMedic] call ace_interact_menu_fnc_addActionToObject;};
	[ammoSpawner, 0, ["ACE_MainActions"], _spareWheel] call ace_interact_menu_fnc_addActionToObject;
	[ammoSpawner, 0, ["ACE_MainActions"], _spareTrack] call ace_interact_menu_fnc_addActionToObject;
};

// Ground vehicle spawner
if !(isNil "groundSpawner") then {
	private _vehType1 = getText (configFile >> "CfgVehicles" >> var_vic1 >> "displayName");
	private _vehType2 = getText (configFile >> "CfgVehicles" >> var_vic2 >> "displayName");
	private _vehType3 = getText (configFile >> "CfgVehicles" >> var_vic3 >> "displayName");
	private _vehType4 = getText (configFile >> "CfgVehicles" >> var_vic4 >> "displayName");

	private _groundVeh1 = ["veh1",_vehType1,"",{[var_vic1, groundPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _groundVeh2 = ["veh2",_vehType2,"",{[var_vic2, groundPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _groundVeh3 = ["veh3",_vehType3,"",{[var_vic3, groundPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _groundVeh4 = ["veh4",_vehType4,"",{[var_vic4, groundPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;

	if (var_vic1 != "") then {[groundSpawner, 0, ["ACE_MainActions"], _groundVeh1] call ace_interact_menu_fnc_addActionToObject;};
	if (var_vic2 != "") then {[groundSpawner, 0, ["ACE_MainActions"], _groundVeh2] call ace_interact_menu_fnc_addActionToObject;};
	if (var_vic3 != "") then {[groundSpawner, 0, ["ACE_MainActions"], _groundVeh3] call ace_interact_menu_fnc_addActionToObject;};
	if (var_vic4 != "") then {[groundSpawner, 0, ["ACE_MainActions"], _groundVeh4] call ace_interact_menu_fnc_addActionToObject;};
};

// Air vehicle spawner
if !(isNil "airSpawner") then {
	private _heliType1 = getText (configFile >> "CfgVehicles" >> var_air1 >> "displayName");
	private _heliType2 = getText (configFile >> "CfgVehicles" >> var_air2 >> "displayName");
	private _heliType3 = getText (configFile >> "CfgVehicles" >> var_air3 >> "displayName");
	private _heliType4 = getText (configFile >> "CfgVehicles" >> var_air4 >> "displayName");

	private _airVeh1 = ["heli1",_heliType1,"",{[var_air1, airPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _airVeh2 = ["heli2",_heliType2,"",{[var_air2, airPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _airVeh3 = ["heli3",_heliType3,"",{[var_air3, airPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;
	private _airVeh4 = ["heli4",_heliType4,"",{[var_air4, airPad] call lmf_assetSpawner_fnc_spawnObjectAtPad;},{true}] call ace_interact_menu_fnc_createAction;

	if (var_air1 != "") then {[airSpawner, 0, ["ACE_MainActions"], _airVeh1] call ace_interact_menu_fnc_addActionToObject;};
	if (var_air2 != "") then {[airSpawner, 0, ["ACE_MainActions"], _airVeh2] call ace_interact_menu_fnc_addActionToObject;};
	if (var_air3 != "") then {[airSpawner, 0, ["ACE_MainActions"], _airVeh3] call ace_interact_menu_fnc_addActionToObject;};
	if (var_air4 != "") then {[airSpawner, 0, ["ACE_MainActions"], _airVeh4] call ace_interact_menu_fnc_addActionToObject;};
};

