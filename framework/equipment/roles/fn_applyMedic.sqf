/*
	Medic loadout
	Applies the Medic loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _role = (_config get "ROLES") get "MEDIC";
private _clothing = _role get "CLOTHING";
private _grenadeSmoke = (_config get "GRENADES") get "SMOKE";

_unit setVariable ["lmf_currentRole", (_role get "DISPLAY_NAME"), true];
_unit setVariable ["lmf_currentRoleKey", "MEDIC"];
_unit setRank (_role get "RANK");

[_unit, _clothing get "UNIFORM", _clothing get "VEST", _clothing get "HEADGEAR", _clothing get "GOGGLES", _clothing get "BACKPACK"] call lmf_equipment_fnc_applyBaseLoadout;

for "_i" from 1 to 3 do {
	for "_i" from 1 to 2 do {[_unit, (selectRandom _grenadeSmoke), true] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 6 do {[_unit, "ACE_fieldDressing", false] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 2 do {[_unit, "ACE_tourniquet", false] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 2 do {[_unit, "ACE_morphine", false] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 2 do {[_unit, "ACE_epinephrine", false] call lmf_equipment_fnc_addItem};
	for "_j" from 1 to 2 do {[_unit, "ACE_bloodIV", false] call lmf_equipment_fnc_addItem};
};

[_unit, (_role get "WEAPON")] call lmf_equipment_fnc_giveWeapon;

[_unit, "lambs_medic"] call bis_fnc_setUnitInsignia;

_unit setUnitTrait ["medic", true];

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
