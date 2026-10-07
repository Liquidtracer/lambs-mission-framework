/*
	Manage time and weather
	Restores the initial time and weather after warmup.
*/

if (!isServer) exitWith {};

waitUntil {sleep 1; !isNil "lmf_warmup_isActive"};
if !(lmf_warmup_isActive) exitWith {};

private _date = date;
private _fog = fogParams;
private _overcast = overcast;
private _rain = rainParams;

// Slow time during warmup
setTimeMultiplier 0.1;

// Wait for warmup end
waitUntil {sleep 0.1; !lmf_warmup_isActive};

// Reset time and weather.
[_date] remoteExec ["setDate"];
setTimeMultiplier 1;
0 setFog _fog;
0 setOvercast _overcast;
forceWeatherChange;
_rain call BIS_fnc_setRain;
