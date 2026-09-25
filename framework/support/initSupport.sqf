/*
    Mine-clearance service
    Starts the mine-clearance service once from postInit and defines the shared Support menu.
    Server owns requests and dispatches; clients register inherited ACE self-actions for respawn and JIP.
    Helpers are compiled here rather than adding another initialization entry in CfgFunctions.

    Mission setup:
    Place an object named lmf_supportStart in Eden with clear vehicle access; its position and heading define the base.
    The vehicle needs seats for four: a driver, an optional main gunner and cargo seats for the remaining engineers.
    The quota is shared by the configured Rifleman's side. Dispatches are spaced 30 seconds apart.
    Search starts within 100 m of the request and follows mines with gaps of at most 20 m.
    Rifleman equipment must have room for a ToolKit; missing backpacks use the configured AT backpack.
*/

if (missionNamespace getVariable ["lmf_support_initialized", false]) exitWith {};
lmf_support_initialized = true;
lmf_support_icon = "\A3\ui_f\data\igui\cfg\simpletasks\types\mine_ca.paa";

if (isServer) then {
    #include "..\..\settings\cfg_Player.sqf"

    private _supportSide = [east, west, independent, civilian] param [getNumber (configFile >> "CfgVehicles" >> (_rifleman#0) >> "side"), sideUnknown];
    lmf_support_config = [var_supportVehicleClass, 4, "lmf_supportStart", _rifleman#0, _atBackpack];
    // Pending setup reservations prevent simultaneous requests from overspending the quota.
    lmf_support_pending = 0;
    lmf_support_dispatchCooldown = 30;
    lmf_support_nextDispatch = 0;
    publicVariable "lmf_support_nextDispatch";
    // The client radius indicates the initial search area, not the eventual clearance boundary.
    lmf_support_state = [0 max floor var_supportClearanceLimit, 100, _supportSide, var_supportClearanceLimit > 0];
    publicVariable "lmf_support_state";

    lmf_support_fnc_notify = {
        params ["_text", ["_callsign", ""]];
        private _recipients = allPlayers select {side group _x == lmf_support_state#2 && {[_x] call lmf_radio_fnc_hasLongRangeRadio}};
        ["lmf_support_message", [_text, _callsign], _recipients] call CBA_fnc_targetEvent;
    };
    lmf_support_fnc_runClearance = compile preprocessFileLineNumbers "framework\support\runClearance.sqf";
    lmf_support_fnc_findStopPosition = compile preprocessFileLineNumbers "framework\support\findStopPosition.sqf";
    lmf_support_fnc_findMinefield = compile preprocessFileLineNumbers "framework\support\findMinefield.sqf";
    lmf_support_fnc_requestClearance = compile preprocessFileLineNumbers "framework\support\requestClearance.sqf";
    ["lmf_support_request", lmf_support_fnc_requestClearance] call CBA_fnc_addEventHandler;
};

if (!hasInterface) exitWith {};
["lmf_support_message", {
    params ["_text", ["_callsign", ""]];
    if (_callsign == "") exitWith {
        ["MINE CLEARANCE", _text, lmf_support_icon, 3.3, 12, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
    };
    if (!([player] call lmf_radio_fnc_hasLongRangeRadio)) exitWith {};
    [_callsign, _text, lmf_support_icon, 3, 12, "TacticalPing4", 1] call lmf_notifications_fnc_showAceMessage;
}] call CBA_fnc_addEventHandler;

// Called once by the ordered client menu setup before registering service actions.
lmf_support_fnc_registerMenu = {
    // The shared parent has no service-specific access restrictions. ACE hides an empty parent.
    private _parent = ["lmf_support", "Support", ["\A3\ui_f_curator\data\displays\rscdisplaycurator\modemodules_ca.paa", LMF_MAIN_COLOR], {}, {true}] call ace_interact_menu_fnc_createAction;
    ["CAManBase", 1, ["ACE_SelfActions"], _parent, true] call ace_interact_menu_fnc_addActionToClass;
};

// Called after Supply Drop so service order is stable even when only one is enabled.
lmf_support_fnc_registerClearanceMenu = {
    // Keep the action after the last dispatch, including for JIP clients.
    if (!(lmf_support_state#3)) exitWith {};
    lmf_support_fnc_selectMinefield = compile preprocessFileLineNumbers "framework\support\selectMinefield.sqf";
    private _condition = {
        params ["_target", "_player"];
        alive _player && {leader group _player == _player} && {side group _player == lmf_support_state#2} && {[_player] call lmf_radio_fnc_hasLongRangeRadio}
    };
    private _request = ["lmf_support_clearance", "Mine Clearance", [lmf_support_icon, LMF_MAIN_COLOR], {
        [] spawn lmf_support_fnc_selectMinefield;
    }, _condition] call ace_interact_menu_fnc_createAction;
    ["CAManBase", 1, ["ACE_SelfActions", "lmf_support"], _request, true] call ace_interact_menu_fnc_addActionToClass;
};
