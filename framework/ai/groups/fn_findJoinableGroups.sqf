/*
	Find joinable groups
	Finds eligible groups for the supplied unit.
	Returns [distance, group] pairs sorted by distance from the unit's group leader.
	Author: Alex2k.
*/

params ["_unit"];

private _group = group _unit;
private _friendlyGroups = (groups lmf_enemySide) select {
	_x getVariable ["lmf_ai_joinableGroup", false] && {_x != _group}
};

_friendlyGroups = _friendlyGroups select {count ((units _x) select {alive _x}) > 0};
_friendlyGroups = _friendlyGroups select {((leader _x) distance2D _unit) < 1500};
_friendlyGroups = _friendlyGroups select {!surfaceIsWater (getPos (vehicle (leader _x)))};
// Helicopter passengers become eligible when their leader is on foot.
_friendlyGroups = _friendlyGroups select {
	isNull (_x getVariable ["lmf_heliTransport_vehicle", objNull])
	|| {isNull objectParent (leader _x)}
};
_friendlyGroups = _friendlyGroups apply {[(leader _group) distance2D (leader _x), _x]};
_friendlyGroups sort true;
_friendlyGroups
