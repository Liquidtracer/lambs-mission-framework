/*
    Mine-clearance request
    Unscheduled server event handler. Validates a request and reserves one dispatch before spawning work.

    Arguments: requesting player object and a three-component ATL map position.
*/

if (!isServer) exitWith {};
params [["_requester", objNull, [objNull]], ["_pos", [], [[]]]];
if (isNull _requester || {!isPlayer _requester} || {!alive _requester}) exitWith {};
private _error = "";
if (serverTime < lmf_support_nextDispatch) then {
    _error = format ["Support available in %1 seconds.", ceil (lmf_support_nextDispatch - serverTime)];
};
if (count _pos != 3 || {_pos findIf {!(_x isEqualType 0)} != -1}) then {_error = "Invalid destination."} else {
    if (surfaceIsWater _pos) then {_error = "Select a minefield on land."};
};
if (side group _requester != lmf_support_state#2) then {_error = "Support is not available to your side."};
if (!([_requester] call lmf_radio_fnc_hasLongRangeRadio)) then {_error = "A long-range radio is required."};
if (leader group _requester != _requester) then {_error = "Only group leaders can request support."};
if (missionNamespace getVariable ["lmf_warmup", true]) then {_error = "Start the mission first."};
if ((lmf_support_state#0) - lmf_support_pending <= 0) then {_error = "No mine-clearance dispatches remaining."};
lmf_support_config params ["_vehicleClass", "_engineerCount", "_startObjectName", "_unitClass"];
private _startObject = missionNamespace getVariable [_startObjectName, objNull];
if (!(_startObject isEqualType objNull) || {isNull _startObject}) then {_error = format ["Start object '%1' is missing.<br/><t color='%2'>Place and name it in Eden.</t>", _startObjectName, LMF_TEXT_COLOR]};
if (!(_vehicleClass isKindOf "LandVehicle") || {!(_unitClass isKindOf "CAManBase")} || {_engineerCount < 1}) then {_error = "Invalid support vehicle, Rifleman class or engineer count."};
if (_error isNotEqualTo "") exitWith {["lmf_support_message", [_error], _requester] call CBA_fnc_targetEvent};

lmf_support_nextDispatch = serverTime + lmf_support_dispatchCooldown;
publicVariable "lmf_support_nextDispatch";
lmf_support_pending = lmf_support_pending + 1;
[_pos, getPosATL _startObject, getDir _startObject] spawn lmf_support_fnc_runClearance;
