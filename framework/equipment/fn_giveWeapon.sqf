/*
	Give weapon
	Give weapon according to weapon type number.
	Run where the unit is local.
	Author: G4rrus. Contributor: Alex2k.

	Arguments:
		0: Unit <OBJECT>
		1: Weapon type <NUMBER> (0-10, see cfg_Player for weapon type definitions)

	Examples:
		[player, 4] call lmf_equipment_fnc_giveWeapon;  // Rifle
		[player, 1] call lmf_equipment_fnc_giveWeapon;  // Pistol
*/

params [["_unit", objNull, [objNull]], ["_weapon", 3, [123]]];

if (isNull _unit || {!local _unit}) exitWith {false};

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _weapons = _config get "WEAPONS";

switch (_weapon) do {
	case 0: {
		private _weaponConfig = _weapons get "FLARE_GUN";
		private _flareGun = (_weaponConfig get "CLASSES") select 0;
		private _flareGunAmmo = (_weaponConfig get "AMMO") select 0;

		_unit addWeapon _flareGun;
		for "_i" from 1 to 4 do {[_unit, _flareGunAmmo, true] call lmf_equipment_fnc_addItem};

	};
	case 1: {
		private _weaponConfig = _weapons get "PISTOL";
		private _pistol = _weaponConfig get "CLASSES";
		private _pistolAmmo = _weaponConfig get "AMMO";
		private _pistolAttach1 = _weaponConfig get "ATTACHMENTS_1";
		private _pistolAttach2 = _weaponConfig get "ATTACHMENTS_2";

		_unit addWeapon (selectRandom _pistol);
		for "_i" from 1 to 2 do {[_unit, selectRandom _pistolAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addHandgunItem (selectRandom _pistolAttach1);
		_unit addHandgunItem (selectRandom _pistolAttach2);
	};
	case 2: {
		private _weaponConfig = _weapons get "SMG";
		private _smg = _weaponConfig get "CLASSES";
		private _smgAmmo = _weaponConfig get "AMMO";
		private _smgOptic = _weaponConfig get "OPTICS";
		private _smgAttach1 = _weaponConfig get "ATTACHMENTS_1";
		private _smgAttach2 = _weaponConfig get "ATTACHMENTS_2";
		private _smgBipod = _weaponConfig get "BIPODS";

		_unit addWeapon (selectRandom _smg);
		for "_i" from 1 to 6 do {[_unit, selectRandom _smgAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _smgAttach1);
		_unit addPrimaryWeaponItem (selectRandom _smgAttach2);
		_unit addPrimaryWeaponItem (selectRandom _smgOptic);
		_unit addPrimaryWeaponItem (selectRandom _smgBipod);
	};
	case 3: {
		private _weaponConfig = _weapons get "CARBINE";
		private _carbine = _weaponConfig get "CLASSES";
		private _carbineAmmo = _weaponConfig get "AMMO";
		private _carbineAmmoT = _weaponConfig get "TRACER_AMMO";
		private _carbineOptic = _weaponConfig get "OPTICS";
		private _carbineAttach1 = _weaponConfig get "ATTACHMENTS_1";
		private _carbineAttach2 = _weaponConfig get "ATTACHMENTS_2";
		private _carbineBipod = _weaponConfig get "BIPODS";

		_unit addWeapon (selectRandom _carbine);
		for "_i" from 1 to 2 do {[_unit, selectRandom _carbineAmmoT, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 8 do {[_unit, selectRandom _carbineAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _carbineAttach1);
		_unit addPrimaryWeaponItem (selectRandom _carbineAttach2);
		_unit addPrimaryWeaponItem (selectRandom _carbineOptic);
		_unit addPrimaryWeaponItem (selectRandom _carbineBipod);
	};
	case 4: {
		private _weaponConfig = _weapons get "RIFLE";
		private _rifle = _weaponConfig get "CLASSES";
		private _rifleAmmo = _weaponConfig get "AMMO";
		private _rifleAmmoT = _weaponConfig get "TRACER_AMMO";
		private _rifleOptic = _weaponConfig get "OPTICS";
		private _rifleAttach1 = _weaponConfig get "ATTACHMENTS_1";
		private _rifleAttach2 = _weaponConfig get "ATTACHMENTS_2";
		private _rifleBipod = _weaponConfig get "BIPODS";

		_unit addWeapon (selectRandom _rifle);
		for "_i" from 1 to 2 do {[_unit, selectRandom _rifleAmmoT, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 8 do {[_unit, selectRandom _rifleAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _rifleAttach1);
		_unit addPrimaryWeaponItem (selectRandom _rifleAttach2);
		_unit addPrimaryWeaponItem (selectRandom _rifleOptic);
		_unit addPrimaryWeaponItem (selectRandom _rifleBipod);
	};
	case 5: {
		private _weaponConfig = _weapons get "RIFLE_GL";
		private _rifleGl = _weaponConfig get "CLASSES";
		private _rifleGlAmmo = _weaponConfig get "AMMO";
		private _rifleGlAmmoT = _weaponConfig get "TRACER_AMMO";
		private _rifleGlOptic = _weaponConfig get "OPTICS";
		private _rifleGlAttach1 = _weaponConfig get "ATTACHMENTS_1";
		private _rifleGlAttach2 = _weaponConfig get "ATTACHMENTS_2";
		private _rifleGlBipod = _weaponConfig get "BIPODS";
		private _rifleGlUgl1 = _weaponConfig get "GL_AMMO_1";
		private _rifleGlUgl2 = _weaponConfig get "GL_AMMO_2";
		private _rifleGlUgl3 = _weaponConfig get "GL_AMMO_3";
		private _rifleGlUgl4 = _weaponConfig get "GL_AMMO_4";

		_unit addWeapon (selectRandom _rifleGl);
		for "_i" from 1 to 2 do {[_unit, selectRandom _rifleGlAmmoT, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 6 do {[_unit, selectRandom _rifleGlAmmo, true] call lmf_equipment_fnc_addItem};

		for "_i" from 1 to 6 do {[_unit, selectRandom _rifleGlUgl1, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 4 do {[_unit, selectRandom _rifleGlUgl2, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 2 do {[_unit, selectRandom _rifleGlUgl3, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 2 do {[_unit, selectRandom _rifleGlUgl4, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _rifleGlAttach1);
		_unit addPrimaryWeaponItem (selectRandom _rifleGlAttach2);
		_unit addPrimaryWeaponItem (selectRandom _rifleGlOptic);
		_unit addPrimaryWeaponItem (selectRandom _rifleGlBipod);
	};
	case 6: {
		private _weaponConfig = _weapons get "DMR";
		private _dmr = _weaponConfig get "CLASSES";
		private _dmrAmmo = _weaponConfig get "AMMO";
		private _dmrOptic = _weaponConfig get "OPTICS";
		private _dmrAttach1 = _weaponConfig get "ATTACHMENTS_1";
		private _dmrAttach2 = _weaponConfig get "ATTACHMENTS_2";
		private _dmrBipod = _weaponConfig get "BIPODS";

		_unit addWeapon (selectRandom _dmr);
		for "_i" from 1 to 8 do {[_unit, selectRandom _dmrAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _dmrAttach1);
		_unit addPrimaryWeaponItem (selectRandom _dmrAttach2);
		_unit addPrimaryWeaponItem (selectRandom _dmrOptic);
		_unit addPrimaryWeaponItem (selectRandom _dmrBipod);
	};
	case 7: {
		private _weaponConfig = _weapons get "LMG";
		private _lmg = _weaponConfig get "CLASSES";
		private _lmgAmmo = _weaponConfig get "AMMO";
		private _lmgAmmoT = _weaponConfig get "TRACER_AMMO";
		private _lmgOptic = _weaponConfig get "OPTICS";
		private _lmgAttach1 = _weaponConfig get "ATTACHMENTS_1";
		private _lmgAttach2 = _weaponConfig get "ATTACHMENTS_2";
		private _lmgBipod = _weaponConfig get "BIPODS";

		_unit addWeapon (selectRandom _lmg);
		for "_i" from 1 to 4 do {[_unit, selectRandom _lmgAmmoT, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 4 do {[_unit, selectRandom _lmgAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _lmgAttach1);
		_unit addPrimaryWeaponItem (selectRandom _lmgAttach2);
		_unit addPrimaryWeaponItem (selectRandom _lmgOptic);
		_unit addPrimaryWeaponItem (selectRandom _lmgBipod);
	};
	case 8: {
		private _weaponConfig = _weapons get "MMG";
		private _mmg = _weaponConfig get "CLASSES";
		private _mmgAmmo = _weaponConfig get "AMMO";
		private _mmgOptic = _weaponConfig get "OPTICS";
		private _mmgAttach1 = _weaponConfig get "ATTACHMENTS_1";
		private _mmgAttach2 = _weaponConfig get "ATTACHMENTS_2";
		private _mmgBipod = _weaponConfig get "BIPODS";

		_unit addWeapon (selectRandom _mmg);
		for "_i" from 1 to 4 do {[_unit, selectRandom _mmgAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _mmgAttach1);
		_unit addPrimaryWeaponItem (selectRandom _mmgAttach2);
		_unit addPrimaryWeaponItem (selectRandom _mmgOptic);
		_unit addPrimaryWeaponItem (selectRandom _mmgBipod);
	};
	case 9: {
		private _weaponConfig = _weapons get "LAT";
		private _lat = _weaponConfig get "CLASSES";
		private _latAmmo = _weaponConfig get "AMMO";

		_unit addWeapon (selectRandom _lat);
		[_unit, selectRandom _latAmmo, true] call lmf_equipment_fnc_addItem
	};
	case 10: {
		private _weaponConfig = _weapons get "MAT";
		private _mat = _weaponConfig get "CLASSES";
		private _matAmmo = _weaponConfig get "AMMO";
		private _matOptic = _weaponConfig get "OPTICS";

		_unit addWeapon (selectRandom _mat);
		for "_i" from 1 to 4 do {[_unit, selectRandom _matAmmo, false] call lmf_equipment_fnc_addItem};

		_unit addSecondaryWeaponItem (selectRandom _matOptic);
	};
};
