/*
	Pilot loadout
	Applies the Pilot loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _role = (_config get "ROLES") get "PILOT";
private _clothing = _role get "CLOTHING";
private _radioL = (_config get "RADIOS") get "L";
private _binocular = (_config get "ITEMS") get "BINOCULAR";
private _nvgPilot = (_config get "ITEMS") get "NVG_PILOT";

_unit setVariable ["lmf_currentRole", (_role get "DISPLAY_NAME"), true];
_unit setRank (_role get "RANK");

[_unit, _clothing get "UNIFORM", _clothing get "VEST", _clothing get "HEADGEAR", _clothing get "GOGGLES", _clothing get "BACKPACK"] call lmf_equipment_fnc_applyBaseLoadout;

// Override base map click restriction
onMapSingleClick "";

[_unit, _radioL, false] call lmf_equipment_fnc_addItem;

_unit addWeapon _binocular;

if (lmf_playerMaps == 1) then {
	_unit linkItem "ItemMap";
	_unit linkItem "ItemCompass";
};
if (lmf_playerGps == 1) then {_unit linkItem "ItemGPS"};
if (lmf_playerNvg == 1) then {_unit linkItem _nvgPilot};

[_unit, "FLARE_GUN"] call lmf_equipment_fnc_giveWeapon;
[_unit, (_role get "WEAPON")] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
