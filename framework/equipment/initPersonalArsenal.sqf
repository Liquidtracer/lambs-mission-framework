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

	// ACE IDCs: loadouts, export, import, cargo plus. Replace handlers as well as disabling buttons:
	// ACE can re-enable the plus control when a cargo row changes.
	{
		private _control = _display displayCtrl _x;
		_control ctrlSetEventHandler ["ButtonClick", ""];
		_control ctrlSetEventHandler ["MouseButtonClick", ""];
		_control ctrlEnable false;
		_control ctrlSetTooltip "Unavailable in Personal Arsenal";
	} forEach [1003, 1004, 1005, 102];

	// Replace this display's handler: a stacked EH would still let ACE import/add cargo.
	// Other keys retain ACE navigation/search/vision behavior. This private callback expects
	// [event name, event arguments] and needs regression testing when ACE is updated.
	_display displaySetEventHandler ["KeyDown", toString {
		params ["_display", "_key", "_shift", "_ctrl"];
		if (_ctrl && {_key in [46, 47]}) exitWith {true}; // Ctrl+C / Ctrl+V
		if (_key == 205 && {missionNamespace getVariable ["ace_arsenal_rightTabLnBFocus", false]}) exitWith {true};
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

private _action = ["lmf_equipment_personalArsenal", "Personal Arsenal", ["A3\ui_f_orange\Data\CfgOrange\Missions\orange_escape_ca.paa", LMF_MAIN_COLOR], {
	params ["_target", "_player"];
	[_player] call lmf_equipment_fnc_openPersonalArsenal;
}, {
	params ["_target", "_player"];
	lmf_warmup_isActive && {alive _player} && {[_player, _target] call ace_common_fnc_canInteractWith}
}] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions", "ACE_Equipment"], _action, true] call ace_interact_menu_fnc_addActionToClass;
