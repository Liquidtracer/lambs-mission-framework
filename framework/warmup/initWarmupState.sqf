/*
	Warmup state
	Initializes warmup state; included in the server section of XEH_postInit.sqf.
*/

if (lmf_warmup) then {
	lmf_warmup_isActive = true;
	publicVariable "lmf_warmup_isActive";
	[] execVM "framework\warmup\manageTimeAndWeather.sqf";
} else {
	lmf_warmup_isActive = false;
	publicVariable "lmf_warmup_isActive";
};

