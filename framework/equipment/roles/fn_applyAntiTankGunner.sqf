/*
    Anti-tank gunner loadout
    Applies the AT Specialist loadout to the supplied local unit.
    Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _antiTankGunner#1, true];
_unit setRank _antiTankGunner#2;

[_unit, _atUniform, _atVest, _atHeadgear, _atGoggles, _atBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, 10] call lmf_equipment_fnc_giveWeapon;
[_unit, _atWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
