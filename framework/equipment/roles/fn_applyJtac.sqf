/*
	JTAC loadout
	Applies the JTAC loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _role = (_config get "ROLES") get "JTAC";
private _clothing = _role get "CLOTHING";
private _radioB = (_config get "RADIOS") get "B";
private _radioL = (_config get "RADIOS") get "L";
private _grenadeSmoke = (_config get "GRENADES") get "SMOKE";
private _grenadeSmokeClr = (_config get "GRENADES") get "SMOKE_COLOR";
private _binocular = (_config get "ITEMS") get "BINOCULAR";

_unit setVariable ["lmf_currentRole", (_role get "DISPLAY_NAME"), true];
_unit setVariable ["lmf_currentRoleKey", "JTAC", true];
_unit setRank (_role get "RANK");

[_unit, _clothing get "UNIFORM", _clothing get "VEST", _clothing get "HEADGEAR", _clothing get "GOGGLES", _clothing get "BACKPACK"] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, _radioL, false] call lmf_equipment_fnc_addItem;
[_unit, _radioB, false] call lmf_equipment_fnc_addItem;

_unit addWeapon _binocular;

for "_i" from 1 to 2 do {
	[_unit, (selectRandom _grenadeSmoke), false] call lmf_equipment_fnc_addItem;
	[_unit, (selectRandom _grenadeSmokeClr), false] call lmf_equipment_fnc_addItem;
};

[_unit, (_role get "WEAPON")] call lmf_equipment_fnc_giveWeapon;

[_unit, "lambs_jtac"] call bis_fnc_setUnitInsignia;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
