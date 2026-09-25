/*
    AI configuration
    Loads mission AI settings once and exposes them to the internal LMF systems.
*/

#include "..\..\settings\cfg_AI.hpp"

private _clothing = createHashMapFromArray [
	["UNIFORM",_uniform],
	["VEST",_vest],
	["HEADGEAR",_headgear],
	["GOGGLES",_goggles],
	["BACKPACK_LIGHT",_backpackLight],
	["BACKPACK_HEAVY",_backpackHeavy],
	["BACKPACK_MEDIC",_backpackMedic],
	["HELI_UNIFORM",_heliUniform],
	["HELI_VEST",_heliVest],
	["HELI_HEADGEAR",_heliHeadgear],
	["CREW_UNIFORM",_crewUniform],
	["CREW_VEST",_crewVest],
	["CREW_HEADGEAR",_crewHeadgear]
];

private _weapons = createHashMapFromArray [
	["PISTOL",[_pistol,_pistolAmmo,[],[]]],
	["CARBINE",[_carbine,_carbineAmmo,_carbineOptic,[]]],
	["RIFLE",[_rifle,_rifleAmmo,_rifleOptic,_attach]],
	["RIFLE_GL",[_rifleGl,_rifleGlAmmo,_rifleGlOptic,_attach]],
	["DMR",[_dmr,_dmrAmmo,_dmrOptic,_attach]],
	["LMG",[_lmg,_lmgAmmo,_lmgOptic,_attach]],
	["MMG",[_mmg,_mmgAmmo,_mmgOptic,_attach]],
	["LAT",[_lat,_latAmmo,[],[]]],
	["MAT",[_mat,_matAmmo,[],[]]],
	["AA",[_aa,_aaAmmo,[],[]]]
];

private _vehicleDefinitions = [
	["CAR",_car],
	["CARARMED",_carArmed],
	["TRUCK",_truck],
	["APC",_apc],
	["TANK",_tank],
	["HELITRANSPORT",_heliTransport],
	["HELIATTACK",_heliAttack],
	["PARA_VEHICLE",_paraVehicle],
	["BOAT",_boat],
	["UAV",_uav]
];
private _vehicles = createHashMapFromArray _vehicleDefinitions;

private _camos = createHashMapFromArray [
	["CAR",_carCamo],
	["CARARMED",_carArmedCamo],
	["TRUCK",_truckCamo],
	["APC",_apcCamo],
	["TANK",_tankCamo],
	["HELITRANSPORT",_heliTransportCamo],
	["HELIATTACK",_heliAttackCamo],
	["BOAT",_boatCamo]
];

private _roleDefinitions = [
	["AUTORIFLEMAN",_autorifleman],
	["CREW",_crew],
	["GRENADIER",_grenadier],
	["MMG_GUNNER",_mmgGunner],
	["MARKSMAN",_marksman],
	["AA_GUNNER",_aaGunner],
	["MAT_GUNNER",_matGunner],
	["OFFICER",_officer],
	["PILOT",_pilot],
	["RIFLEMAN",_rifleman],
	["RIFLEMAN_AT",_riflemanAt],
	["SQUAD_LEADER",_squadLeader],
	["MEDIC",_medic]
];
private _roles = createHashMapFromArray _roleDefinitions;

private _roleByClass = createHashMap;
{
	_x params ["_roleKey","_class"];
	if (_class isNotEqualTo "") then {_roleByClass set [toLower _class,_roleKey]};
} forEach _roleDefinitions;

private _vehicleByClass = createHashMap;
{
	_x params ["_vehicleKey","_classes"];
	{if (_x isNotEqualTo "") then {_vehicleByClass set [toLower _x,_vehicleKey]}} forEach _classes;
} forEach _vehicleDefinitions;

lmf_ai_config = createHashMapFromArray [
	["CUSTOM_GEAR",_enemyGear],
	["SKILL",_enemySkill],
	["CLOTHING",_clothing],
	["WEAPONS",_weapons],
	["UGL",_rifleGlUgl],
	["GRENADES",_grenade],
	["SMOKE_GRENADES",_grenadeSmoke],
	["NVG",_nvg],
	["VEHICLES",_vehicles],
	["VEHICLE_BY_CLASS",_vehicleByClass],
	["CAMOS",_camos],
	["FLAG",_flag],
	["AMMO_BLACKLIST",_ammoBlacklist],
	["ROLES",_roles],
	["ROLE_BY_CLASS",_roleByClass]
];

lmf_ai_weaponCache = createHashMap;
