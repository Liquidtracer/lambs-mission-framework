/*
	Player equipment settings
	Defines player equipment, also used in configured vehicles and supply crates.

	Loaded at startup when lmf_playerGear = true, or lazily for explicit equipment operations when lmf_playerGear = false.
*/

// Radios
private _radioB = "ACRE_PRC148";
private _radioL = "ACRE_PRC148";
private _radioR = "ACRE_PRC343";

// --- Infantry roles ---------------------------------------------------------------------------
// Clothing arrays set to [""] inherit the rifleman configuration.

// Weapon keys: FLARE_GUN, PISTOL, SMG, CARBINE, RIFLE, RIFLE_GL,
// DMR, LMG, MMG, LAT, MAT.

// Rifleman
private _rUniform = ["LAMBS_U_CombatUniformMC", "LAMBS_U_CombatUniformMC_shortsleeve"];
private _rVest = ["LAMBS_V_PlateCarrier2_brn", "LAMBS_V_PlateCarrier2_grn", "V_PlateCarrier2_rgr", "V_PlateCarrier2_wdl", "V_PlateCarrier2_blk"];
private _rHeadgear = ["LAMBS_H_HelmetSpecB_brn", "LAMBS_H_HelmetSpecB_gry", "LAMBS_H_HelmetSpecB_grn"];
private _rGoggles = ["G_Combat", "G_Lowprofile", "G_Tactical_Clear", "G_Tactical_Black", "G_Shades_Black", "G_Spectacles_Tinted"];
private _rBackpack = ["LAMBS_B_AssaultPack_mtp"];
private _rWeapon = "RIFLE";

// Platoon commander
private _plUniform = [""];
private _plVest = [""];
private _plHeadgear = [""];
private _plGoggles = [""];
private _plBackpack = ["B_RadioBag_01_mtp_F"];
private _plWeapon = "RIFLE";

// Platoon sergeant
private _psgUniform = [""];
private _psgVest = [""];
private _psgHeadgear = [""];
private _psgGoggles = [""];
private _psgBackpack = ["B_RadioBag_01_mtp_F"];
private _psgWeapon = "RIFLE";

// Medic
private _medUniform = [""];
private _medVest = [""];
private _medHeadgear = [""];
private _medGoggles = [""];
private _medBackpack = ["LAMBS_B_Kitbag_mtp_medic"];
private _medWeapon = "RIFLE";

// Squad leader
private _slUniform = [""];
private _slVest = [""];
private _slHeadgear = [""];
private _slGoggles = [""];
private _slBackpack = ["B_RadioBag_01_mtp_F"];
private _slWeapon = "RIFLE_GL";

// Team leader
private _tlUniform = [""];
private _tlVest = [""];
private _tlHeadgear = [""];
private _tlGoggles = [""];
private _tlBackpack = ["B_RadioBag_01_mtp_F"];
private _tlWeapon = "RIFLE";

// Autorifleman
private _arUniform = [""];
private _arVest = [""];
private _arHeadgear = [""];
private _arGoggles = [""];
private _arBackpack = ["LAMBS_B_Kitbag_mtp"];
private _arWeapon = "LMG";

// AT specialist
private _atUniform = [""];
private _atVest = [""];
private _atHeadgear = [""];
private _atGoggles = [""];
private _atBackpack = ["LAMBS_B_Carryall_mtp"];
private _atWeapon = "RIFLE";

// AT assistant
private _ataUniform = [""];
private _ataVest = [""];
private _ataHeadgear = [""];
private _ataGoggles = [""];
private _ataBackpack = ["LAMBS_B_Carryall_mtp"];
private _ataWeapon = "RIFLE";

// Grenadier
private _gUniform = [""];
private _gVest = [""];
private _gHeadgear = [""];
private _gGoggles = [""];
private _gBackpack = [""];
private _gWeapon = "RIFLE_GL";

// Machine gunner
private _mgUniform = [""];
private _mgVest = [""];
private _mgHeadgear = [""];
private _mgGoggles = [""];
private _mgBackpack = ["LAMBS_B_Carryall_mtp"];
private _mgWeapon = "MMG";

// Assistant machine gunner
private _mgaUniform = [""];
private _mgaVest = [""];
private _mgaHeadgear = [""];
private _mgaGoggles = [""];
private _mgaBackpack = ["LAMBS_B_Carryall_mtp"];
private _mgaWeapon = "RIFLE";

// RTO
private _rtoUniform = [""];
private _rtoVest = [""];
private _rtoHeadgear = [""];
private _rtoGoggles = [""];
private _rtoBackpack = ["B_RadioBag_01_mtp_F"];
private _rtoWeapon = "RIFLE";

// JTAC
private _jtacUniform = [""];
private _jtacVest = [""];
private _jtacHeadgear = [""];
private _jtacGoggles = [""];
private _jtacBackpack = ["B_RadioBag_01_mtp_F"];
private _jtacWeapon = "RIFLE";

// --- Aircrew roles ----------------------------------------------------------------------------------
// Helicopter pilot
private _hpUniform = ["LAMBS_B_HeliPilotCoveralls"];
private _hpVest = ["V_TacVest_oli"];
private _hpHeadgear = ["H_PilotHelmetHeli_B"];
private _hpGoggles = ["G_Aviator"];
private _hpBackpack = ["LAMBS_B_AssaultPack_m98"];
private _hpWeapon = "SMG";

// Helicopter crew
private _hcUniform = ["LAMBS_B_HeliPilotCoveralls"];
private _hcVest = ["V_TacVest_oli"];
private _hcHeadgear = ["H_CrewHelmetHeli_B"];
private _hcGoggles = ["G_Aviator"];
private _hcBackpack = ["LAMBS_B_AssaultPack_m98"];
private _hcWeapon = "SMG";

// Plane pilot
private _pUniform = ["U_B_PilotCoveralls"];
private _pVest = ["V_TacVest_blk"];
private _pHeadgear = ["H_PilotHelmetFighter_B"];
private _pGoggles = ["G_Aviator"];
private _pBackpack = ["B_AssaultPack_blk"];
private _pWeapon = "SMG";

// --- Ground vehicle roles ---------------------------------------------------------------------------
// Commander and crew clothing set to [""] inherits the vehicle platoon leader, which falls back to Rifleman.
// Vehicle platoon leader
private _vplUniform = [""];
private _vplVest = ["LAMBS_CarrierRigKBT_01_Brown_F", "LAMBS_CarrierRigKBT_01_Green_F"];
private _vplHeadgear = ["H_HelmetCrew_B"];
private _vplGoggles = [""];
private _vplBackpack = ["B_AssaultPack_blk"];
private _vplWeapon = "SMG";

// Vehicle platoon sergeant / vehicle commander
private _vpsgUniform = [""];
private _vpsgVest = [""];
private _vpsgHeadgear = [""];
private _vpsgGoggles = [""];
private _vpsgBackpack = [""];
private _vpsgWeapon = _vplWeapon; // Use the platoon leader's category, or set an explicit weapon key.

// Vehicle crew
private _vcUniform = [""];
private _vcVest = [""];
private _vcHeadgear = [""];
private _vcGoggles = [""];
private _vcBackpack = [""];
private _vcWeapon = _vplWeapon; // Use the platoon leader's category, or set an explicit weapon key.

// --- Weapons ----------------------------------------------------------------------------------------
// Flare gun (FLARE_GUN)
private _flareGun = "hgun_Pistol_Signal_F";
private _flareGunAmmo = "6Rnd_GreenSignal_F";

// Pistol (PISTOL)
private _pistol = ["LAMBS_hgun_P07_blk_F"];
private _pistolAmmo = ["16Rnd_9x21_Mag"];
private _pistolAttach1 = [""];
private _pistolAttach2 = [""];

// SMG (SMG)
private _smg = ["SMG_02_F"];
private _smgAmmo = ["30Rnd_9x21_Mag_SMG_02"];
private _smgOptic = ["optic_Aco_smg", "optic_ACO_grn_smg"];
private _smgAttach1 = ["acc_pointer_IR"];
private _smgAttach2 = [""];
private _smgBipod = [""];

// Carbine (CARBINE)
private _carbine = ["LAMBS_arifle_Mk20C_black_F", "arifle_Mk20C_plain_F"];
private _carbineAmmo = ["30Rnd_556x45_Stanag"];
private _carbineAmmoT = ["30Rnd_556x45_Stanag_Tracer_Red"];
private _carbineOptic = ["optic_Aco", "optic_Holosight", "optic_MRCO"];
private _carbineAttach1 = ["acc_pointer_IR"];
private _carbineAttach2 = [""];
private _carbineBipod = [""];

// Rifle (RIFLE)
private _rifle = ["LAMBS_arifle_Mk20_black_F", "arifle_Mk20_plain_F"];
private _rifleAmmo = ["30Rnd_556x45_Stanag"];
private _rifleAmmoT = ["30Rnd_556x45_Stanag_Tracer_Red"];
private _rifleOptic = ["optic_Hamr", "optic_MRCO", "optic_Holosight_blk_F"];
private _rifleAttach1 = ["acc_pointer_IR"];
private _rifleAttach2 = [""];
private _rifleBipod = [""];

// Rifle GL (RIFLE_GL)
private _rifleGl = ["LAMBS_arifle_Mk20_GL_black_F", "arifle_Mk20_GL_plain_F"];
private _rifleGlAmmo = ["30Rnd_556x45_Stanag"];
private _rifleGlAmmoT = ["30Rnd_556x45_Stanag_Tracer_Red"];
private _rifleGlUgl1 = ["1Rnd_HE_Grenade_shell"];
private _rifleGlUgl2 = ["1Rnd_Smoke_Grenade_shell"];
private _rifleGlUgl3 = ["UGL_FlareGreen_F"];
private _rifleGlUgl4 = ["1Rnd_HE_Grenade_shell"];
private _rifleGlOptic = ["optic_Hamr", "optic_MRCO"];
private _rifleGlAttach1 = ["acc_pointer_IR"];
private _rifleGlAttach2 = [""];
private _rifleGlBipod = [""];

// DMR (DMR)
private _dmr = ["LAMBS_srifle_EBR_black_F"];
private _dmrAmmo = ["20Rnd_762x51_Mag"];
private _dmrOptic = ["optic_DMS", "optic_SOS", "optic_AMS"];
private _dmrAttach1 = ["acc_pointer_IR"];
private _dmrAttach2 = [""];
private _dmrBipod = ["bipod_01_F_blk", "bipod_01_F_snd", "bipod_01_F_mtp"];

// Light machine gun (LMG)
private _lmg = ["LAMBS_LMG_03_brn_F","LMG_03_F"];
private _lmgAmmo = ["200Rnd_556x45_Box_F"];
private _lmgAmmoT = ["200Rnd_556x45_Box_Tracer_F"];
private _lmgOptic = ["optic_Hamr", "optic_MRCO"];
private _lmgAttach1 = ["acc_pointer_IR"];
private _lmgAttach2 = [""];
private _lmgBipod = [""];

// Medium machine gun (MMG)
private _mmg = ["MMG_02_black_F"];
private _mmgAmmo = ["130Rnd_338_Mag"];
private _mmgOptic = ["optic_MRCO", "optic_DMS", "optic_Hamr"];
private _mmgAttach1 = ["acc_pointer_IR"];
private _mmgAttach2 = [""];
private _mmgBipod = ["bipod_01_F_blk", "bipod_01_F_snd", "bipod_01_F_mtp"];

// Light anti-tank
private _lat = [""];
private _latAmmo = [""];

// Medium anti-tank
private _mat = ["launch_MRAWS_sand_F"];
private _matAmmo = ["MRAWS_HEAT_F"];
private _matOptic = [""];

// Grenades and explosives
private _grenade = ["HandGrenade"];
private _grenadeSmoke = ["SmokeShell"];
private _grenadeSmokeClr = ["SmokeShellGreen"];

// Miscellaneous
private _binocular = "Rangefinder";
private _nvg = "NVGoggles";
private _nvgPilot = "NVGoggles";

// --- Role definitions (do not use the same classname twice) -----------------------------------------
private _antiTankGunner = ["B_soldier_AT_F", "AT Specialist", "CORPORAL"];
private _antiTankAssistant = ["B_soldier_AAT_F", "AT Assistant", "PRIVATE"];
private _autorifleman = ["B_soldier_AR_F", "Automatic Rifleman", "CORPORAL"];
private _crewLeader = ["B_soldier_repair_F", "Vehicle Platoon Commander", "LIEUTENANT"];
private _crewSgt = ["B_engineer_F", "Vehicle Commander", "SERGEANT"];
private _crew = ["B_crew_F", "Vehicle Crew", "PRIVATE"];
private _grenadier = ["B_Soldier_GL_F", "Grenadier", "PRIVATE"];
private _heloCrew = ["B_helicrew_F", "Helicopter Crew", "CORPORAL"];
private _heloPilot = ["B_Helipilot_F", "Helicopter Pilot", "LIEUTENANT"];
private _jtac = ["B_support_GMG_F", "JTAC", "SERGEANT"];
private _machineGunner = ["B_HeavyGunner_F", "Machine Gunner", "CORPORAL"];
private _machineGunnerAssistant = ["B_support_AMG_F", "Assistant Machine Gunner", "PRIVATE"];
private _medic = ["B_medic_F", "Medic", "CORPORAL"];
private _pilot = ["B_Pilot_F", "Pilot", "LIEUTENANT"];
private _platoonLeader = ["B_officer_F", "Platoon Commander", "LIEUTENANT"];
private _platoonSgt = ["B_Soldier_lite_F", "Platoon Sergeant", "SERGEANT"];
private _rifleman = ["B_soldier_LAT_F", "Rifleman", "PRIVATE"];
private _rto = ["B_support_MG_F", "RTO", "PRIVATE"];
private _squadLeader = ["B_Soldier_SL_F", "Squad Leader", "SERGEANT"];
private _teamLeader = ["B_Soldier_TL_F", "Assistant Squad Leader", "CORPORAL"];