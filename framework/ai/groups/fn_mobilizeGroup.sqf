/*
	Mobilize classified group
	Marks an accepted Converge order or patrol contact transition as QRF, preserving origin and identity.
	Internal server helper. Arguments: group. Call only after final task eligibility checks.
*/

params ["_group"];
if (!isServer || {isNull _group} || {!local _group}) exitWith {};

isNil {
	private _tags = +(_group getVariable ["lmf_ai_groupTags", []]);
	if (_tags isEqualTo [] || {"QRF" in _tags}) exitWith {};
	_tags pushBackUnique "QRF";
	_group setVariable ["lmf_ai_groupTags", _tags];
	private _name = _group getVariable ["lmf_ai_groupName", ""];
	// Preserve explicit mission/BFT renames made after spawning.
	if (_name != "" && {groupId _group == _name} && {(_group getVariable ["lmf_bft_state", []]) isEqualTo []}) then {
		_group setGroupIdGlobal [_name + " (QRF)"];
	};
};
