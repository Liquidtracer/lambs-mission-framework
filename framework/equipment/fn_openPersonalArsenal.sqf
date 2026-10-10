/*
	Open personal arsenal
	Internal client helper. Rebuilds the whitelist from the acting unit's current registry role.
	No supplies are virtualized; ACE handles existing inventory and container changes.
	Weapon switching is experimental: ACE may discard incompatible magazines.

	Arguments: 0: Local acting unit <OBJECT>
*/

params [["_unit", objNull, [objNull]]];
if (!hasInterface || {isNull _unit} || {!local _unit} || {!alive _unit}) exitWith {};
if (!lmf_playerGear || {!lmf_personalArsenal} || {!lmf_warmup} || {!(missionNamespace getVariable ["lmf_warmup_isActive", false])}) exitWith {};
private _box = missionNamespace getVariable ["lmf_equipment_personalArsenalBox", objNull];
if (isNull _box) exitWith {};
if (!isNil "ace_arsenal_camera") exitWith {};

private _config = call lmf_equipment_fnc_getPlayerConfig;
private _roleKey = _unit getVariable ["lmf_currentRoleKey", ""];
private _roles = _config get "ROLES";
if (!(_roleKey isEqualType "") || {!(_roleKey in _roles)}) exitWith {
	["Personal Arsenal", "No valid LMF role is assigned.", "", 3, 12, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
};

private _role = _roles get _roleKey;
private _clothing = _role get "CLOTHING";
private _items = [];
{
	_x params ["_key", "_root"];
	{
		if (_x isEqualType "" && {_x != ""} && {isClass (configFile >> _root >> _x)}) then {
			_items pushBackUnique _x;
		};
	} forEach (_clothing getOrDefault [_key, []]);
} forEach [["UNIFORM", "CfgWeapons"], ["VEST", "CfgWeapons"], ["HEADGEAR", "CfgWeapons"], ["GOGGLES", "CfgGlasses"], ["BACKPACK", "CfgVehicles"]];

private _weapon = (_config get "WEAPONS") getOrDefault [_role get "WEAPON", createHashMap];
// Offer the role's configured weapon variants and attachments in Personal Arsenal.
// ACE addVirtualItems performs its own baseWeapon normalization and filters unsupported classes.
{
	{
		if (_x isEqualType "" && {_x != ""} && {isClass (configFile >> "CfgWeapons" >> _x)}) then {
			_items pushBackUnique _x;
		};
	} forEach (_weapon getOrDefault [_x, []]);
} forEach ["CLASSES", "OPTICS", "ATTACHMENTS_1", "ATTACHMENTS_2", "BIPODS"];

// Reset only our holder. false initializes an empty whitelist even when all pools are empty.
[_box, true, false] call ace_arsenal_fnc_removeVirtualItems;
[_box, false, false] call ace_arsenal_fnc_addVirtualItems;
[_box, _items, false] call ace_arsenal_fnc_addVirtualItems;
[_box, _unit, false] call ace_arsenal_fnc_openBox;
