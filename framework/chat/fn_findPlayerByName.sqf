/*
    Find player by name
    Finds a player by a full or partial name, ignoring case. Returns objNull when no player or more than one player matches.
    Author: Cuel (2015-04-21).

    Arguments:
        0: Player name or fragment <STRING>

    Example:
        ["Cuel"] call lmf_chat_fnc_findPlayerByName;

    Returns: Matching player or objNull <OBJECT>
*/

params ["_name"];
private _matches = [];
{
  if ([_name, name _x] call BIS_fnc_inString) then {
    _matches pushBack _x;
  };
} forEach ([] call CBA_fnc_players);

if (count _matches == 1) exitWith {_matches select 0};
objNull