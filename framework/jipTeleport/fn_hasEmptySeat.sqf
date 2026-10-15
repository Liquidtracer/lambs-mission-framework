/*
	Teleport seat availability
	Accepts a player or vehicle; moveInAny reports whether the move succeeds at use.

	Arguments:
		0: Player or vehicle <OBJECT>

	Example:
		[transport_1] call lmf_jipTeleport_fnc_hasEmptySeat;

	Returns: Whether an eligible vehicle has an unlocked ordinary cargo seat <BOOLEAN>
*/

params [["_target", objNull, [objNull]]];
if (isNull _target) exitWith {false};

private _vehicle = vehicle _target;
if (!alive _vehicle || {_vehicle isKindOf "CAManBase"} || {_vehicle isKindOf "ParachuteBase"}) exitWith {false};

// Ordinary cargo only, excluding FFV; respect locks as in the destination moveInAny call.
(_vehicle emptyPositions ["CARGO", false]) > 0
