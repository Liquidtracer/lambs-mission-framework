/*
    Rifleman loadout
    Applies the Rifleman loadout to the supplied local unit.
    Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _rifleman#1, true];
_unit setRank _rifleman#2;

[_unit, _rUniform, _rVest, _rHeadgear, _rGoggles, _rBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _rWeapon] call lmf_equipment_fnc_giveWeapon;
if (var_riflemanLat) then {[_unit, 9] call lmf_equipment_fnc_giveWeapon};

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
