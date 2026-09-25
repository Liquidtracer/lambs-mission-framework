/*
    Platoon sergeant loadout
    Applies the Platoon Sergeant loadout to the supplied local unit.
    Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _platoonSgt#1, true];
_unit setRank _platoonSgt#2;

[_unit, _psgUniform, _psgVest, _psgHeadgear, _psgGoggles, _psgBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _radioL, false] call lmf_equipment_fnc_addItem;

_unit addWeapon _binocular;

if (var_playerMaps == 1) then {
	_unit linkItem "ItemMap";
	_unit linkItem "ItemCompass";
};
if (var_playerGps == 1) then {_unit linkItem "ItemGPS"};

for "_i" from 1 to 2 do {
	[_unit, (selectRandom _grenadeSmoke), false] call lmf_equipment_fnc_addItem;
	[_unit, (selectRandom _grenadeSmokeClr), false] call lmf_equipment_fnc_addItem;
};

if (!var_pistolAll) then {[_unit, 1] call lmf_equipment_fnc_giveWeapon};
[_unit, _psgWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
