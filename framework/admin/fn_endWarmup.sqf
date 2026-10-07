/*
	End warmup
	Ends the warmup phase.

	Arguments:
		0: Requesting admin <OBJECT>

	Example:
		[player] call lmf_admin_fnc_endWarmup;
*/

params ["_unit"];

#include "checkAdminAccess.sqf"

[] spawn {
	if (lmf_warmup) then {
		_result = ["Start mission?", "START MISSION", "OK", true] call BIS_fnc_guiMessage;
		if (_result) then {
			lmf_warmup = false;
			publicVariable "lmf_warmup";
		};
	};
};