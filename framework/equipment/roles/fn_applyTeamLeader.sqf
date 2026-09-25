/*
    Team leader loadout
    Applies the Team Leader loadout to the supplied local unit.
    Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setRank _teamLeader#2;
_unit setVariable ["lmf_currentRole", _teamLeader#1, true];

[_unit, _tlUniform, _tlVest, _tlHeadgear, _tlGoggles, _tlBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _radioL, false] call lmf_equipment_fnc_addItem;

for "_i" from 1 to 2 do {
	[_unit, (selectRandom _grenadeSmoke), false] call lmf_equipment_fnc_addItem;
	[_unit, (selectRandom _grenadeSmokeClr), false] call lmf_equipment_fnc_addItem;
};

[_unit, _tlWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
