/*
	Helicopter crew loadout
	Applies the Helicopter Crew loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _heloCrew#1, true];
_unit setRank _heloCrew#2;

[_unit, _hcUniform, _hcVest, _hcHeadgear, _hcGoggles, _hcBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _hcWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
