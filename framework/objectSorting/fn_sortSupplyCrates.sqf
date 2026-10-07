/*
	Sort supply crates
	Routes configured local supply crates to the supply initializer.

	Arguments:
		0: Supply crate <OBJECT>

	Example:
		[crate_1] call lmf_objectSorting_fnc_sortSupplyCrates;
*/

private _supp = _this select 0;

if !(local _supp) exitWith {};
if !(var_playerGear) exitWith {};

private _type = typeOf _supp;
private _allSupplies = [var_supSquad, var_supLarge, var_supExplosives, var_supMedical, var_supVehicle];
if (_allSupplies findIf {_type == _x} == -1) exitWith {};

[_supp] call lmf_supplyCrates_fnc_initSupplyCrate;