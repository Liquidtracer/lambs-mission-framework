/*
	Paced AI creation
	Internal unscheduled server worker, active only while requests exist.
	Creates at most one soldier per callback; schedules from actual completion, never catches up.
	Drone engine crew creation is an intentional atomic exception within the same queue.
*/

if (lmf_ai_spawnQueue isEqualTo []) exitWith {lmf_ai_spawnWorkerActive = false};
// CBA timers use frame-based mission time; also gate actual creation against wall time.
private _remaining = (missionNamespace getVariable ["lmf_ai_nextSpawnAt", 0]) - diag_tickTime;
if (_remaining > 0) exitWith {
	[{[] call lmf_ai_fnc_processSpawnQueue}, [], _remaining] call CBA_fnc_waitAndExecute;
};
(lmf_ai_spawnQueue deleteAt 0) params ["_promise", "_request"];
_request params ["_group", "_class", "_position", "_placement", ["_vehicle", objNull], ["_seat", ""], ["_staged", false]];
private _result = objNull;
if (_class == "") then {
	_result = grpNull;
	if (alive _vehicle && {local _vehicle}) then {
		_result = createVehicleCrew _vehicle;
		_result setVariable ["lmf_ai_spawning", true];
	};
} else {
	if (!isNull _group && {local _group} && {_seat isEqualTo "" || {alive _vehicle && {local _vehicle}}}) then {
		if (!isNull _vehicle && {!_staged}) then {_position = getPos _vehicle};
		_result = _group createUnit [_class, _position, [], 0, _placement];
		if (!isNull _result) then {
			// Match spawnGroup's side normalization without moving into a temporary group.
			if (_placement == "FORM") then {[_result] joinSilent _group; _result setDir 0};
			_result setVariable ["lmf_ai_spawnSeat", [_vehicle, _seat]];
			if (_staged) then {
				_result allowDamage false;
				_result hideObjectGlobal true;
				_result enableSimulationGlobal false;
			} else {
				[_result] call lmf_ai_fnc_seatSpawnedUnit;
			};
		};
	};
};
// Arm the next callback before resolving: continuations execute unscheduled here.
lmf_ai_nextSpawnAt = diag_tickTime + 0.1;
[{[] call lmf_ai_fnc_processSpawnQueue}, [], 0.1] call CBA_fnc_waitAndExecute;
_promise terminate _result;
