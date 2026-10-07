/*
	Machine gunner loadout
	Applies the Machine Gunner loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _machineGunner#1, true];
_unit setRank _machineGunner#2;

[_unit, _mgUniform, _mgVest, _mgHeadgear, _mgGoggles, _mgBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, "ACE_SpareBarrel", false] call lmf_equipment_fnc_addItem;

[_unit, _mgWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
