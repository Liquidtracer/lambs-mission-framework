/*
    Supply crate equipment
    Fills configured supply crates with player equipment.

    Arguments:
        0: Supply crate <OBJECT>

    Example:
        [crate_1] call lmf_supplyCrates_fnc_initSupplyCrate;
*/

params [["_supp",objNull,[objNull]]];
if (isNull _supp) exitWith {};

#include "..\..\settings\cfg_Player.sqf"

// Apply loadout
clearWeaponCargoGlobal _supp;
clearMagazineCargoGlobal _supp;
clearItemCargoGlobal _supp;
clearBackpackCargoGlobal _supp;

if (typeOf _supp == var_supVehicle) exitWith {
	[_supp, 20] call ace_cargo_fnc_setSpace;
	for "_i" from 1 to 3 do {
		["ACE_Track",_supp,true] call ace_cargo_fnc_loadItem;
		["ACE_Wheel",_supp,true] call ace_cargo_fnc_loadItem;
		["Land_CanisterFuel_F",_supp,true] call ace_cargo_fnc_loadItem;
	};
	_supp addItemCargoGlobal ["Toolkit",3];
};

if (typeOf _supp == var_supSquad) exitWith {
	_supp addItemCargoGlobal ["ACE_CableTie",10];
	_supp addItemCargoGlobal ["ACE_Wirecutter",1];
	if (_lat#0 != "") then {_supp addWeaponCargoGlobal [_lat#0, 2];};
	if (_lmgAmmo#0 != "") then {_supp addMagazineCargoGlobal [_lmgAmmo#0, 5];};
	if (_mmgAmmo#0 != "") then {_supp addMagazineCargoGlobal [_mmgAmmo#0, 5];};
	// if (_matAmmo#0 != "") then {_supp addMagazineCargoGlobal [_matAmmo#0, 4];};
	if (_rifleAmmo#0 != "") then {_supp addMagazineCargoGlobal [_rifleAmmo#0, 15];};
	if (_carbineAmmo#0 != "") then {_supp addMagazineCargoGlobal [_carbineAmmo#0, 15];};
	if (_rifleGlAmmo#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlAmmo#0, 15];};
	if (_smgAmmo#0 != "") then {_supp addMagazineCargoGlobal [_smgAmmo#0, 5];};
	if (_rifleGlUgl1#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlUgl1#0, 8];};
	if (_rifleGlUgl2#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlUgl2#0, 8];};
	if (_rifleGlUgl3#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlUgl3#0, 4];};
	if (_rifleGlUgl4#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlUgl4#0, 4];};
};

if (typeOf _supp == var_supLarge) exitWith {
	_supp addItemCargoGlobal ["ACE_CableTie",20];
	if (_carbineAmmo#0 != "") then {_supp addMagazineCargoGlobal [_carbineAmmo#0, 40];};
	if (_rifleAmmo#0 != "") then {_supp addMagazineCargoGlobal [_rifleAmmo#0, 40];};
	if (_rifleGlAmmo#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlAmmo#0, 40];};
	if (_lmgAmmo#0 != "") then {_supp addMagazineCargoGlobal [_lmgAmmo#0, 20];};
	if (_smgAmmo#0 != "") then {_supp addMagazineCargoGlobal [_smgAmmo#0, 20];};
	if (_mmgAmmo#0 != "") then {_supp addMagazineCargoGlobal [_mmgAmmo#0, 12];};
	if (_matAmmo#0 != "") then {_supp addMagazineCargoGlobal [_matAmmo#0, 12];};
	if (_rifleGlUgl1#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlUgl1#0, 20];};
	if (_rifleGlUgl2#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlUgl2#0, 20];};
	if (_rifleGlUgl3#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlUgl3#0, 10];};
	if (_rifleGlUgl4#0 != "") then {_supp addMagazineCargoGlobal [_rifleGlUgl4#0, 10];};
	if (_grenade#0 != "") then {_supp addMagazineCargoGlobal [_grenade#0, 10];};
	if (_grenadeSmoke#0 != "") then {_supp addMagazineCargoGlobal [_grenadeSmoke#0, 10];};
	if (_grenadeSmokeClr#0 != "") then {_supp addMagazineCargoGlobal [_grenadeSmokeClr#0, 10];};
	if (_lat#0 != "") then {_supp addWeaponCargoGlobal [_lat#0, 6];};
	_supp addItemCargoGlobal ["ACE_Wirecutter",3];
	// _supp addItemCargoGlobal ["ACE_IR_Strobe_Item",30];
};

if (typeOf _supp == var_supMedical) exitWith {
	_supp addItemCargoGlobal ["ACE_morphine",15];
	_supp addItemCargoGlobal ["ACE_epinephrine",15];
	_supp addItemCargoGlobal ["ACE_tourniquet",10];
	// _supp addItemCargoGlobal ["ACE_splint",10];
	_supp addItemCargoGlobal ["ACE_bloodIV",15];
	_supp addItemCargoGlobal ["ACE_fieldDressing",50];
	_supp addItemCargoGlobal ["ACE_bodyBag",10];
};

if (typeOf _supp == var_supExplosives) exitWith {
	_supp addItemCargoGlobal ["DemoCharge_Remote_Mag", 10];
	_supp addItemCargoGlobal ["SatchelCharge_Remote_Mag", 5];
	_supp addItemCargoGlobal ["ACE_M26_Clacker",2];

	// if ((_backpackLight#0) != "") then {_supp addBackpackCargoGlobal [(selectRandom _backpackLight), 2];};
};