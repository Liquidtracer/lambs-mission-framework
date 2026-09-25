/*
    Minefield selection
    Scheduled client-only map selection. Closing the map cancels selection, never an accepted dispatch.
    The server rechecks availability after confirmation; no client reserves or spends the quota.
    Requires the replicated cooldown deadline and claims the shared client support-selection lock.
*/

if (!hasInterface || {missionNamespace getVariable ["lmf_support_selecting", false]}) exitWith {};
if (lmf_support_state#0 <= 0) exitWith {
    ["MINE CLEARANCE", "No mine-clearance dispatches remaining.", lmf_support_icon, 3.8, 12, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
};
// Reject cooldown attempts before opening the map or installing selection handlers.
private _remaining = ceil (lmf_support_nextDispatch - serverTime);
if (_remaining > 0) exitWith {
    ["MINE CLEARANCE", format ["Support available in %1 seconds.", _remaining], lmf_support_icon, 3.3, 12, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
};
if (missionNamespace getVariable ["lmf_warmup", true]) exitWith {
    ["MINE CLEARANCE", "Start the mission first.", lmf_support_icon, 3, 12, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
};
if (!("ItemMap" in assignedItems player)) exitWith {
    ["MINE CLEARANCE", "A map is required.", lmf_support_icon, 3, 12, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
};

// Scheduled callers must claim the shared selection without a scheduler interruption.
private _claimed = false;
isNil {
    if (!(missionNamespace getVariable ["lmf_support_selecting", false])) then {
        lmf_support_selecting = true;
        _claimed = true;
    };
};
if (!_claimed) exitWith {};
lmf_support_selectedPosition = [];
lmf_support_selectionCancelled = false;
private _requester = player;
private _mapWasOpen = visibleMap;
private _mapEh = addMissionEventHandler ["MapSingleClick", {
    params ["_units", "_pos"];
    if (lmf_support_selectedPosition isEqualTo [] && {!lmf_support_selectionCancelled}) then {lmf_support_selectedPosition = +_pos};
}];
private _closeEh = addMissionEventHandler ["Map", {
    params ["_opened"];
    if (!_opened) then {lmf_support_selectionCancelled = true};
}];
if (!_mapWasOpen) then {openMap true};
["MINE CLEARANCE", "Click the minefield location.<br/>Close the map to cancel selection.", lmf_support_icon, 3.3, 12, "taskUpdated", 1] call lmf_notifications_fnc_showAceMessage;
waitUntil {uiSleep 0.1; lmf_support_selectionCancelled || {!visibleMap} || {lmf_support_selectedPosition isNotEqualTo []} || {!alive _requester} || {player isNotEqualTo _requester}};
removeMissionEventHandler ["MapSingleClick", _mapEh];

if (!lmf_support_selectionCancelled && {visibleMap} && {alive _requester} && {player isEqualTo _requester} && {lmf_support_selectedPosition isNotEqualTo []}) then {
    private _pos = +lmf_support_selectedPosition;
    private _marker = createMarkerLocal ["lmf_support_selection", _pos];
    _marker setMarkerShapeLocal "ELLIPSE";
    _marker setMarkerBrushLocal "Solid";
    _marker setMarkerColorLocal "ColorBLUFOR";
    _marker setMarkerAlphaLocal 0.5;
    _marker setMarkerSizeLocal [lmf_support_state#1, lmf_support_state#1];
    private _confirmed = [format ["Request mine clearance here?<br/>Dispatches remaining: %1", lmf_support_state#0], "MINE CLEARANCE", "REQUEST", "CANCEL"] call BIS_fnc_guiMessage;
    deleteMarkerLocal _marker;
    if (_confirmed && {!lmf_support_selectionCancelled} && {visibleMap} && {alive _requester} && {player isEqualTo _requester}) then {
        ["lmf_support_request", [_requester, _pos]] call CBA_fnc_serverEvent;
    };
};
removeMissionEventHandler ["Map", _closeEh];
if (!_mapWasOpen) then {openMap false};
lmf_support_selectedPosition = [];
lmf_support_selectionCancelled = false;
lmf_support_selecting = false;
