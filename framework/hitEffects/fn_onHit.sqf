/*
    Player hit effects
    Applies a ppEffect if the player is hit.
    Effect by Drgn V4karian and Alex2k.

    Arguments:
        0: Affected unit <OBJECT>

    Example:
        [player] spawn lmf_hitEffects_fnc_onHit;
*/

params ["_unit"];

// Reserve one hit effect per unit without scheduler interruption.
private _acquired = false;
isNil {
    if (_unit getVariable ["lmf_player_isGettingHit", false]) exitWith {};
    if (lifeState _unit == "INCAPACITATED") exitWith {};
    if (!isNull (findDisplay 312)) exitWith {};
    if (vehicle _unit != _unit || {!alive _unit}) exitWith {};

    _unit setVariable ["lmf_player_isGettingHit", true];
    _acquired = true;
};
if (!_acquired) exitWith {};
openMap [false, false];

private _blur = ppEffectCreate ["dynamicBlur", 401];
_blur ppEffectEnable true;
_blur ppEffectForceInNVG true;

private _blink = ppEffectCreate ["colorCorrections", 1501];
_blink ppEffectEnable true;
_blink ppEffectForceInNVG true;
_blink ppEffectAdjust [1,1,0,[0,0,0,0.9],[1,1,1,1],[0.5,0.5,0.5,0],[1,1,0,0,0,0,4]];
_blink ppEffectCommit 0;

if (33 > random 100) then {
	_unit addForce [_unit vectorModelToWorld [0, 0, 0.7], [(random 1), (random 1), -2], false];
	playSound "combat_deafness";

	_blur ppEffectAdjust [7];
	_blur ppEffectCommit 0;
	_blur ppEffectAdjust [0];
	_blur ppEffectCommit 11;

	private _h1 = 0.3;
	private _h2 = 0.1;
	_blink ppEffectAdjust [1,1,0,[0,0,0,0.9],[1,1,1,1],[0.5,0.5,0.5,0],[_h1,_h2,0,0,0,0,2]];
	_blink ppEffectCommit 0.1;
	sleep 2;

	_h1 = 0.5;
	_h2 = 0.3;
	_blink ppEffectAdjust [1,1,0,[0,0,0,0.9],[1,1,1,1],[0.5,0.5,0.5,0],[_h1,_h2,0,0,0,0,2]];
	_blink ppEffectCommit 3;
	sleep 3;

	_h1 = 0.3;
	_h2 = 0.1;
	_blink ppEffectAdjust [1,1,0,[0,0,0,0.9],[1,1,1,1],[0.5,0.5,0.5,0],[_h1,_h2,0,0,0,0,2]];
	_blink ppEffectCommit 3;
	sleep 3;

	_h1 = 1;
	_h2 = 1;
	_blink ppEffectAdjust [1,1,0,[0,0,0,0.9],[1,1,1,1],[0.5,0.5,0.5,0],[_h1,_h2,0,0,0,0,2]];
	_blink ppEffectCommit 1;
	sleep 1;
	_blink ppEffectAdjust [1,1,0,[0,0,0,0],[1,1,1,1],[0.5,0.5,0.5,0],[_h1,_h2,0,0,0,0,2]];
	_blink ppEffectCommit 0.1;
	_blur ppEffectAdjust [0];
	_blur ppEffectCommit 0.1;
	sleep 0.1;
	ppEffectDestroy [_blink, _blur];
} else {
	_blur ppEffectAdjust [7];
	_blur ppEffectCommit 0;
	_blur ppEffectAdjust [0];
	_blur ppEffectCommit 1.25;

	private _h1 = 0.3;
	private _h2 = 0.03;
	_blink ppEffectAdjust [1,1,0,[0,0,0,0.9],[1,1,1,1],[0.5,0.5,0.5,0],[_h1,_h2,0,0,0,0,2]];
	_blink ppEffectCommit 0;
	sleep 0.01;

	_h1 = 1;
	_h2 = 1;
	_blink ppEffectAdjust [1,1,0,[0,0,0,0.9],[1,1,1,1],[0.5,0.5,0.5,0],[_h1,_h2,0,0,0,0,2]];
	_blink ppEffectCommit 1;
	sleep 1;
	_blink ppEffectAdjust [1,1,0,[0,0,0,0],[1,1,1,1],[0.5,0.5,0.5,0],[_h1,_h2,0,0,0,0,2]];
	_blink ppEffectCommit 0.1;
	_blur ppEffectAdjust [0];
	_blur ppEffectCommit 0.1;
	sleep 0.1;
	ppEffectDestroy [_blink, _blur];
};

_unit setVariable ["lmf_player_isGettingHit", false];
