/*
	Supply-drop requests
	Registers supply-drop requests and ACE actions for selecting a delivery location.
	Server publishes a shared 30-second deadline; clients reject cooldown attempts before map selection.
	Request events carry the drop position, crate classname and requesting player for server feedback.
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
		params ["_dropPos", "_crate", "_requester"];
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

		[_spawnPos, _dropPos, _plane, _crate] spawn lmf_supplyDrop_fnc_deliverSupplies;

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
		[_player, _params select 0] spawn lmf_supplyDrop_fnc_selectDropPosition;
	};

	// Availability belongs to the client; the statement receives ACE's current player.
	private _parentSupplyDrop = ["lmf_supplyDrop_menu", "Supply Drop", ["\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", LMF_MAIN_COLOR], {true}, {
		lmf_supplyDrop_menuAvailable
	}] call ace_interact_menu_fnc_createAction;
	["CAManBase", 1, ["ACE_SelfActions"], _parentSupplyDrop, true] call ace_interact_menu_fnc_addActionToClass;

	private _suppliesMenu = ["lmf_supplyDrop_supplies", "Supplies", ["\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa", LMF_MAIN_COLOR], {true}, {true}] call ace_interact_menu_fnc_createAction;
	["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu"], _suppliesMenu, true] call ace_interact_menu_fnc_addActionToClass;

	private _dropLarge = ["lmf_supplyDrop_ammoLarge", "Large Ammo Crate", "", _statement, {true}, {}, [lmf_supLarge]] call ace_interact_menu_fnc_createAction;
	private _dropSquad = ["lmf_supplyDrop_ammoSquad", "Small Ammo Crate", "", _statement, {true}, {}, [lmf_supSquad]] call ace_interact_menu_fnc_createAction;
	private _dropExplo = ["lmf_supplyDrop_ammoExplosive", "Explosives Crate", "", _statement, {true}, {}, [lmf_supExplosives]] call ace_interact_menu_fnc_createAction;
	private _dropMed = ["lmf_supplyDrop_ammoMedic", "Medical Crate", "", _statement, {true}, {}, [lmf_supMedical]] call ace_interact_menu_fnc_createAction;
	private _dropVehicle = ["lmf_supplyDrop_ammoVehicle", "Vehicle Supplies (RRR)", "", _statement, {true}, {}, [lmf_supVehicle]] call ace_interact_menu_fnc_createAction;

	if !(lmf_supLarge isEqualTo "") then {["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_supplies"], _dropLarge, true] call ace_interact_menu_fnc_addActionToClass;};
	if !(lmf_supSquad isEqualTo "") then {["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_supplies"], _dropSquad, true] call ace_interact_menu_fnc_addActionToClass;};
	if !(lmf_supExplosives isEqualTo "") then {["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_supplies"], _dropExplo, true] call ace_interact_menu_fnc_addActionToClass;};
	if !(lmf_supMedical isEqualTo "") then {["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_supplies"], _dropMed, true] call ace_interact_menu_fnc_addActionToClass;};
	if !(lmf_supVehicle isEqualTo "") then {["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_supplies"], _dropVehicle, true] call ace_interact_menu_fnc_addActionToClass;};

	if (lmf_supplyDropLimit > 0 && lmf_supplyDropVehicles && {lmf_vic1 != "" || lmf_vic2 != "" || lmf_vic3 != "" || lmf_vic4 != ""}) then {
		private _vicMenu = ["lmf_supplyDrop_vehicles", "Vehicles", ["\A3\ui_f\data\Map\VehicleIcons\iconCrateVeh_ca.paa", LMF_MAIN_COLOR], {lmf_supplyDropVehicles}, {true}] call ace_interact_menu_fnc_createAction;
		["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu"], _vicMenu, true] call ace_interact_menu_fnc_addActionToClass;

		private _vehType1 = getText (configFile >> "CfgVehicles" >> lmf_vic1 >> "displayName");
		private _vehType2 = getText (configFile >> "CfgVehicles" >> lmf_vic2 >> "displayName");
		private _vehType3 = getText (configFile >> "CfgVehicles" >> lmf_vic3 >> "displayName");
		private _vehType4 = getText (configFile >> "CfgVehicles" >> lmf_vic4 >> "displayName");

		private _dropVic1 = ["lmf_supplyDrop_vic1", _vehType1, "", _statement, {true}, {}, [lmf_vic1]] call ace_interact_menu_fnc_createAction;
		private _dropVic2 = ["lmf_supplyDrop_vic2", _vehType2, "", _statement, {true}, {}, [lmf_vic2]] call ace_interact_menu_fnc_createAction;
		private _dropVic3 = ["lmf_supplyDrop_vic3", _vehType3, "", _statement, {true}, {}, [lmf_vic3]] call ace_interact_menu_fnc_createAction;
		private _dropVic4 = ["lmf_supplyDrop_vic4", _vehType4, "", _statement, {true}, {}, [lmf_vic4]] call ace_interact_menu_fnc_createAction;

		if !(lmf_vic1 isEqualTo "") then {["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_vehicles"], _dropVic1, true] call ace_interact_menu_fnc_addActionToClass;};
		if !(lmf_vic2 isEqualTo "") then {["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_vehicles"], _dropVic2, true] call ace_interact_menu_fnc_addActionToClass;};
		if !(lmf_vic3 isEqualTo "") then {["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_vehicles"], _dropVic3, true] call ace_interact_menu_fnc_addActionToClass;};
		if !(lmf_vic4 isEqualTo "") then {["CAManBase", 1, ["ACE_SelfActions", "lmf_supplyDrop_menu", "lmf_supplyDrop_vehicles"], _dropVic4, true] call ace_interact_menu_fnc_addActionToClass;};
	};
};
