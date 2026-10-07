/*
	Vehicle commander loadout
	Applies the Vehicle Commander loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _crewSgt#1, true];
_unit setRank _crewSgt#2;

[_unit, _vpsgUniform, _vpsgVest, _vpsgHeadgear, _vpsgGoggles, _vpsgBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _radioL, false] call lmf_equipment_fnc_addItem;

_unit addWeapon _binocular;

if (lmf_playerMaps == 1) then {
	_unit linkItem "ItemMap";
	_unit linkItem "ItemCompass";
};
if (lmf_playerGps == 1) then {_unit linkItem "ItemGPS"};

if (!lmf_pistolAll) then {[_unit, 1] call lmf_equipment_fnc_giveWeapon};
[_unit, _vpsgWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
