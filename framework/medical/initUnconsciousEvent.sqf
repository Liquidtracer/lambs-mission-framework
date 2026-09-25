/*
    Unconsciousness handling
    Registers unconsciousness handling; included by XEH_postInit.sqf.
*/

["ace_unconscious", {
    params [["_unit", objNull],["_state", false]];
    if (!_state || {!(local _unit)}) exitWith {};

    // Player
    if (isPlayer _unit) then {
        [] spawn {
            uiSleep 3;
            while {(lifeState player) isEqualTo "INCAPACITATED"} do {
                private _nearUnitsSorted = nearestObjects [player, ["Man"], 50, true];
                _nearUnitsSorted = _nearUnitsSorted select {side _x == side (group player)};
                _nearUnitsSorted = _nearUnitsSorted select {_x != player};
                private _message = "";
                if (count _nearUnitsSorted > 0) then {
                    private _nearestUnit = _nearUnitsSorted#0;
                    private _distance = round (player distance2D _nearestUnit);
                    _message = format ["<img image='A3\3den\data\cfgwaypoints\support_ca.paa' size='2' color='#ed1b2e'/><br/><t font='PuristaBold' color='%2'>Nearest friendly unit: %1m</t>", _distance, LMF_TEXT_COLOR];
                    hintSilent parseText _message;
                } else {
                    hintSilent "";
                };
                uiSleep 1;
            };
            hintSilent "";
        };

        [{
            params ["_unit"];
            _unit setUnitTrait ["camouflageCoef",var_camoCoef];
            // ace_medical_deathChance = 0.20;
            // [{params ["_unit"]; (lifeState _unit) isNotEqualTo "INCAPACITATED"}, {params ["_unit"]; ace_medical_deathChance = a2k_originalDeathChance}, [_unit]] call CBA_fnc_waitUntilAndExecute;
        }, [_unit], 30] call CBA_fnc_waitAndExecute;

    // AI
    } else {
        [{ params ["_unit"]; [_unit, false] call ace_medical_status_fnc_setUnconsciousState; }, [_unit], (5 + (random 180))] call CBA_fnc_waitAndExecute;
    };

}] call CBA_fnc_addEventHandler;

