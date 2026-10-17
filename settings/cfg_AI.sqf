/*
	AI settings
	Defines enemy AI equipment, vehicles and infantry classes used throughout LMF.
	Add several classnames to a pool to randomize the selection.
	Leave an ammo pool empty to let LMF select a compatible magazine automatically.
	Weapon variants with built-in attachments are supported.
	Vehicle identifiers correspond to the type names used by LMF spawning functions.
	Setting _enemyGear to false disables custom soldier loadouts; other AI settings still apply.
*/

// General settings
private _enemyGear = true; // Applies custom AI gear.
private _enemySkill = 1; // Skill preset: 0 = untrained, 1 = regular, 2 = elite.

// Clothing
private _uniform = ["U_O_CombatUniform_ocamo", "U_O_SpecopsUniform_ocamo"];
private _vest = ["V_HarnessO_brn", "V_HarnessOGL_brn", "V_TacVest_khk"];
private _headgear = ["H_HelmetO_ocamo", "H_HelmetLeaderO_ocamo"];
private _goggles = ["G_Balaclava_oli", "G_Combat"];

private _backpackLight = ["B_FieldPack_ocamo", "B_FieldPack_cbr"];
private _backpackHeavy = ["B_Carryall_ocamo"]; // Used by autoriflemen, MMG, MAT and AA
private _backpackMedic = ["B_FieldPack_ocamo"];

// Helicopter crew and pilots (pilots receive no backpack)
private _heliUniform = ["U_O_PilotCoveralls"];
private _heliVest = ["V_TacVest_khk"];
private _heliHeadgear = ["H_PilotHelmetHeli_O"];

// Vehicle crew
private _crewUniform = ["U_O_SpecopsUniform_ocamo"];
private _crewVest = ["V_BandollierB_khk"];
private _crewHeadgear = ["H_HelmetCrew_O"];

// Weapons
private _pistol = ["hgun_Rook40_F"];
private _pistolAmmo = ["16Rnd_9x21_Mag"];

private _carbine = ["arifle_Katiba_C_F"];
private _carbineOptic = ["optic_ACO_grn"];
private _carbineAmmo = ["30Rnd_65x39_caseless_green"];

private _rifle = ["arifle_Katiba_F"];
private _rifleOptic = ["optic_Arco", "optic_ACO_grn"];
private _rifleAmmo = ["30Rnd_65x39_caseless_green"];

private _rifleGl = ["arifle_Katiba_GL_F"];
private _rifleGlOptic = ["optic_Arco", "optic_ACO_grn"];
private _rifleGlAmmo = ["30Rnd_65x39_caseless_green"];
private _rifleGlUgl = ["1Rnd_HE_Grenade_shell", "1Rnd_Smoke_Grenade_shell"]; // Required for UGL ammunition

private _dmr = ["srifle_DMR_01_F"];
private _dmrOptic = ["optic_DMS"];
private _dmrAmmo = ["10Rnd_762x54_Mag"];

private _lmg = ["LMG_Zafir_F"];
private _lmgOptic = ["optic_Arco"];
private _lmgAmmo = ["150Rnd_762x54_Box"];

private _mmg = ["MMG_01_hex_F"];
private _mmgOptic = ["optic_Arco"];
private _mmgAmmo = ["150Rnd_93x64_Mag"];

private _lat = ["launch_RPG32_F"];
private _latAmmo = ["RPG32_F"];

private _mat = ["launch_O_Titan_short_F"]; // Leave empty to give MAT gunners a rifle instead
private _matAmmo = ["Titan_AT"];

private _aa = ["launch_O_Titan_F"];
private _aaAmmo = ["Titan_AA"];

private _grenade = ["HandGrenade"];
private _grenadeSmoke = ["SmokeShell", "SmokeShellRed"];
private _attach = ["acc_pointer_IR"];
private _nvg = ["NVGoggles_OPFOR"];

// Vehicles (leave camo pools empty if no camo should be applied)
// Car
private _car = ["O_MRAP_02_F"];
private _carCamo = [];

// Armed car
private _carArmed = ["O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F"];
private _carArmedCamo = [];

// Truck
private _truck = ["O_Truck_02_transport_F", "O_Truck_02_covered_F"];
private _truckCamo = [];

// APC
private _apc = ["O_APC_Wheeled_02_rcws_v2_F", "O_APC_Tracked_02_cannon_F"];
private _apcCamo = [];

// Tank
private _tank = ["O_MBT_02_cannon_F"];
private _tankCamo = [];

// Transport helicopter
private _heliTransport = ["O_Heli_Light_02_unarmed_F"];
private _heliTransportCamo = [];

// Attack helicopter
private _heliAttack = ["O_Heli_Attack_02_dynamicLoadout_F"];
private _heliAttackCamo = [];

private _paraVehicle = ["O_T_VTOL_02_infantry_dynamicLoadout_F"]; // Aircraft used by spawnParadropQrf

// Boat
private _boat = ["O_Boat_Armed_01_hmg_F"];
private _boatCamo = [];

// Drones
private _drones = ["O_UGV_01_rcws_F"]; // UAVs and UGVs used by DRONE QRF.

// Miscellaneous
private _flag = ""; // Path to flag texture
private _ammoBlacklist = []; // Banned vehicle ammo

// Unit classnames (define the active enemy faction; do not duplicate classnames)
private _autorifleman = "O_Soldier_AR_F";
private _crew = "O_crew_F";
private _grenadier = "O_Soldier_GL_F";
private _mmgGunner = "O_Soldier_AAR_F";
private _marksman = "O_soldier_M_F";
private _aaGunner = "O_Soldier_AA_F";
private _matGunner = "O_Soldier_AT_F";
private _officer = "O_officer_F";
private _pilot = "O_helipilot_F";
private _rifleman = "O_Soldier_F";
private _riflemanAt = "O_Soldier_LAT_F";
private _squadLeader = "O_Soldier_SL_F";
private _medic = "O_medic_F";
