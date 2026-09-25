/*
    Group arrival notifications
    Starts group arrival notifications once from player-client postInit.
    CBA player events observe membership independently of group ownership.
    The intro flag gates arrivals; only JIP announces the initial membership.
    State belongs to the client session and survives replacement of the player unit.
*/

if (!hasInterface || {missionNamespace getVariable ["lmf_groupNotifications_started", false]}) exitWith {};
lmf_groupNotifications_started = true;

// Register the receiver before waiting for our own intro. Never replay old arrivals.
["lmf_groupNotifications_arrived", {
    params ["_unit", "_group", "_recipient"];
    if (isNull _unit || {isNull _group} || {_recipient != player} || {_unit == player}
        || {group _unit != _group} || {group player != _group} || {leader _group != player}) exitWith {};

    // Escape player-controlled text before inserting it into ACE structured text.
    private _playerName = ((toArray name _unit) apply {
        switch (_x) do {
            case 38: {"&amp;"};
            case 60: {"&lt;"};
            case 62: {"&gt;"};
            default {toString [_x]};
        }
    }) joinString "";

    ["", format ["<t color='%2'>%1</t><br/>joined your group.", _playerName, LMF_HIGHLIGHT_FRIENDLY_COLOR],
        "\A3\3den\data\displays\display3den\panelright\modegroups_ca.paa", 2.55, 12, "", 1.1]
        call lmf_notifications_fnc_showAceMessage;
}] call CBA_fnc_addEventHandler;

// One sender per player session; the group baseline suppresses repeated events and same-group respawn.
lmf_groupNotifications_fnc_notifyArrival = {
    private _group = group player;
    if (isNull player || {isNull _group} || {_group == lmf_groupNotifications_lastGroup}) exitWith {};
    lmf_groupNotifications_lastGroup = _group;

    private _recipient = leader _group;
    if (isNull _recipient || {_recipient == player} || {!isPlayer _recipient}) exitWith {};
    ["lmf_groupNotifications_arrived", [player, _group, _recipient], _recipient] call CBA_fnc_targetEvent;
};

[] spawn {
    waitUntil {uiSleep 0.2; missionNamespace getVariable ["lmf_player_introComplete", false]};

    // Seed normal startup silently. A JIP session announces its current group once.
    lmf_groupNotifications_lastGroup = group player;
    if (didJIP) then {
        lmf_groupNotifications_lastGroup = grpNull;
        call lmf_groupNotifications_fnc_notifyArrival;
    };

    ["group", {
        params ["_unit"];
        // CBA also observes Zeus remote control; only our actual player counts.
        if (_unit == player) then {
            call lmf_groupNotifications_fnc_notifyArrival;
        };
    }, true] call CBA_fnc_addPlayerEventHandler;
};
