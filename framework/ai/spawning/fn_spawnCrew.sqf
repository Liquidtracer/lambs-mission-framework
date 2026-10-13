/*
	Spawn paced vehicle crew
	Internal scheduled server helper. Preserves BIS spawnCrew seat eligibility, including FFV.
	Based on Bohemia's BIS_fnc_spawnCrew by Joris-Jan van 't Land.
	Arguments: vehicle, local group, crew class, optional staged flag, optional seat allowlist.
	Omitting the allowlist uses all eligible seats; an explicit empty array creates no crew.
	Returns created units. Caller owns pruning, commander selection and group readiness.
*/

params ["_vehicle", "_group", "_class", ["_staged", false], ["_seatAllowlist", []]];
if (!canSuspend || {isNull _group} || {!local _group}) exitWith {[]};
if (getNumber (configFile >> "CfgVehicles" >> _class >> "isMan") != 1) exitWith {[]};
_group setVariable ["lmf_ai_spawning", true];
private _entry = configFile >> "CfgVehicles" >> typeOf _vehicle;
private _crew = [];
private _seats = [];
if (getNumber (_entry >> "hasDriver") == 1 && {isNull driver _vehicle}) then {_seats pushBack "DRIVER"};
// Engine paths include nested and FFV seats; BIS spawnCrew filters on hasGunner only.
// Do not apply createVehicleCrew's different dontCreateAI/non-FFV policy here.
{
	private _turretConfig = [_vehicle, _x] call BIS_fnc_turretConfig;
	if (getNumber (_turretConfig >> "hasGunner") == 1 && {isNull (_vehicle turretUnit _x)}) then {
		_seats pushBack _x;
	};
} forEach allTurrets [_vehicle, true];
if (count _this > 4) then {_seats = _seats arrayIntersect _seatAllowlist};
private _failed = false;
{
	private _unit = [_group, _class, getPos _vehicle, "NONE", _vehicle, _x, _staged] call lmf_ai_fnc_requestSpawn;
	if (isNull _unit) exitWith {_failed = true};
	_crew pushBack _unit;
	if (!_staged && {!isNil {_unit getVariable "lmf_ai_spawnSeat"}}) exitWith {_failed = true};
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
