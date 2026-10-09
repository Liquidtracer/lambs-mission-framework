/*
	Resolve supply crate definition
	Internal lookup shared by spawn paths and initialization. Definitions are read-only.
	Explicit arguments and object tags must name an enabled category; invalid tags block fallback.
	Only untagged objects may resolve by an unambiguous enabled classname match.

	Arguments:
		0: Category, or "" to resolve the object <STRING>
		1: Optional crate for object tag/classname fallback <OBJECT>
	Returns: [category, classname, displayName], or [] when unresolved <ARRAY>
*/

params ["_category", ["_crate", objNull, [objNull]]];

if (_category isEqualTo "" && {!isNull _crate}) then {
	_category = _crate getVariable ["lmf_supplyCrate_category", ""];
};

if !(_category isEqualTo "") exitWith {
	private _index = lmf_supplyCrates_definitions findIf {(_x select 0) isEqualTo _category && {(_x select 1) != ""}};
	if (_index < 0) exitWith {[]};
	lmf_supplyCrates_definitions select _index
};

if (isNull _crate) exitWith {[]};
// A present but empty object tag is invalid, not permission to guess a category.
if !(isNil {_crate getVariable "lmf_supplyCrate_category"}) exitWith {[]};
private _classname = typeOf _crate;
private _matches = lmf_supplyCrates_definitions select {(_x select 1) != "" && {(_x select 1) isEqualTo _classname}};
if (count _matches != 1) exitWith {[]};
_matches select 0
