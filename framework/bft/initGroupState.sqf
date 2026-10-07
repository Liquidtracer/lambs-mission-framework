/*
	BFT group state
	Loaded synchronously in preInit. The server is the only writer.
	lmf_bft_state = [callsign, default icon, manual override ("" = default)].
	Missing/empty state means no BFT registration. Public group state also serves JIP.
*/

lmf_bft_fnc_isCallsignAvailable = {
	params ["_grp", "_callsign"];
	(allGroups findIf {
		_x != _grp && {side _x == side _grp} && {count units _x > 0} && {
			toUpper (groupId _x) == _callsign
			|| {((_x getVariable ["lmf_bft_state", []]) param [0, ""]) == _callsign}
		}
	}) == -1
};

lmf_bft_fnc_sendFeedback = {
	params ["_recipient", "_message", ["_success", true], ["_value", ""]];
	if (isNull _recipient) exitWith {};
	["lmf_bft_feedback", [_recipient, _message, _success, _value], _recipient] call CBA_fnc_targetEvent;
};

lmf_bft_fnc_applyCallsign = {
	if (!isServer) exitWith {};
	// Also serialize direct calls from scheduled server scripts with requests from clients.
	isNil {
		params ["_grp", "_type", "_txt", ["_requester", objNull]];
		if (!lmf_bft || {isNull _grp}) exitWith {};
		if (!isNull _requester && {_requester != leader _grp || {!alive _requester}}) exitWith {
			[_requester, "Only the current group leader can change BFT.", false] call lmf_bft_fnc_sendFeedback;
		};
		_txt = toUpper _txt;
		if (_txt == "") exitWith {};
		private _state = _grp getVariable ["lmf_bft_state", []];
		if ((_state param [0, ""]) == _txt) exitWith {
			[_requester, "callsignAlready", false, _txt] call lmf_bft_fnc_sendFeedback;
		};
		if !([_grp, _txt] call lmf_bft_fnc_isCallsignAvailable) exitWith {
			[_requester, "callsignInUse", false, _txt] call lmf_bft_fnc_sendFeedback;
		};

		// Reclaim only the requested name, without deleting empty lobby/JIP groups.
		private _groups = allGroups;
		private _emptyConflicts = _groups select {
			_x != _grp && {side _x == side _grp} && {units _x isEqualTo []} && {
				toUpper (groupId _x) == _txt
				|| {((_x getVariable ["lmf_bft_state", []]) param [0, ""]) == _txt}
			}
		};
		{
			private _emptyGroup = _x;
			if (toUpper (groupId _emptyGroup) == _txt) then {
				private _number = 1;
				private _unusedName = format ["LMF EMPTY %1", _number];
				while {(_groups findIf {
					side _x == side _grp && {
						toUpper (groupId _x) == _unusedName
						|| {((_x getVariable ["lmf_bft_state", []]) param [0, ""]) == _unusedName}
					}
				}) != -1} do {
					_number = _number + 1;
					_unusedName = format ["LMF EMPTY %1", _number];
				};
				_emptyGroup setGroupIdGlobal [_unusedName];
			};
			if !((_emptyGroup getVariable ["lmf_bft_state", []]) isEqualTo []) then {
				_emptyGroup setVariable ["lmf_bft_state", [], true];
			};
		} forEach _emptyConflicts;

		// CBA_fnc_setCallsign defers to the next frame; finish this transaction now.
		_grp setGroupIdGlobal [_txt];
		_grp setVariable ["lmf_bft_state", [_txt, _type, _state param [2, ""]], true];
		[_requester, "callsignSet", true, _txt] call lmf_bft_fnc_sendFeedback;
	};
};

// Server arguments: [group, default icon, callsign]. Client requests are asynchronous.
lmf_bft_fnc_setCallsign = {
	params ["_grp", ["_type", "b_inf"], ["_txt", ""], ["_requester", objNull]];
	if (isServer) exitWith {
		[_grp, _type, _txt, _requester] call lmf_bft_fnc_applyCallsign;
	};
	["lmf_bft_setCallsign", [_grp, _type, _txt, player]] call CBA_fnc_serverEvent;
};

lmf_bft_fnc_applyIcon = {
	if (!isServer) exitWith {};
	isNil {
		params ["_grp", "_type", ["_requester", objNull], ["_label", ""]];
		if (!lmf_bft || {isNull _grp}) exitWith {};
		if (!isNull _requester && {_requester != leader _grp || {!alive _requester}}) exitWith {
			[_requester, "Only the current group leader can change BFT.", false] call lmf_bft_fnc_sendFeedback;
		};
		private _state = _grp getVariable ["lmf_bft_state", []];
		if (_state isEqualTo []) exitWith {
			[_requester, "Select a BFT callsign first.", false] call lmf_bft_fnc_sendFeedback;
		};
		if ((_state select 2) != _type) then {
			_grp setVariable ["lmf_bft_state", [_state select 0, _state select 1, _type], true];
		};
		private _message = if (_type == "") then {"iconReset"} else {"iconSet"};
		[_requester, _message, true, _label] call lmf_bft_fnc_sendFeedback;
	};
};

lmf_bft_fnc_setIcon = {
	params ["_grp", ["_type", ""], ["_label", ""], ["_requester", objNull]];
	if (isServer) exitWith {
		[_grp, _type, _requester, _label] call lmf_bft_fnc_applyIcon;
	};
	["lmf_bft_setIcon", [_grp, _type, player, _label]] call CBA_fnc_serverEvent;
};

if (isServer) then {
	["lmf_bft_setCallsign", {
		_this call lmf_bft_fnc_applyCallsign;
	}] call CBA_fnc_addEventHandler;
	["lmf_bft_setIcon", {
		_this call lmf_bft_fnc_applyIcon;
	}] call CBA_fnc_addEventHandler;
};

if (hasInterface) then {
	["lmf_bft_feedback", {
		params ["_recipient", "_message", "_success", ["_value", ""]];
		if (_recipient != player) exitWith {};

		private _text = _message;
		if (_value != "" || {_message in ["iconSet", "iconReset"]}) then {
			private _body = switch (_message) do {
				case "callsignAlready": {
					format ["<t shadow='2' color='%3' size='1' >Your callsign is already</t><t shadow='2' color='%2' size='1' > %1</t>.", _value, LMF_HIGHLIGHT_FRIENDLY_COLOR, LMF_TEXT_COLOR]
				};
				case "callsignInUse": {
					format ["Callsign %1 is already in use.", _value]
				};
				case "callsignSet": {
					format ["<t shadow='2' color='%3' size='1' >Callsign set to</t><t shadow='2' color='%2' size='1' > %1</t>.", _value, LMF_HIGHLIGHT_FRIENDLY_COLOR, LMF_TEXT_COLOR]
				};
				case "iconSet": {
					format ["<t shadow='2' color='%3' size='1' >Icon set to</t><t shadow='2' color='%2' size='1' > %1</t>.", _value, LMF_HIGHLIGHT_FRIENDLY_COLOR, LMF_TEXT_COLOR]
				};
				case "iconReset": {
					format ["<t shadow='2' color='%2' size='1' >Icon reset to</t><t shadow='2' color='%1' size='1' > default</t>.", LMF_HIGHLIGHT_FRIENDLY_COLOR, LMF_TEXT_COLOR]
				};
				default {_message};
			};
			_text = _body;
		};
		// Re-selecting the current callsign is informational.
		private _isError = !_success && {_message != "callsignAlready"};
		["Blue Force Tracker", _text, "A3\modules_f\data\portraitstrategicmapimage_ca.paa", 2.55, 12,
			if (_isError) then {"addItemFailed"} else {["", "beep"] select _success}, 1.1, _isError] call lmf_notifications_fnc_showAceMessage;
	}] call CBA_fnc_addEventHandler;
};
