/*
	Role selection
	Adds role selection to crateRoles; included in the scheduled postInit action setup.
*/

if !(isNil "crateRoles") then {

	#include "..\..\settings\cfg_Player.sqf"

	// Main actions
	private _parentInfantry = ["lmf_equipment_infantry", "Infantry", "\A3\3den\Data\Attributes\Stance\up_ca.paa", {true;}, {true}] call ace_interact_menu_fnc_createAction;
	private _parentHq = ["lmf_equipment_hq", "HQ Roles", "\A3\ui_f\data\map\markers\nato\b_inf.paa", {true;}, {true}] call ace_interact_menu_fnc_createAction;
	private _parentSquad = ["lmf_equipment_squad", "Squad Roles", "\A3\ui_f\data\map\markers\nato\b_inf.paa", {true;}, {true}] call ace_interact_menu_fnc_createAction;
	private _parentWeapons = ["lmf_equipment_weapons", "Weapons", "\A3\ui_f\data\map\markers\nato\b_inf.paa", {true;}, {true}] call ace_interact_menu_fnc_createAction;
	private _parentAirCrew = ["lmf_equipment_airCrew", "Air Crew", "\A3\ui_f\data\GUI\Rsc\RscDisplayGarage\helicopter_ca.paa", {true;}, {true}] call ace_interact_menu_fnc_createAction;
	private _parentGroundCrew = ["lmf_equipment_groundCrew", "Ground Crew", "\A3\ui_f\data\GUI\Rsc\RscDisplayGarage\tank_ca.paa", {true;}, {true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions"], _parentInfantry] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry"], _parentHq] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry"], _parentSquad] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry"], _parentWeapons] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions"], _parentAirCrew] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions"], _parentGroundCrew] call ace_interact_menu_fnc_addActionToObject;

	// Subactions
	// Platoon HQ
	private _pltLead = ["lmf_equipment_platoonLeader", _platoonLeader#1, "\A3\ui_f\data\GUI\Cfg\Ranks\lieutenant_pr.paa", {[player] call lmf_equipment_fnc_applyPlatoonLeader}, {true}] call ace_interact_menu_fnc_createAction;
	private _pltSgt = ["lmf_equipment_platoonSergeant", _platoonSgt#1, "\A3\ui_f\data\GUI\Cfg\Ranks\sergeant_pr.paa", {[player] call lmf_equipment_fnc_applyPlatoonSergeant}, {true}] call ace_interact_menu_fnc_createAction;
	private _medic = ["lmf_equipment_medic", _medic#1, "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\heal_ca.paa", {[player] call lmf_equipment_fnc_applyMedic}, {true}] call ace_interact_menu_fnc_createAction;
	private _rto = ["lmf_equipment_radioOperator", _rto#1, "\A3\modules_f_curator\Data\portraitRadio_ca.paa", {[player] call lmf_equipment_fnc_applyRadioOperator}, {true}] call ace_interact_menu_fnc_createAction;
	private _jtac = ["lmf_equipment_jtac", _jtac#1, "\A3\modules_f_curator\Data\portraitCAS_ca.paa", {[player] call lmf_equipment_fnc_applyJtac}, {true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_hq"], _pltLead] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_hq"], _pltSgt] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_hq"], _medic] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_hq"], _rto] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_hq"], _jtac] call ace_interact_menu_fnc_addActionToObject;

	// Infantry squad
	private _squadLeader = ["lmf_equipment_squadLeader", _squadLeader#1, "\A3\ui_f\data\map\vehicleicons\iconManLeader_ca.paa", {[player] call lmf_equipment_fnc_applySquadLeader}, {true}] call ace_interact_menu_fnc_createAction;
	private _squad2ic = ["lmf_equipment_teamLeader", _teamLeader#1, "\A3\ui_f\data\map\vehicleicons\iconManLeader_ca.paa", {[player] call lmf_equipment_fnc_applyTeamLeader}, {true}] call ace_interact_menu_fnc_createAction;
	private _autorifleman = ["lmf_equipment_autorifleman", _autorifleman#1, "\A3\ui_f\data\map\vehicleicons\iconManMG_ca.paa", {[player] call lmf_equipment_fnc_applyAutorifleman}, {true}] call ace_interact_menu_fnc_createAction;
	private _grenadier = ["lmf_equipment_grenadier", _grenadier#1, "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa", {[player] call lmf_equipment_fnc_applyGrenadier}, {true}] call ace_interact_menu_fnc_createAction;
	private _rifleman = ["lmf_equipment_rifleman", _rifleman#1, "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa", {[player] call lmf_equipment_fnc_applyRifleman}, {true}] call ace_interact_menu_fnc_createAction;

	private _matG = ["lmf_equipment_antiTankGunner", _antiTankGunner#1, "\A3\ui_f\data\map\vehicleicons\iconManAT_ca.paa", {[player] call lmf_equipment_fnc_applyAntiTankGunner}, {true}] call ace_interact_menu_fnc_createAction;
	private _matA = ["lmf_equipment_antiTankAssistant", _antiTankAssistant#1, "\A3\ui_f\data\map\vehicleicons\iconManAT_ca.paa", {[player] call lmf_equipment_fnc_applyAntiTankAssistant}, {true}] call ace_interact_menu_fnc_createAction;
	private _mmgg = ["lmf_equipment_machineGunner", _machineGunner#1, "\A3\ui_f\data\map\vehicleicons\iconManMG_ca.paa", {[player] call lmf_equipment_fnc_applyMachineGunner}, {true}] call ace_interact_menu_fnc_createAction;
	private _mmga = ["lmf_equipment_machineGunnerAssistant", _machineGunnerAssistant#1, "\A3\ui_f\data\map\vehicleicons\iconManMG_ca.paa", {[player] call lmf_equipment_fnc_applyMachineGunnerAssistant}, {true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_squad"], _squadLeader] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_squad"], _squad2ic] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_squad"], _autorifleman] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_squad"], _grenadier] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_squad"], _rifleman] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_weapons"], _matG] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_weapons"], _matA] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_weapons"], _mmgg] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_infantry", "lmf_equipment_weapons"], _mmga] call ace_interact_menu_fnc_addActionToObject;

	// Ground vehicle crew
	private _vehPltCmd = ["lmf_equipment_vehiclePlatoonLeader", _crewLeader#1, "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa", {[player] call lmf_equipment_fnc_applyVehiclePlatoonLeader}, {true}] call ace_interact_menu_fnc_createAction;
	private _vehCommander = ["lmf_equipment_vehicleCommander", _crewSgt#1, "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa", {[player] call lmf_equipment_fnc_applyVehicleCommander}, {true}] call ace_interact_menu_fnc_createAction;
	private _vehDriver = ["lmf_equipment_vehicleCrew", _crew#1, "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa", {[player] call lmf_equipment_fnc_applyVehicleCrew}, {true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_groundCrew"], _vehPltCmd] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_groundCrew"], _vehCommander] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_groundCrew"], _vehDriver] call ace_interact_menu_fnc_addActionToObject;

	// Air vehicle crew
	private _heli = ["lmf_equipment_helicopterPilot", _heloPilot#1, "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa", {[player] call lmf_equipment_fnc_applyHelicopterPilot}, {true}] call ace_interact_menu_fnc_createAction;
	private _heliCrew = ["lmf_equipment_helicopterCrew", _heloCrew#1, "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa", {[player] call lmf_equipment_fnc_applyHelicopterCrew}, {true}] call ace_interact_menu_fnc_createAction;
	private _fighter = ["lmf_equipment_pilot", _pilot#1, "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa", {[player] call lmf_equipment_fnc_applyPilot}, {true}] call ace_interact_menu_fnc_createAction;

	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_airCrew"], _heli] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_airCrew"], _heliCrew] call ace_interact_menu_fnc_addActionToObject;
	[crateRoles, 0, ["ACE_MainActions", "lmf_equipment_airCrew"], _fighter] call ace_interact_menu_fnc_addActionToObject;
};
