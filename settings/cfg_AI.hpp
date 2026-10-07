/*
	AI settings
	Defines enemy AI equipment, vehicles and infantry classes used throughout LMF.
	Add several classnames to a pool to randomize the selection.
	Leave an ammo pool empty to let LMF select a compatible magazine automatically.
	Weapon variants with built-in attachments are supported.
	Vehicle identifiers correspond to the type names used by LMF spawning functions.
	If _enemyGear is false, only the vehicle and unit classname sections need to be configured.
*/

// General settings
private _enemyGear = true; // Applies custom AI gear.
private _enemySkill = 1; // Skill preset: 0 = untrained, 1 = regular, 2 = elite.

// Clothing
private _uniform = ["U_O_V_Soldier_Viper_F"];
private _vest = ["V_HarnessO_ghex_F", "V_HarnessOGL_ghex_F"];
private _headgear = ["rhs_altyn_novisor", "rhs_altyn_novisor_bala", "rhs_altyn_novisor_ess", "rhs_altyn_novisor_ess_bala"];
private _goggles = [];

private _backpackLight = ["B_FieldPack_ghex_F"];
private _backpackHeavy = ["B_Carryall_ghex_F"]; // Used by autoriflemen, MMG, MAT and AA
private _backpackMedic = ["B_ViperLightHarness_ghex_F"];

// Helicopter crew and pilots (pilots receive no backpack)
private _heliUniform = ["U_O_V_Soldier_Viper_F"];
private _heliVest = ["V_BandollierB_ghex_F"];
private _heliHeadgear = ["H_PilotHelmetHeli_O"];

// Vehicle crew
private _crewUniform = ["U_O_V_Soldier_Viper_F"];
private _crewVest = ["V_BandollierB_ghex_F"];
private _crewHeadgear = ["H_HelmetCrew_O_ghex_F"];

// Weapons
private _pistol = ["rhs_weap_pya"];
private _pistolAmmo = [];

private _carbine = ["rhs_weap_aks74u"];
private _carbineOptic = [];
private _carbineAmmo = [];

private _rifle = ["rhs_weap_ak74m"];
private _rifleOptic = ["rhs_acc_pkas"];
private _rifleAmmo = [];

private _rifleGl = ["rhs_weap_ak74m_gp25"];
private _rifleGlOptic = ["rhs_acc_pkas"];
private _rifleGlAmmo = [];
private _rifleGlUgl = ["CUP_IlumFlareGreen_GP25_M", "CUP_1Rnd_HE_GP25_M"]; // Required for UGL ammunition

private _dmr = ["rhs_weap_ak74m"];
private _dmrOptic = ["rhs_acc_pkas"];
private _dmrAmmo = [];

private _lmg = ["rhs_weap_pkp"];
private _lmgOptic = [];
private _lmgAmmo = ["rhs_100Rnd_762x54mmR_green"];

private _mmg = ["rhs_weap_pkp"];
private _mmgOptic = [];
private _mmgAmmo = ["rhs_100Rnd_762x54mmR_green"];

private _lat = ["CUP_launch_RPG26_Loaded"];
private _latAmmo = [];

private _mat = ["rhs_weap_rpg7"]; // Leave empty to give MAT gunners a rifle instead
private _matAmmo = ["CUP_PG7V_M"];

private _aa = ["rhs_weap_rpg7"];
private _aaAmmo = ["CUP_PG7V_M"];

private _grenade = ["MiniGrenade"];
private _grenadeSmoke = ["SmokeShell", "SmokeShellOrange"];
private _attach = ["rhs_acc_perst1ik"];
private _nvg = ["NVGoggles_OPFOR"];

// Vehicles (leave camo pools empty if no camo should be applied)
// Car
private _car = ["CUP_O_Tigr_M_233114_CSAT_T"];
private _carCamo = [];

// Armed car
private _carArmed = ["CUP_O_Tigr_M_233114_PK_CSAT_T", "CUP_O_Tigr_M_233114_PK_CSAT_T", "CUP_O_Tigr_M_233114_PK_CSAT_T", "CUP_O_Tigr_M_233114_KORD_CSAT_T"];
private _carArmedCamo = [];

// Truck
private _truck = ["O_T_Truck_02_F"];
private _truckCamo = [];

// APC
private _apc = ["CUP_O_BTR80_CSAT_T"];
private _apcCamo = [];

// Tank
private _tank = ["CUP_O_BMP1P_CSAT_T", "CUP_O_T72_CSAT_T"];
private _tankCamo = [];

// Transport helicopter
private _heliTransport = ["O_Heli_Light_02_unarmed_F"];
private _heliTransportCamo = [];

// Attack helicopter
private _heliAttack = ["CUP_O_Mi24_Mk3_CSAT_T"];
private _heliAttackCamo = [];

private _paraVehicle = ["CUP_O_C130J_TKA"]; // Aircraft used by spawnParadropQrf

// Boat
private _boat = ["O_T_Boat_Armed_01_hmg_F"];
private _boatCamo = [];

// UAV
private _uav = ["O_UAV_01_F"];

// Miscellaneous
private _flag = ""; // Path to flag texture
private _ammoBlacklist = []; // Banned vehicle ammo

// Unit classnames (define the active enemy faction; do not duplicate classnames)
private _autorifleman = "CUP_O_RU_Soldier_AR_EMR";
private _crew = "CUP_O_RU_Crew_EMR";
private _grenadier = "CUP_O_RU_Soldier_GL_EMR";
private _mmgGunner = "CUP_O_RU_Soldier_MG_EMR";
private _marksman = "CUP_O_RU_Soldier_Marksman_EMR";
private _aaGunner = "CUP_O_RU_Soldier_AA_EMR";
private _matGunner = "CUP_O_RU_Soldier_HAT_EMR";
private _officer = "CUP_O_RU_Officer_EMR";
private _pilot = "CUP_O_RU_Pilot_EMR";
private _rifleman = "CUP_O_RU_Soldier_EMR";
private _riflemanAt = "CUP_O_RU_Soldier_LAT_EMR";
private _squadLeader = "CUP_O_RU_Soldier_SL_EMR";
private _medic = "CUP_O_RU_Medic_EMR";
