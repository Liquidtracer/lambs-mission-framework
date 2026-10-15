/*
	Classified combat group selection
	Matches exact case-insensitive tags with OR semantics; ALL still requires LMF classification.
	Excludes pure transports and groups still preparing, inserting or landing.
	Arguments: group, tag array. Returns: eligibility <BOOLEAN>.
	Read on the server; callers retain their side, locality and task-specific checks.
*/

params ["_group", "_types"];
private _tags = _group getVariable ["lmf_ai_groupTags", []];
if (_tags isEqualTo [] || {"TRANSPORT" in _tags}) exitWith {false};
if (_group getVariable ["lmf_ai_spawning", false]
	|| {_group getVariable ["lmf_ai_inserting", false]}
	|| {_group getVariable ["lmf_taskConverge_active", false]}
	|| {_group getVariable ["lmf_heliTransport_active", false]}) exitWith {false};
private _transport = _group getVariable ["lmf_heliTransport_vehicle", objNull];
if (!isNull _transport && {units _group findIf {alive _x && {objectParent _x == _transport}} != -1}) exitWith {false};
_types findIf {toUpper _x == "ALL" || {toUpper _x in _tags}} != -1
