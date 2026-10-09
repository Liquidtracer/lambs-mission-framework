/*
	Spawn object at pad
	Creates an asset at the supplied pad; called by local ACE actions.
	Optional third argument selects an enabled Supply Crate category instead of the classname.
*/

params ["_vehType", ["_spawnPad", objNull, [objNull]], ["_category", ""]];

if !(_category isEqualTo "") then {
	private _definition = [_category] call lmf_supplyCrates_fnc_getDefinition;
	_vehType = if (_definition isEqualTo []) then {""} else {_definition select 1};
};
if (_vehType isEqualTo "") exitWith {};

if (count (_spawnPad nearEntities [["Man", "Air", "LandVehicle", "Ship"], 7]) > 0) exitWith {
	["Spawner", "Spawn pad is occupied.", "", 2, 12, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
};

// Tag before CBA's next-frame InitPost, including callers running scheduled.
private _vehicle = objNull;
isNil {
	_vehicle = _vehType createVehicle getPosATL _spawnPad;
	if !(_category isEqualTo "") then {
		_vehicle setVariable ["lmf_supplyCrate_category", _category, true];
	};
};
if (lmf_playerGear && {!(_category isEqualTo "")}) then {
	[_vehicle, _category] call lmf_supplyCrates_fnc_initSupplyCrate;
};
private _dir = getDir _spawnPad;
_vehicle setDir _dir;
private _conditionRemove = {true};
if (_vehicle isKindOf "Thing") then {_conditionRemove = {_target distance2D ammoPad < 10}};
if (_vehicle isKindOf "Land") then {_conditionRemove = {_target distance2D groundPad < 10}};
if (_vehicle isKindOf "Air") then {_conditionRemove = {_target distance2D airPad < 10}};

private _vehDelete = ["lmf_assetSpawner_delete", "Delete", ["\A3\ui_f\data\map\MapControl\taskIconFailed_ca.paa", LMF_ERROR_COLOR], {deleteVehicle _target}, _conditionRemove] call ace_interact_menu_fnc_createAction;
[_vehicle, 0, ["ACE_MainActions"], _vehDelete] remoteExec ["ace_interact_menu_fnc_addActionToObject", 0, _vehicle];

private _vehTypeText = getText (configFile >> "CfgVehicles" >> _vehType >> "displayName");
["Spawner", format ["Created: <t color='%2'>%1</t>", _vehTypeText, LMF_HIGHLIGHT_FRIENDLY_COLOR], "", 2, 12, "beep"] call lmf_notifications_fnc_showAceMessage;
