/*
	Boat assault initialization
	Starts landing on detection and checks for autonomous GUARD arrivals at the shore.
	Call once on the group owner. Argument: group.
*/

params ["_group"];

if (!local _group) exitWith {};

// GUARD can reach shore before this group detects an enemy.
[_group, vehicle leader _group] spawn {
	params ["_group", "_veh"];
	private _finished = false;
	while {!_finished} do {
		sleep 5;
		isNil {
			if (isNull _group || {!local _group} || {!alive _veh} ||
				{(units _group) findIf {alive _x && {objectParent _x == _veh}} == -1}
			) exitWith {_finished = true};
			if (_group getVariable ["lmf_taskConverge_active", false]) exitWith {};
			if (waypointType [_group, currentWaypoint _group] != "GUARD") exitWith {};
			if (!isTouchingGround _veh || {abs speed _veh >= 20}) exitWith {};

			_group setVariable ["lmf_taskConverge_active", true];
			[_group, _veh] call lmf_ai_fnc_dismountBoatGroup;
			_finished = true;
		};
	};
};

_group addEventHandler ["EnemyDetected", {
	params ["_group", "_newTarget"];

	if (_group getVariable ["lmf_taskConverge_active", false]) exitWith {};
	if !(isTouchingGround (vehicle _newTarget)) exitWith {};

	private _leader = leader _group;
	private _veh = vehicle _leader;

	if !(_veh isKindOf "Ship") exitWith {
		_group removeEventHandler [_thisEvent, _thisEventHandler];
	};

	_group removeEventHandler [_thisEvent, _thisEventHandler];
	_group setVariable ["lmf_taskConverge_active", true];
	[_group, _veh, getPosASL _newTarget, 1000] spawn lmf_ai_fnc_landBoatGroup;
}];
