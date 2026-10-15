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
	if (lmf_warmup_isActive) then {
		private _result = ["Start mission?", "Start Mission", "OK", true] call BIS_fnc_guiMessage;
		if (_result) then {
			lmf_warmup_isActive = false;
			publicVariable "lmf_warmup_isActive";
		};
	};
};