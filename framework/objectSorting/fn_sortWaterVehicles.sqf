/*
    Sort water vehicles
    Routes configured local boats to the AI initializer.

    Arguments:
        0: Ship <OBJECT>

    Example:
        [boat_1] call lmf_objectSorting_fnc_sortWaterVehicles;
*/

private _ship = _this select 0;

if !(local _ship) exitWith {};

private _vehicleKey = (lmf_ai_config get "VEHICLE_BY_CLASS") getOrDefault [toLower (typeOf _ship),""];

// Configured AI vehicles
if (_vehicleKey == "BOAT") then {[_ship] call lmf_ai_fnc_initWaterVehicle};
