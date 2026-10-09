/*
	Anti-tank assistant loadout
	Applies the AT Assistant loadout to the supplied local unit.
	Author: Alex2k.
*/

params [["_unit", objNull, [objNull]]];

if (isNull _unit || {!local _unit}) exitWith {};

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _role = (_config get "ROLES") get "ANTI_TANK_ASSISTANT";
private _clothing = _role get "CLOTHING";
private _matAmmo = ((_config get "WEAPONS") get "MAT") get "AMMO";

_unit setVariable ["lmf_currentRole", (_role get "DISPLAY_NAME"), true];
_unit setRank (_role get "RANK");

[_unit, _clothing get "UNIFORM", _clothing get "VEST", _clothing get "HEADGEAR", _clothing get "GOGGLES", _clothing get "BACKPACK"] call lmf_equipment_fnc_applyBaseLoadout;

for "_i" from 1 to 4 do {[_unit, (selectRandom _matAmmo), false] call lmf_equipment_fnc_addItem};

[_unit, (_role get "WEAPON")] call lmf_equipment_fnc_giveWeapon;

if (time > 10) then {[_unit getVariable "lmf_currentRole"] call lmf_equipment_fnc_showRoleChangeMessage};
