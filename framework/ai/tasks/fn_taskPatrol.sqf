/*
	AI patrol
	Assigns patrol behavior to an AI group.
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

{[_x] call lmf_ai_fnc_clearGarrisonStance} forEach units _group;

{deleteWaypoint _x} forEachReversed (waypoints _group);

private _waypointTimeoutArray = [30, 60, 90];
private _waterMode = [0, 2] select (vehicle (leader _group) isKindOf "Ship");

for "_i" from 0 to 3 do {
	private _randomPos = [_patrolTarget, _patrolRadius/2, _patrolRadius, 0, _waterMode, 1] call BIS_fnc_findSafePos;
	private _wp = _group addWaypoint [_randomPos, 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointTimeout _waypointTimeoutArray;
};

private _randomCyclePos = [_patrolTarget, _patrolRadius/2, _patrolRadius/2, 0, _waterMode, 1] call BIS_fnc_findSafePos;
private _wpCycle = _group addWaypoint [_randomCyclePos, 0];
_wpCycle setWaypointType "CYCLE";
_wpCycle setWaypointTimeout _waypointTimeoutArray;

_group setBehaviour "AWARE";
[{params ["_group", "_behaviour"]; _group setBehaviour _behaviour;}, [_group, _behaviour], 5] call CBA_fnc_waitAndExecute; // Delay for them not to get stuck
_group setSpeedMode _speed;
_group setFormation _formation;

_group addEventHandler ["CommandChanged", {
	params ["_group", "_newCommand"];
	if ((isNull (leader _group)) || !alive (leader _group) || (behaviour (leader _group) == "COMBAT")) exitWith {
		{_x enableAI "PATH"; _x setUnitPos "AUTO"} forEach (units _group);
		_group removeEventHandler [_thisEvent, _thisEventHandler];
	};

	if (_newCommand != "MOVE") then {
		(leader _group) setUnitPos "MIDDLE";
		{
			_x disableAI "PATH";
			_x setUnitPos (["DOWN", "MIDDLE"] select (count (nearestTerrainObjects [_x, ["House"], 50, false]) > 4));
		} forEach (units _group) - [(leader _group)];
	} else {
		{_x setUnitPos "AUTO"; _x enableAI "PATH"} forEach (units _group);
	};
}];
