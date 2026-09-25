/*
    Ground vehicle initialization
    Applies the configured AI ground-vehicle settings.

    Arguments:
        0: Ground vehicle <OBJECT>

    Example:
        [truck_1] call lmf_ai_fnc_initGroundVehicle;
*/

params [["_vic",objNull,[objNull]]];
if (isNull _vic) exitWith {};

private _camos = lmf_ai_config get "CAMOS";
private _vehicleKey = (lmf_ai_config get "VEHICLE_BY_CLASS") getOrDefault [toLower (typeOf _vic),""];
private _ammoBlacklist = lmf_ai_config get "AMMO_BLACKLIST";
private _flag = lmf_ai_config get "FLAG";

// Apply general settings
clearWeaponCargoGlobal _vic;
clearMagazineCargoGlobal _vic;
clearItemCargoGlobal _vic;
clearBackpackCargoGlobal _vic;

{if (_x isNotEqualTo "") then {_vic removeMagazines _x}} forEach _ammoBlacklist;

// Apply vehicle-specific settings.
if (_vehicleKey isNotEqualTo "") then {
	private _validCamos = (_camos get _vehicleKey) select {_x isNotEqualTo ""};
	if !(_validCamos isEqualTo []) then {[_vic,[selectRandom _validCamos,1]] call BIS_fnc_initVehicle};
};

// Flag
if (_flag isNotEqualTo "") then {_vic forceFlagTexture _flag};

// Vehicle flip handler & dismount tweaks
_vic addEventHandler ["GetOut", {
	params ["_vehicle", "_role", "_unit", "_turret"];
	if (!alive _unit) exitWith {};
	_unit setAmmo [primaryWeapon _unit, 0];
	_unit setSuppression 1;

	if (!alive _vehicle) exitWith {};
	if (_role == "driver" && {(vectorUp _vehicle) select 2 < 0} && {allPlayers findIf {_x distance2D _vehicle < 1000} == -1} ) then {
		_vehicle setPosATL [(getPosATL _vehicle)#0, (getPosATL _vehicle)#1, (getPosATL _vehicle)#2 + 3];
		_vehicle setDir (getDir _vehicle);
	};
}];

// Vehicle lights
[
	{
	params ["_vic"];
		_vic disableAI "LIGHTS";
		_vic action ["lightOff", _vic];
		_vic action ["CollisionLightOff", _vic];
	},
	[_vic], 5
] call CBA_fnc_waitAndExecute;
