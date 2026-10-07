/*
	Squad leader loadout
	Applies the Squad Leader loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

#include "..\..\..\settings\cfg_Player.sqf"

_unit setVariable ["lmf_currentRole", _squadLeader#1, true];
_unit setRank _squadLeader#2;

[_unit, _slUniform, _slVest, _slHeadgear, _slGoggles, _slBackpack] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _radioL, false] call lmf_equipment_fnc_addItem;

_unit addWeapon _binocular;

if (lmf_playerMaps == 1) then {
	_unit linkItem "ItemMap";
	_unit linkItem "ItemCompass";
};
if (lmf_playerGps == 1) then {_unit linkItem "ItemGPS"};

for "_i" from 1 to 2 do {
	[_unit, (selectRandom _grenadeSmoke), false] call lmf_equipment_fnc_addItem;
	[_unit, (selectRandom _grenadeSmokeClr), false] call lmf_equipment_fnc_addItem;
};

[_unit, _slWeapon] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
