/*
	IED UAV drop attack
	Uses loaded LXWS IED pylon payloads, retaining the drone's GUARD waypoint when empty.
	Run scheduled where the drone and its AI group are local (Vehicle QRF: server).
	Author: Alex2k.

	Arguments:
		0: UAV <OBJECT>
		1: Target <OBJECT>

	Example:
		[uav_1, target_1] spawn lmf_ai_fnc_taskUavAttack;
*/

params ["_veh", "_target"];
if (!alive _veh || {!local _veh} || {!(_veh isKindOf "Air")}) exitWith {};

private _grp = group _veh;
if (!local _grp) exitWith {};
private _pylonConfig = configFile >> "CfgVehicles" >> typeOf _veh >> "Components" >> "TransportPylonsComponent" >> "Pylons";
private _iedPylons = (configProperties [_pylonConfig, "isClass _x && {'LXWS_IED_DRONE_PYLON' in getArray (_x >> 'hardpoints')}", true]) apply {configName _x};
private _loadedPayload = {
	private _pylons = getAllPylonsInfo _veh;
	private _index = _pylons findIf {
		_x params ["", "_name", "", "_magazine", "_ammo"];
		_name in _iedPylons && {_ammo > 0} && {_magazine != ""}
		&& {getText (configFile >> "CfgMagazines" >> _magazine >> "pylonWeapon") != ""}
	};
	if (_index == -1) exitWith {[]};
	_pylons # _index
};
if (call _loadedPayload isEqualTo []) exitWith {};

// Target and move to enemy
_grp reveal [_target, 4];

private _movementEh = _grp addEventHandler ["EnemyDetected", {
	params ["_group", "_newTarget"];
	private _veh = vehicle (leader _group);
	if (!alive _veh || {!local _veh} || {!local _group}) exitWith {_group removeEventHandler [_thisEvent, _thisEventHandler];};
	if (!alive _newTarget || {!isTouchingGround (vehicle _newTarget)}) exitWith {};

	if (50 > random 100) then {
		(leader _group) doMove (_newTarget getPos [50, (leader _group) getDir _newTarget]);
	};
}];

while {alive _veh && {local _veh} && {local _grp} && {call _loadedPayload isNotEqualTo []}} do {
	_veh flyInHeight [50 + random 150, true];
	waitUntil {
		sleep 5;
		!alive _veh || {!local _veh} || {!local _grp} || {call _loadedPayload isEqualTo []}
		|| {(_veh targets [true, 25]) findIf {alive _x && {isTouchingGround (vehicle _x)}} != -1}
	};
	if (!alive _veh || {!local _veh} || {!local _grp} || {call _loadedPayload isEqualTo []}) exitWith {};

	_veh flyInHeight [20 + random 40, true];

	// Recheck life and the actual loaded payload together immediately before firing.
	isNil {
		if (!alive _veh || {!local _veh} || {!local _grp}) exitWith {};
		private _payload = call _loadedPayload;
		if (_payload isEqualTo []) exitWith {};
		private _weapon = getText (configFile >> "CfgMagazines" >> (_payload # 3) >> "pylonWeapon");
		[_veh, _weapon] call BIS_fnc_fire;
	};

	private _nextDrop = time + 30;
	waitUntil {
		sleep 1;
		!alive _veh || {!local _veh} || {!local _grp} || {call _loadedPayload isEqualTo []} || {time >= _nextDrop}
	};
};

_grp removeEventHandler ["EnemyDetected", _movementEh];
