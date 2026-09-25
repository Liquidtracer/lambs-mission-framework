/*
    Ground vehicle initialization
    Initializes cargo for configured player ground vehicles.

    Arguments:
        0: Ground vehicle <OBJECT>

    Example:
        [truck_1] call lmf_playerVehicles_fnc_initGroundVehicle;
*/

params [["_vic",objNull,[objNull]]];
if (isNull _vic) exitWith {};

#include "..\..\settings\cfg_Player.sqf"
private _type = typeOf _vic;

// Apply loadout
clearWeaponCargoGlobal _vic;
clearMagazineCargoGlobal _vic;
clearItemCargoGlobal _vic;
clearBackpackCargoGlobal _vic;

_vic addItemCargoGlobal ["Toolkit",1];
// [var_supMedical,_vic,true] call ace_cargo_fnc_loadItem;
if (_type == var_vic1) then {
};

if (_type == var_vic2) then {
};

if (_type == var_vic3) then {
};

if (_type == var_vic4) then {
};
