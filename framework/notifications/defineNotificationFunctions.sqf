/*
	Notification helpers
	Defines local helpers for mission outcome and framework notifications.
*/

lmf_notifications_fnc_showVictory = {
	["LMFvictory", ["MISSION COMPLETED"]] call BIS_fnc_showNotification;
};

lmf_notifications_fnc_showDefeat = {
	["LMFdefeat", ["MISSION FAILED"]] call BIS_fnc_showNotification;
};

lmf_notifications_fnc_showNotification = {
	params ["_msg"];
	["LMFnotification", [_msg]] call BIS_fnc_showNotification;
};
