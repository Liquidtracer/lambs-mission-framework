/*
	Set player safety
	Controls player damage and weapon safety during warmup.

	Arguments:
		0: Enable safety <BOOLEAN> (default: false)

	Example:
		[true] call lmf_admin_fnc_setPlayerSafety;
*/

if !(hasInterface) exitWith {};
params [["_state", false]];

if (_state) then {
	lmf_noGuns = player addEventHandler ["Fired", {deleteVehicle (_this select 6);}];
	player allowDamage false;
} else {
	player removeEventHandler ["Fired", lmf_noGuns];
	player allowDamage true;
};