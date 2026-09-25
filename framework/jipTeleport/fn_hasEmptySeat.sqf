/*
    Teleport seat availability
    Accepts a player or vehicle; moveInAny reports whether the move succeeds at use.

    Arguments:
        0: Player or vehicle <OBJECT>

    Example:
        [transport_1] call lmf_jipTeleport_fnc_hasEmptySeat;

    Returns: Whether an eligible vehicle has an empty seat <BOOLEAN>
*/

params [["_target", objNull, [objNull]]];
if (isNull _target) exitWith {false};

private _vehicle = vehicle _target;
if (!alive _vehicle || {_vehicle isKindOf "CAManBase"} || {_vehicle isKindOf "ParachuteBase"}) exitWith {false};

// All positions (including cargo/FFV); matches the ordinary moveInAny syntax.
(_vehicle emptyPositions "") > 0
