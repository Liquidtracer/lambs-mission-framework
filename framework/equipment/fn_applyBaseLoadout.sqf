/*
    Apply base loadout
    Applies base loadout to unit (clothing, radio, linked items, medical).
    Inherits from rifleman configuration when a role-specific array is [""].
    Author: Alex2k.

    Arguments:
        0: Unit <OBJECT>
        1: Uniform options <ARRAY> ([""] uses rifleman default)
        2: Vest options <ARRAY> ([""] uses rifleman default)
        3: Headgear options <ARRAY> ([""] uses rifleman default)
        4: Goggles options <ARRAY> ([""] uses rifleman default)
        5: Backpack options <ARRAY> ([""] uses rifleman default)

    Example:
        [player] call lmf_equipment_fnc_applyBaseLoadout;

    Returns: true if loadout was applied, false if unit is null or not local <BOOLEAN>
*/

params [
	["_unit", objNull, [objNull]],
	["_uniform", [""]],
	["_vest", [""]],
	["_headgear", [""]],
	["_goggles", [""]],
	["_backpack", [""]]
];

if (isNull _unit || {!local _unit}) exitWith {false};

#include "..\..\settings\cfg_Player.sqf"

if (_uniform isEqualTo [""]) then {_uniform = _rUniform};
if (_vest isEqualTo [""]) then {_vest = _rVest};
if (_headgear isEqualTo [""]) then {_headgear = _rHeadgear};
if (_goggles isEqualTo [""]) then {_goggles = _rGoggles};
if (_backpack isEqualTo [""]) then {_backpack = _rBackpack};

removeAllWeapons _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeUniform _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;

_unit forceAddUniform (selectRandom _uniform);
_unit addVest (selectRandom _vest);
_unit addHeadgear (selectRandom _headgear);
_unit addGoggles (selectRandom _goggles);
_unit addBackpack (selectRandom _backpack);
clearAllItemsFromBackpack _unit;

// Radio
_unit addWeapon "ItemWatch";
_unit addWeapon "ItemRadioAcreFlagged";
if (var_personalRadio) then {_unit addItem _radioR};

// Linked items
if (var_playerMaps == 0) then {
	_unit addWeapon "ItemMap";
	_unit addWeapon "ItemCompass";
	_unit addItem "ACE_Chemlight_Shield_Red";
};
if (var_playerGps == 0) then {_unit addWeapon "ItemGPS"};
if (var_playerNvg == 0) then {_unit addWeapon _nvg};

// Medical
for "_i" from 1 to 4 do {_unit addItem "ACE_fieldDressing"};
for "_i" from 1 to 2 do {_unit addItem "ACE_tourniquet"};
_unit addItem "ACE_morphine";

// Sidearm
if (var_pistolAll) then {[_unit, 1] call lmf_equipment_fnc_giveWeapon};

// Grenades
for "_i" from 1 to 2 do {[_unit, (selectRandom _grenade), true] call lmf_equipment_fnc_addItem};

// Default traits and map click (override in specific roles if needed)
onMapSingleClick "_shift";
_unit setUnitTrait ["medic", false];
_unit setUnitTrait ["engineer", false];
[_unit] call lmf_equipment_fnc_applyRankInsignia;

true