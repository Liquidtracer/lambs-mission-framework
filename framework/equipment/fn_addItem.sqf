/*
    Add item
    Distributes items to unit in prioritized ordering.
    Priority: Backpack > vest > uniform (default), or vest > backpack > uniform if _vestFirst = true.
    Author: Alex2k.

    Arguments:
        0: Unit <OBJECT>
        1: Item to distribute <STRING>
        2: Add to vest first <BOOLEAN> (default: false)

    Examples:
        [player, "acc_flashlight"] call lmf_equipment_fnc_addItem;
        [player, "bipod_01_F_snd", true] call lmf_equipment_fnc_addItem;
*/

params ["_unit", "_item", ["_vestFirst", false]];

if (_item isEqualTo "") exitWith {};

if (_vestFirst) then {
    if (_unit canAddItemToVest _item) exitWith {_unit addItemToVest _item};
    if (_unit canAddItemToBackpack _item) exitWith {_unit addItemToBackpack _item};
    _unit addItem _item;
} else {
    if (_unit canAddItemToBackpack _item) exitWith {_unit addItemToBackpack _item};
    if (_unit canAddItemToVest _item) exitWith {_unit addItemToVest _item};
    _unit addItem _item;
};
