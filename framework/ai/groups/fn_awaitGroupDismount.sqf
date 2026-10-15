/*
	Dismounted group classification
	After an intentional vehicle exit, removes current-platform tags once all living members are on foot.
	Preserves origin, QRF and transport status. Does not issue orders or change names.
	Internal server helper. Arguments: group. Locality loss cancels the update.
	Only LMF intentional exit flows call this; unrelated/external dismounts are not tracked.
*/

params ["_group"];
if (!isServer || {isNull _group} || {!local _group}) exitWith {};
[
	{
		params ["_group"];
		isNull _group || {!local _group} || {units _group findIf {alive _x && {!isNull objectParent _x}} == -1}
	},
	{
		params ["_group"];
		if (isNull _group || {!local _group}) exitWith {};
		private _tags = (_group getVariable ["lmf_ai_groupTags", []]) - ["VEHICLE", "AIR", "BOAT"];
		if (_tags isEqualTo []) exitWith {};
		_tags pushBackUnique "INFANTRY";
		_group setVariable ["lmf_ai_groupTags", _tags];
	},
	[_group]
] call CBA_fnc_waitUntilAndExecute;
