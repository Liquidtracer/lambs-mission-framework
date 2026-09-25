/*
    Bring into vehicle
    Internal #bring vehicle helper. Execute on the target player's client.

    Arguments: target unit, requesting admin, admin's vehicle at request time.
    Chat access is controlled by CBA admin command registration.
*/

params ["_unit", "_caller", "_vehicle"];
if (!local _unit || {isNull _caller}) exitWith {};

if (isNull _vehicle || {!alive _vehicle} || {objectParent _caller != _vehicle}) exitWith {
    "Bring cancelled: your vehicle is no longer available." remoteExec ["systemChat", _caller];
};
if (objectParent _unit == _vehicle) exitWith {
    format ["%1 is already in your vehicle.", name _unit] remoteExec ["systemChat", _caller];
};

// Only ordinary passenger seats; do not use driver or turret positions.
private _seats = fullCrew [_vehicle, "cargo", true];
private _seatIndex = _seats findIf {isNull (_x select 0)};
if (_seatIndex == -1) exitWith {
    "Bring cancelled: no passenger seat available." remoteExec ["systemChat", _caller];
};

private _cargoIndex = (_seats select _seatIndex) select 2;
moveOut _unit;
_unit moveInCargo [_vehicle, _cargoIndex];

if (objectParent _unit == _vehicle) then {
    format ["Teleported %1 into your vehicle.", name _unit] remoteExec ["systemChat", _caller];
} else {
    format ["Could not move %1 into your vehicle.", name _unit] remoteExec ["systemChat", _caller];
};
