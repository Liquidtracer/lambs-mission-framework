/*
    Spectator event registration
    Registers spectator display handlers; included in the client section of XEH_postInit.sqf.
*/

["ace_spectator_displayLoaded", {
    params ["_display"];
    uiNamespace setVariable ["lmf_spectatorDisplay", _display];
    [_display] spawn lmf_spectator_fnc_showMedicalInfo;
}] call CBA_fnc_addEventHandler;

["ace_spectator_displayUnloaded", {
    params ["_display"];
    if ((uiNamespace getVariable ["lmf_spectatorDisplay", displayNull]) isEqualTo _display) then {
        uiNamespace setVariable ["lmf_spectatorDisplay", displayNull];
    };
}] call CBA_fnc_addEventHandler;

