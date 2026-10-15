/*
	Spawned group identity
	Assigns server-local classification and a sequential visible name once during LMF spawning.
	Arguments: group, uppercase tags, reserved name prefix, optional subtype suffix.
	Internal helper; never called automatically for Eden groups or player callsigns.
*/

params ["_group", "_tags", "_prefix", ["_subtype", ""]];
if (!isServer || {isNull _group} || {!local _group}) exitWith {};

isNil {
	_group setVariable ["lmf_ai_groupTags", +_tags];
	private _suffix = if (_subtype == "") then {""} else {format [" (%1)", _subtype]};
	private _name = [_group, _prefix, " ", _suffix] call lmf_ai_fnc_assignCallsign;
	_group setVariable ["lmf_ai_groupName", _name];
};
