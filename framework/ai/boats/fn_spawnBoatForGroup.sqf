/*
    Spawn boat for group
    Converts an infantry group spawned over water into a boat assault group.
    Does nothing when the spawn position is not over water.

    Arguments:
        0: Spawn position <ARRAY>
        1: Infantry group <GROUP>
        2: Boat classname <STRING>

    Example:
        [[1200, 2400, 0], grp1, "O_Boat_Armed_01_hmg_F"] call lmf_ai_fnc_spawnBoatForGroup;
*/

params ["_spawnPos", "_grp", "_typeOfVehicle"];

if !(surfaceIsWater _spawnPos) exitWith {};

private _pos = [_spawnPos select 0, _spawnPos select 1, 0.5];
private _veh = createVehicle [_typeOfVehicle, _pos, [], 0, "NONE"];
_veh setUnloadInCombat [false, false];

{
	_x moveInAny _veh;
} forEach (units _grp);

{deleteVehicle _x} forEach ((units _grp) select {isNull objectParent _x});

_grp setGroupIDGlobal [format ["Boat %1", groupId _grp]];
_grp setBehaviourStrong "CARELESS";
_grp setSpeedMode "FULL";

[_grp] call lmf_ai_fnc_initBoatAssault;
