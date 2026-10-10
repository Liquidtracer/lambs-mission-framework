/*
	Personal arsenal
	Registers one inherited client self-action after the intro. ACE owns inventory handling.
	UI restrictions apply only to the local LMF holder, not other mission arsenals.
	Author: Alex2k. Contributor: Drgn V4karian.
*/

if (!hasInterface || {!lmf_playerGear} || {!lmf_personalArsenal} || {!lmf_warmup}) exitWith {};
if (missionNamespace getVariable ["lmf_equipment_personalArsenalInitialized", false]) exitWith {};
lmf_equipment_personalArsenalInitialized = true;

waitUntil {sleep 1; !isNil "lmf_warmup_isActive"};
waitUntil {uiSleep 0.2; missionNamespace getVariable ["lmf_player_introComplete", false]};
if (!lmf_warmup_isActive) exitWith {};

// A private local holder avoids changing arsenals attached to players or mission objects.
lmf_equipment_personalArsenalBox = "Land_HelipadEmpty_F" createVehicleLocal [0, 0, 0];

["ace_arsenal_displayOpened", {
	params ["_display"];
	if ((missionNamespace getVariable ["ace_arsenal_currentBox", objNull]) isNotEqualTo lmf_equipment_personalArsenalBox) exitWith {};

	// ACE has applied its Favorites default, but has not filled the panels yet.
	// Override only this display session; ACE clears favoritesOnly on close.
	ace_arsenal_favoritesOnly = false;
	(_display displayCtrl 1006) ctrlSetText format ["%1: %2", localize "STR_GEAR_ITEMS", localize "str_word_all"];

	// ACE IDCs: loadouts, export, import, cargo plus/minus, Remove All.
	// Clear click handlers too: ACE can re-enable cargo controls when the panel updates.
	{
		private _control = _display displayCtrl _x;
		_control ctrlSetEventHandler ["ButtonClick", ""];
		_control ctrlSetEventHandler ["MouseButtonClick", ""];
		_control ctrlEnable false;
		_control ctrlSetTooltip "Unavailable in Personal Arsenal";
	} forEach [1003, 1004, 1005, 102, 101, 40];

	// Replace this display's handler: a stacked EH would still let ACE import or change cargo.
	// Other keys retain ACE navigation/search/vision behavior. This private callback expects
	// [event name, event arguments] and needs regression testing when ACE is updated.
	_display displaySetEventHandler ["KeyDown", toString {
		params ["_display", "_key", "_shift", "_ctrl"];
		if (_ctrl && {_key in [46, 47]}) exitWith {true}; // Ctrl+C / Ctrl+V
		if (_key in [203, 205] && {missionNamespace getVariable ["ace_arsenal_rightTabLnBFocus", false]}) exitWith {true}; // Left / Right
		["KeyDown", _this] call ace_arsenal_fnc_onKeyDown
	}];

	// Preserve the existing lighting, with cleanup bound to this display.
	private _lights = [];
	{
		private _light = "#lightpoint" createVehicleLocal position ace_arsenal_center;
		_light setLightBrightness 1;
		_light setLightAmbient [0, 0, 0];
		_light setLightColor [1, 1, 1];
		_light lightAttachObject [ace_arsenal_center, _x];
		_lights pushBack _light;
	} forEach [[0, 3, 5], [0, -3, 5]];
	_display setVariable ["lmf_equipment_arsenalLights", _lights];
	_display displayAddEventHandler ["Unload", {
		params ["_display"];
		{deleteVehicle _x} forEach (_display getVariable ["lmf_equipment_arsenalLights", []]);
	}];
}] call CBA_fnc_addEventHandler;

// Shared by both panel events; runs only for this client's Personal Arsenal.
lmf_equipment_fnc_restrictArsenalPanel = {
	params ["_display", "_leftPanel", "_rightPanel", "_listId"];
	if ((missionNamespace getVariable ["ace_arsenal_currentBox", objNull]) isNotEqualTo lmf_equipment_personalArsenalBox) exitWith {};

	// Left fill follows identity-tab initialization; right fill follows container-tab activation.
	// Match ACE's disabled identity-tab appearance without hiding any category icons.
	{
		private _control = _display displayCtrl _x;
		_control ctrlSetEventHandler ["ButtonClick", ""];
		_control ctrlSetEventHandler ["MouseButtonClick", ""];
		_control ctrlEnable false;
		_control ctrlSetFade ([0.6, 0] select (_x == 1006));
		_control ctrlCommit 0;
		_control ctrlSetTooltip "Unavailable in Personal Arsenal";
	} forEach [2033, 2035, 2037, 2026, 2022, 2031, 2029, 2024, 1006];

	private _isWeapon = _leftPanel in [2002, 2004, 2006];
	private _isContainer = _leftPanel in [2010, 2012, 2014];
	private _hideRightPanel = _isContainer || {_leftPanel == 2020};
	if (_isWeapon || {_hideRightPanel}) then {
		// Cargo controls/backgrounds, loaded magazines (including secondary muzzle), and load bar.
		private _hidden = [7, 15, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 101, 102, 3001, 3002, 3003, 3004];
		for "_idc" from 60 to 79 do {_hidden pushBack _idc}; // ACE custom cargo categories.
		if (_hideRightPanel) then {
			// Entire right panel, including attachment tabs, sorting and search.
			_hidden append [5, 6, 14, 17, 171, 19, 42, 21, 22, 23, 24, 25, 26, 27, 28];
		};
		{
			private _control = _display displayCtrl _x;
			_control ctrlShow false;
			_control ctrlEnable false;
		} forEach _hidden;
	};
	if (_listId == -1) exitWith {}; // Visibility refresh after ACE's Hide/Show UI toggle.
	if (_isContainer && {_listId == 14}) then {
		// ACE's later updateRightPanel can show Remove All again, after rightPanelFilled.
		[{
			params ["_display", "_leftPanel"];
			if (isNull _display || {(missionNamespace getVariable ["ace_arsenal_currentLeftPanel", -1]) != _leftPanel}) exitWith {};
			[_display, _leftPanel, -1, -1] call lmf_equipment_fnc_restrictArsenalPanel;
		}, [_display, _leftPanel]] call CBA_fnc_execNextFrame;
	};

	// Left filling precedes selection: do not carry a binocular's loaded-magazine tab into weapons.
	if (_isWeapon && {_listId == 13} && {(missionNamespace getVariable ["ace_arsenal_currentRightPanel", -1]) in [3002, 3004]}) then {
		ace_arsenal_currentRightPanel = 22;
	};
	if (_isWeapon && {_listId == 14} && {!(_rightPanel in [22, 24, 26, 28])}) exitWith {
		// An internal refresh can still request a hidden tab. Empty its UI list before ACE's
		// final selection, then reopen optics after that fill completes (no nested panel fill).
		lbClear (_display displayCtrl 14);
		[{
			params ["_display", "_leftPanel", "_rightPanel"];
			if (isNull _display) exitWith {};
			if ((missionNamespace getVariable ["ace_arsenal_currentBox", objNull]) isNotEqualTo lmf_equipment_personalArsenalBox) exitWith {};
			if (ace_arsenal_currentLeftPanel != _leftPanel || {ace_arsenal_currentRightPanel != _rightPanel}) exitWith {};
			[_display, _display displayCtrl 22, false] call ace_arsenal_fnc_fillRightPanel;
		}, [_display, _leftPanel, _rightPanel]] call CBA_fnc_execNextFrame;
	};

	// Right-side Empty exists only in weapon/binocular attachment and loaded-magazine lists.
	// Container cargo uses listnbox 15, has no Empty row, and keeps its existing cargo restrictions.
	if (_listId == 14 && {!(_leftPanel in [2002, 2004, 2006, 2020]) || {!(_rightPanel in [22, 24, 26, 28, 3002, 3004])}}) exitWith {};

	// Both fill events precede ACE's final sorting and selection. Deleting Empty there would
	// make ACE's default lbSetCurSel 0 equip the first alternative in an empty slot.
	[{
		params ["_display", "_leftPanel", "_rightPanel", "_listId"];
		if (isNull _display) exitWith {};
		if ((missionNamespace getVariable ["ace_arsenal_currentBox", objNull]) isNotEqualTo lmf_equipment_personalArsenalBox) exitWith {};
		if ((missionNamespace getVariable ["ace_arsenal_currentLeftPanel", -1]) != _leftPanel) exitWith {};
		if (_listId == 14 && {(missionNamespace getVariable ["ace_arsenal_currentRightPanel", -1]) != _rightPanel}) exitWith {};

		private _list = _display displayCtrl _listId;
		private _emptyRow = -1;
		for "_row" from 0 to (lbSize _list - 1) do {
			if ((_list lbValue _row) == -1 && {(_list lbData _row) == ""}) exitWith {_emptyRow = _row};
		};
		if (_emptyRow == -1) exitWith {};

		// Deselect before deletion so a selected Empty row cannot select its successor.
		// Both ACE selection handlers ignore -1. Restore only the same non-empty item.
		private _selection = lbCurSel _list;
		_list lbSetCurSel -1;
		_list lbDelete _emptyRow;
		if (_selection >= 0 && {_selection != _emptyRow}) then {
			_list lbSetCurSel (_selection - ([0, 1] select (_selection > _emptyRow)));
		};
	}, _this] call CBA_fnc_execNextFrame;
};

["ace_arsenal_leftPanelFilled", {
	params ["_display", "_leftPanel"];
	[_display, _leftPanel, -1, 13] call lmf_equipment_fnc_restrictArsenalPanel;
}] call CBA_fnc_addEventHandler;

["ace_arsenal_rightPanelFilled", {
	params ["_display", "_leftPanel", "_rightPanel"];
	[_display, _leftPanel, _rightPanel, 14] call lmf_equipment_fnc_restrictArsenalPanel;
}] call CBA_fnc_addEventHandler;

["ace_arsenal_showToggle", {
	params ["_display", "_shown"];
	if (!_shown) exitWith {};
	[_display, missionNamespace getVariable ["ace_arsenal_currentLeftPanel", -1], -1, -1] call lmf_equipment_fnc_restrictArsenalPanel;
}] call CBA_fnc_addEventHandler;

private _action = ["lmf_equipment_personalArsenal", "Personal Arsenal", ["A3\ui_f_orange\Data\CfgOrange\Missions\orange_escape_ca.paa", LMF_MAIN_COLOR], {
	params ["_target", "_player"];
	[_player] call lmf_equipment_fnc_openPersonalArsenal;
}, {
	params ["_target", "_player"];
	lmf_warmup_isActive && {alive _player} && {[_player, _target] call ace_common_fnc_canInteractWith}
}] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions", "ACE_Equipment"], _action, true] call ace_interact_menu_fnc_addActionToClass;
