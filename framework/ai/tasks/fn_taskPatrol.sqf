/*
	AI patrol
	Assigns patrol behavior to an AI group.
	Call where the group is local. No suspension required.
	Author: Alex2k.

	Arguments:
		0: Group <GROUP>
		1: Patrol target <OBJECT or ARRAY>
		2: Patrol radius in meters <NUMBER>
		3: Behaviour <STRING>
		4: Speed <STRING>
		5: Formation <STRING>

	Example:
		[grp1, objective_1, 100, "AWARE", "NORMAL", "STAG COLUMN"] call lmf_ai_fnc_taskPatrol;
*/

params ["_group", "_patrolTarget", "_patrolRadius", "_behaviour", "_speed", "_formation"];

if (!local _group) exitWith {};
private _garrisoned = units _group select {_x getVariable ["ace_ai_garrisonned", false]};
[_garrisoned] call ace_ai_fnc_unGarrison;
{_x setUnitPos "AUTO"} forEach _garrisoned;

{deleteWaypoint _x} forEachReversed (waypoints _group);

private _waypointTimeoutArray = [30, 60, 90];
private _waterMode = [0, 2] select (vehicle (leader _group) isKindOf "Ship");
// Keep failed land and water searches at the patrol target instead of the map default.
private _fallbackPos = if (_patrolTarget isEqualType objNull) then {getPos _patrolTarget} else {_patrolTarget};
private _defaultPos = [_fallbackPos, _fallbackPos];

for "_i" from 0 to 3 do {
	private _randomPos = [_patrolTarget, _patrolRadius/2, _patrolRadius, 0, _waterMode, 1, 0, [], _defaultPos] call BIS_fnc_findSafePos;
	private _wp = _group addWaypoint [_randomPos, 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointTimeout _waypointTimeoutArray;
};

private _randomCyclePos = [_patrolTarget, _patrolRadius/2, _patrolRadius/2, 0, _waterMode, 1, 0, [], _defaultPos] call BIS_fnc_findSafePos;
private _wpCycle = _group addWaypoint [_randomCyclePos, 0];
_wpCycle setWaypointType "CYCLE";
_wpCycle setWaypointTimeout _waypointTimeoutArray;

_group setBehaviour _behaviour;
_group setSpeedMode _speed;
_group setFormation _formation;
