/*
	Monitor warmup deadline
	Ends warmup when the configured deadline is reached.
*/

if (!isServer) exitWith {};
if (lmf_maxWarmupTime isEqualTo "") exitWith {};

// Keep MM:SS in settings; compare numeric mission time so a delayed tick cannot miss it.
private _parts = lmf_maxWarmupTime splitString ":";
if (count _parts != 2) exitWith {
	diag_log format ["LMF warmup: invalid lmf_maxWarmupTime '%1'; expected MM:SS.", lmf_maxWarmupTime];
};
private _deadline = (parseNumber (_parts select 0)) * 60 + parseNumber (_parts select 1);

waitUntil {sleep 1; CBA_missionTime >= _deadline || {!lmf_warmup_isActive}};
if (lmf_warmup_isActive) then {
	lmf_warmup_isActive = false;
	publicVariable "lmf_warmup_isActive";
};
