/*
	Map configuration
	Enables map textures and optionally restricts shared markers.
	Author: Alex2k.
*/

if !(hasInterface) exitWith {};

[{getClientStateNumber > 8}, {
	[{visibleMap}, {
		// Enable map textures.
		ctrlActivate ((findDisplay 12) displayCtrl 107);
		// Hide and disable the texture toggle in old-school mode.
		if (lmf_oldSchoolMap) then {
			disableSerialization;
			private _display = uiNamespace getVariable "RSCDiary";
			private _ctrl = _display displayCtrl 1201;
			_ctrl ctrlEnable false;
			_ctrl ctrlSetTextColor [0, 0, 0, 0];
			_ctrl ctrlSetTooltip "";
			_ctrl ctrlCommit 0;
		};
	}, []] call CBA_fnc_waitUntilAndExecute;

	// Remove existing user markers and hide incoming shared markers in old-school mode.
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
