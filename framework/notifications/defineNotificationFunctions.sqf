/*
	Notification helpers
	Defines local helpers for mission outcome and framework notifications.
*/

lmf_notifications_fnc_showVictory = {
	["lmf_notifications_victory", ["Mission completed"]] call BIS_fnc_showNotification;
};

lmf_notifications_fnc_showDefeat = {
	["lmf_notifications_defeat", ["Mission failed"]] call BIS_fnc_showNotification;
};

lmf_notifications_fnc_showNotification = {
	params ["_msg"];
	["lmf_notifications_message", [_msg]] call BIS_fnc_showNotification;
};
