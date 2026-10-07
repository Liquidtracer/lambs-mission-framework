/*
	Anti-tank assistant loadout
	Applies the AT Assistant loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _antiTankAssistant#1, true];
_unit setRank _antiTankAssistant#2;

[_unit, _ataUniform, _ataVest, _ataHeadgear, _ataGoggles, _ataBackpack] call lmf_equipment_fnc_applyBaseLoadout;

for "_i" from 1 to 4 do {[_unit, (selectRandom _matAmmo), false] call lmf_equipment_fnc_addItem};

[_unit, _ataWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
