/*
	Supply-drop requests
	Registers supply-drop requests and ACE actions for selecting a delivery location.
	Server publishes a shared 30-second deadline; clients reject cooldown attempts before map selection.
	Requests carry position, category (or vehicle classname), requester and an actual-vehicle flag.
	Author: Alex2k. Contributor: G4rrus.
*/

// Server
if (isServer) then {
	if (markerColor "respawn" isEqualTo "") then {
		systemChat "LMF Supply Drop: 'respawn' marker required!";
	};

	lmf_supplyDropPos = getMarkerPos "respawn";

	lmf_remainingSuppDrops = lmf_supplyDropLimit;
	publicVariable "lmf_remainingSuppDrops";
	lmf_supplyDrop_nextRequest = 0;
	publicVariable "lmf_supplyDrop_nextRequest";

	["lmf_supplyDrop_request", {
		params ["_dropPos", "_selection", "_requester", ["_isVehicle", false, [true]]];
		private _category = "";
		private _crate = "";
		if (_isVehicle) then {
			if (lmf_supplyDropVehicles && {_selection in lmf_groundVehicles} && {_selection != ""} && {isClass (configFile >> "CfgVehicles" >> _selection)}) then {
				_crate = _selection;
			};
		} else {
			private _definition = [_selection] call lmf_supplyCrates_fnc_getDefinition;
			if (_definition isNotEqualTo []) then {
				_definition params ["_resolvedCategory", "_classname"];
				_category = _resolvedCategory;
				_crate = _classname;
			};
		};
		if (_crate isEqualTo "") exitWith {
			["lmf_supplyDrop_response", ["Requested supplies are unavailable.", true], _requester] call CBA_fnc_targetEvent;
		};
		// The server decides availability, including requests from already open dialogs.
		if (lmf_remainingSuppDrops <= 0) exitWith {
			["lmf_supplyDrop_response", ["No supply drops remaining.", true], _requester] call CBA_fnc_targetEvent;
		};
		private _remaining = ceil (lmf_supplyDrop_nextRequest - serverTime);
		if (_remaining > 0) exitWith {
			["lmf_supplyDrop_response", [format ["Supply drop available in %1 seconds.", _remaining], true], _requester] call CBA_fnc_targetEvent;
		};

		private _plane = lmf_supplyDropAircraft;

		// Calculate the spawn position.
		private _initPos = lmf_supplyDropPos;
		private _dir = _dropPos getDir _initPos;
		private _spawnPos = _initPos getPos [random 5000, _dir];
		if (_spawnPos distance2D _dropPos < 5000) then {
			_spawnPos = _initPos getPos [5000, _dir];
		};

		// Reserve the drop before starting the scheduled delivery script.
		lmf_supplyDrop_nextRequest = serverTime + 30;
		publicVariable "lmf_supplyDrop_nextRequest";
		lmf_remainingSuppDrops = lmf_remainingSuppDrops - 1;
		publicVariable "lmf_remainingSuppDrops";

		[_spawnPos, _dropPos, _plane, _crate, _category] spawn lmf_supplyDrop_fnc_deliverSupplies;

		if (lmf_remainingSuppDrops <= 0) then {
			["lmf_supplyDrop_availability", []] call CBA_fnc_globalEvent;
		};

		["lmf_supplyDrop_response", ["Supply drop requested.", false], _requester] call CBA_fnc_targetEvent;
	}] call CBA_fnc_addEventHandler;
};

// Player
if !(hasInterface) exitWith {};

// Report the server's decision to the requester, including concurrent requests.
["lmf_supplyDrop_response", {
	params ["_text", "_isError"];
	["Supply Drop", _text, "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", 2.6, 10, ["beep", "addItemFailed"] select _isError, 1, _isError] call lmf_notifications_fnc_showAceMessage;
}] call CBA_fnc_addEventHandler;

// Called once by the ordered client menu setup after replicated quota and deadline are available.
lmf_supplyDrop_fnc_registerMenu = {
	// Client availability survives respawn; JIP initializes from the replicated quota.
	lmf_supplyDrop_menuAvailable = lmf_remainingSuppDrops > 0;
	["lmf_supplyDrop_availability", {
		params [["_available", false]];
		lmf_supplyDrop_menuAvailable = _available;
	}] call CBA_fnc_addEventHandler;

	lmf_supplyDrop_fnc_selectDropPosition = compile preprocessFileLineNumbers "framework\supplyDrop\selectDropPosition.sqf";
	lmf_supplyDrop_selectionId = 0;

	// ACE actions
	private _statement = {
		params ["_target", "_player", "_params"];

		// Reject cooldown attempts before opening the map or installing selection handlers.
		private _remaining = ceil (lmf_supplyDrop_nextRequest - serverTime);
		if (_remaining > 0) exitWith {
			["Supply Drop", format ["Supply drop available in %1 seconds.", _remaining], "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", 3, 10, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
		};

		// Exit if not ready
		if !("ItemMap" in (assignedItems _player)) exitWith {
			["Supply Drop", "A map is required.", "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", 2.5, 10, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
		};

		if !([_player] call lmf_radio_fnc_hasLongRangeRadio) exitWith {
			["Supply Drop", "A long-range radio is required.", "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", 2.5, 10, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
		};

		if (lmf_warmup_isActive) exitWith {
			["Supply Drop", "Start the mission first.", "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", 2.5, 10, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
		};

		// Reserve the client selection before starting scheduled map work.
		private _claimed = false;
		isNil {
			if (!(missionNamespace getVariable ["lmf_supplyDrop_selecting", false])) then {
				lmf_supplyDrop_selecting = true;
				_claimed = true;
			};
		};
		if (!_claimed) exitWith {};
		[_player, _params select 0, _params select 1] spawn lmf_supplyDrop_fnc_selectDropPosition;
	};

	// Availability belongs to the client; the statement receives ACE's current player.
	private _parentSupplyDrop = ["lmf_supplyDrop_menu", "Supply Drop", ["\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", LMF_MAIN_COLOR], {true}, {
		lmf_supplyDrop_menuAvailable
	}] call ace_interact_menu_fnc_createAction;
	["CAManBase", 1, ["ACE_SelfActions"], _parentSupplyDrop, true] call ace_interact_menu_fnc_addActionToClass;

	private _suppliesMenu = ["lmf_supplyDrop_supplies", "Supplies", ["\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa", LMF_MAIN_COLOR], {true}, {true}] call ace_interact_menu_fnc_createAction;
	["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu"], _suppliesMenu, true] call ace_interact_menu_fnc_addActionToClass;

	{
		_x params ["_category", "_classname", "_displayName"];
		if (_classname != "") then {
			private _action = [format ["lmf_supplyDrop_supply%1", _category], _displayName, "", _statement, {true}, {}, [_category, false]] call ace_interact_menu_fnc_createAction;
			["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_supplies"], _action, true] call ace_interact_menu_fnc_addActionToClass;
		};
	} forEach lmf_supplyCrates_definitions;

	private _groundVehicles = lmf_groundVehicles select {_x != "" && {isClass (configFile >> "CfgVehicles" >> _x)}};
	if (lmf_supplyDropLimit > 0 && lmf_supplyDropVehicles && {count _groundVehicles > 0}) then {
		private _vicMenu = ["lmf_supplyDrop_vehicles", "Vehicles", ["\A3\ui_f\data\Map\VehicleIcons\iconCrateVeh_ca.paa", LMF_MAIN_COLOR], {lmf_supplyDropVehicles}, {true}] call ace_interact_menu_fnc_createAction;
		["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu"], _vicMenu, true] call ace_interact_menu_fnc_addActionToClass;

		{
			private _displayName = getText (configFile >> "CfgVehicles" >> _x >> "displayName");
			private _action = [format ["lmf_supplyDrop_ground%1", _forEachIndex], _displayName, "", _statement, {true}, {}, [_x, true]] call ace_interact_menu_fnc_createAction;
			["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_vehicles"], _action, true] call ace_interact_menu_fnc_addActionToClass;
		} forEach _groundVehicles;
	};
};
