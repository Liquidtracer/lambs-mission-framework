/*
	Boat initialization
	Applies the configured AI boat settings.

	Arguments:
		0: Ship <OBJECT>

	Example:
		[boat_1] call lmf_ai_fnc_initWaterVehicle;
*/

params [["_ship", objNull, [objNull]]];
if (isNull _ship) exitWith {};

private _camos = lmf_ai_config get "CAMOS";
private _vehicleKey = (lmf_ai_config get "VEHICLE_BY_CLASS") getOrDefault [toLower (typeOf _ship), ""];
private _ammoBlacklist = lmf_ai_config get "AMMO_BLACKLIST";

// Apply general settings
clearWeaponCargoGlobal _ship;
clearMagazineCargoGlobal _ship;
clearItemCargoGlobal _ship;
clearBackpackCargoGlobal _ship;

{if (_x isNotEqualTo "") then {_ship removeMagazines _x}} forEach _ammoBlacklist;

// Apply vehicle-specific settings.
if (_vehicleKey == "BOAT") then {
	private _validCamos = (_camos get "BOAT") select {_x isNotEqualTo ""};
	if !(_validCamos isEqualTo []) then {[_ship, [selectRandom _validCamos, 1]] call BIS_fnc_initVehicle};
};

// Vehicle lights
[
	{
	params ["_ship"];
		_ship disableAI "LIGHTS";
		_ship action ["lightOff", _ship];
		_ship action ["CollisionLightOff", _ship];
	},
	[_ship], 5
] call CBA_fnc_waitAndExecute;

// Dismount tweaks
_ship addEventHandler ["GetOut", {
	params ["_vehicle", "_role", "_unit", "_turret"];
	if (!alive _vehicle) then {

		if (75 > random 100) exitWith {_unit setDamage 1};
		[_unit, true] call ace_medical_status_fnc_setUnconsciousState;
		[{
			params ["_unit"];
			[_unit, false] call ace_medical_status_fnc_setUnconsciousState;
			_unit setAmmo [primaryWeapon _unit, 0];
			_unit setSuppression 1;
		}, [_unit], 5 + (random 30)] call CBA_fnc_waitAndExecute;
	} else {

		_unit setAmmo [primaryWeapon _unit, 0];
		_unit setSuppression 1;
	};
}];
