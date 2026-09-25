/*
    Show role change message
    Shows the supplied role name through the shared loadout notification.
*/

params ["_loadout"];

["NEW LOADOUT", _loadout, "\A3\ui_f\data\igui\cfg\actions\gear_ca.paa", 2.85, 10, "", 1.45] call lmf_notifications_fnc_showAceMessage;
