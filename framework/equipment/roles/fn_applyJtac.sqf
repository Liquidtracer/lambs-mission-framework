/*
	JTAC loadout
	Applies the JTAC loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _jtac#1, true];
_unit setRank _jtac#2;

[_unit, _jtacUniform, _jtacVest, _jtacHeadgear, _jtacGoggles, _jtacBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _radioL, false] call lmf_equipment_fnc_addItem;
[_unit, _radioB, false] call lmf_equipment_fnc_addItem;

_unit addWeapon _binocular;

for "_i" from 1 to 2 do {
	[_unit, (selectRandom _grenadeSmoke), false] call lmf_equipment_fnc_addItem;
	[_unit, (selectRandom _grenadeSmokeClr), false] call lmf_equipment_fnc_addItem;
};

[_unit, _jtacWeapon] call lmf_equipment_fnc_giveWeapon;

[_unit, "lambs_jtac"] call bis_fnc_setUnitInsignia;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
