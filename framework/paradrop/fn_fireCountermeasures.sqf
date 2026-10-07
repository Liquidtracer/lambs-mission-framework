/*
	Fire countermeasures
	Fires the paradrop countermeasure sequence.

	Arguments:
		0: Aircraft <OBJECT>
		1: Interval between bursts <NUMBER> (default: 2)

	Example:
		[plane_1, 2] spawn lmf_paradrop_fnc_fireCountermeasures;
*/

params [
	["_aircraft", objNull, [objNull]],
	["_interval", 2, [0]]
];

if (isNull _aircraft || {_aircraft getVariable ["lmf_firingCountermeasures", false]}) exitWith {};

_aircraft setVariable ["lmf_firingCountermeasures", true];

for "_i" from 1 to 8 do {
	(driver _aircraft) forceWeaponFire ["CMFlareLauncher", "Burst"];
	_aircraft action ["useWeapon", _aircraft, driver _aircraft, 0];
	sleep _interval;
};

_aircraft setVariable ["lmf_firingCountermeasures", false];
