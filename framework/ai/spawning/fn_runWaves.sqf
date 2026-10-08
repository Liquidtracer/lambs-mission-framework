/*
	Run AI waves
	Manages replacements for one primary group or object.
	Call synchronously from a scheduled server spawner scope.

	Arguments:
		0: One-shot operation returning GROUP or OBJECT <CODE>
		1: Total tickets <NUMBER>
		2: Replacement delay in seconds <NUMBER>
		3: Proximity position <OBJECT or ARRAY>
		4: Proximity radius in meters <NUMBER>
		5: Polling interval in seconds <NUMBER> (default: 5)

	Returns: Nothing.
*/

params ["_spawnOne", "_waveTickets", "_waveDelay", "_wavePos", "_waveRadius", ["_wavePoll", 5]];
if (!([] call lmf_ai_fnc_isSpawner) || {!canSuspend}) exitWith {};
_wavePoll = _wavePoll max 0.1;

private _isFinished = {
	params ["_primary"];
	if (isNull _primary) exitWith {true};
	if (_primary isEqualType grpNull) exitWith {units _primary findIf {alive _x} == -1};
	!alive _primary
};

while {_waveTickets > 0} do {
	private _proximity = [_wavePos, _waveRadius] call lmf_ai_fnc_getPlayerProximityState;
	while {_proximity == "airClose"} do {
		sleep _wavePoll;
		_proximity = [_wavePos, _waveRadius] call lmf_ai_fnc_getPlayerProximityState;
	};
	if (_proximity == "groundClose") exitWith {};

	private _primary = call _spawnOne;
	// Stop failed sources without retrying.
	if (isNil "_primary") exitWith {};
	if !(_primary isEqualType grpNull || {_primary isEqualType objNull}) exitWith {};
	if (isNull _primary || {[_primary] call _isFinished}) exitWith {};
	_waveTickets = _waveTickets - 1;
	if (_waveTickets <= 0) exitWith {};

	waitUntil {
		sleep _wavePoll;
		_proximity = [_wavePos, _waveRadius] call lmf_ai_fnc_getPlayerProximityState;
		_proximity == "groundClose" || {[_primary] call _isFinished}
	};
	if (_proximity == "groundClose") exitWith {};
	if (_waveDelay > 0) then {sleep _waveDelay;};
};
