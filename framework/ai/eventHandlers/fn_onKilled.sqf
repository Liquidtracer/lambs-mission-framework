/*
	AI death handling
	Handles AI death.

	Arguments:
		0: Affected unit <OBJECT>

	Example:
		[soldier_1] call lmf_ai_fnc_onKilled;
*/

params ["_unit"];
if !(local _unit) exitWith {};

// _unit unlinkItem (hmd _unit);
// _unit removeWeapon (binocular _unit);
// removeAllPrimaryWeaponItems _unit;
