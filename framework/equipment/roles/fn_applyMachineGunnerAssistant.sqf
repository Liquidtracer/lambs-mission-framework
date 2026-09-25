/*
    Machine gunner assistant loadout
    Applies the Assistant Machine Gunner loadout to the supplied local unit.
    Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _machineGunnerAssistant#1, true];
_unit setRank _machineGunnerAssistant#2;

[_unit, _mgaUniform, _mgaVest, _mgaHeadgear, _mgaGoggles, _mgaBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, "ACE_SpareBarrel", false] call lmf_equipment_fnc_addItem;
for "_i" from 1 to 4 do {[_unit, (selectRandom _mmgAmmo), false] call lmf_equipment_fnc_addItem};

[_unit, _mgaWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
