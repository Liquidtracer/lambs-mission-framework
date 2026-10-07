/*
	Drop unit
	Routes a paradrop operation to the machine where the unit is local.

	Arguments:
		0: Unit <OBJECT>
		1: Drop mode <STRING> (default: "EJECT"; "EJECT", "POSITION" or "BACKPACK")
		2: Mode data <ARRAY> (see below)

	Example:
		[soldier_1, "EJECT", [plane_1, 1, "Steerable_Parachute_F"]] spawn lmf_paradrop_fnc_dropUnit;

	Modes and data:
		EJECT: [aircraft, delay, parachute class]
		POSITION: [position, direction, parachute class]
		BACKPACK: [aircraft, delay, parachute backpack class]
*/

params [
	["_unit", objNull, [objNull]],
	["_mode", "EJECT", [""]],
	["_data", [], [[]]]
];

if (isNull _unit) exitWith {false};

_mode = toUpper _mode;
private _isLocal = local _unit;

if (local _unit) then {
	if (_mode == "BACKPACK" && {canSuspend}) then {
		[_unit, _mode, _data] call lmf_paradrop_fnc_dropUnitLocal;
	} else {
		[_unit, _mode, _data] spawn lmf_paradrop_fnc_dropUnitLocal;
	};
} else {
	[_unit, _mode, _data] remoteExec ["lmf_paradrop_fnc_dropUnitLocal", _unit];
};

if (canSuspend && {_mode == "EJECT" || {_mode == "BACKPACK" && {!_isLocal}}}) then {
	sleep (_data param [1, 0, [0]]);
};
true
