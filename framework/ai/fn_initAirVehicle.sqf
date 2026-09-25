/*
    Aircraft initialization
    Applies the configured AI aircraft settings.

    Arguments:
        0: Aircraft <OBJECT>

    Example:
        [plane_1] call lmf_ai_fnc_initAirVehicle;
*/

params [["_air",objNull,[objNull]]];
if (isNull _air) exitWith {};

private _camos = lmf_ai_config get "CAMOS";
private _vehicleKey = (lmf_ai_config get "VEHICLE_BY_CLASS") getOrDefault [toLower (typeOf _air),""];
private _ammoBlacklist = lmf_ai_config get "AMMO_BLACKLIST";

// Apply general settings
clearWeaponCargoGlobal _air;
clearMagazineCargoGlobal _air;
clearItemCargoGlobal _air;
clearBackpackCargoGlobal _air;

{if (_x isNotEqualTo "") then {_air removeMagazines _x}} forEach _ammoBlacklist;

// Apply vehicle-specific settings.
if (_vehicleKey isNotEqualTo "") then {
	private _validCamos = (_camos get _vehicleKey) select {_x isNotEqualTo ""};
	if !(_validCamos isEqualTo []) then {[_air,[selectRandom _validCamos,1]] call BIS_fnc_initVehicle};
	_air setVehicleLock "LOCKEDPLAYER";
};

// Vehicle lights
[
	{
	params ["_air"];
		_air disableAI "LIGHTS";
		_air action ["lightOff", _air];
		_air action ["CollisionLightOff", _air];
	},
	[_air], 5
] call CBA_fnc_waitAndExecute;

// Dismount tweaks
_air addEventHandler ["GetOut", {
	params ["_vehicle", "_role", "_unit", "_turret"];
	if (!alive _vehicle) then {

		if (getPos _vehicle select 2 > 15 && 75 > random 100) exitWith {_unit setDamage 1};
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
