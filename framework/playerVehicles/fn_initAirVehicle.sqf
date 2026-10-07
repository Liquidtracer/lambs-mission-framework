/*
	Aircraft initialization
	Initializes cargo for configured player aircraft.

	Arguments:
		0: Aircraft <OBJECT>

	Example:
		[plane_1] call lmf_playerVehicles_fnc_initAirVehicle;
*/

params [["_air", objNull, [objNull]]];
if (isNull _air) exitWith {};

// Apply loadout
clearWeaponCargoGlobal _air;
clearMagazineCargoGlobal _air;
clearItemCargoGlobal _air;
clearBackpackCargoGlobal _air;

_air addItemCargoGlobal ["Toolkit", 1];
