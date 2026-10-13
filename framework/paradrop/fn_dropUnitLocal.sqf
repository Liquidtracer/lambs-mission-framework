/*
	Local unit paradrop
	Performs the locality-sensitive part of a unit paradrop.
	Called through lmf_paradrop_fnc_dropUnit.

	Arguments:
		0: Local unit <OBJECT>
		1: Drop mode <STRING> (default: "EJECT"; "EJECT", "POSITION" or "BACKPACK")
		2: Mode data <ARRAY> (same format as lmf_paradrop_fnc_dropUnit)

	Example:
		[soldier_1, "EJECT", [plane_1, 1, "Steerable_Parachute_F"]] spawn lmf_paradrop_fnc_dropUnitLocal;
*/

params [
	["_unit", objNull, [objNull]],
	["_mode", "EJECT", [""]],
	["_data", [], [[]]]
];

if (isNull _unit || {!local _unit}) exitWith {};

switch (_mode) do {
	case "EJECT": {
		_data params [
			["_aircraft", objNull, [objNull]],
			["_delay", 0, [0]],
			["_parachuteType", "Steerable_Parachute_F", [""]]
		];

		if (isNull _aircraft || {vehicle _unit != _aircraft}) exitWith {};

		private _protectLanding = isPlayer _unit;
		_unit allowDamage false;
		sleep 0.1;

		if (!isPlayer _unit) then {
			unassignVehicle _unit;
		};

		moveOut _unit;
		if (isPlayer _unit) then {
			openMap false;
		};
		_unit setDir (getDir _aircraft);

		sleep _delay;

		private _parachute = createVehicle [_parachuteType, [0, 0, 0], [], 0, "NONE"];
		_parachute setPosASL (getPosASLVisual _unit);
		_parachute setVectorDirAndUp [vectorDirVisual _unit, vectorUpVisual _unit];
		_unit moveInDriver _parachute;
		if (!_protectLanding) then {
			_unit allowDamage true;
		};

		private _chemlight = createVehicle ["Chemlight_red", getPos _unit, [], 0, "NONE"];
		_chemlight attachTo [_unit, [0, 0, 0.45]];

		waitUntil {sleep 0.1; vehicle _unit != _parachute};
		deleteVehicle _chemlight;
		_unit playActionNow "PlayerProne";

		// Keep players protected through the landing bounce after parachute exit.
		if (_protectLanding) then {
			sleep 2;
			_unit allowDamage true;
		};
	};

	case "POSITION": {
		_data params [
			["_position", [0, 0, 0], [[]], 3],
			["_direction", 0, [0]],
			["_parachuteType", "Steerable_Parachute_F", [""]]
		];

		if (vehicle _unit != _unit) then {
			if (!isPlayer _unit) then {unassignVehicle _unit};
			moveOut _unit;
		};

		_unit setPos _position;
		private _parachute = createVehicle [_parachuteType, _position, [], 0, "CAN_COLLIDE"];
		_parachute setDir _direction;
		_unit moveInAny _parachute;
	};

	case "BACKPACK": {
		_data params [
			["_aircraft", objNull, [objNull]],
			["_delay", 1.5, [0]],
			["_parachuteBackpack", "ACE_NonSteerableParachute", [""]]
		];

		if (isNull _aircraft || {vehicle _unit != _aircraft}) exitWith {};

		private _backpack = backpack _unit;
		private _items = backpackItems _unit;
		removeBackpack _unit;
		_unit addBackpack _parachuteBackpack;
		// Release the aircraft seat without ordering an ordinary exit before the parachute action.
		isNil {
			if (!isPlayer _unit) then {unassignVehicle _unit};
			_unit action ["openParachute", vehicle _unit];
		};
		sleep _delay;
		_unit addBackpack _backpack;
		{_unit addItem _x} forEach _items;
	};
};
