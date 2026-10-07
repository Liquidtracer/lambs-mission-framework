/*
	Report performance
	Reports server and headless-client performance to the supplied player.

	Arguments:
		0: Player receiving performance messages <OBJECT>

	Example:
		[admin_1] spawn lmf_admin_fnc_reportPerformance;
*/

if (hasInterface && {!isServer}) exitWith {};

params ["_unit"];

// Request FPS from the server and headless clients.
"Checking FPS" remoteExec ["systemChat", _unit];

for "_i" from 1 to 10 do {
	(format ["%1 has %2 FPS (%3/10)", ["Headless client", "Server"] select (isServer), round diag_fps, _i]) remoteExec ["systemChat", _unit];
	sleep 5;
};