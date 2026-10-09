/*
	Player equipment configuration
	Builds the machine-local registry during preInit when custom player gear is enabled.
	Existing consumers still include cfg_Player directly. Treat registry pools as read-only.
*/

#include "..\..\settings\cfg_Player.sqf"

// Temporary conversion until cfg_Player uses string weapon keys.
private _weaponKeys = ["FLARE_GUN", "PISTOL", "SMG", "CARBINE", "RIFLE", "RIFLE_GL", "DMR", "LMG", "MMG", "LAT", "MAT"];

private _roleDefinitions = [
	["RIFLEMAN", _rifleman, _rWeapon, [_rUniform, _rVest, _rHeadgear, _rGoggles, _rBackpack]],
	["PLATOON_LEADER", _platoonLeader, _plWeapon, [_plUniform, _plVest, _plHeadgear, _plGoggles, _plBackpack]],
	["PLATOON_SERGEANT", _platoonSgt, _psgWeapon, [_psgUniform, _psgVest, _psgHeadgear, _psgGoggles, _psgBackpack]],
	["MEDIC", _medic, _medWeapon, [_medUniform, _medVest, _medHeadgear, _medGoggles, _medBackpack]],
	["SQUAD_LEADER", _squadLeader, _slWeapon, [_slUniform, _slVest, _slHeadgear, _slGoggles, _slBackpack]],
	["TEAM_LEADER", _teamLeader, _tlWeapon, [_tlUniform, _tlVest, _tlHeadgear, _tlGoggles, _tlBackpack]],
	["AUTORIFLEMAN", _autorifleman, _arWeapon, [_arUniform, _arVest, _arHeadgear, _arGoggles, _arBackpack]],
	["ANTI_TANK_GUNNER", _antiTankGunner, _atWeapon, [_atUniform, _atVest, _atHeadgear, _atGoggles, _atBackpack]],
	["ANTI_TANK_ASSISTANT", _antiTankAssistant, _ataWeapon, [_ataUniform, _ataVest, _ataHeadgear, _ataGoggles, _ataBackpack]],
	["GRENADIER", _grenadier, _gWeapon, [_gUniform, _gVest, _gHeadgear, _gGoggles, _gBackpack]],
	["MACHINE_GUNNER", _machineGunner, _mgWeapon, [_mgUniform, _mgVest, _mgHeadgear, _mgGoggles, _mgBackpack]],
	["MACHINE_GUNNER_ASSISTANT", _machineGunnerAssistant, _mgaWeapon, [_mgaUniform, _mgaVest, _mgaHeadgear, _mgaGoggles, _mgaBackpack]],
	["RTO", _rto, _rtoWeapon, [_rtoUniform, _rtoVest, _rtoHeadgear, _rtoGoggles, _rtoBackpack]],
	["JTAC", _jtac, _jtacWeapon, [_jtacUniform, _jtacVest, _jtacHeadgear, _jtacGoggles, _jtacBackpack]],
	["HELICOPTER_PILOT", _heloPilot, _hpWeapon, [_hpUniform, _hpVest, _hpHeadgear, _hpGoggles, _hpBackpack]],
	["HELICOPTER_CREW", _heloCrew, _hcWeapon, [_hcUniform, _hcVest, _hcHeadgear, _hcGoggles, _hcBackpack]],
	["PILOT", _pilot, _pWeapon, [_pUniform, _pVest, _pHeadgear, _pGoggles, _pBackpack]],
	["VEHICLE_PLATOON_LEADER", _crewLeader, _vplWeapon, [_vplUniform, _vplVest, _vplHeadgear, _vplGoggles, _vplBackpack]],
	["VEHICLE_COMMANDER", _crewSgt, _vpsgWeapon, [_vpsgUniform, _vpsgVest, _vpsgHeadgear, _vpsgGoggles, _vpsgBackpack]],
	["VEHICLE_CREW", _crew, _vcWeapon, [_vcUniform, _vcVest, _vcHeadgear, _vcGoggles, _vcBackpack]]
];
private _clothingKeys = ["UNIFORM", "VEST", "HEADGEAR", "GOGGLES", "BACKPACK"];
private _riflemanClothing = [_rUniform, _rVest, _rHeadgear, _rGoggles, _rBackpack];
private _roles = createHashMap;
private _roleByClass = createHashMap;
{
	_x params ["_roleKey", "_definition", "_weaponId", "_clothingPools"];
	_definition params ["_class", "_displayName", "_rank"];
	private _clothing = createHashMap;
	{
		private _pool = _x;
		// Only the exact sentinel inherits; empty and mixed pools remain unchanged.
		if (_pool isEqualTo [""]) then {_pool = _riflemanClothing select _forEachIndex};
		_clothing set [_clothingKeys select _forEachIndex, _pool];
	} forEach _clothingPools;
	_roles set [_roleKey, createHashMapFromArray [
		["CLASS", _class],
		["DISPLAY_NAME", _displayName],
		["RANK", _rank],
		["WEAPON", _weaponKeys select _weaponId],
		["CLOTHING", _clothing]
	]];
	if (_class isNotEqualTo "") then {_roleByClass set [toLower _class, _roleKey]};
} forEach _roleDefinitions;

private _weapons = createHashMapFromArray [
	["FLARE_GUN", createHashMapFromArray [
		["CLASSES", [_flareGun]],
		["AMMO", [_flareGunAmmo]]
	]],
	["PISTOL", createHashMapFromArray [
		["CLASSES", _pistol],
		["AMMO", _pistolAmmo],
		["ATTACHMENTS_1", _pistolAttach1],
		["ATTACHMENTS_2", _pistolAttach2]
	]],
	["SMG", createHashMapFromArray [
		["CLASSES", _smg],
		["AMMO", _smgAmmo],
		["OPTICS", _smgOptic],
		["ATTACHMENTS_1", _smgAttach1],
		["ATTACHMENTS_2", _smgAttach2],
		["BIPODS", _smgBipod]
	]],
	["CARBINE", createHashMapFromArray [
		["CLASSES", _carbine],
		["AMMO", _carbineAmmo],
		["TRACER_AMMO", _carbineAmmoT],
		["OPTICS", _carbineOptic],
		["ATTACHMENTS_1", _carbineAttach1],
		["ATTACHMENTS_2", _carbineAttach2],
		["BIPODS", _carbineBipod]
	]],
	["RIFLE", createHashMapFromArray [
		["CLASSES", _rifle],
		["AMMO", _rifleAmmo],
		["TRACER_AMMO", _rifleAmmoT],
		["OPTICS", _rifleOptic],
		["ATTACHMENTS_1", _rifleAttach1],
		["ATTACHMENTS_2", _rifleAttach2],
		["BIPODS", _rifleBipod]
	]],
	["RIFLE_GL", createHashMapFromArray [
		["CLASSES", _rifleGl],
		["AMMO", _rifleGlAmmo],
		["TRACER_AMMO", _rifleGlAmmoT],
		["OPTICS", _rifleGlOptic],
		["ATTACHMENTS_1", _rifleGlAttach1],
		["ATTACHMENTS_2", _rifleGlAttach2],
		["BIPODS", _rifleGlBipod],
		["GL_AMMO_1", _rifleGlUgl1],
		["GL_AMMO_2", _rifleGlUgl2],
		["GL_AMMO_3", _rifleGlUgl3],
		["GL_AMMO_4", _rifleGlUgl4]
	]],
	["DMR", createHashMapFromArray [
		["CLASSES", _dmr],
		["AMMO", _dmrAmmo],
		["OPTICS", _dmrOptic],
		["ATTACHMENTS_1", _dmrAttach1],
		["ATTACHMENTS_2", _dmrAttach2],
		["BIPODS", _dmrBipod]
	]],
	["LMG", createHashMapFromArray [
		["CLASSES", _lmg],
		["AMMO", _lmgAmmo],
		["TRACER_AMMO", _lmgAmmoT],
		["OPTICS", _lmgOptic],
		["ATTACHMENTS_1", _lmgAttach1],
		["ATTACHMENTS_2", _lmgAttach2],
		["BIPODS", _lmgBipod]
	]],
	["MMG", createHashMapFromArray [
		["CLASSES", _mmg],
		["AMMO", _mmgAmmo],
		["OPTICS", _mmgOptic],
		["ATTACHMENTS_1", _mmgAttach1],
		["ATTACHMENTS_2", _mmgAttach2],
		["BIPODS", _mmgBipod]
	]],
	["LAT", createHashMapFromArray [
		["CLASSES", _lat],
		["AMMO", _latAmmo]
	]],
	["MAT", createHashMapFromArray [
		["CLASSES", _mat],
		["AMMO", _matAmmo],
		["OPTICS", _matOptic]
	]]
];

lmf_player_config = createHashMapFromArray [
	["ROLES", _roles],
	["ROLE_BY_CLASS", _roleByClass],
	["WEAPONS", _weapons],
	["RADIOS", createHashMapFromArray [
		["B", _radioB],
		["L", _radioL],
		["R", _radioR]
	]],
	["AVAILABLE_OPTICS", _availableOptics],
	["GRENADES", createHashMapFromArray [
		["FRAG", _grenade],
		["SMOKE", _grenadeSmoke],
		["SMOKE_COLOR", _grenadeSmokeClr]
	]],
	["ITEMS", createHashMapFromArray [
		["BINOCULAR", _binocular],
		["NVG", _nvg],
		["NVG_PILOT", _nvgPilot]
	]]
];
