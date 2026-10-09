/*
	Sort ground vehicles
	Routes local ground vehicles to the AI or player-vehicle initializer.

	Arguments:
		0: Ground vehicle <OBJECT>

	Example:
		[truck_1] call lmf_objectSorting_fnc_sortGroundVehicles;
*/

private _vic = _this select 0;

if !(local _vic) exitWith {};

private _type = typeOf _vic;
private _vehicleKey = (lmf_ai_config get "VEHICLE_BY_CLASS") getOrDefault [toLower _type, ""];

// Configured AI vehicles
if (_vehicleKey in ["CAR", "CARARMED", "TRUCK", "APC", "TANK"]) then {[_vic] call lmf_ai_fnc_initGroundVehicle};

// Configured player vehicles
if !(lmf_playerGear) exitWith {};
if (_type in lmf_groundVehicles) then {
	[_vic] call lmf_playerVehicles_fnc_initGroundVehicle;
};
