/*
    AI flare response
    Responds to a non-enemy flare by directing nearby reinforcements. Arguments: RGB colour, shooter, projectile.
    Author: Alex2k.
*/

params ["_colorRgb", "_shooter", "_projectile"];

private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {};
if (side _shooter == var_enemySide) exitWith {};

_detectionRange = 800;
_targetPos = [[[(getPos _shooter), 200]], []] call BIS_fnc_randomPos;

_qrf = allGroups select {(((groupID _x) find "QRF") != -1 || ((groupID _x) find "Patrol") != -1 || ((groupID _x) find "Car") != -1) && ((leader _x) distance2D _targetPos < _detectionRange)};
if (_qrf isEqualTo []) exitWith {};

_nearestQrf = [_qrf, _targetPos] call BIS_fnc_nearestPosition;

(units _nearestQrf) doMove _targetPos;
_nearestQrf setBehaviour "AWARE";
_nearestQrf setSpeedMode "NORMAL";