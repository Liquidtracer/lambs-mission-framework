/*
	Report AI spawn status
	Internal server helper. Sends non-persistent ZEN feedback only to the requesting player.
	Arguments: optional [player object, label] context, status, reason.
	An empty context disables feedback; this does not change the spawn result.
*/

params [["_feedback", [], [[]]], "_status", "_reason"];
if (!isServer || {_feedback isEqualTo []}) exitWith {};
_feedback params [["_requester", objNull, [objNull]], ["_label", "AI", [""]]];
if (isNull _requester || {!isPlayer _requester}) exitWith {};

["lmf_zen_spawnFeedback", [_requester, _label, _status, _reason], _requester] call CBA_fnc_targetEvent;
