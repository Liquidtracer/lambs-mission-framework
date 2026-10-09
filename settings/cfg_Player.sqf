/*
	Player equipment settings
	Defines player equipment, also used in configured vehicles and supply crates.

	Only required when custom player gear is enabled.
*/

// Radios
private _radioB = "ACRE_PRC148";
private _radioL = "ACRE_PRC148";
private _radioR = "ACRE_PRC343";

private _availableOptics = ["JCA_optic_MRCS_black"]; // Available during warmup (ACE self-interaction)

// --- Infantry roles ---------------------------------------------------------------------------
// Clothing arrays set to [""] inherit the rifleman configuration.

// Weapon keys: FLARE_GUN, PISTOL, SMG, CARBINE, RIFLE, RIFLE_GL,
// DMR, LMG, MMG, LAT, MAT.

// Rifleman
private _rUniform = ["LAMBS_U_CombatUniformB_full"];
private _rVest = ["LAMBS_CarrierRigKBT_01_light_Brown_F"];
private _rHeadgear = ["CUP_H_OpsCore_Black", "CUP_H_OpsCore_Black_NoHS", "CUP_H_OpsCore_Black_SF", "CUP_H_OpsCore_Grey", "CUP_H_OpsCore_Grey_NoHS", "CUP_H_OpsCore_Grey_SF"];
private _rGoggles = ["G_Balaclava_TI_blk_F"];
private _rBackpack = ["B_AssaultPack_blk"];
private _rWeapon = "RIFLE";

// Platoon commander
private _plUniform = [""];
private _plVest = [""];
private _plHeadgear = [""];
private _plGoggles = [""];
private _plBackpack = ["B_RadioBag_01_black_F"];
private _plWeapon = "RIFLE";

// Platoon sergeant
private _psgUniform = [""];
private _psgVest = [""];
private _psgHeadgear = [""];
private _psgGoggles = [""];
private _psgBackpack = ["B_RadioBag_01_black_F"];
private _psgWeapon = "RIFLE";

// Medic
private _medUniform = [""];
private _medVest = [""];
private _medHeadgear = [""];
private _medGoggles = [""];
private _medBackpack = ["B_Messenger_Black_F"];
private _medWeapon = "RIFLE";

// Squad leader
private _slUniform = [""];
private _slVest = [""];
private _slHeadgear = [""];
private _slGoggles = [""];
private _slBackpack = ["B_RadioBag_01_black_F"];
private _slWeapon = "RIFLE_GL";

// Team leader
private _tlUniform = [""];
private _tlVest = [""];
private _tlHeadgear = [""];
private _tlGoggles = [""];
private _tlBackpack = ["B_RadioBag_01_black_F"];
private _tlWeapon = "RIFLE";

// Autorifleman
private _arUniform = [""];
private _arVest = [""];
private _arHeadgear = [""];
private _arGoggles = [""];
private _arBackpack = ["B_FieldPack_blk"];
private _arWeapon = "LMG";

// AT specialist
private _atUniform = [""];
private _atVest = [""];
private _atHeadgear = [""];
private _atGoggles = [""];
private _atBackpack = ["B_Carryall_blk"];
private _atWeapon = "RIFLE";

// AT assistant
private _ataUniform = [""];
private _ataVest = [""];
private _ataHeadgear = [""];
private _ataGoggles = [""];
private _ataBackpack = ["B_Carryall_blk"];
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
private _mgBackpack = ["B_FieldPack_blk"];
private _mgWeapon = "MMG";

// Assistant machine gunner
private _mgaUniform = [""];
private _mgaVest = [""];
private _mgaHeadgear = [""];
private _mgaGoggles = [""];
private _mgaBackpack = ["B_FieldPack_blk"];
private _mgaWeapon = "RIFLE";

// RTO
private _rtoUniform = [""];
private _rtoVest = [""];
private _rtoHeadgear = [""];
private _rtoGoggles = [""];
private _rtoBackpack = ["B_RadioBag_01_black_F"];
private _rtoWeapon = "RIFLE";

// JTAC
private _jtacUniform = [""];
private _jtacVest = [""];
private _jtacHeadgear = [""];
private _jtacGoggles = [""];
private _jtacBackpack = ["B_RadioBag_01_black_F"];
private _jtacWeapon = "RIFLE_GL";

// --- Aircrew roles ----------------------------------------------------------------------------------
// Helicopter pilot
private _hpUniform = ["U_I_HeliPilotCoveralls"];
private _hpVest = ["V_TacVest_oli"];
private _hpHeadgear = ["H_PilotHelmetHeli_I"];
private _hpGoggles = ["G_Aviator"];
private _hpBackpack = ["B_AssaultPack_khk"];
private _hpWeapon = "SMG";

// Helicopter crew
private _hcUniform = [""];
private _hcVest = [""];
private _hcHeadgear = [""];
private _hcGoggles = [""];
private _hcBackpack = [""];
private _hcWeapon = "SMG";

// Plane pilot
private _pUniform = [""];
private _pVest = [""];
private _pHeadgear = [""];
private _pGoggles = [""];
private _pBackpack = [""];
private _pWeapon = "SMG";

// --- Ground vehicle roles ---------------------------------------------------------------------------
// Vehicle platoon leader
private _vplUniform = [""];
private _vplVest = ["V_BandollierB_oli"];
private _vplHeadgear = ["H_HelmetCrew_I"];
private _vplGoggles = [""];
private _vplBackpack = [""];
private _vplWeapon = "SMG";

// Vehicle platoon sergeant / vehicle commander
private _vpsgUniform = [""];
private _vpsgVest = [""];
private _vpsgHeadgear = [""];
private _vpsgGoggles = [""];
private _vpsgBackpack = [""];
private _vpsgWeapon = "SMG";

// Vehicle crew
private _vcUniform = [""];
private _vcVest = [""];
private _vcHeadgear = [""];
private _vcGoggles = [""];
private _vcBackpack = [""];
private _vcWeapon = "SMG";

// --- Weapons ----------------------------------------------------------------------------------------
// Flare gun (FLARE_GUN)
private _flareGun = "CUP_hgun_FlareGun";
private _flareGunAmmo = "";

// Pistol (PISTOL)
private _pistol = ["CUP_hgun_FlareGun"];
private _pistolAmmo = ["CUP_IllumFlareRed_265_M", "CUP_IllumFlareGreen_265_M"];
private _pistolAttach1 = [""];
private _pistolAttach2 = [""];

// SMG (SMG)
private _smg = ["SMG_03C_black"];
private _smgAmmo = ["50Rnd_570x28_SMG_03"];
private _smgOptic = [""];
private _smgAttach1 = [""];
private _smgAttach2 = [""];
private _smgBipod = [""];

// Carbine (CARBINE)
private _carbine = [""];
private _carbineAmmo = [""];
private _carbineAmmoT = [""];
private _carbineOptic = [""];
private _carbineAttach1 = [""];
private _carbineAttach2 = [""];
private _carbineBipod = [""];

// Rifle (RIFLE)
private _rifle = ["CUP_arifle_Mk17_CQC_Black", "CUP_arifle_Mk17_CQC_AFG_black", "CUP_arifle_Mk17_CQC_FG_black"];
private _rifleAmmo = ["CUP_30Rnd_762x51_2_B_SCAR"];
private _rifleAmmoT = ["CUP_30Rnd_TE1_Red_Tracer_762x51_1_SCAR"];
private _rifleOptic = _availableOptics;
private _rifleAttach1 = ["acc_pointer_IR"];
private _rifleAttach2 = ["JCA_muzzle_snds_762_tactical_black"];
private _rifleBipod = [""];

// Rifle GL (RIFLE_GL)
private _rifleGl = ["CUP_arifle_Mk17_CQC_EGLM_black"];
private _rifleGlAmmo = ["CUP_30Rnd_762x51_2_B_SCAR"];
private _rifleGlAmmoT = ["CUP_30Rnd_TE1_Red_Tracer_762x51_1_SCAR"];
private _rifleGlUgl1 = ["ACE_40mm_Flare_red"];
private _rifleGlUgl2 = ["1Rnd_HE_Grenade_shell"];
private _rifleGlUgl3 = ["ACE_40mm_Flare_red"];
private _rifleGlUgl4 = ["1Rnd_HE_Grenade_shell"];
private _rifleGlOptic = _availableOptics;
private _rifleGlAttach1 = ["acc_pointer_IR"];
private _rifleGlAttach2 = ["JCA_muzzle_snds_762_tactical_black"];
private _rifleGlBipod = [""];

// DMR (DMR)
private _dmr = [""];
private _dmrAmmo = [""];
private _dmrOptic = [""];
private _dmrAttach1 = [""];
private _dmrAttach2 = [""];
private _dmrBipod = [""];

// Light machine gun (LMG)
private _lmg = ["CUP_lmg_Mk48"];
private _lmgAmmo = ["CUP_100Rnd_TE4_LRT4_Red_Tracer_762x51_Belt_M"];
private _lmgAmmoT = ["CUP_100Rnd_TE4_LRT4_Red_Tracer_762x51_Belt_M"];
private _lmgOptic = _availableOptics;
private _lmgAttach1 = ["acc_pointer_IR"];
private _lmgAttach2 = [""];
private _lmgBipod = [""];

// Medium machine gun (MMG)
private _mmg = [""];
private _mmgAmmo = [""];
private _mmgOptic = [""];
private _mmgAttach1 = [""];
private _mmgAttach2 = [""];
private _mmgBipod = [""];

// Light anti-tank
private _lat = [""];
private _latAmmo = [""];

// Medium anti-tank
private _mat = [""];
private _matAmmo = [""];
private _matOptic = [""];

// Grenades and explosives
private _grenade = ["HandGrenade"];
private _grenadeSmoke = ["SmokeShell"];
private _grenadeSmokeClr = ["SmokeShellGreen"];

// Miscellaneous
private _binocular = "ACE_Vector";
private _nvg = "ACE_NVG_Gen4_Black";
private _nvgPilot = "ACE_NVG_Gen4_Green";

// --- Role definitions (do not use the same classname twice) -----------------------------------------
private _antiTankGunner = ["B_Soldier_AT_F", "AT Specialist", "CORPORAL"];
private _antiTankAssistant = ["B_Soldier_AAT_F", "AT Assistant", "PRIVATE"];
private _autorifleman = ["B_Soldier_AR_F", "Automatic Rifleman", "CORPORAL"];
private _crewLeader = ["B_soldier_repair_F", "Vehicle Platoon Commander", "LIEUTENANT"];
private _crewSgt = ["B_engineer_F", "Vehicle Commander", "SERGEANT"];
private _crew = ["B_crew_F", "Vehicle Crew", "PRIVATE"];
private _grenadier = ["B_Soldier_GL_F", "Grenadier", "PRIVATE"];
private _heloCrew = ["B_helicrew_F", "Helicopter Crew", "CORPORAL"];
private _heloPilot = ["B_helipilot_F", "Helicopter Pilot", "LIEUTENANT"];
private _jtac = ["B_support_GMG_F", "JTAC", "SERGEANT"];
private _machineGunner = ["B_HeavyGunner_F", "Machine Gunner", "CORPORAL"];
private _machineGunnerAssistant = ["B_support_AMG_F", "Assistant Machine Gunner", "PRIVATE"];
private _medic = ["B_medic_F", "Medic", "CORPORAL"];
private _pilot = ["B_Pilot_F", "Pilot", "LIEUTENANT"];
private _platoonLeader = ["B_officer_F", "Platoon Commander", "LIEUTENANT"];
private _platoonSgt = ["B_Soldier_lite_F", "Platoon Sergeant", "SERGEANT"];
private _rifleman = ["B_Soldier_LAT_F", "Rifleman", "PRIVATE"];
private _rto = ["B_support_MG_F", "RTO", "PRIVATE"];
private _squadLeader = ["B_Soldier_SL_F", "Squad Leader", "SERGEANT"];
private _teamLeader = ["B_Soldier_TL_F", "Assistant Squad Leader", "CORPORAL"];