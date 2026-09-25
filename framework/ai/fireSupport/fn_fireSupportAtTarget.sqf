/*
    Fire support at target
    Makes server-owned AI artillery fire a missile or salvo at a given vehicle.
    Supports NATO MK41 VLS / Cruise Missiles and artillery-computer vehicles.
    Run scheduled (spawn / remoteExec). Returns after the battery cooldown.
    Author: Alex2k.

    Arguments:
        0: Artillery vehicle <OBJECT>
        1: Target vehicle <OBJECT>
        2: Delay before firing in seconds <NUMBER> (default: 10)
        3: Player-requested strike: radio messages and VLS BFT <BOOLEAN> (default: false)
        4: Artillery rounds <NUMBER> (default: 1; VLS always fires one missile)

    Cooldowns: VLS 60 seconds after launch; artillery 10 seconds after firing ends.
    Flight time never holds the battery lock. Artillery has no flight monitoring.

    Example:
        [art1, tank3, 12, true, 6] spawn lmf_ai_fnc_fireSupportAtTarget;
*/

params [
    ["_artillery", objNull, [objNull]],
    ["_target", objNull, [objNull]],
    ["_delay", 10, [0]],
    ["_playerRequested", false, [true]],
    ["_rounds", 1, [0]]
];

if (!isServer || isNull _artillery || isNull _target || !alive _target) exitWith {};

_rounds = (round _rounds) max 1;
_delay = _delay max 0;

private _sendMessage = {
    params ["_message", ["_isError", false]];
    if (_playerRequested) then {
        ["FIRE SUPPORT", _message, "A3\modules_f_curator\data\portraitradio_ca.paa", 3.3, 12, ["TacticalPing4", "addItemFailed"] select _isError, 1.45, _isError] remoteExec [
            "lmf_notifications_fnc_showAceMessage",
            (allPlayers - entities "HeadlessClient_F") select {[_x] call lmf_radio_fnc_hasLongRangeRadio}
        ];
    };
};
private _targetType = getText (configFile >> "CfgVehicles" >> typeOf _target >> "displayName");

// Acquire the server lock without a scheduler interruption between check and set.
private _acquired = false;
isNil {
    if !(_artillery getVariable ["lmf_artilleryBusy", false]) then {
        _artillery setVariable ["lmf_artilleryBusy", true, true];
        _acquired = true;
    };
};
if (!_acquired) exitWith {
    [format ["Battery busy.<br/><t color='%2'>Unable to accept [%1].</t>", _targetType, LMF_TEXT_COLOR], true] call _sendMessage;
};

private _abort = {
    params ["_reason"];
    _artillery setVariable ["lmf_artilleryBusy", false, true];
    [format ["Unable to engage [%1].<br/>%2", _targetType, _reason], true] call _sendMessage;
};
if (!alive _artillery || {!local _artillery}) exitWith {
    ["Battery unavailable."] call _abort;
};

[format ["Target received: [%1].<br/>Preparing fire mission.", _targetType]] call _sendMessage;
sleep _delay;

// The battery or target may have been destroyed/deleted during preparation.
if (isNull _artillery || {!alive _artillery} || {!local _artillery}) exitWith {
    ["Battery unavailable."] call _abort;
};
if (isNull _target || {!alive _target}) exitWith {
    ["Target no longer available."] call _abort;
};

private _targetPosition = getPos _target;
private _usesArtilleryFire = !(_artillery isKindOf "Ship")
    && {getNumber (configOf _artillery >> "artilleryScanner") > 0};
private _artilleryMagazine = "";
private _expectedWeapon = "";
private _allowedMagazines = [];

if (_usesArtilleryFire) then {
    private _artilleryMagazines = getArtilleryAmmo [_artillery];
    private _magazineIndex = _artilleryMagazines findIf {
        _targetPosition inRangeOfArtillery [[_artillery], _x]
    };
    if (_magazineIndex != -1) then {
        _artilleryMagazine = _artilleryMagazines # _magazineIndex;
        _allowedMagazines = [_artilleryMagazine];
    };
} else {
    // The direct-fire branch supports MK41 VLS only.
    _expectedWeapon = "weapon_VLS_01";
    _allowedMagazines = getArray (configFile >> "CfgWeapons" >> _expectedWeapon >> "magazines");
};

if (_allowedMagazines isEqualTo []) exitWith {
    ["No suitable ammunition or firing solution."] call _abort;
};

private _friendlySide = side _artillery;
_friendlySide reportRemoteTarget [_target, 300];
_target confirmSensorTarget [_friendlySide, true];

// Server-local state: accepted magazines, weapon filter, count, first projectile,
// first-shot time, last-shot time. MG fire cannot confirm launch or advance a salvo.
_artillery setVariable ["lmf_fireSupportState", [_allowedMagazines, _expectedWeapon, 0, objNull, -1, -1]];
private _firedEh = _artillery addEventHandler ["Fired", {
    params ["_unit", "_weapon", "", "", "", "_magazine", "_projectile"];
    private _state = _unit getVariable ["lmf_fireSupportState", []];
    if (_state isEqualTo []) exitWith {};
    if !(_magazine in (_state # 0)) exitWith {};
    if ((_state # 1) isNotEqualTo "" && {_weapon != (_state # 1)}) exitWith {};
    if ((_state # 2) == 0) then {
        _state set [3, _projectile];
        _state set [4, time];
    };
    _state set [2, (_state # 2) + 1];
    _state set [5, time];
    _unit setVariable ["lmf_fireSupportState", _state];
}];
private _cleanup = {
    _artillery removeEventHandler ["Fired", _firedEh];
    _artillery setVariable ["lmf_fireSupportState", nil];
};

if (_usesArtilleryFire) then {
    _artillery doArtilleryFire [_targetPosition, _artilleryMagazine, _rounds];
} else {
    _artillery fireAtTarget [_target, _expectedWeapon];
};

private _launchTimeout = time + ([8, 30] select _usesArtilleryFire);
waitUntil {
    sleep 0.2;
    ((_artillery getVariable ["lmf_fireSupportState", [[], "", 0]]) # 2) > 0
    || {!alive _artillery} || {!local _artillery} || {time > _launchTimeout}
};
private _state = _artillery getVariable ["lmf_fireSupportState", [[], "", 0, objNull, -1, -1]];
if ((_state # 2) == 0) exitWith {
    call _cleanup;
    ["No launch confirmed."] call _abort;
};

private _firstShotTime = _state # 4;
private _projectile = _state # 3;
private _cooldownEnd = _firstShotTime + 60;

// Announce the first confirmed shot, not the end of a multi-round salvo.
if (_usesArtilleryFire) then {
    private _message = if (_rounds == 1) then {"Round away."} else {
        format ["Shot.<br/>Firing %1-round salvo.", _rounds]
    };
    [format ["%1<br/>[%2]", _message, _targetType]] call _sendMessage;
} else {
    [format ["Missile away.<br/>[%1]", _targetType]] call _sendMessage;
};

if (_usesArtilleryFire) then {
    private _salvoTimeout = time + (30 max (_rounds * 15));
    waitUntil {
        sleep 0.25;
        ((_artillery getVariable ["lmf_fireSupportState", [[], "", 0]]) # 2) >= _rounds
        || {!alive _artillery} || {!local _artillery}
        || {unitReady _artillery} || {time > _salvoTimeout}
    };
    _state = _artillery getVariable ["lmf_fireSupportState", _state];
    private _roundsFired = _state # 2;
    private _firingComplete = _roundsFired >= _rounds || {unitReady _artillery};
    // Anchor a full salvo to its last shot; a partial salvo to observed completion.
    _cooldownEnd = (if (_roundsFired >= _rounds) then {_state # 5} else {time}) + 10;
    if (alive _artillery && {local _artillery}) then {
        if (!_firingComplete) then {
            [format ["Firing confirmation timed out.<br/><t color='%3'>%1 rounds confirmed at [%2].</t>", _roundsFired, _targetType, LMF_TEXT_COLOR], true] call _sendMessage;
        } else {
            if (_rounds > 1) then {
                [format ["Rounds complete.<br/>%1 rounds fired at [%2].", _roundsFired, _targetType]] call _sendMessage;
            };
        };
    };
} else {
    if (_playerRequested) then {
        if (!isNull _projectile) then {
            [_projectile, "mil_triangle", "ColorWEST", [0.9, 1.2], "MSL", 0.25, true, true, -1, true]
                call lmf_bft_fnc_trackObject;
        };
        // Independent flight notification: no battery state is read or written here.
        // Disappearance is approximate end-of-flight, not confirmation of a target hit.
        [_projectile, _targetType, _firstShotTime] spawn {
            params ["_projectile", "_targetType", "_firstShotTime"];
            waitUntil {
                sleep 0.25;
                isNull _projectile || {!alive _projectile} || {time > _firstShotTime + 300}
            };
            if (!isNull _projectile && {alive _projectile}) exitWith {};
            ["FIRE SUPPORT", format ["Splash.<br/>[%1]", _targetType]] remoteExec [
                "lmf_notifications_fnc_showAceMessage",
                (allPlayers - entities "HeadlessClient_F") select {[_x] call lmf_radio_fnc_hasLongRangeRadio}
            ];
        };
    };
};
call _cleanup;

// No impact wait: availability is governed only by firing and the fixed cooldown.
waitUntil {
    sleep 0.25;
    time >= _cooldownEnd || {!alive _artillery} || {!local _artillery}
};
_artillery setVariable ["lmf_artilleryBusy", false, true];
if (alive _artillery && {local _artillery}) then {
    ["Battery standing by."] call _sendMessage;
} else {
    ["Battery unavailable.", true] call _sendMessage;
};
