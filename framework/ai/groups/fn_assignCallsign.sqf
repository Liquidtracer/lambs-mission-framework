/*
	Assign callsign
	Assigns a sequential callsign to an AI group.
	Must be executed on the server.
	Prefixes used here are treated as reserved LMF prefixes.
	Author: Alex2k.

	Arguments:
		0: Group <GROUP>
		1: Prefix <STRING>
		2: Number separator <STRING> (default: "-")
		3: Suffix <STRING> (default: "")

	Example:
		[grp1, "ATLAS"] call lmf_ai_fnc_assignCallsign;

	Returns: Assigned callsign, or an empty string on failure <STRING>
*/

params [
	["_group", grpNull, [grpNull]],
	["_prefix", "", [""]],
	["_separator", "-", [""]],
	["_suffix", "", [""]]
];

if (!isServer) exitWith {""};
if (isNull _group || {_prefix isEqualTo ""}) exitWith {""};

private _callsign = "";
// Concurrent scheduled spawners must reserve and apply each number together.
isNil {
	if (isNil "lmf_ai_callsignCounters") then {lmf_ai_callsignCounters = createHashMap};
	private _number = (lmf_ai_callsignCounters getOrDefault [_prefix, 0]) + 1;
	lmf_ai_callsignCounters set [_prefix, _number];
	_callsign = format ["%1%2%3%4", _prefix, _separator, _number, _suffix];
	_group setGroupIdGlobal [_callsign];
};

_callsign
