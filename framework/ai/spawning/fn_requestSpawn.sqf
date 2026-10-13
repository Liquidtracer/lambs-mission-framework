/*
	Request AI creation
	Internal scheduled server entrypoint. Queues one soldier or an atomic drone crew operation.
	Returns the created OBJECT (soldier) or GROUP (drone), using a native local promise.
	Arguments: group, class (empty for drone crew), position, placement, vehicle, seat, staged.
*/

if (!canSuspend || {!([] call lmf_ai_fnc_isSpawner)}) exitWith {objNull};
private _promise = spawn "LMF AI creation";
isNil {
	if (isNil "lmf_ai_spawnQueue") then {lmf_ai_spawnQueue = []};
	lmf_ai_spawnQueue pushBack [_promise, _this];
	if !(missionNamespace getVariable ["lmf_ai_spawnWorkerActive", false]) then {
		lmf_ai_spawnWorkerActive = true;
		[] call lmf_ai_fnc_processSpawnQueue;
	};
};
waitUntil _promise
