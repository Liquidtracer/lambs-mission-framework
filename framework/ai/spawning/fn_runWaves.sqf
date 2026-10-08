/*
	Run AI waves
	Manages replacements for one wave source, following only its primary group or object.
	Call from a scheduled server scope that keeps the spawn operation's locals alive.
	The public spawners handle startup waiting before entering this controller.
	Ends after spawning the final ticket; only pending replacements require a completion wait.
	Grounded player proximity ends the source; airborne proximity delays spawning.
	A missing, unsupported, null or already-finished delivery ends the source.

	Arguments:
		0: One-shot operation returning a GROUP or OBJECT <CODE>
		1: Total tickets, including the first spawn <NUMBER>
		2: Delay between completed delivery and replacement, seconds <NUMBER>
		3: Proximity position <OBJECT or ARRAY>
		4: Proximity radius in meters <NUMBER>
		5: Proximity and completion polling interval, seconds <NUMBER> (default: 5)

	Example (inside a scheduled spawner):
		[_spawnOnce, _tickets, 0, _spawnPos, 500, 10] call lmf_ai_fnc_runWaves;

	Returns: Nothing. Do not spawn a code closure that depends on caller locals.
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
	// Stop failed sources instead of spending tickets in a rapid retry loop.
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
