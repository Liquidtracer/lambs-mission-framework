/*
	Personal arsenal
	Provides personal arsenal and available-optics actions during warmup.
	Uses the starting slot's headgear and goggles, with the same Rifleman fallback as applyBaseLoadout.
	Author: Alex2k. Contributor: Drgn V4karian.
*/

if (!var_playerGear || {!var_personalArsenal} || {!var_warmup}) exitWith {};
["Preload"] call BIS_fnc_arsenal;

#include "..\..\settings\cfg_Player.sqf"

waitUntil {sleep 1; !isNil "lmf_warmup"};
waitUntil {uiSleep 0.2; missionNamespace getVariable ["lmf_player_introComplete", false]};
if !(lmf_warmup) exitWith {};

// Add gear based on roles
private _role = typeOf player;
// Infantry roles
// Rifleman
if (_role == _rifleman#0) then {
	[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
};
// Platoon leader
if (_role == _platoonLeader#0) then {
	if (_plHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _plHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_plGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _plGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Platoon sergeant
if (_role == _platoonSgt#0) then {
	if (_psgHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _psgHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_psgGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _psgGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Medic
if (_role == _medic#0) then {
	if (_medHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _medHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_medGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _medGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Squad leader
if (_role == _squadLeader#0) then {
	if (_slHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _slHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_slGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _slGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Team leader
if (_role == _teamLeader#0) then {
	if (_tlHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _tlHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_tlGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _tlGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Autorifleman
if (_role == _autorifleman#0) then {
	if (_arHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _arHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_arGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _arGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// AT specialist
if (_role == _antiTankGunner#0) then {
	if (_atHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _atHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_atGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _atGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// AT assistant
if (_role == _antiTankAssistant#0) then {
	if (_ataHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _ataHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_ataGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _ataGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Machine gunner
if (_role == _machineGunner#0) then {
	if (_mgHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _mgHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_mgGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _mgGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Assistant machine gunner
if (_role == _machineGunnerAssistant#0) then {
	if (_mgaHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _mgaHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_mgaGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _mgaGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Grenadier
if (_role == _grenadier#0) then {
	if (_gHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _gHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_gGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _gGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// RTO
if (_role == _rto#0) then {
	if (_rtoHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _rtoHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_rtoGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _rtoGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// JTAC
if (_role == _jtac#0) then {
	if (_jtacHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _jtacHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_jtacGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _jtacGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};

// Aircrew roles
// Helicopter pilot
if (_role == _heloPilot#0) then {
	[player, [_hpHeadgear, _rHeadgear] select (_hpHeadgear isEqualTo [""]), false, false] call BIS_fnc_addVirtualItemCargo;
	[player, [_hpGoggles, _rGoggles] select (_hpGoggles isEqualTo [""]), false, false] call BIS_fnc_addVirtualItemCargo;
};
// Helicopter crew
if (_role == _heloCrew#0) then {
	if (_hcHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _hcHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_hcGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _hcGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Plane pilot
if (_role == _pilot#0) then {
	if (_pHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _pHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_pGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _pGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};

// Ground vehicle roles
// Vehicle platoon leader
if (_role == _crewLeader#0) then {
	[player, [_vplHeadgear, _rHeadgear] select (_vplHeadgear isEqualTo [""]), false, false] call BIS_fnc_addVirtualItemCargo;
	[player, [_vplGoggles, _rGoggles] select (_vplGoggles isEqualTo [""]), false, false] call BIS_fnc_addVirtualItemCargo;
};
// Vehicle platoon sergeant / vehicle commander
if (_role == _crewSgt#0) then {
	if (_vpsgHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _vpsgHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_vpsgGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _vpsgGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
};
// Vehicle crew
if (_role == _crew#0) then {
	if (_vcHeadgear isEqualTo [""]) then {
		[player, _rHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _vcHeadgear, false, false] call BIS_fnc_addVirtualItemCargo;
	};
	if (_vcGoggles isEqualTo [""]) then {
		[player, _rGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	} else {
		[player, _vcGoggles, false, false] call BIS_fnc_addVirtualItemCargo;
	};
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
private _personalArsenal = ["personalArsenal", "Personal Arsenal", ["A3\ui_f_orange\Data\CfgOrange\Missions\orange_escape_ca.paa", LMF_MAIN_COLOR], {["Open", [false, player, player]] spawn bis_fnc_arsenal; player action ["SwitchWeapon", player, player, 100];}, {lmf_warmup}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "ACE_Equipment"], _personalArsenal] call ace_interact_menu_fnc_addActionToObject;

private _specialRoles = [_crew#0, _heloPilot#0, _heloCrew#0, _pilot#0, _crewLeader#0, _crewSgt#0];
if (_specialRoles findIf {_x == _role} != -1) exitWith {};

// Available optics action
if (isNil "_availableOptics") exitWith {};
if (_availableOptics isEqualTo [""]) exitWith {};
lmf_player_availableOptics = _availableOptics;

_condition = {
	lmf_warmup
};
_statement = {
	params ["_target", "_player", "_params"];
	// Run on hover:
	// ["ace_common_displayTextStructured", ["someone is thinking of giving you items", 1.5, _target], [_target]] call CBA_fnc_targetEvent;
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
		private _action = [format ["item:%1", _x], _displayName, "", _childStatement, {true}, {}, _x] call ace_interact_menu_fnc_createAction;
		_actions pushBack [_action, [], _target]; // New action, it's children, and the action's target
	} forEach lmf_player_availableOptics;

	_actions
};
_modifierFunc = {
	params ["_target", "_player", "_params", "_actionData"];
	// Modify the action - index 1 is the display name, 2 is the icon...
	// _actionData set [1, format ["Available Optics: %1", count lmf_player_availableOptics]];
};
_action = ["availableOptics", "Available Optics", ["\A3\ui_f_curator\data\rsccommon\rscattributeinventory\filter_7_ca.paa", LMF_MAIN_COLOR], _statement, _condition, _insertChildren, [123], "", 4, [false, false, false, true, false], _modifierFunc] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions", "ACE_Equipment"], _action] call ace_interact_menu_fnc_addActionToObject;
