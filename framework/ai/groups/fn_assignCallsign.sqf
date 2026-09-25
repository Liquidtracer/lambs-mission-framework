/*
    Assign callsign
    Assigns a sequential callsign to an AI group.
    Must be executed on the server.
    Prefixes used here are treated as reserved LMF prefixes.
    Author: Alex2k.

    Arguments:
        0: Group <GROUP>
        1: Prefix <STRING>

    Example:
        [grp1, "ATLAS"] call lmf_ai_fnc_assignCallsign;

    Returns: Assigned callsign, or an empty string on failure <STRING>
*/

params [
    ["_group", grpNull, [grpNull]],
    ["_prefix", "", [""]]
];

if (!isServer) exitWith {""};
if (isNull _group || {_prefix isEqualTo ""}) exitWith {""};

if (isNil "lmf_ai_callsignCounters") then {
    lmf_ai_callsignCounters = createHashMap;
};

private _number = (lmf_ai_callsignCounters getOrDefault [_prefix, 0]) + 1;
lmf_ai_callsignCounters set [_prefix, _number];

private _callsign = format ["%1-%2", _prefix, _number];
_group setGroupIdGlobal [_callsign];

_callsign
