/*
	Vehicle crew loadout
	Applies the Vehicle Crew loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _crew#1, true];
_unit setRank _crew#2;

[_unit, _vcUniform, _vcVest, _vcHeadgear, _vcGoggles, _vcBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _vcWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
