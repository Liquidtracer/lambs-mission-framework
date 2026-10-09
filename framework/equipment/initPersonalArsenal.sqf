/*
	Personal arsenal
	Provides personal arsenal and available-optics actions during warmup.
	Uses the starting slot's headgear and goggles, with the same Rifleman fallback as applyBaseLoadout.
	Author: Alex2k. Contributor: Drgn V4karian.
*/

if (!lmf_playerGear || {!lmf_personalArsenal} || {!lmf_warmup}) exitWith {};
["Preload"] call BIS_fnc_arsenal;

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _availableOptics = _config get "AVAILABLE_OPTICS";

waitUntil {sleep 1; !isNil "lmf_warmup_isActive"};
waitUntil {uiSleep 0.2; missionNamespace getVariable ["lmf_player_introComplete", false]};
if !(lmf_warmup_isActive) exitWith {};

// Add gear based on the starting slot; clothing inheritance is resolved by the registry.
private _roleKey = (_config get "ROLE_BY_CLASS") getOrDefault [toLower (typeOf player), ""];
if (_roleKey isNotEqualTo "") then {
	private _clothing = ((_config get "ROLES") get _roleKey) get "CLOTHING";
	[player, _clothing get "HEADGEAR", false, false] call BIS_fnc_addVirtualItemCargo;
	[player, _clothing get "GOGGLES", false, false] call BIS_fnc_addVirtualItemCargo;
};

// Remove ability to randomize/save/load/export/import loadouts
[missionNamespace, "arsenalOpened", {
	disableSerialization;
	private _display = _this select 0;
	{
		(_display displayCtrl _x) ctrlSetTextColor [1, 0, 0, 0.3];
		(_display displayCtrl _x) ctrlRemoveAllEventHandlers "buttonclick";
		(_display displayCtrl _x) ctrlEnable false;
	} forEach [
		44150, // Random loadout
		44146, // Save loadout
		44147, // Load loadout
		44148, // Export loadout
		44149, // Import loadout
		44151, // Hide interface
		954, // Container: miscellaneous items
		930, // Rifle
		931, // Launcher
		932, // Handgun
		933, // Uniform
		934, // Vest
		935, // Backpack
		938, // NVG
		939, // Binoculars
		940, // Map
		941, // Terminal
		942, // Communication
		943, // Navigation
		944, // Watch
		900, // Rifle on character
		901, // Launcher on character
		902, // Handgun on character
		903, // Uniform on character
		904, // Vest on character
		905, // Backpack on character
		908, // NVG on character
		909 // Binoculars on character
	];
	_display displayAddEventHandler ["KeyDown", "true"];
}] call BIS_fnc_addScriptedEventHandler;

// On arsenal opened
[missionNamespace, "arsenalOpened", {
		// Light in front of player
		lmf_arsenalLight1 = "#lightpoint" createVehicleLocal position player;
		lmf_arsenalLight1 setLightBrightness 1;
		lmf_arsenalLight1 setLightAmbient [0.0, 0.0, 0.0];
		lmf_arsenalLight1 setLightColor [1.0, 1.0, 1.0];
		lmf_arsenalLight1 lightAttachObject [player, [0, 3, 5]];

		// Light behind player
		lmf_arsenalLight2 = "#lightpoint" createVehicleLocal position player;
		lmf_arsenalLight2 setLightBrightness 1;
		lmf_arsenalLight2 setLightAmbient [0.0, 0.0, 0.0];
		lmf_arsenalLight2 setLightColor [1.0, 1.0, 1.0];
		lmf_arsenalLight2 lightAttachObject [player, [0, -3, 5]];
}] call BIS_fnc_addScriptedEventHandler;

// On arsenal closed
[missionNamespace, "arsenalClosed", {
	deleteVehicle lmf_arsenalLight1;
	deleteVehicle lmf_arsenalLight2;
}] call BIS_fnc_addScriptedEventHandler;

// Add actions
private _personalArsenal = ["lmf_equipment_personalArsenal", "Personal Arsenal", ["A3\ui_f_orange\Data\CfgOrange\Missions\orange_escape_ca.paa", LMF_MAIN_COLOR], {["Open", [false, player, player]] spawn bis_fnc_arsenal; player action ["SwitchWeapon", player, player, 100];}, {lmf_warmup_isActive}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "ACE_Equipment"], _personalArsenal] call ace_interact_menu_fnc_addActionToObject;

private _specialRoles = ["VEHICLE_CREW", "HELICOPTER_PILOT", "HELICOPTER_CREW", "PILOT", "VEHICLE_PLATOON_LEADER", "VEHICLE_COMMANDER"];
if (_roleKey in _specialRoles) exitWith {};

// Available optics action
if (isNil "_availableOptics") exitWith {};
if (_availableOptics isEqualTo [""]) exitWith {};
lmf_player_availableOptics = _availableOptics;

_condition = {
	lmf_warmup_isActive
};
_statement = {
	params ["_target", "_player", "_params"];
};
_insertChildren = {
	params ["_target", "_player", "_params"];
	// Add children to this action
	private _actions = [];
	{
		private _childStatement = {
			_target addPrimaryWeaponItem (_this select 2);
			{
				if (_x in (items _target)) then {_target removeItem _x};
			} forEach lmf_player_availableOptics;
		};
		_displayName = [configFile >> "CfgWeapons" >> _x] call BIS_fnc_displayName;
		private _action = [format ["lmf_equipment_optic_%1", _x], _displayName, "", _childStatement, {true}, {}, _x] call ace_interact_menu_fnc_createAction;
		_actions pushBack [_action, [], _target]; // New action, it's children, and the action's target
	} forEach lmf_player_availableOptics;

	_actions
};
_modifierFunc = {
	params ["_target", "_player", "_params", "_actionData"];
};
_action = ["lmf_equipment_availableOptics", "Available Optics", ["\A3\ui_f_curator\data\rsccommon\rscattributeinventory\filter_7_ca.paa", LMF_MAIN_COLOR], _statement, _condition, _insertChildren, [123], "", 4, [false, false, false, true, false], _modifierFunc] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "ACE_Equipment"], _action] call ace_interact_menu_fnc_addActionToObject;
