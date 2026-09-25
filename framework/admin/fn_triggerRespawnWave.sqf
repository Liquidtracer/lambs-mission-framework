/*
    Trigger respawn wave
    Prompts the admin to start a respawn wave.

    Arguments:
        0: Requesting admin <OBJECT>

    Example:
        [player] call lmf_admin_fnc_triggerRespawnWave;
*/

params ["_unit"];

#include "checkAdminAccess.sqf"

[] spawn {
	private _parentDisplay = uiNamespace getVariable ["lmf_spectatorDisplay", displayNull];
	if (isNull _parentDisplay) then {
		_parentDisplay = [] call BIS_fnc_displayMission;
	};

	private _result = ["Trigger respawn wave?", "RESPAWN WAVE", "OK", true, _parentDisplay] call BIS_fnc_guiMessage;
	if (_result) then {
		private _deadPlayers = [] call ace_spectator_fnc_players;
		[30] remoteExec ["setPlayerRespawnTime", _deadPlayers, false];
	};
};
