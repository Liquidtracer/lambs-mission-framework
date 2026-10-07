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

#include "..\..\settings\cfg_Player.sqf"

switch (_weapon) do {
	case 0: {
		_unit addWeapon _flareGun;
		for "_i" from 1 to 4 do {[_unit, _flareGunAmmo, true] call lmf_equipment_fnc_addItem};

	};
	case 1: {
		_unit addWeapon (selectRandom _pistol);
		for "_i" from 1 to 2 do {[_unit, selectRandom _pistolAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addHandgunItem (selectRandom _pistolAttach1);
		_unit addHandgunItem (selectRandom _pistolAttach2);
	};
	case 2: {
		_unit addWeapon (selectRandom _smg);
		for "_i" from 1 to 6 do {[_unit, selectRandom _smgAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _smgAttach1);
		_unit addPrimaryWeaponItem (selectRandom _smgAttach2);
		_unit addPrimaryWeaponItem (selectRandom _smgOptic);
		_unit addPrimaryWeaponItem (selectRandom _smgBipod);
	};
	case 3: {
		_unit addWeapon (selectRandom _carbine);
		for "_i" from 1 to 2 do {[_unit, selectRandom _carbineAmmoT, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 8 do {[_unit, selectRandom _carbineAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _carbineAttach1);
		_unit addPrimaryWeaponItem (selectRandom _carbineAttach2);
		_unit addPrimaryWeaponItem (selectRandom _carbineOptic);
		_unit addPrimaryWeaponItem (selectRandom _carbineBipod);
	};
	case 4: {
		_unit addWeapon (selectRandom _rifle);
		for "_i" from 1 to 2 do {[_unit, selectRandom _rifleAmmoT, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 8 do {[_unit, selectRandom _rifleAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _rifleAttach1);
		_unit addPrimaryWeaponItem (selectRandom _rifleAttach2);
		_unit addPrimaryWeaponItem (selectRandom _rifleOptic);
		_unit addPrimaryWeaponItem (selectRandom _rifleBipod);
	};
	case 5: {
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
		_unit addWeapon (selectRandom _dmr);
		for "_i" from 1 to 8 do {[_unit, selectRandom _dmrAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _dmrAttach1);
		_unit addPrimaryWeaponItem (selectRandom _dmrAttach2);
		_unit addPrimaryWeaponItem (selectRandom _dmrOptic);
		_unit addPrimaryWeaponItem (selectRandom _dmrBipod);
	};
	case 7: {
		_unit addWeapon (selectRandom _lmg);
		for "_i" from 1 to 4 do {[_unit, selectRandom _lmgAmmoT, true] call lmf_equipment_fnc_addItem};
		for "_i" from 1 to 4 do {[_unit, selectRandom _lmgAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _lmgAttach1);
		_unit addPrimaryWeaponItem (selectRandom _lmgAttach2);
		_unit addPrimaryWeaponItem (selectRandom _lmgOptic);
		_unit addPrimaryWeaponItem (selectRandom _lmgBipod);
	};
	case 8: {
		_unit addWeapon (selectRandom _mmg);
		for "_i" from 1 to 4 do {[_unit, selectRandom _mmgAmmo, true] call lmf_equipment_fnc_addItem};

		_unit addPrimaryWeaponItem (selectRandom _mmgAttach1);
		_unit addPrimaryWeaponItem (selectRandom _mmgAttach2);
		_unit addPrimaryWeaponItem (selectRandom _mmgOptic);
		_unit addPrimaryWeaponItem (selectRandom _mmgBipod);
	};
	case 9: {
		_unit addWeapon (selectRandom _lat);
		[_unit, selectRandom _latAmmo, true] call lmf_equipment_fnc_addItem
	};
	case 10: {
		_unit addWeapon (selectRandom _mat);
		for "_i" from 1 to 4 do {[_unit, selectRandom _matAmmo, false] call lmf_equipment_fnc_addItem};

		_unit addSecondaryWeaponItem (selectRandom _matOptic);
	};
};
