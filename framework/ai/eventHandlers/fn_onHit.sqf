/*
    AI hit reaction
    Applies the AI hit reaction.
    Author: Alex2k.

    Arguments:
        0: Affected unit <OBJECT>

    Example:
        [soldier_1] call lmf_ai_fnc_onHit;
*/

params ["_unit"];

if (lifeState _unit == "INCAPACITATED" || lifeState _unit == "DEAD" || (vehicle _unit) isNotEqualTo _unit) exitWith {};
if (time < (_unit getVariable ["lmf_ai_hitReactionCooldownUntil", 0])) exitWith {};
if (75 > random 100) then {
    _unit setVariable ["lmf_ai_hitReactionCooldownUntil", time + 5];
    _unit addForce [_unit vectorModelToWorld [0,0,0.7], [(random 1),(random 1),-2]];
    if (30 > random 100) then {
        playSound3D [
            selectRandom [
                "\z\ace\addons\fire\sounds\scream1.ogg",
                "\z\ace\addons\fire\sounds\scream2.ogg",
                "\z\ace\addons\fire\sounds\scream3.ogg",
                "\z\ace\addons\fire\sounds\scream4.ogg",
                "\z\ace\addons\fire\sounds\scream5.ogg",
                "\z\ace\addons\fire\sounds\scream6.ogg",
                "\z\ace\addons\fire\sounds\scream7.ogg",
                "\z\ace\addons\fire\sounds\scream8.ogg",
                "\z\ace\addons\fire\sounds\scream9.ogg",
                "\z\ace\addons\fire\sounds\scream10.ogg",
                "\z\ace\addons\fire\sounds\scream11.ogg",
                "\z\ace\addons\fire\sounds\scream12.ogg",
                "\z\ace\addons\fire\sounds\scream13.ogg",
                "\z\ace\addons\fire\sounds\scream14.ogg",
                "\z\ace\addons\fire\sounds\scream15.ogg"
            ], _unit, false, getPosASL _unit, 0.85];
    };
    [{params ["_unit"]; _unit setUnconscious false;}, [_unit], 5 + (random 25)] call CBA_fnc_waitAndExecute;
};
