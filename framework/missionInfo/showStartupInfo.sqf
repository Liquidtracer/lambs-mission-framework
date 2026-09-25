/*
    Startup mission information
    One local startup message per login, including JIP. No respawn hook or persistent UI.
*/

if (!hasInterface) exitWith {};

waitUntil {uiSleep 0.2; missionNamespace getVariable ["lmf_player_introComplete", false]};
if (var_personalArsenal) then {
    waitUntil {uiSleep 0.2; scriptDone lmf_player_arsenalInit};
};
waitUntil {uiSleep 0.2; scriptDone lmf_player_menuInit};
// Reveal the world only when the menus are ready and the startup message can open.
cutText ["", "BLACK IN", 5, true];
if (!alive player) exitWith {};

private _entries = [];
private _addEntry = {
    params ["_title", "_body", "_path"];
    _entries pushBack format [
        "<t font='PuristaBold' color='%1'>%2</t><br/><t font='PuristaMedium' size='0.8'>%3</t><br/><t font='PuristaMedium' color='%4' size='0.8'>%5</t>",
        LMF_MAIN_COLOR, _title, _body, LMF_LINK_COLOR, _path
    ];
};

if (lmf_warmup && {var_personalArsenal}) then {
    ["PERSONAL ARSENAL", "Customize your personal equipment.",
        " Self-Interact » Equipment » Personal Arsenal"] call _addEntry;

    if (count (missionNamespace getVariable ["lmf_player_availableOptics", []]) > 0) then {
        ["AVAILABLE OPTICS", "Choose an optic for your primary weapon.",
            " Self-Interact » Equipment » Available Optics"] call _addEntry;
    };
};

if (var_bft && {count (var_bftInfantry + var_bftGroundVehicles + var_bftAirVehicles) > 0}) then {
    ["BLUE FORCE TRACKER", "Group leaders select their group's callsign and icon.",
        " Self-Interact » Blue Force Tracker"] call _addEntry;
};

if (var_supplyDropLimit > 0 && {lmf_remainingSuppDrops > 0}) then {
    private _body = if (var_supplyDropVehicles && {var_vic1 != "" || var_vic2 != "" || var_vic3 != "" || var_vic4 != ""}) then {
        "Request supplies or vehicles. Requires a map and long-range radio."
    } else {
        "Request supplies. Requires a map and long-range radio."
    };
    ["SUPPLY DROP", _body,
        " Self-Interact » Support » Supply Drop"] call _addEntry;
};

if (lmf_support_state#3 && {side group player == lmf_support_state#2}) then {
    private _body = if (lmf_support_state#0 > 0) then {
        "Group leaders can request mine clearance. Requires a map and long-range radio."
    } else {
        "No mine-clearance dispatches remaining."
    };
    ["MINE CLEARANCE", _body,
        " Self-Interact » Support » Mine Clearance"] call _addEntry;
};

if (lmf_warmup && {var_forwardDeploy}) then {
    ["FORWARD DEPLOY", "Group leaders register their group for deployment before warmup ends.",
        " Self-Interact » Register Forward Deploy"] call _addEntry;
};

if (player getVariable ["lmf_jipAvailable", false]) then {
    ["JIP TELEPORT", "Teleport to friendlies once. Available for five minutes, until you leave the 200 m spawn area or die.",
        " Self-Interact » JIP Teleport"] call _addEntry;
};

if (_entries isEqualTo []) exitWith {};

private _text = format [
    "<t align='left' font='PuristaBold' size='1.4'>LMF Systems</t><br/><t align='left' font='PuristaMedium' size='0.8'>These systems are available through ACE self-interact.<br/>Some are limited to warmup or group leaders.</t><br/><br/>%2",
    LMF_MAIN_COLOR, _entries joinString "<br/><br/>"
];

[parseText _text, "LAMBS Mission Framework", "OK", false] call BIS_fnc_guiMessage;
