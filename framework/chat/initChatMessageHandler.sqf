/*
    Chat message receiver
    Registers the client chat receiver; included by XEH_postInit.sqf.
*/

["lmf_chatMessage", {
    params ["_sender", "_msg", "_type", "_receiver", ["_ping", true]];

    private _args = switch (toLower _type) do {
        case "zeus": {
            [{!(profileName isEqualTo _sender) && !isNull (getAssignedCuratorLogic player)}, format ["(Zeus) %1:", _sender]];
        };
        case "whisper": {
            [{profileName isEqualTo _receiver}, format ["Whisper from %1:", _sender]];
        };
        default {
            [{true}, format ["Notice (%1):", _sender]];
        };
    };
    _args params ["_condition", "_text"];

    if ([] call _condition) then {
        lmf_chatChannel radioChannelAdd [ACE_player];
        lmf_chatChannel radioChannelSetCallsign _text;
        ACE_player customChat [lmf_chatChannel, _msg];
        lmf_chatChannel radioChannelRemove [ACE_player];
        playSound "beep";
    };
}] call CBA_fnc_addEventHandler;

