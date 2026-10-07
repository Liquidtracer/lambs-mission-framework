/*
	Manage NVG
	Makes AI stow away NVG when it's not dark, and re-equip when it is.
	Author: Alex2k.

	Example:
		[] spawn lmf_ai_fnc_manageNvg;
*/

waitUntil {sleep 1; CBA_missionTime > 0};
private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {};

private _nvg = (lmf_ai_config get "NVG") select {_x isNotEqualTo ""};
if (_nvg isEqualTo []) exitWith {};

private _applyNightState = {
	params ["_isNight"];

	{
		if (!isPlayer _x && {alive _x}) then {
			if (_isNight) then {
				_x linkItem (selectRandom _nvg);
			} else {
				_x unlinkItem (hmd _x);
			};
		};
	} forEach (units var_enemySide);
};

private _wasNight = sunOrMoon < 1;
[_wasNight] call _applyNightState;

while {true} do {
	sleep 30;

	private _isNight = sunOrMoon < 1;
	if (_isNight isNotEqualTo _wasNight) then {
		[_isNight] call _applyNightState;
		_wasNight = _isNight;
	};
};
