/*
    Build weapon loadout
    Builds one Unit Loadout Array weapon entry from a configured LMF weapon definition.
    Uses configured weapon classnames unchanged and retains any built-in attachments.
    Selects a compatible primary magazine automatically when no magazine is configured.

    Arguments:
        0: Weapon definition [weapons, magazines, optics, attachments] <ARRAY> (default: [])
        1: Secondary muzzle magazine pool <ARRAY> (default: [])

    Example:
        [[["arifle_MX_F"], [], [], []]] call lmf_ai_fnc_buildWeaponLoadout;
*/

params [
	["_weaponDefinition",[],[[]]],
	["_secondaryAmmoPool",[],[[]]]
];

if (_weaponDefinition isEqualTo []) exitWith {[[],"","",[]]};
_weaponDefinition params ["_weaponPool","_ammoPool","_opticPool","_attachmentPool"];

private _validWeapons = _weaponPool select {_x isNotEqualTo "" && {isClass (configFile >> "CfgWeapons" >> _x)}};
if (_validWeapons isEqualTo []) exitWith {[[],"","",[]]};

private _weapon = selectRandom _validWeapons;
private _cached = lmf_ai_weaponCache getOrDefault [_weapon,[]];

if (_cached isEqualTo []) then {
	private _weaponConfig = configFile >> "CfgWeapons" >> _weapon;
	private _muzzles = getArray (_weaponConfig >> "muzzles");
	if (_muzzles isEqualTo []) then {_muzzles = ["this"]};

	private _primaryMagazines = compatibleMagazines [_weapon,"this"];
	private _secondaryMuzzle = _muzzles param [1,"",[""]];
	private _secondaryMagazines = if (_secondaryMuzzle isEqualTo "") then {[]} else {compatibleMagazines [_weapon,_secondaryMuzzle]};
	private _configuredPrimary = getArray (_weaponConfig >> "magazines");
	private _configuredSecondary = if (_secondaryMuzzle isEqualTo "") then {[]} else {getArray (_weaponConfig >> _secondaryMuzzle >> "magazines")};
	private _primaryAvailable = _primaryMagazines + _configuredPrimary;
	private _secondaryAvailable = _secondaryMagazines + _configuredSecondary;

	private _components = _weapon call BIS_fnc_weaponComponents;
	if !(_components isEqualTo []) then {_components deleteAt 0};

	private _slotItems = [
		(compatibleItems [_weapon,"MuzzleSlot"]) apply {toLower _x},
		(compatibleItems [_weapon,"PointerSlot"]) apply {toLower _x},
		(compatibleItems [_weapon,"CowsSlot"]) apply {toLower _x},
		(compatibleItems [_weapon,"UnderBarrelSlot"]) apply {toLower _x}
	];

	private _attachments = ["","","",""];
	{
		private _component = _x;
		private _componentLower = toLower _component;
		private _slot = _slotItems findIf {_componentLower in _x};
		if (_slot != -1) then {_attachments set [_slot,_component]};
	} forEach _components;

	_cached = [_attachments,_primaryAvailable,_secondaryAvailable,_configuredPrimary param [0,""],_configuredSecondary param [0,""],_slotItems];
	lmf_ai_weaponCache set [_weapon,_cached];
};

_cached params ["_attachments","_primaryAvailable","_secondaryAvailable","_primaryDefault","_secondaryDefault","_slotItems"];
_attachments = +_attachments;

private _selectMagazine = {
	params ["_requested","_available","_default"];
	private _availableLower = _available apply {toLower _x};
	private _validRequested = _requested select {_x isNotEqualTo "" && {toLower _x in _availableLower}};
	if !(_validRequested isEqualTo []) exitWith {selectRandom _validRequested};

	if (_default isNotEqualTo "") exitWith {_default};
	_available param [0,"",[""]]
};

private _applyAttachment = {
	params ["_item"];
	if (_item isEqualTo "") exitWith {};
	private _itemLower = toLower _item;
	private _slot = _slotItems findIf {_itemLower in _x};
	if (_slot != -1) then {_attachments set [_slot,_item]};
};

if !(_opticPool isEqualTo []) then {[selectRandom _opticPool] call _applyAttachment};
if !(_attachmentPool isEqualTo []) then {[selectRandom _attachmentPool] call _applyAttachment};

private _primaryMagazine = [_ammoPool,_primaryAvailable,_primaryDefault] call _selectMagazine;
private _secondaryMagazine = "";
if (_secondaryAmmoPool findIf {_x isNotEqualTo ""} != -1) then {
	_secondaryMagazine = [_secondaryAmmoPool,_secondaryAvailable,_secondaryDefault] call _selectMagazine;
};

private _primaryLoaded = if (_primaryMagazine isEqualTo "") then {[]} else {[_primaryMagazine,getNumber (configFile >> "CfgMagazines" >> _primaryMagazine >> "count")]};
private _secondaryLoaded = if (_secondaryMagazine isEqualTo "") then {[]} else {[_secondaryMagazine,getNumber (configFile >> "CfgMagazines" >> _secondaryMagazine >> "count")]};

[
	[_weapon,_attachments#0,_attachments#1,_attachments#2,_primaryLoaded,_secondaryLoaded,_attachments#3],
	_primaryMagazine,
	_secondaryMagazine,
	_secondaryAvailable
]
