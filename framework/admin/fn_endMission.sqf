/*
    End mission
    Ends the mission with the selected outcome.

    Arguments:
        0: Requesting admin <OBJECT>
        1: Victory <BOOLEAN> (default: true; false = defeat)

    Example:
        [player, true] call lmf_admin_fnc_endMission;
*/

params ["_unit",["_state",true]];

#include "checkAdminAccess.sqf"

[_state] spawn {
	params ["_state"];
	private _ending = if (_state) then {
		["End mission? (Victory)", "lmf_notifications_fnc_showVictory", "EveryoneWon"]
	} else {
		["End mission? (Defeat)", "lmf_notifications_fnc_showDefeat", "EveryoneLost"]
	};
	_ending params ["_message", "_hintFunction", "_endingName"];

	private _result = [_message, "END MISSION", "OK", true] call BIS_fnc_guiMessage;
	if (_result) then {
		remoteExec [_hintFunction];
		sleep 10;
		[_endingName] remoteExec ["BIS_fnc_endMissionServer", 2];
	};
};
