/*
	Resolve supply crate definition
	Internal lookup shared by spawn paths and initialization. Definitions are read-only.
	PreInit disables conflicting classnames; objects resolve by their configured classname.

	Arguments:
		0: Category, or "" to resolve the object <STRING>
		1: Optional crate for classname lookup <OBJECT>
	Returns: [category, classname, displayName], or [] when unresolved <ARRAY>
*/

params ["_category", ["_crate", objNull, [objNull]]];

private _index = if (_category isEqualTo "") then {
	private _classname = toLower typeOf _crate;
	lmf_supplyCrates_definitions findIf {(_x select 1) != "" && {toLower (_x select 1) isEqualTo _classname}}
} else {
	lmf_supplyCrates_definitions findIf {(_x select 1) != "" && {(_x select 0) isEqualTo _category}}
};
if (_index < 0) exitWith {[]};
lmf_supplyCrates_definitions select _index
