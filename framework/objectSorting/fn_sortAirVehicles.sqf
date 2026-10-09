/*
	Sort air vehicles
	Routes local aircraft to the AI or player-vehicle initializer.

	Arguments:
		0: Aircraft <OBJECT>

	Example:
		[plane_1] call lmf_objectSorting_fnc_sortAirVehicles;
*/

private _air = _this select 0;

if !(local _air) exitWith {};

private _type = typeOf _air;
private _vehicleKey = (lmf_ai_config get "VEHICLE_BY_CLASS") getOrDefault [toLower _type, ""];

// Configured AI vehicles
if (_vehicleKey in ["HELITRANSPORT", "HELIATTACK"]) then {[_air] call lmf_ai_fnc_initAirVehicle};

// Player vehicles
if !(lmf_playerGear) exitWith {};
if (_type in lmf_airVehicles) then {
	[_air] call lmf_playerVehicles_fnc_initAirVehicle;
};
