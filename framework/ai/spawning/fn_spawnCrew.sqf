/*
	Spawn paced vehicle crew
	Internal scheduled server helper. Preserves BIS spawnCrew driver/turret traversal, including FFV.
	Based on Bohemia's BIS_fnc_spawnCrew by Joris-Jan van 't Land.
	Arguments: vehicle, local group, crew class, optional staged flag.
	Returns created units. Caller owns pruning, commander selection and group readiness.
*/

params ["_vehicle", "_group", "_class", ["_staged", false]];
if (!canSuspend || {isNull _group} || {!local _group}) exitWith {[]};
if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") != 1) exitWith {[]};
_group setVariable ["lmf_ai_spawning", true];
private _entry = configFile >> "CfgVehicles" >> typeOf _vehicle;
private _crew = [];
private _seats = [];
if (getNumber (_entry >> "hasDriver") == 1 && {isNull driver _vehicle}) then {_seats pushBack "DRIVER"};
private _collectTurrets = {
	params ["_turrets", "_path"];
	for "_i" from 0 to (count _turrets - 1) step 2 do {
		private _turret = _path + [_turrets # _i];
		if (isNull (_vehicle turretUnit _turret)) then {_seats pushBack _turret};
		[_turrets # (_i + 1), _turret] call _collectTurrets;
	};
};
[[_entry >> "Turrets"] call BIS_fnc_returnVehicleTurrets, []] call _collectTurrets;
private _failed = false;
{
	private _unit = [_group, _class, getPos _vehicle, "NONE", _vehicle, _x, _staged] call lmf_ai_fnc_requestSpawn;
	if (isNull _unit) exitWith {_failed = true};
	_crew pushBack _unit;
	if (!_staged && {objectParent _unit != _vehicle}) exitWith {_failed = true};
} forEach _seats;
if (_failed) exitWith {
	{
		private _parent = objectParent _x;
		if (isNull _parent) then {deleteVehicle _x} else {_parent deleteVehicleCrew _x};
	} forEach _crew;
	[]
};
if (!_staged) then {[_vehicle, "LIEUTENANT"] call BIS_fnc_setRank};
[_group] call lmf_ai_fnc_waitForSpawnInit;
_crew
