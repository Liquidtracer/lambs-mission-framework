/*
	Seat a prepared soldier
	Internal local operation, called atomically with creation or paradrop release.
	Uses the seat stored by the creation worker. An empty seat leaves infantry on foot.
*/

params ["_unit"];
(_unit getVariable ["lmf_ai_spawnSeat", [objNull, ""]]) params ["_vehicle", "_seat"];
if (_seat isEqualType []) then {
	_unit moveInTurret [_vehicle, _seat];
} else {
	switch (_seat) do {
		case "DRIVER": {_unit moveInDriver _vehicle};
		case "ANY": {_unit moveInAny _vehicle};
		case "CARGO": {_unit assignAsCargo _vehicle; _unit moveInCargo _vehicle};
	};
};
_unit setVariable ["lmf_ai_spawnSeat", nil];
