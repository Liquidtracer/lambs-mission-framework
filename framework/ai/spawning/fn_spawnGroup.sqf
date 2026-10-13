/*
	Spawn paced infantry
	Internal scheduled server helper for LMF class arrays, not the full BIS spawnGroup API.
	Preserves FORM placement, north heading and highest-rank leadership in one group.
	Returns GROUP after InitPost/gear attempts. Caller clears lmf_ai_spawning after task setup.
	Arguments: position, side, classes, optional vehicle, seat (ANY/CARGO), staged.
*/

params ["_position", "_side", "_classes", ["_vehicle", objNull], ["_seat", ""], ["_staged", false]];
if (!canSuspend || {!([] call lmf_ai_fnc_isSpawner)}) exitWith {grpNull};
if (_classes isEqualTo [] || {_classes findIf {getNumber (configFile >> "CfgVehicles" >> _x >> "isMan") != 1} != -1}) exitWith {grpNull};
private _group = createGroup _side;
if (isNull _group) exitWith {grpNull};
_group setVariable ["lmf_ai_spawning", true];
private _failed = false;
{
	if (isNull _group || {!local _group}) exitWith {_failed = true};
	private _unit = [_group, _x, _position, "FORM", _vehicle, _seat, _staged] call lmf_ai_fnc_requestSpawn;
	if (isNull _unit) exitWith {_failed = true};
} forEach _classes;
if (_failed) exitWith {
	{
		if (local _x) then {
			private _parent = objectParent _x;
			if (isNull _parent) then {deleteVehicle _x} else {_parent deleteVehicleCrew _x};
		};
	} forEach units _group;
	if (local _group) then {deleteGroup _group};
	grpNull
};
[_group] call lmf_ai_fnc_waitForSpawnInit;
private _leader = objNull;
{
	if (alive _x && {isNull _leader || {rankId _x > rankId _leader}}) then {_leader = _x};
} forEach units _group;
if (!isNull _leader) then {_group selectLeader _leader};
_group
