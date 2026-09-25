/*
    Medic loadout
    Applies the Medic loadout to the supplied local unit.
    Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _medic#1, true];
_unit setRank _medic#2;

[_unit, _medUniform, _medVest, _medHeadgear, _medGoggles, _medBackpack] call lmf_equipment_fnc_applyBaseLoadout;

for "_i" from 1 to 3 do {
	for "_i" from 1 to 2 do {[_unit, (selectRandom _grenadeSmoke), true] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 6 do {[_unit, "ACE_fieldDressing", false] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 2 do {[_unit, "ACE_tourniquet", false] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 2 do {[_unit, "ACE_morphine", false] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 2 do {[_unit, "ACE_epinephrine", false] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 2 do {[_unit, "ACE_bloodIV", false] call lmf_equipment_fnc_addItem};
};

[_unit, _medWeapon] call lmf_equipment_fnc_giveWeapon;

[_unit, "lambs_medic"] call bis_fnc_setUnitInsignia;

_unit setUnitTrait ["medic", true];

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
