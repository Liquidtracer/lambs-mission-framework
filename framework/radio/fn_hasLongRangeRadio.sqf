/*
    Long-range radio check
    Checks whether the unit carries a long range radio.
    Author: Alex2k.

    Arguments:
        0: Unit <OBJECT>

    Example:
        [player] call lmf_radio_fnc_hasLongRangeRadio;

    Returns: Whether a supported long range radio is present <BOOLEAN>
*/

params ["_unit"];

["ACRE_PRC148","ACRE_PRC152","ACRE_PRC77","ACRE_PRC117F","ACRE_SEM70"] findIf {[_unit, _x] call acre_api_fnc_hasKindOfRadio} != -1;
