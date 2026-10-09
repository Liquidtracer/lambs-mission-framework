/*
	Machine gunner assistant loadout
	Applies the Assistant Machine Gunner loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _role = (_config get "ROLES") get "MACHINE_GUNNER_ASSISTANT";
private _clothing = _role get "CLOTHING";
private _mmgAmmo = ((_config get "WEAPONS") get "MMG") get "AMMO";

_unit setVariable ["lmf_currentRole", (_role get "DISPLAY_NAME"), true];
_unit setVariable ["lmf_currentRoleKey", "MACHINE_GUNNER_ASSISTANT", true];
_unit setRank (_role get "RANK");

[_unit, _clothing get "UNIFORM", _clothing get "VEST", _clothing get "HEADGEAR", _clothing get "GOGGLES", _clothing get "BACKPACK"] call lmf_equipment_fnc_applyBaseLoadout;

[_unit, "ACE_SpareBarrel", false] call lmf_equipment_fnc_addItem;
for "_i" from 1 to 4 do {[_unit, (selectRandom _mmgAmmo), false] call lmf_equipment_fnc_addItem};

[_unit, (_role get "WEAPON")] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
