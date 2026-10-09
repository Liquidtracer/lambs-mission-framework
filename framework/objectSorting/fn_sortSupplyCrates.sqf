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
if !(lmf_playerGear) exitWith {};

[_supp] call lmf_supplyCrates_fnc_initSupplyCrate;
