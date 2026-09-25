/*
    Pilot loadout
    Applies the Pilot loadout to the supplied local unit.
    Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _pilot#1, true];
_unit setRank _pilot#2;

[_unit, _pUniform, _pVest, _pHeadgear, _pGoggles, _pBackpack] call lmf_equipment_fnc_applyBaseLoadout;

// Override base map click restriction
onMapSingleClick "";

[_unit, _radioL, false] call lmf_equipment_fnc_addItem;

_unit addWeapon _binocular;

if (var_playerMaps == 1) then {
	_unit linkItem "ItemMap";
	_unit linkItem "ItemCompass";
};
if (var_playerGps == 1) then {_unit linkItem "ItemGPS"};
if (var_playerNvg == 1) then {_unit linkItem _nvgPilot};

[_unit, 0] call lmf_equipment_fnc_giveWeapon;
[_unit, _pWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
