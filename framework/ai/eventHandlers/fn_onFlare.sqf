/*
	AI flare response
	Responds to a non-enemy flare by directing nearby reinforcements. Arguments: RGB color, shooter, projectile.
	Author: Alex2k.
*/

params ["_colorRgb", "_shooter", "_projectile"];

private _spawner = [] call lmf_ai_fnc_isSpawner;
if !(_spawner) exitWith {};
if (side _shooter == lmf_enemySide) exitWith {};

private _detectionRange = 800;
private _targetPos = [[[(getPos _shooter), 200]], []] call BIS_fnc_randomPos;

// Infantry/patrol response; ordinary flares also retain the car-type exception.
private _qrf = allGroups select {
	local _x && {side _x == lmf_enemySide} && {[_x, ["QRF", "PATROL"]] call lmf_ai_fnc_canRetaskGroup}
	&& {
		private _tags = _x getVariable ["lmf_ai_groupTags", []];
		!("AIR" in _tags) && {!("DRONE" in _tags)} && {
			("INFANTRY" in _tags && {!("VEHICLE" in _tags)})
			|| {(_x getVariable ["lmf_ai_vehicleType", ""]) in ["CAR", "CARARMED"]}
		}
	}
	&& {alive leader _x} && {(leader _x) distance2D _targetPos < _detectionRange}
};
if (_qrf isEqualTo []) exitWith {};

private _nearestQrf = [_qrf, _targetPos] call BIS_fnc_nearestPosition;

(units _nearestQrf) doMove _targetPos;
_nearestQrf setBehaviour "AWARE";
_nearestQrf setSpeedMode "NORMAL";