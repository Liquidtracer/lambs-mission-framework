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

// Apply loadout
clearWeaponCargoGlobal _vic;
clearMagazineCargoGlobal _vic;
clearItemCargoGlobal _vic;
clearBackpackCargoGlobal _vic;

_vic addItemCargoGlobal ["Toolkit",1];
