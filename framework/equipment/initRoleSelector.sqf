/*
    Role selection
    Adds role selection to crateRoles; included in the scheduled postInit action setup.
*/

if !(isNil "crateRoles") then {

	#include "..\..\settings\cfg_Player.sqf"

	// Main actions
	private _parentInfantry = ["parentInfantry","Infantry","\A3\3den\Data\Attributes\Stance\up_ca.paa",{true;},{true}] call ace_interact_menu_fnc_createAction;
	private _parentHq = ["parentHQ","HQ Roles","\A3\ui_f\data\map\markers\nato\b_inf.paa",{true;},{true}] call ace_interact_menu_fnc_createAction;
	private _parentSquad = ["parentSquad","Squad Roles","\A3\ui_f\data\map\markers\nato\b_inf.paa",{true;},{true}] call ace_interact_menu_fnc_createAction;
	private _parentWeapons = ["parentWeapons","Weapons","\A3\ui_f\data\map\markers\nato\b_inf.paa",{true;},{true}] call ace_interact_menu_fnc_createAction;
	private _parentAirCrew = ["parentAirCrew","Air Crew","\A3\ui_f\data\GUI\Rsc\RscDisplayGarage\helicopter_ca.paa",{true;},{true}] call ace_interact_menu_fnc_createAction;
	private _parentGroundCrew = ["parentGroundCrew","Ground Crew","\A3\ui_f\data\GUI\Rsc\RscDisplayGarage\tank_ca.paa",{true;},{true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions"], _parentInfantry] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry"], _parentHq] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry"], _parentSquad] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry"], _parentWeapons] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions"], _parentAirCrew] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions"], _parentGroundCrew] call ace_interact_menu_fnc_addActionToObject;

	// Subactions
	// Platoon HQ
	private _pltLead = ["platoonLeader", _platoonLeader#1,"\A3\ui_f\data\GUI\Cfg\Ranks\lieutenant_pr.paa",{[player] call lmf_equipment_fnc_applyPlatoonLeader},{true}] call ace_interact_menu_fnc_createAction;
	private _pltSgt = ["platoonSergeant", _platoonSgt#1,"\A3\ui_f\data\GUI\Cfg\Ranks\sergeant_pr.paa",{[player] call lmf_equipment_fnc_applyPlatoonSergeant},{true}] call ace_interact_menu_fnc_createAction;
	private _medic = ["medic", _medic#1,"\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\heal_ca.paa",{[player] call lmf_equipment_fnc_applyMedic},{true}] call ace_interact_menu_fnc_createAction;
	private _rto = ["rto", _rto#1,"\A3\modules_f_curator\Data\portraitRadio_ca.paa",{[player] call lmf_equipment_fnc_applyRadioOperator},{true}] call ace_interact_menu_fnc_createAction;
	private _jtac = ["jtac", _jtac#1,"\A3\modules_f_curator\Data\portraitCAS_ca.paa",{[player] call lmf_equipment_fnc_applyJtac},{true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentHQ"], _pltLead] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentHQ"], _pltSgt] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentHQ"], _medic] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentHQ"], _rto] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentHQ"], _jtac] call ace_interact_menu_fnc_addActionToObject;

	// Infantry squad
	private _squadLeader = ["squadLeader", _squadLeader#1,"\A3\ui_f\data\map\vehicleicons\iconManLeader_ca.paa",{[player] call lmf_equipment_fnc_applySquadLeader},{true}] call ace_interact_menu_fnc_createAction;
	private _squad2ic = ["squad2ic", _teamLeader#1,"\A3\ui_f\data\map\vehicleicons\iconManLeader_ca.paa",{[player] call lmf_equipment_fnc_applyTeamLeader},{true}] call ace_interact_menu_fnc_createAction;
	private _autorifleman = ["autorifleman", _autorifleman#1,"\A3\ui_f\data\map\vehicleicons\iconManMG_ca.paa",{[player] call lmf_equipment_fnc_applyAutorifleman},{true}] call ace_interact_menu_fnc_createAction;
	private _grenadier = ["genadier", _grenadier#1,"\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa",{[player] call lmf_equipment_fnc_applyGrenadier},{true}] call ace_interact_menu_fnc_createAction;
	private _rifleman = ["rifleman", _rifleman#1,"\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa",{[player] call lmf_equipment_fnc_applyRifleman},{true}] call ace_interact_menu_fnc_createAction;

	private _matG = ["matGunner", _antiTankGunner#1,"\A3\ui_f\data\map\vehicleicons\iconManAT_ca.paa",{[player] call lmf_equipment_fnc_applyAntiTankGunner},{true}] call ace_interact_menu_fnc_createAction;
	private _matA = ["matAssistant", _antiTankAssistant#1,"\A3\ui_f\data\map\vehicleicons\iconManAT_ca.paa",{[player] call lmf_equipment_fnc_applyAntiTankAssistant},{true}] call ace_interact_menu_fnc_createAction;
	private _mmgg = ["machineGunner", _machineGunner#1,"\A3\ui_f\data\map\vehicleicons\iconManMG_ca.paa",{[player] call lmf_equipment_fnc_applyMachineGunner},{true}] call ace_interact_menu_fnc_createAction;
	private _mmga = ["machineGunnerAssistant", _machineGunnerAssistant#1,"\A3\ui_f\data\map\vehicleicons\iconManMG_ca.paa",{[player] call lmf_equipment_fnc_applyMachineGunnerAssistant},{true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentSquad"], _squadLeader] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentSquad"], _squad2ic] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentSquad"], _autorifleman] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentSquad"], _grenadier] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentSquad"], _rifleman] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentWeapons"], _matG] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentWeapons"], _matA] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentWeapons"], _mmgg] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentInfantry","parentWeapons"], _mmga] call ace_interact_menu_fnc_addActionToObject;

	// Ground vehicle crew
	private _vehPltCmd = ["vehPlatoonLeader", _crewLeader#1,"\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa",{[player] call lmf_equipment_fnc_applyVehiclePlatoonLeader},{true}] call ace_interact_menu_fnc_createAction;
	private _vehCommander = ["vehCommander", _crewSgt#1,"\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa",{[player] call lmf_equipment_fnc_applyVehicleCommander},{true}] call ace_interact_menu_fnc_createAction;
	private _vehDriver = ["vehDriver", _crew#1,"\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa",{[player] call lmf_equipment_fnc_applyVehicleCrew},{true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions","parentGroundCrew"], _vehPltCmd] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentGroundCrew"], _vehCommander] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentGroundCrew"], _vehDriver] call ace_interact_menu_fnc_addActionToObject;

	// Air vehicle crew
	private _heli = ["heli", _heloPilot#1,"\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa",{[player] call lmf_equipment_fnc_applyHelicopterPilot},{true}] call ace_interact_menu_fnc_createAction;
	private _heliCrew = ["heliCrew", _heloCrew#1,"\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa",{[player] call lmf_equipment_fnc_applyHelicopterCrew},{true}] call ace_interact_menu_fnc_createAction;
	private _fighter = ["fighter", _pilot#1,"\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa",{[player] call lmf_equipment_fnc_applyPilot},{true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions","parentAirCrew"], _heli] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentAirCrew"], _heliCrew] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions","parentAirCrew"], _fighter] call ace_interact_menu_fnc_addActionToObject;
};
