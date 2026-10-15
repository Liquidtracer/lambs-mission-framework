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
		6: Optional ZEN feedback [player object, label] <ARRAY> (default: []; first attempt only)

	Returns: Nothing.
*/

params ["_spawnOne", "_waveTickets", "_waveDelay", "_wavePos", "_waveRadius", ["_wavePoll", 5], ["_waveFeedback", [], [[]]]];
if (!([] call lmf_ai_fnc_isSpawner) || {!canSuspend}) exitWith {};
_wavePoll = _wavePoll max 0.1;

private _isFinished = {
	params ["_primary"];
	if (isNull _primary) exitWith {true};
	if (_primary isEqualType grpNull) exitWith {units _primary findIf {alive _x} == -1};
	!alive _primary
};

if (_waveTickets <= 0) exitWith {
	[_waveFeedback, "Cancelled", "No spawn tickets"] call lmf_ai_fnc_reportSpawn;
};

while {_waveTickets > 0} do {
	private _proximity = [_wavePos, _waveRadius] call lmf_ai_fnc_getPlayerProximityState;
	if (_proximity == "airClose") then {
		[_waveFeedback, "Waiting", "Airborne player nearby"] call lmf_ai_fnc_reportSpawn;
	};
	while {_proximity == "airClose"} do {
		sleep _wavePoll;
		_proximity = [_wavePos, _waveRadius] call lmf_ai_fnc_getPlayerProximityState;
	};
	if (_proximity == "groundClose") exitWith {
		[_waveFeedback, "Cancelled", format ["Player within %1m", _waveRadius]] call lmf_ai_fnc_reportSpawn;
	};

	private _primary = call _spawnOne;
	// Stop failed sources without retrying.
	if (isNil "_primary") exitWith {[_waveFeedback, "Failed", "Spawner returned no result."] call lmf_ai_fnc_reportSpawn;};
	if !(_primary isEqualType grpNull || {_primary isEqualType objNull}) exitWith {[_waveFeedback, "Failed", "Spawner returned an invalid result."] call lmf_ai_fnc_reportSpawn;};
	if (isNull _primary || {[_primary] call _isFinished}) exitWith {[_waveFeedback, "Failed", "No living group or vehicle remained after preparation."] call lmf_ai_fnc_reportSpawn;};
	[_waveFeedback, "Success", "Group or vehicle created and initialized; insertion may continue."] call lmf_ai_fnc_reportSpawn;
	// Only the first attempt belongs to the initiating ZEN request.
	_waveFeedback = [];
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
