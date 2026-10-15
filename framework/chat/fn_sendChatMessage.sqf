/*
	Send chat message
	Sends a custom chat command. Internal helper.
	Author: Cuel.

	Arguments:
		0: Message <STRING>
		1: Message type <STRING> ("zeus", "whisper" or regular chat)
		2: Receiver name or player <STRING or OBJECT> (default: "")

	Example:
		["Ready to move.", "whisper", "Alex2k"] call lmf_chat_fnc_sendChatMessage;
*/

params ["_msg", "_type", ["_receiver", ""]];

private _receiverName = if (_receiver isEqualType objNull) then {name _receiver} else {_receiver};

private _callsign = switch (toLower _type) do {
	case "zeus": {"to Zeus:"};
	case "whisper": {format ["Whisper to %1:", _receiverName]};
	default {"Chat:"}
};

lmf_chatChannel radioChannelAdd [ACE_player];
lmf_chatChannel radioChannelSetCallsign _callsign;
player customChat [lmf_chatChannel, _msg];
lmf_chatChannel radioChannelRemove [ACE_player];

switch (toLower _type) do {
	case "whisper": {
		private _target = if (_receiver isEqualType objNull) then {_receiver} else {[_receiver] call lmf_chat_fnc_findPlayerByName};
		if (!isNull _target) then {
			["lmf_chatMessage", [profileName, _msg, _type, _target], _target] call CBA_fnc_targetEvent;
		};
	};
	case "zeus": {
		private _targets = (allPlayers - entities "HeadlessClient_F") select {_x != player && {!isNull (getAssignedCuratorLogic _x)}};
		["lmf_chatMessage", [profileName, _msg, _type, _receiver], _targets] call CBA_fnc_targetEvent;
	};
	default {
		["lmf_chatMessage", [profileName, _msg, _type, _receiver]] call CBA_fnc_globalEvent;
	};
};

playSound "3DEN_notificationDefault";
