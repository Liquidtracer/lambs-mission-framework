/*
	AI unit initialization
	Applies skill, equipment and event handlers to configured enemy AI.
	Builds the complete inventory locally before applying it with one setUnitLoadout command.

	Arguments:
		0: Unit <OBJECT>

	Example:
		[soldier_1] call lmf_ai_fnc_initUnit;
*/

params [["_unit", objNull, [objNull]]];
if (isNull _unit || {!local _unit}) exitWith {};

private _clothing = lmf_ai_config get "CLOTHING";
private _weapons = lmf_ai_config get "WEAPONS";

// Select equipment for the configured role.
private _role = (lmf_ai_config get "ROLE_BY_CLASS") getOrDefault [toLower typeOf _unit, ""];
if (_role isEqualTo "") then {_role = ["RIFLEMAN", selectRandom ["GRENADIER", "MARKSMAN", "RIFLEMAN_AT", "AUTORIFLEMAN", "SQUAD_LEADER"]] select (50 > random 100)};

// Apply skill
private _skill = switch (lmf_ai_config get "SKILL") do {
	case 0: {random [0.20, 0.30, 0.40]};
	case 2: {random [0.80, 0.90, 1.00]};
	default {random [0.50, 0.60, 0.70]};
};
_unit setSkill _skill;
_unit setSkill ["spotDistance", 1];
_unit setSkill ["spotTime", 1];
if (_role in ["AUTORIFLEMAN", "MMG_GUNNER", "MARKSMAN"]) then {_unit setSkill ((skill _unit) * 1.3)};

// Event handlers
_unit addEventHandler ["Hit", {
	params ["_unit", "_source", "_damage", "_instigator"];
	[_unit] call lmf_ai_fnc_onHit;
}];

/* _unit addEventHandler ["Killed", {
	_this call lmf_ai_fnc_onKilled;
}]; */

if !(lmf_ai_config get "CUSTOM_GEAR") exitWith {
	private _validNvGs = (lmf_ai_config get "NVG") select {_x isNotEqualTo ""};
	if (sunOrMoon < 1 && {!(_validNvGs isEqualTo [])}) then {_unit linkItem (selectRandom _validNvGs)};
};

// Choose clothing
private _selectFromPool = {
	params ["_pool"];
	if (_pool isEqualTo []) exitWith {""};
	selectRandom _pool
};

private _uniform = [_clothing get "UNIFORM"] call _selectFromPool;
private _vest = [_clothing get "VEST"] call _selectFromPool;
private _backpack = [_clothing get "BACKPACK_LIGHT"] call _selectFromPool;
private _headgear = [_clothing get "HEADGEAR"] call _selectFromPool;
private _goggles = [_clothing get "GOGGLES"] call _selectFromPool;

if (_role in ["MMG_GUNNER", "MAT_GUNNER", "AA_GUNNER", "AUTORIFLEMAN"]) then {_backpack = [_clothing get "BACKPACK_HEAVY"] call _selectFromPool};
if (_role == "PILOT") then {
	_uniform = [_clothing get "HELI_UNIFORM"] call _selectFromPool;
	_vest = [_clothing get "HELI_VEST"] call _selectFromPool;
	_headgear = [_clothing get "HELI_HEADGEAR"] call _selectFromPool;
	_backpack = "";
};
if (_role == "CREW") then {
	_uniform = [_clothing get "CREW_UNIFORM"] call _selectFromPool;
	_vest = [_clothing get "CREW_VEST"] call _selectFromPool;
	_headgear = [_clothing get "CREW_HEADGEAR"] call _selectFromPool;
};
if (_role == "MEDIC") then {_backpack = [_clothing get "BACKPACK_MEDIC"] call _selectFromPool};

// Choose weapons
private _weaponSetup = switch _role do {
	case "AUTORIFLEMAN": {["LMG", "", "", 5, 0, 0]};
	case "RIFLEMAN_AT": {["RIFLE", "LAT", "", 8, 0, 0]};
	case "GRENADIER": {["RIFLE_GL", "", "", 8, 0, 0]};
	case "MMG_GUNNER": {["MMG", "", "", 4, 0, 0]};
	case "MARKSMAN": {["DMR", "", "", 8, 0, 0]};
	case "CREW": {["CARBINE", "", "", 6, 0, 0]};
	case "PILOT": {["CARBINE", "", "", 6, 0, 0]};
	case "AA_GUNNER": {["RIFLE", "AA", "", 8, 2, 0]};
	case "OFFICER": {["", "", "PISTOL", 0, 0, 3]};
	case "MEDIC": {["RIFLE", "", "", 6, 0, 0]};
	case "MAT_GUNNER": {
		private _hasMat = ((_weapons get "MAT")#0) findIf {_x isNotEqualTo ""} != -1;
		if (_hasMat) then {["", "MAT", "", 0, 3, 0]} else {["RIFLE", "", "", 8, 0, 0]}
	};
	default {["RIFLE", "", "", 8, 0, 0]};
};
_weaponSetup params ["_primaryType", "_secondaryType", "_handgunType", "_primaryReserve", "_secondaryReserve", "_handgunReserve"];

private _emptyWeapon = [[], "", "", []];
private _uglPool = if (_role == "GRENADIER") then {lmf_ai_config get "UGL"} else {[]};
private _primary = if (_primaryType isEqualTo "") then {_emptyWeapon} else {[(_weapons get _primaryType), _uglPool] call lmf_ai_fnc_buildWeaponLoadout};
private _secondary = if (_secondaryType isEqualTo "") then {_emptyWeapon} else {[(_weapons get _secondaryType)] call lmf_ai_fnc_buildWeaponLoadout};
private _handgun = if (_handgunType isEqualTo "") then {_emptyWeapon} else {[(_weapons get _handgunType)] call lmf_ai_fnc_buildWeaponLoadout};

// Build container contents
private _uniformItems = [];
private _vestItems = [];
private _backpackItems = [];

private _addItem = {
	params ["_container", "_item", "_count"];
	if (_item isNotEqualTo "" && {_count > 0}) then {_container pushBack [_item, _count]};
};
private _addMagazine = {
	params ["_container", "_magazine", "_count"];
	if (_magazine isNotEqualTo "" && {_count > 0} && {isClass (configFile >> "CfgMagazines" >> _magazine)}) then {
		_container pushBack [_magazine, _count, getNumber (configFile >> "CfgMagazines" >> _magazine >> "count")];
	};
};
private _selectNonEmpty = {
	params ["_pool"];
	private _valid = _pool select {_x isNotEqualTo ""};
	if (_valid isEqualTo []) exitWith {""};
	selectRandom _valid
};
private _selectCompatible = {
	params ["_pool", "_compatible"];
	private _compatibleLower = _compatible apply {toLower _x};
	private _valid = _pool select {_x isNotEqualTo "" && {toLower _x in _compatibleLower}};
	if (_valid isEqualTo []) exitWith {""};
	selectRandom _valid
};

// Essential items are added before ammunition and optional equipment.
[_uniformItems, "ACE_fieldDressing", 1 + floor random 3] call _addItem;
if (50 > random 100) then {[_uniformItems, "ACE_morphine", 1] call _addItem};
if (50 > random 100) then {[_uniformItems, "ACE_tourniquet", 1] call _addItem};

if (_role == "MEDIC") then {
	[_backpackItems, "ACE_fieldDressing", 12] call _addItem;
	[_backpackItems, "ACE_tourniquet", 2] call _addItem;
	[_backpackItems, "ACE_morphine", 4] call _addItem;
	[_backpackItems, "ACE_epinephrine", 4] call _addItem;
	[_backpackItems, "ACE_bloodIV", 6] call _addItem;
};

private _primaryMagazineContainer = if (_primaryType in ["LMG", "MMG"]) then {_backpackItems} else {_vestItems};
[_primaryMagazineContainer, _primary#1, _primaryReserve] call _addMagazine;
[_vestItems, _handgun#1, _handgunReserve] call _addMagazine;
[_backpackItems, _secondary#1, _secondaryReserve] call _addMagazine;

if (_role == "GRENADIER") then {
	for "_i" from 1 to 5 do {[_backpackItems, [_uglPool, _primary#3] call _selectCompatible, 1] call _addMagazine};
};

if (50 > random 100) then {[_vestItems, [(lmf_ai_config get "GRENADES")] call _selectNonEmpty, 1] call _addMagazine};
if (50 > random 100) then {[_vestItems, [(lmf_ai_config get "SMOKE_GRENADES")] call _selectNonEmpty, 1] call _addMagazine};
if (_role == "MEDIC") then {[_vestItems, [(lmf_ai_config get "SMOKE_GRENADES")] call _selectNonEmpty, 2] call _addMagazine};

// Build and apply loadout
private _binocular = if (_role in ["SQUAD_LEADER", "MARKSMAN"]) then {["Binocular", "", "", "", [], [], ""]} else {[]};
private _nvg = "";
if (sunOrMoon < 1) then {_nvg = [(lmf_ai_config get "NVG")] call _selectNonEmpty};
private _backpackLoadout = if (_backpack isEqualTo "") then {[]} else {[_backpack, _backpackItems]};

private _loadout = [
	_primary#0,
	_secondary#0,
	_handgun#0,
	[_uniform, _uniformItems],
	[_vest, _vestItems],
	_backpackLoadout,
	_headgear,
	_goggles,
	_binocular,
	["", "", "", "", "", _nvg]
];

private _applyLoadout = {
	params ["_unit", "_loadout"];
	if (isNull _unit || {!alive _unit} || {!local _unit}) exitWith {};
	if (isSwitchingWeapon _unit) exitWith {};
	_unit setUnitLoadout [_loadout, true];
};

if (isSwitchingWeapon _unit) then {
	[_unit, _loadout, _applyLoadout] spawn {
		params ["_unit", "_loadout", "_applyLoadout"];
		waitUntil [{isNull _unit || {!alive _unit} || {!local _unit} || {!isSwitchingWeapon _unit}}, 10, 0.05];
		[_unit, _loadout] call _applyLoadout;
	};
} else {
	[_unit, _loadout] call _applyLoadout;
};
