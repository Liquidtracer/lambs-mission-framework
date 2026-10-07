/*
	Group BFT
	Provides client rendering and the ACE menu for group tracking.
*/

if (!hasInterface || {missionNamespace getVariable ["lmf_bft_clientStarted", false]}) exitWith {};
lmf_bft_clientStarted = true;
disableSerialization;

ace_map_mapIllumination = false;
player removeItem "ACE_Chemlight_Shield_Red";
lmf_bft_markerSide = "ColorWEST";
lmf_bft_iconColor = [0, 0.3, 0.6, 1];
lmf_bft_renderedGroups = [];
lmf_bft_hoverGroup = grpNull;
lmf_bft_followTarget = grpNull;
lmf_bft_followActive = false;
lmf_bft_lastPlayer = objNull;
lmf_bft_nextRefresh = 0;
uiNamespace setVariable ["lmf_bft_hoverControls", []];

lmf_bft_fnc_updateGroupIcon = {
	params ["_grp", "_type", "_txt"];
	private _iconId = _grp getVariable ["lmf_bft_localIcon", -1];
	private _exists = (getGroupIcons _grp) findIf {(_x select 0) == _iconId};
	if (_exists != -1 && {(_grp getVariable ["lmf_bft_drawnIcon", []]) isEqualTo [_type, _txt]}) exitWith {};
	if (_exists == -1) then {
		_iconId = _grp addGroupIcon [_type, [0, 0]];
		_grp setVariable ["lmf_bft_localIcon", _iconId];
	} else {
		_grp setGroupIcon [_iconId, _type, [0, 0]];
	};
	_grp setVariable ["lmf_bft_drawnIcon", [_type, _txt]];
	private _scale = if (_grp == lmf_bft_hoverGroup) then {1.4} else {1.3};
	_grp setGroupIconParams [lmf_bft_iconColor, _txt, _scale, true];
};

lmf_bft_fnc_clearHover = {
	private _oldGroup = lmf_bft_hoverGroup;
	lmf_bft_hoverGroup = grpNull;
	{ctrlDelete _x} forEach (uiNamespace getVariable ["lmf_bft_hoverControls", []]);
	uiNamespace setVariable ["lmf_bft_hoverControls", []];
	if (!isNull _oldGroup) then {
		private _params = getGroupIconParams _oldGroup;
		_params set [2, 1.3];
		_oldGroup setGroupIconParams _params;
	};
};

lmf_bft_fnc_stopFollowing = {
	if (!lmf_bft_followActive) exitWith {};
	lmf_bft_followActive = false;
	lmf_bft_followTarget = grpNull;
	private _map = findDisplay 12 displayCtrl 51;
	if (!isNull _map) then {ctrlMapAnimClear _map};
	hintSilent "";
};

lmf_bft_fnc_attachMapClickHandler = {
	private _map = findDisplay 12 displayCtrl 51;
	if (isNull _map || {_map getVariable ["lmf_bft_clickInstalled", false]}) exitWith {};
	_map setVariable ["lmf_bft_clickInstalled", true];
	_map ctrlAddEventHandler ["MouseButtonDown", {
		params ["_map", "_button", "_posX", "_posY", "_shift", "_control"];
		// Ctrl-click remains reserved for selecting a follow target in GroupIconClick.
		// Ordinary left clicks stop following, including clicks on empty map space.
		if (_button == 0 && {!_control}) then {[] call lmf_bft_fnc_stopFollowing};
		false
	}];
};

lmf_bft_fnc_refreshGroupIcons = {
	private _current = [];
	{
		private _state = _x getVariable ["lmf_bft_state", []];
		// Follow the engine's group membership; do not reveal deaths through an alive filter.
		if (!(_state isEqualTo []) && {side _x == side group player} && {count units _x > 0}) then {
			_state params ["_callsign", "_defaultIcon", "_override"];
			private _icon = if (_override == "") then {_defaultIcon} else {_override};
			[_x, _icon, _callsign] call lmf_bft_fnc_updateGroupIcon;
			_current pushBack _x;
		};
	} forEach allGroups;

	// Remove only LMF's own icon. Do not clear icons belonging to another module.
	{
		if (!isNull _x) then {
			private _iconId = _x getVariable ["lmf_bft_localIcon", -1];
			if (_iconId >= 0) then {_x removeGroupIcon _iconId};
			_x setVariable ["lmf_bft_localIcon", -1];
			_x setVariable ["lmf_bft_drawnIcon", []];
		};
	} forEach (lmf_bft_renderedGroups - _current);
	lmf_bft_renderedGroups = _current;
	if (!(lmf_bft_hoverGroup in _current)) then {[] call lmf_bft_fnc_clearHover};
	if (!(lmf_bft_followTarget in _current)) then {[] call lmf_bft_fnc_stopFollowing};
};

// Add actions
// Class self-actions survive respawn and teamSwitch; registration runs once per client.
lmf_bft_fnc_registerMenu = {
	private _isLeader = {
		params ["_target", "_player"];
		_player == leader (group _player)
	};

	private _addMenu = {
		params ["_id", "_label", "_icon", "_parentPath", ["_condition", {true}]];
		private _actionIcon = if (_icon == "") then {""} else {[_icon, LMF_MAIN_COLOR]};
		private _action = [_id, _label, _actionIcon, {}, _condition] call ace_interact_menu_fnc_createAction;
		["CAManBase", 1, _parentPath, _action, true] call ace_interact_menu_fnc_addActionToClass
	};

	private _addCallsign = {
		params ["_id", "_callsign", "_markerType", "_icon", "_parentPath"];

		// Store each choice in ACE action parameters; the click must not depend on loop variables.
		private _action = [
			_id, _callsign, [_icon, LMF_MAIN_COLOR],
			{
				params ["_target", "_player", "_actionParams"];
				_actionParams params ["_markerType", "_callsign"];
				[group _player, _markerType, _callsign, _player] call lmf_bft_fnc_setCallsign;
			},
			_isLeader, {}, [_markerType, _callsign]
		] call ace_interact_menu_fnc_createAction;
		["CAManBase", 1, _parentPath, _action, true] call ace_interact_menu_fnc_addActionToClass;
	};

	private _vehicleIcon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
	private _categories = [
		["lmf_bft_infantry", "Infantry", lmf_bftInfantry, "b_inf", "\A3\ui_f\data\map\markers\nato\b_inf.paa", true],
		["lmf_bft_vehicles", "Vehicles", lmf_bftGroundVehicles, "b_armor", "\A3\ui_f\data\map\markers\nato\b_armor.paa", false],
		["lmf_bft_air", "Air", lmf_bftAirVehicles, "b_air", "\A3\ui_f\data\map\markers\nato\b_air.paa", false]
	];

	// Hide the selection menu when all lists are empty, but keep the tracker and map handlers running.
	if (_categories findIf {count (_x select 2) > 0} != -1) then {
		private _rootPath = [
			"lmf_bft_menu", "Blue Force Tracker", "A3\modules_f\data\portraitstrategicmapimage_ca.paa",
			["ACE_SelfActions"], _isLeader
		] call _addMenu;

		{
			_x params ["_categoryId", "_label", "_names", "_markerType", "_icon", "_infantry"];
			if (count _names > 0) then {
				private _categoryPath = [_categoryId, _label, _icon, _rootPath] call _addMenu;

				{
					private _name = toUpper _x;
					private _familyId = format ["%1_%2", _categoryId, _forEachIndex];
					private _familyPath = [_familyId, _name, _icon, _categoryPath] call _addMenu;

					if (_infantry) then {
						[
							_familyId + "_hq", format ["%1/6", _name], _markerType,
							_icon, _familyPath
						] call _addCallsign;
					};

					for "_i" from 1 to 4 do {
						private _callsign = if (_infantry) then {format ["%1/%2", _name, _i]} else {format ["%1%2", _name, _i]};
						[format ["%1_%2", _familyId, _i], _callsign, _markerType, _icon, _familyPath] call _addCallsign;
					};

					if (_infantry) then {
						private _vehiclePath = [_familyId + "_vehicles", "Vehicles", "", _familyPath] call _addMenu;
						for "_i" from 1 to 4 do {
							[
								format ["%1_%2v", _familyId, _i], format ["%1/%2V", _name, _i],
								"b_motor_inf", _vehicleIcon, _vehiclePath
							] call _addCallsign;
						};
					};
				} forEach _names;
			};
		} forEach _categories;

		// Keep the menu visible before callsign selection; the server explains the prerequisite.
		private _iconPath = [
			"lmf_bft_icon", "Icon", "", _rootPath, _isLeader
		] call _addMenu;

		// Fixed framework choices: mission makers only configure the callsign lists.
		{
			_x params ["_markerType", "_label"];
			private _icon = if (_markerType == "") then {
				"A3\3den\data\cfgwaypoints\cycle_ca.paa"
			} else {
				format ["\A3\ui_f\data\map\markers\nato\%1.paa", _markerType]
			};
			private _action = [
				format ["lmf_bft_icon_%1", _forEachIndex], _label, [_icon, if (_markerType == "") then {LMF_TEXT_COLOR} else {LMF_MAIN_COLOR}],
				{
					params ["_target", "_player", "_actionParams"];
					_actionParams params ["_markerType", "_label"];
					[group _player, _markerType, _label, _player] call lmf_bft_fnc_setIcon;
				},
				_isLeader, {}, [_markerType, _label]
			] call ace_interact_menu_fnc_createAction;
			["CAManBase", 1, _iconPath, _action, true] call ace_interact_menu_fnc_addActionToClass;
		} forEach [
			["b_inf", "Infantry"],
			["b_motor_inf", "Motorized"],
			["b_mech_inf", "Mechanized"],
			["b_armor", "Armor"],
			["b_hq", "HQ"],
			["b_recon", "Recon"],
			["b_air", "Helicopter"],
			["b_plane", "Plane"],
			["b_mortar", "Mortar"],
			["b_med", "Medical"],
			["b_support", "Support"],
			["", "Reset icon"]
		];
	};

};

// Map UI
addMissionEventHandler ["Map", {
	params ["_opened"];
	if (_opened) then {
		[] call lmf_bft_fnc_attachMapClickHandler;
		setGroupIconsVisible [true, false];
		setGroupIconsSelectable true;
		[] call lmf_bft_fnc_refreshGroupIcons;
	} else {
		[] call lmf_bft_fnc_clearHover;
		[] call lmf_bft_fnc_stopFollowing;
	};
}];

addMissionEventHandler ["GroupIconOverEnter", {
	params ["_is3D", "_group", "_iconId", "_posX", "_posY"];
	if (_is3D || {!visibleMap} || {!(_group in lmf_bft_renderedGroups)}) exitWith {};
	// This event fires continuously while hovering; keep the existing control for this group.
	private _controls = uiNamespace getVariable ["lmf_bft_hoverControls", []];
	if (_group == lmf_bft_hoverGroup && {count _controls == 3} && {_controls findIf {isNull _x} == -1}) exitWith {};
	[] call lmf_bft_fnc_clearHover;
	private _display = findDisplay 46;
	if (isNull _display) exitWith {};
	lmf_bft_hoverGroup = _group;

	private _leader = leader _group;
	private _names = (units _group - [_leader]) apply {name _x};
	private _lineHeight = 0.033;
	private _finalHeight = (count _names + 1) * _lineHeight;

	private _header = _display ctrlCreate ["RscStructuredText", -1];
	private _members = _display ctrlCreate ["RscStructuredText", -1];
	private _help = _display ctrlCreate ["RscStructuredText", -1];
	uiNamespace setVariable ["lmf_bft_hoverControls", [_header, _members, _help]];

	_header ctrlSetPosition [_posX - 0.3, _posY - 0.094, 0.25, 0.047];
	_header ctrlSetBackgroundColor [0, 0.25, 0.5, 0.85];
	_header ctrlCommit 0;
	_members ctrlSetPosition [_posX - 0.3, _posY - 0.044, 0.25, _finalHeight];
	_members ctrlSetBackgroundColor [0, 0.1, 0.2, 0.4];
	_members ctrlCommit 0;
	_help ctrlSetPosition [_posX - 0.3, _posY - _lineHeight + _finalHeight - 0.007, 0.25, 0.065];
	_help ctrlSetBackgroundColor [0, 0.1, 0.2, 0.4];
	_help ctrlCommit 0;

	_header ctrlSetStructuredText parseText format [
		"<t shadow='2' font='PuristaBold' color='%2' size='1.15' align='center' >    %1</t><img size='1' shadow='0' align='right' image='A3\modules_f\data\portraitstrategicmapimage_ca.paa'/>",
		(_group getVariable ["lmf_bft_state", []]) param [0, ""],
		LMF_MAIN_COLOR
	];
	_members ctrlSetStructuredText parseText format [
		"<t shadow='2' color='%3' size='0.82' align='center' >%1</t><br/><t shadow='2' color='%3' size='0.82' align='center' >%2</t>",
		name _leader, _names joinString "<br/>",
		LMF_TEXT_COLOR
	];
	_help ctrlSetStructuredText parseText format [
		"<t shadow='2' color='%1' size='0.75' align='center' >Click group icon to go to position</t><br/><t shadow='2' color='%1' size='0.75' align='center' >Ctrl-click group icon to follow</t>",
		LMF_TEXT_COLOR_DARK
	];
	private _params = getGroupIconParams _group;
	_params set [2, 1.4];
	_group setGroupIconParams _params;
}];

addMissionEventHandler ["GroupIconOverLeave", {
	params ["_is3D", "_group"];
	if (_group == lmf_bft_hoverGroup) then {[] call lmf_bft_fnc_clearHover};
}];

addMissionEventHandler ["GroupIconClick", {
	params ["_is3D", "_group", "_iconId", "_button", "_posX", "_posY", "_shift", "_control"];
	if (_is3D || {_button != 0} || {!visibleMap} || {!(_group in lmf_bft_renderedGroups)}) exitWith {};
	private _map = findDisplay 12 displayCtrl 51;
	if (isNull _map) exitWith {};
	if (_control && {lmf_bft_followActive} && {lmf_bft_followTarget == _group}) exitWith {};
	[] call lmf_bft_fnc_stopFollowing;
	if (_control) then {
		lmf_bft_followTarget = _group;
		lmf_bft_followActive = true;
		playSound "beep";
	};
	ctrlMapAnimClear _map;
	_map ctrlMapAnimAdd [0.25, ctrlMapScale _map, getPosASL (leader _group)];
	ctrlMapAnimCommit _map;
}];

// Read public group state locally at 1 Hz while the map is open; movement is handled by Arma.
[{
	if (player != lmf_bft_lastPlayer) then {
		lmf_bft_lastPlayer = player;
		[] call lmf_bft_fnc_clearHover;
		[] call lmf_bft_fnc_stopFollowing;
		setGroupIconsVisible [true, false];
		setGroupIconsSelectable true;
		lmf_bft_nextRefresh = 0;
	};
	if (!visibleMap) exitWith {
		if (!isNull lmf_bft_hoverGroup) then {[] call lmf_bft_fnc_clearHover};
		if (lmf_bft_followActive) then {[] call lmf_bft_fnc_stopFollowing};
	};
	if (diag_tickTime >= lmf_bft_nextRefresh) then {
		[] call lmf_bft_fnc_attachMapClickHandler;
		[] call lmf_bft_fnc_refreshGroupIcons;
		lmf_bft_nextRefresh = diag_tickTime + 1;
	};
	if (lmf_bft_followActive) then {
		private _map = findDisplay 12 displayCtrl 51;
		private _leader = leader lmf_bft_followTarget;
		if (isNull _map || {isNull _leader}) exitWith {[] call lmf_bft_fnc_stopFollowing};
		if (ctrlMapAnimDone _map) then {
			_map ctrlMapAnimAdd [0.25, ctrlMapScale _map, getPosASL _leader];
			ctrlMapAnimCommit _map;
			// Refresh follow text after callsign changes.
			hintSilent parseText format [
				"<img size='1.4' shadow='0' align='center' color='%2' image='A3\modules_f\data\portraitstrategicmapimage_ca.paa'/><br/><t shadow='2' color='%3' size='1' align='center' >Following </t><t shadow='2' color='%2' size='1' align='center' >%1</t><br/><t shadow='2' color='%3' size='1' align='center' >Click map to unfollow</t>",
				(lmf_bft_followTarget getVariable ["lmf_bft_state", []]) param [0, ""],
				LMF_MAIN_COLOR, LMF_TEXT_COLOR
			];
		};
	};
}, 0.1] call CBA_fnc_addPerFrameHandler;
