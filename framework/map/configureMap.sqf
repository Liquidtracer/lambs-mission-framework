/*
	Map configuration
	Auto activates map textures.
	Adds "Oldschool map system" that deletes markers that aren't local to the player.
	Author: Alex2k.
*/

if !(hasInterface) exitWith {};

[{getClientStateNumber > 8}, {
	// Modify map controls
	[{visibleMap}, {
		// Auto activate the textures button
		ctrlActivate ((findDisplay 12) displayCtrl 107);
		// (Removes textures button)
		if (lmf_oldSchoolMap) then {
			disableSerialization;
			_display = uiNamespace getVariable "RSCDiary";
			_ctrl = _display displayCtrl 1201;
			_ctrl ctrlEnable false;
			_ctrl ctrlSetTextColor [0, 0, 0, 0];
			_ctrl ctrlSetTooltip "";
			_ctrl ctrlCommit 0;
		};
	}, []] call CBA_fnc_waitUntilAndExecute;

	// Oldschool map system
	if (lmf_oldSchoolMap) then {
		{
			if ((_x find "_USER_DEFINED #") != -1) then {deleteMarkerLocal _x};
		} forEach allMapMarkers;

		addMissionEventHandler ["MarkerCreated", {
			params ["_marker", "_channelNumber", "_owner", "_local"];
			if (!_local) then {deleteMarkerLocal _marker};
		}];
	};
}, []] call CBA_fnc_waitUntilAndExecute;
