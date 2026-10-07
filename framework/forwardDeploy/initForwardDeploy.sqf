/*
    Forward deployment
    Registers forward-deployment events and ACE actions for troops and claimable assets.
    Author: Alex2k. Contributor: G4rrus.
    Forward deploy will commence (with a slight delay) at the end of the warmup/briefing stage.
    lmf_deployHeight determines if it is a ground forward deploy or an airdrop.
    Assets that shall be claimable must be marked before this script executes (it executes post init)
    You can mark assets to be claimable by for example putting 'this setVariable ["lmf_deploy_unowned",true];' in their init in the editor.
    This requires the briefing stage component.
*/

if !(lmf_forwardDeploy) exitWith {};

// Server
if (isServer) then {
	// Create hash table on server
	lmf_deploy_hash = [[],true] call CBA_fnc_hashCreate;

	// Update hash table event
	["lmf_deploy_updateHashEvent",{
		params [
			["_group",grpNull],
			["_mrkName",""],
			["_vehicle",objNull],
			["_isDelete",false]
		];

		private _key = [lmf_deploy_hash,_group] call CBA_fnc_hashGet;
		private _vics = [];
		private _dir = markerDir _mrkName;

		if !(_key isEqualType true) then {
			_vics = _key select 2;
		};

		// Unregister
		if (isNull _vehicle && {_isDelete}) exitWIth {
			{
				_x setVariable ["lmf_deploy_unowned",true,true];
			} forEach _vics;
			[lmf_deploy_hash,_group] call CBA_fnc_hashRem;
			deleteMarker (_key select 0);
		};

		// Vehicle
		if !(isNUll _vehicle) then {
			if !(_key isEqualType true) then { // Preserves the marker when updating an asset registration.
				_mrkName = _key select 0;
				_dir = _key select 1;
			};
			if (_isDelete) then {
				_vics = _vics - [_vehicle];
				_vehicle setVariable ["lmf_deploy_unowned",true,true];
			} else {
				if (_vehicle getVariable ["lmf_deploy_unowned",true] isEqualType true) then {
					_vics pushBackUnique _vehicle;
					_vehicle setVariable ["lmf_deploy_unowned",_group,true];
				};
			};
		};

		// Update key
		[lmf_deploy_hash,_group,[_mrkName,_dir,_vics]] call CBA_fnc_hashSet;
	}] call CBA_fnc_addEventHandler;

	// Cleanup loop
	[{
		[] call lmf_forwardDeploy_fnc_updateDeploymentRegistrations;
		if !(lmf_warmup_isActive) then {
			[(_this select 1)] call CBA_fnc_removePerFrameHandler;
			["lmf_deploy_initiateDeploy",[]] call CBA_fnc_localEvent;
		};
	},5,[]] call CBA_fnc_addPerFrameHandler;

	["lmf_deploy_initiateDeploy", {
		["lmf_deploy_removeActions",[]] call CBA_fnc_globalEvent;

		// Pass the registered deployment data to the deployment function.
		private _hashGroups = [lmf_deploy_hash] call CBA_fnc_hashKeys;
		private _paraParams = [];
		{
			private _key = [lmf_deploy_hash,_x] call CBA_fnc_hashGet;
			private _info = [_x,_key];
			_paraParams pushBack _info;
		} forEach _hashGroups;
		[{
			[_this select 0,lmf_deployHeight] call lmf_forwardDeploy_fnc_deployUnitsAndAssets;
		},[_paraParams], 8] call CBA_fnc_waitAndExecute;
	}] call CBA_fnc_addEventHandler;
};

// Player
if !(hasInterface) exitWith {};

// Called once by the ordered client menu setup after the intro.
lmf_forwardDeploy_fnc_registerMenu = {
    if !(lmf_warmup_isActive) exitWith {};
    player setVariable ["lmf_deploy_menuAvailable", true];

    // Events
    ["lmf_deploy_removeActions", {
    	cutText ["","BLACK OUT",4,true];

        player setVariable ["lmf_deploy_menuAvailable", false];
    	{
    		[_x,0,["ACE_MainActions","lmf_deploy_register_vic"]] call ace_interact_menu_fnc_removeActionFromObject;
    		[_x,0,["ACE_MainActions","lmf_deploy_unregister_vic"]] call ace_interact_menu_fnc_removeActionFromObject;
    	} forEach lmf_drop_vehiclesToRegister;

    	[{
    		cutText ["","BLACK IN",4,true];
    		["vehicle",lmf_deploy_vehicleExitEh] call CBA_fnc_removePlayerEventHandler;
    	}, [], 12] call CBA_fnc_waitAndExecute;
    }] call CBA_fnc_addEventHandler;

    // Leave the claimed vehicle.
    lmf_deploy_vehicleExitEh = ["vehicle",{
        params ["_unit", "_newVehicle", "_oldVehicle"];
        private _variable = _newVehicle getVariable "lmf_deploy_unowned";
    	if !(isNil "_variable") exitWith {
    		moveOut player;
    		titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>VEHICLE DEPLOY</t><br/><t shadow='2' color='%2' size='1.5'>Can't enter deployable vehicle yet</t>", LMF_ERROR_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
    	};
    },false] call CBA_fnc_addPlayerEventHandler;

    // Player action handlers
    private _statementRegister = {
    	// Exit if not ready
    	if !("ItemMap" in (assignedItems player)) exitWith {
    		titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>UNAVAILABLE</t><br/><t shadow='2' color='%2' size='1.5'>You need a map to enter the deploy menu</t>", LMF_ERROR_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
    	};

    	// Open map and inform
    	openMap true;
    	private _mapText = format ["<t font='PuristaBold' shadow='2' color='%1' size='1.6' align='left'>FORWARD DEPLOY</t><br/><t shadow='2' color='%2' size='1.2' align='left'>- Left-click to register/move deploy position.</t><br/><t shadow='2' color='%2' size='1.2' align='left'>- Shift + Left-Click to rotate zone towards cursor.<br/><t shadow='2' color='%2' size='1.2' align='left'>- Exit Map to confirm placement.", LMF_MAIN_COLOR, LMF_TEXT_COLOR];
    	"lmf_deploy_layer" cutText [_mapText,"PLAIN",1.5,true,true];

    	// Map click EH
    	private _mapClickEhDeploy = addMissionEventHandler ["MapSingleClick",{
    		params ["_units","_pos","_alt","_shift"];

    		private _grp = group player;
    		if !(player isEqualTo leader _grp) exitWith {
    			openMap false;
    		};

    		private _mrkName = format ["mrk_deploy_%1",player];
    		private _grpId = groupId _grp;

    		if (markerText _mrkName isEqualTo "") exitWith {
    			private _mrkType = ["mil_arrow2","mil_start"] select (lmf_deployHeight < 100);
    			lmf_deployMarker = createMarker [_mrkName,_pos];
    			lmf_deployMarker setMarkerType _mrkType;
    			lmf_deployMarker setMarkerSize [0.75, 0.75];
    			lmf_deployMarker setMarkerColor "ColorWest";
    			lmf_deployMarker setMarkerText format ["%1",_grpId];
    		};

    		if !(_shift) then {
    			lmf_deployMarker setMarkerPos _pos;
    			lmf_deployMarker setMarkerText format ["%1",_grpId];
    		} else {
    			private _mrkPos = getMarkerPos lmf_deployMarker;
    			lmf_deployMarker setMarkerDir (_mrkPos getDir _pos);
    		};
    	}];

    	// Remove the map handler on close and recheck group leadership.
    	[{
    		!visibleMap
    	},{
    		removeMissionEventHandler ["MapSingleClick",(_this select 0)];
    		"lmf_deploy_layer" cutText ["","PLAIN",0.01,true];
    		if !(isNil "lmf_deployMarker") then {
    			_grp = group player;
    			if (player isEqualTo leader _grp) then {
    				private _grpId = groupId _grp;
    				private _mrkName = format ["mrk_deploy_%1",_grpId];
    				private _mrkPos = markerPos lmf_deployMarker;
    				private _mrkDir = markerDir lmf_deployMarker;
    				private _mrkType = markerType lmf_deployMarker;
    				deleteMarker lmf_deployMarker;
    				private _deployMarkerR = createMarker [_mrkName,_mrkPos];
    				_deployMarkerR setMarkerDir _mrkDir;
    				_deployMarkerR setMarkerType _mrkType;
    				_deployMarkerR setMarkerSize [0.75, 0.75];
    				_deployMarkerR setMarkerColor "ColorWest";
    				_deployMarkerR setMarkerText format ["%1",_grpId];

    				["lmf_deploy_updateHashEvent",[_grp,_deployMarkerR,objNull,false]] call CBA_fnc_serverEvent;
    				_grp setVariable ["lmf_deploy_unregistered",false,true];
    				private _t1 = format ["<t font='PuristaBold' shadow='2' color='%2' size='2'>DEPLOY</t><br/><t  shadow='2' color='%3' size='1.5'>%1 ready for deployment</t>",_grpId, LMF_HIGHLIGHT_FRIENDLY_COLOR, LMF_TEXT_COLOR];
    				titleText [_t1, "PLAIN", 0.3, false, true];
    			} else {
    				deleteMarker lmf_deployMarker;
    				titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>DEPLOY</t><br/><t  shadow='2' color='%2' size='1.5'>You are no longer the leader of your group</t>", LMF_ERROR_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
    			};
    		};
    	},[
    		_mapClickEhDeploy
    	]] call CBA_fnc_waitUntilAndExecute;
    };

    private _statementUnregister = {
    	private _grp = group player;
    	["lmf_deploy_updateHashEvent",[_grp,"",objNull,true]] call CBA_fnc_serverEvent;
    	_grp setVariable ["lmf_deploy_unregistered",true,true];
    	private _t3 = format ["<t font='PuristaBold' shadow='2' color='%2' size='2'>DEPLOY</t><br/><t  shadow='2' color='%3' size='1.5'>%1 will not be deployed</t>",groupID _grp, LMF_ERROR_COLOR, LMF_TEXT_COLOR];
    	titleText [_t3, "PLAIN", 0.3, false, true];
    };

    // Player action conditions
    private _conditionRegister = {
        params ["_target", "_player", "_params"];
        _player isEqualTo (_params select 0)
            && {_player getVariable ["lmf_deploy_menuAvailable", false]}
            && {player isEqualTo (leader group player) && {!visibleMap && {(group player) getVariable ["lmf_deploy_unregistered",true]}}}
    };

    private _conditionUnregister = {
        params ["_target", "_player", "_params"];
        _player isEqualTo (_params select 0)
            && {_player getVariable ["lmf_deploy_menuAvailable", false]}
            && {player isEqualTo (leader group player) && {!visibleMap && {!((group player) getVariable ["lmf_deploy_unregistered",true])}}}
    };

    // Player actions
    private _iconRegister = [["\A3\ui_f\data\map\vehicleicons\iconParachute_ca.paa",LMF_HIGHLIGHT_FRIENDLY_COLOR],["\A3\3den\data\displays\display3den\panelright\modeobjects_ca.paa",LMF_HIGHLIGHT_FRIENDLY_COLOR]] select (lmf_deployHeight < 100);
    private _iconUnregister = [["\A3\ui_f\data\map\vehicleicons\iconParachute_ca.paa",LMF_ERROR_COLOR],["\A3\3den\data\displays\display3den\panelright\modeobjects_ca.paa",LMF_ERROR_COLOR]] select (lmf_deployHeight < 100);

    private _registerGroup = ["lmf_deploy_register","Register Forward Deploy",_iconRegister,_statementRegister,_conditionRegister,{},[player]] call ace_interact_menu_fnc_createAction;
    private _unregisterGroup = ["lmf_deploy_unregister","Unregister Forward Deploy",_iconUnregister,_statementUnregister,_conditionUnregister,{},[player]] call ace_interact_menu_fnc_createAction;
    ["CAManBase",1,["ACE_SelfActions"],_registerGroup,true] call ace_interact_menu_fnc_addActionToClass;
    ["CAManBase",1,["ACE_SelfActions"],_unregisterGroup,true] call ace_interact_menu_fnc_addActionToClass;

    // Vehicle actions
    lmf_drop_vehiclesToRegister = [];
    {
    	private _variable = _x getVariable "lmf_deploy_unowned";
    	if !(isNil "_variable") then {
    		lmf_drop_vehiclesToRegister pushBackUnique _x;
    	};
    } forEach vehicles;

    // Vehicle action handlers
    private _statementRegisterVic = {
    	params ["_target","_player","_params"];

    	private _variable = _target getVariable ["lmf_deploy_unowned",true];
    	if (_variable isEqualType true) then {
    		titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>VEHICLE DEPLOY</t><br/><t  shadow='2' color='%2' size='1.5'>Vehicle ready for deployment</t>", LMF_HIGHLIGHT_FRIENDLY_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
    		["lmf_deploy_updateHashEvent",[group player,"",_target,false]] call CBA_fnc_serverEvent;
    	} else {
    		private _text = format ["<t font='PuristaBold' shadow='2' color='%2' size='2'>UNAVAILABLE</t><br/><t  shadow='2' color='%3' size='1.5'>This vehicle is already owned by %1</t>",groupId _variable, LMF_ERROR_COLOR, LMF_TEXT_COLOR];
    		titleText [_text,"PLAIN",0.3,false,true];
    	};
    };

    private _statementUnregisterVic = {
    	["lmf_deploy_updateHashEvent",[group player,"",_target,true]] call CBA_fnc_serverEvent;
    	titleText [(format ["<t font='PuristaBold' shadow='2' color='%1' size='2'>VEHICLE DEPLOY</t><br/><t  shadow='2' color='%2' size='1.5'>Vehicle will not be deployed</t>", LMF_ERROR_COLOR, LMF_TEXT_COLOR]), "PLAIN", 0.3, false, true];
    };

    // Vehicle action conditions
    private _conditionRegisterVic = {
    	player isEqualTo (leader group player) && {!((_target getVariable ["lmf_deploy_unowned",true]) isEqualTo (group player))}
    };

    private _conditionUnregisterVic = {
    	player isEqualTo (leader group player) && {((_target getVariable ["lmf_deploy_unowned",true]) isEqualTo (group player))}
    };

    private _registerVic = ["lmf_deploy_register_vic","Claim Vehicle",_iconRegister,_statementRegisterVic,_conditionRegisterVic] call ace_interact_menu_fnc_createAction;
    private _unregisterVic = ["lmf_deploy_unregister_vic","Unclaim Vehicle",_iconUnregister,_statementUnregisterVic,_conditionUnregisterVic] call ace_interact_menu_fnc_createAction;

    {
    	[_x,0,["ACE_MainActions"],_registerVic] call ace_interact_menu_fnc_addActionToObject;
    	[_x,0,["ACE_MainActions"],_unregisterVic] call ace_interact_menu_fnc_addActionToObject;
    } forEach lmf_drop_vehiclesToRegister;
};
