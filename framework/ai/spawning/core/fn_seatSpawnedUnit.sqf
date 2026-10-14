/*
	Seat a prepared soldier
	Internal local operation, called atomically with creation or paradrop release.
	Uses the seat stored by the creation worker. An empty seat leaves infantry on foot.
	Returns verified success; failed seating retains the marker for caller cleanup.
*/

params ["_unit"];
if (!alive _unit || {!local _unit} || {isNil {_unit getVariable "lmf_ai_spawnSeat"}}) exitWith {false};
(_unit getVariable "lmf_ai_spawnSeat") params ["_vehicle", "_seat"];
if (_seat isEqualTo "") exitWith {
	_unit setVariable ["lmf_ai_spawnSeat", nil];
	true
};
if (!alive _vehicle) exitWith {false};
if (_seat isEqualType []) then {
	_unit moveInTurret [_vehicle, _seat];
} else {
	switch (_seat) do {
		case "DRIVER": {_unit moveInDriver _vehicle};
		case "ANY": {_unit moveInAny _vehicle};
		case "CARGO": {_unit assignAsCargo _vehicle; _unit moveInCargo _vehicle};
	};
};
private _seated = objectParent _unit == _vehicle;
if (_seat isEqualType []) then {
	_seated = _seated && {_vehicle turretUnit _seat == _unit};
} else {
	if (_seat == "DRIVER") then {_seated = _seated && {driver _vehicle == _unit}};
};
if (_seated) then {_unit setVariable ["lmf_ai_spawnSeat", nil]};
_seated
