/*
    Warmup state
    Initializes warmup state; included in the server section of XEH_postInit.sqf.
*/

if (var_warmup) then {
    lmf_warmup = true;
    publicVariable "lmf_warmup";
    [] execVM "framework\warmup\manageTimeAndWeather.sqf";
} else {
    lmf_warmup = false;
    publicVariable "lmf_warmup";
};

