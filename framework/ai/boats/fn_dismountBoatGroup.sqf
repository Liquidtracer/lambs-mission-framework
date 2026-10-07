/*
	Boat group dismount
	Releases the boat and dismounts its infantry with the existing smoke and staggered delays.
	Call unscheduled on the group owner after reserving lmf_taskConverge_active.
	Preserves waypoints. Releases the reservation after dismounting completes.

	Arguments: group, boat.
*/

params ["_group", "_veh"];

if (!isNull _group && {(units _group) findIf {alive _x} != -1}) then {
	_group leaveVehicle _veh;
	_group setBehaviourStrong "AWARE";

	{
		private _unit = _x;
		if (alive _unit && {vehicle _unit == _veh}) then {
			[
				{
					params ["_unit"];
					moveOut _unit;
					[_unit, getPos _unit] call lambs_main_fnc_doSmoke;
				},
				[_unit],
				random 3
			] call CBA_fnc_waitAndExecute;
		};
	} forEach (units _group);
};

// Keep converge blocked through the delayed dismounts.
[
	{
		params ["_group", "_veh"];
		isNull _group || {isNull _veh} ||
		{(units _group) findIf {alive _x && {objectParent _x == _veh}} == -1}
	},
	{
		params ["_group"];
		if (!isNull _group) then {
			_group setVariable ["lmf_taskConverge_active", false];
		};
	},
	[_group, _veh]
] call CBA_fnc_waitUntilAndExecute;
