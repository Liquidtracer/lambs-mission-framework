/*
    Radio operator loadout
    Applies the RTO loadout to the supplied local unit.
    Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _rto#1, true];
_unit setRank _rto#2;

[_unit, _rtoUniform, _rtoVest, _rtoHeadgear, _rtoGoggles, _rtoBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _radioL, false] call lmf_equipment_fnc_addItem;
[_unit, _radioB, false] call lmf_equipment_fnc_addItem;

[_unit, _rtoWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
