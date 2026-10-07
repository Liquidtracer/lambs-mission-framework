/*
	Forward deployment
	Registers forward-deployment events and ACE actions for troops and claimable assets.
	Author: Alex2k. Contributor: G4rrus.
	Deployment starts shortly after warmup ends; requires the warmup component.
	lmf_forwardDeploy_height selects ground deployment or an airdrop.
	Mark claimable assets before postInit, for example in their Eden init:
		this setVariable ["lmf_forwardDeploy_registration", true];
	Registration: absent = excluded, true = eligible/unclaimed, GROUP = claimed by that group.
*/

if !(lmf_forwardDeploy) exitWith {};

// Server
if (isServer) then {
	// Create the server registry.
	lmf_forwardDeploy_registry = [[], true] call CBA_fnc_hashCreate;

	// Handle registration updates.
	["lmf_forwardDeploy_updateRegistryEvent", {
		params [
			["_group", grpNull],
			["_mrkName", ""],
			["_vehicle", objNull],
			["_isDelete", false]
		];

		private _key = [lmf_forwardDeploy_registry, _group] call CBA_fnc_hashGet;
		private _vics = [];
		private _dir = markerDir _mrkName;

		if !(_key isEqualType true) then {
			_vics = _key select 2;
		};

		// Unregister
		if (isNull _vehicle && {_isDelete}) exitWith {
			{
				_x setVariable ["lmf_forwardDeploy_registration", true, true];
			} forEach _vics;
			[lmf_forwardDeploy_registry, _group] call CBA_fnc_hashRem;
			deleteMarker (_key select 0);
		};

		// Vehicle
		if !(isNull _vehicle) then {
			// Preserve the marker when updating an asset registration.
			if !(_key isEqualType true) then {
				_mrkName = _key select 0;
				_dir = _key select 1;
			};
			if (_isDelete) then {
				_vics = _vics - [_vehicle];
				_vehicle setVariable ["lmf_forwardDeploy_registration", true, true];
			} else {
				if (_vehicle getVariable ["lmf_forwardDeploy_registration", true] isEqualType true) then {
					_vics pushBackUnique _vehicle;
					_vehicle setVariable ["lmf_forwardDeploy_registration", _group, true];
				};
			};
		};

		// Store the group's registration.
		[lmf_forwardDeploy_registry, _group, [_mrkName, _dir, _vics]] call CBA_fnc_hashSet;
	}] call CBA_fnc_addEventHandler;

	// Cleanup loop
	[{
		[] call lmf_forwardDeploy_fnc_updateDeploymentRegistrations;
		if !(lmf_warmup_isActive) then {
			[(_this select 1)] call CBA_fnc_removePerFrameHandler;
			["lmf_forwardDeploy_initiateDeploy", []] call CBA_fnc_localEvent;
		};
	}, 5, []] call CBA_fnc_addPerFrameHandler;

	["lmf_forwardDeploy_initiateDeploy", {
		["lmf_forwardDeploy_removeActions", []] call CBA_fnc_globalEvent;

		// Pass the registered deployment data to the deployment function.
		private _hashGroups = [lmf_forwardDeploy_registry] call CBA_fnc_hashKeys;
		private _paraParams = [];
		{
			private _key = [lmf_forwardDeploy_registry, _x] call CBA_fnc_hashGet;
			private _info = [_x, _key];
			_paraParams pushBack _info;
		} forEach _hashGroups;
		[{
			[_this select 0, lmf_forwardDeploy_height] call lmf_forwardDeploy_fnc_deployUnitsAndAssets;
		}, [_paraParams], 8] call CBA_fnc_waitAndExecute;
	}] call CBA_fnc_addEventHandler;
};

// Player
if !(hasInterface) exitWith {};

// Called once by the ordered client menu setup after the intro.
lmf_forwardDeploy_fnc_registerMenu = {
	if !(lmf_warmup_isActive) exitWith {};
	player setVariable ["lmf_forwardDeploy_menuAvailable", true];

	// Events
	["lmf_forwardDeploy_removeActions", {
		cutText ["", "BLACK OUT", 4, true];

		player setVariable ["lmf_forwardDeploy_menuAvailable", false];
		{
			[_x, 0, ["ACE_MainActions", "lmf_forwardDeploy_registerVic"]] call ace_interact_menu_fnc_removeActionFromObject;
			[_x, 0, ["ACE_MainActions", "lmf_forwardDeploy_unregisterVic"]] call ace_interact_menu_fnc_removeActionFromObject;
		} forEach lmf_forwardDeploy_vehiclesToRegister;

		[{
			cutText ["", "BLACK IN", 4, true];
			["vehicle", lmf_forwardDeploy_vehicleExitEh] call CBA_fnc_removePlayerEventHandler;
		}, [], 12] call CBA_fnc_waitAndExecute;
	}] call CBA_fnc_addEventHandler;

	// Prevent entry into assets marked for deployment.
	lmf_forwardDeploy_vehicleExitEh = ["vehicle", {
		params ["_unit", "_newVehicle", "_oldVehicle"];
		private _variable = _newVehicle getVariable "lmf_forwardDeploy_registration";
		if !(isNil "_variable") exitWith {
			moveOut player;
			titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>Forward Deploy</t><br/><t shadow='2' color='%2' size='1.5'>You cannot enter a deployable vehicle yet.</t>", LMF_ERROR_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
		};
	}, false] call CBA_fnc_addPlayerEventHandler;

	// Player action handlers
	private _statementRegister = {
		// Require a map to place the deployment position.
		if !("ItemMap" in (assignedItems player)) exitWith {
			titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>Unavailable</t><br/><t shadow='2' color='%2' size='1.5'>You need a map to open the deployment menu.</t>", LMF_ERROR_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
		};

		// Open the map with placement instructions.
		openMap true;
		private _mapText = format ["<t font='PuristaBold' shadow='2' color='%1' size='1.6' align='left'>Forward Deploy</t><br/><t shadow='2' color='%2' size='1.2' align='left'>- Left-click to register or move the deployment position.</t><br/><t shadow='2' color='%2' size='1.2' align='left'>- Shift + left-click to rotate the deployment zone toward the cursor.</t><br/><t shadow='2' color='%2' size='1.2' align='left'>- Close the map to confirm placement.</t>", LMF_MAIN_COLOR, LMF_TEXT_COLOR];
		"lmf_forwardDeploy_layer" cutText [_mapText, "PLAIN", 1.5, true, true];

		// Handle deployment placement and rotation.
		private _mapClickEhDeploy = addMissionEventHandler ["MapSingleClick", {
			params ["_units", "_pos", "_alt", "_shift"];

			private _grp = group player;
			if !(player isEqualTo leader _grp) exitWith {
				openMap false;
			};

			private _markerPrefix = "lmf_forwardDeploy_marker_";
			private _mrkName = format ["%1%2", _markerPrefix, player];
			private _grpId = groupId _grp;

			if (markerText _mrkName isEqualTo "") exitWith {
				private _mrkType = ["mil_arrow2", "mil_start"] select (lmf_forwardDeploy_height < 100);
				lmf_forwardDeploy_marker = createMarker [_mrkName, _pos];
				lmf_forwardDeploy_marker setMarkerType _mrkType;
				lmf_forwardDeploy_marker setMarkerSize [0.75, 0.75];
				lmf_forwardDeploy_marker setMarkerColor "ColorWest";
				lmf_forwardDeploy_marker setMarkerText format ["%1", _grpId];
			};

			if !(_shift) then {
				lmf_forwardDeploy_marker setMarkerPos _pos;
				lmf_forwardDeploy_marker setMarkerText format ["%1", _grpId];
			} else {
				private _mrkPos = getMarkerPos lmf_forwardDeploy_marker;
				lmf_forwardDeploy_marker setMarkerDir (_mrkPos getDir _pos);
			};
		}];

		// Remove the map handler on close and recheck group leadership.
		[{
			!visibleMap
		}, {
			removeMissionEventHandler ["MapSingleClick", (_this select 0)];
			"lmf_forwardDeploy_layer" cutText ["", "PLAIN", 0.01, true];
			if !(isNil "lmf_forwardDeploy_marker") then {
				_grp = group player;
				if (player isEqualTo leader _grp) then {
					private _grpId = groupId _grp;
					private _markerPrefix = "lmf_forwardDeploy_marker_";
					private _mrkName = format ["%1%2", _markerPrefix, _grpId];
					private _mrkPos = markerPos lmf_forwardDeploy_marker;
					private _mrkDir = markerDir lmf_forwardDeploy_marker;
					private _mrkType = markerType lmf_forwardDeploy_marker;
					deleteMarker lmf_forwardDeploy_marker;
					private _deployMarkerR = createMarker [_mrkName, _mrkPos];
					_deployMarkerR setMarkerDir _mrkDir;
					_deployMarkerR setMarkerType _mrkType;
					_deployMarkerR setMarkerSize [0.75, 0.75];
					_deployMarkerR setMarkerColor "ColorWest";
					_deployMarkerR setMarkerText format ["%1", _grpId];

					["lmf_forwardDeploy_updateRegistryEvent", [_grp, _deployMarkerR, objNull, false]] call CBA_fnc_serverEvent;
					_grp setVariable ["lmf_forwardDeploy_unregistered", false, true];
					private _t1 = format ["<t font='PuristaBold' shadow='2' color='%2' size='2'>Forward Deploy</t><br/><t shadow='2' color='%3' size='1.5'>%1 is ready for deployment.</t>", _grpId, LMF_HIGHLIGHT_FRIENDLY_COLOR, LMF_TEXT_COLOR];
					titleText [_t1, "PLAIN", 0.3, false, true];
				} else {
					deleteMarker lmf_forwardDeploy_marker;
					titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>Forward Deploy</t><br/><t shadow='2' color='%2' size='1.5'>You are no longer the leader of your group.</t>", LMF_ERROR_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
				};
			};
		}, [
			_mapClickEhDeploy
		]] call CBA_fnc_waitUntilAndExecute;
	};

	private _statementUnregister = {
		private _grp = group player;
		["lmf_forwardDeploy_updateRegistryEvent", [_grp, "", objNull, true]] call CBA_fnc_serverEvent;
		_grp setVariable ["lmf_forwardDeploy_unregistered", true, true];
		private _t3 = format ["<t font='PuristaBold' shadow='2' color='%2' size='2'>Forward Deploy</t><br/><t shadow='2' color='%3' size='1.5'>%1 will not be deployed.</t>", groupId _grp, LMF_ERROR_COLOR, LMF_TEXT_COLOR];
		titleText [_t3, "PLAIN", 0.3, false, true];
	};

	// Player action conditions
	private _conditionRegister = {
		params ["_target", "_player", "_params"];
		_player isEqualTo (_params select 0)
			&& {_player getVariable ["lmf_forwardDeploy_menuAvailable", false]}
			&& {player isEqualTo (leader group player) && {!visibleMap && {(group player) getVariable ["lmf_forwardDeploy_unregistered", true]}}}
	};

	private _conditionUnregister = {
		params ["_target", "_player", "_params"];
		_player isEqualTo (_params select 0)
			&& {_player getVariable ["lmf_forwardDeploy_menuAvailable", false]}
			&& {player isEqualTo (leader group player) && {!visibleMap && {!((group player) getVariable ["lmf_forwardDeploy_unregistered", true])}}}
	};

	// Player actions
	private _iconRegister = [["\A3\ui_f\data\map\vehicleicons\iconParachute_ca.paa", LMF_HIGHLIGHT_FRIENDLY_COLOR], ["\A3\3den\data\displays\display3den\panelright\modeobjects_ca.paa", LMF_HIGHLIGHT_FRIENDLY_COLOR]] select (lmf_forwardDeploy_height < 100);
	private _iconUnregister = [["\A3\ui_f\data\map\vehicleicons\iconParachute_ca.paa", LMF_ERROR_COLOR], ["\A3\3den\data\displays\display3den\panelright\modeobjects_ca.paa", LMF_ERROR_COLOR]] select (lmf_forwardDeploy_height < 100);

	private _registerGroup = ["lmf_forwardDeploy_register", "Register Forward Deploy", _iconRegister, _statementRegister, _conditionRegister, {}, [player]] call ace_interact_menu_fnc_createAction;
	private _unregisterGroup = ["lmf_forwardDeploy_unregister", "Unregister Forward Deploy", _iconUnregister, _statementUnregister, _conditionUnregister, {}, [player]] call ace_interact_menu_fnc_createAction;
	["CAManBase", 1, ["ACE_SelfActions"], _registerGroup, true] call ace_interact_menu_fnc_addActionToClass;
	["CAManBase", 1, ["ACE_SelfActions"], _unregisterGroup, true] call ace_interact_menu_fnc_addActionToClass;

	// Vehicle actions
	lmf_forwardDeploy_vehiclesToRegister = [];
	{
		private _variable = _x getVariable "lmf_forwardDeploy_registration";
		if !(isNil "_variable") then {
			lmf_forwardDeploy_vehiclesToRegister pushBackUnique _x;
		};
	} forEach vehicles;

	// Vehicle action handlers
	private _statementRegisterVic = {
		params ["_target", "_player", "_params"];

		private _variable = _target getVariable ["lmf_forwardDeploy_registration", true];
		if (_variable isEqualType true) then {
			titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>Forward Deploy</t><br/><t shadow='2' color='%2' size='1.5'>Vehicle ready for deployment.</t>", LMF_HIGHLIGHT_FRIENDLY_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
			["lmf_forwardDeploy_updateRegistryEvent", [group player, "", _target, false]] call CBA_fnc_serverEvent;
		} else {
			private _text = format ["<t font='PuristaBold' shadow='2' color='%2' size='2'>Unavailable</t><br/><t shadow='2' color='%3' size='1.5'>This vehicle is already claimed by %1.</t>", groupId _variable, LMF_ERROR_COLOR, LMF_TEXT_COLOR];
			titleText [_text, "PLAIN", 0.3, false, true];
		};
	};

	private _statementUnregisterVic = {
		["lmf_forwardDeploy_updateRegistryEvent", [group player, "", _target, true]] call CBA_fnc_serverEvent;
		titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>Forward Deploy</t><br/><t shadow='2' color='%2' size='1.5'>Vehicle will not be deployed.</t>", LMF_ERROR_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
	};

	// Vehicle action conditions
	private _conditionRegisterVic = {
		player isEqualTo (leader group player) && {!((_target getVariable ["lmf_forwardDeploy_registration", true]) isEqualTo (group player))}
	};

	private _conditionUnregisterVic = {
		player isEqualTo (leader group player) && {((_target getVariable ["lmf_forwardDeploy_registration", true]) isEqualTo (group player))}
	};

	private _registerVic = ["lmf_forwardDeploy_registerVic", "Claim Vehicle", _iconRegister, _statementRegisterVic, _conditionRegisterVic] call ace_interact_menu_fnc_createAction;
	private _unregisterVic = ["lmf_forwardDeploy_unregisterVic", "Unclaim Vehicle", _iconUnregister, _statementUnregisterVic, _conditionUnregisterVic] call ace_interact_menu_fnc_createAction;

	{
		[_x, 0, ["ACE_MainActions"], _registerVic] call ace_interact_menu_fnc_addActionToObject;
		[_x, 0, ["ACE_MainActions"], _unregisterVic] call ace_interact_menu_fnc_addActionToObject;
	} forEach lmf_forwardDeploy_vehiclesToRegister;
};
