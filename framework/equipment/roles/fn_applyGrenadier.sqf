/*
    Grenadier loadout
    Applies the Grenadier loadout to the supplied local unit.
    Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _grenadier#1, true];
_unit setRank _grenadier#2;

[_unit, _gUniform, _gVest, _gHeadgear, _gGoggles, _gBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _gWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
