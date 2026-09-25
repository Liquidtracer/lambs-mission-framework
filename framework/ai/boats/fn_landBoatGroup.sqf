/*
    Land boat group
    Assigns the boat landing route and monitors dismounting. Run scheduled.
    The caller must reserve lmf_taskConverge_active before starting this helper.

    Arguments: group, boat, target position, shoreline search radius in metres.
*/

params ["_group", "_veh", "_targetPos", "_radius"];

{deleteWaypoint _x} forEachReversed (waypoints _group);

private _boatPos = getPosASL _veh;
private _shorelinePos = [_boatPos, _targetPos, _radius] call lmf_ai_fnc_findShorelinePosition;

if (_shorelinePos isEqualTo []) exitWith {
    private _wpGuardFail = _group addWaypoint [[_boatPos select 0, _boatPos select 1, 0], 0];
    _wpGuardFail setWaypointType "GUARD";
    _group setVariable ["lmf_taskConverge_active", false];
};

private _dirToBoat = _shorelinePos getDir _veh;
private _movePos = _shorelinePos getPos [30, _dirToBoat];
_movePos set [2, 0];

// Approach
private _wpMove = _group addWaypoint [_movePos, 0];
_wpMove setWaypointType "MOVE";

// Landing
private _wpGetOut = _group addWaypoint [_shorelinePos, 0];
_wpGetOut setWaypointType "GETOUT";
_wpGetOut setWaypointCompletionRadius 50;

[
    // Wait until group is wiped, boat is dead, or boat hits land
    {
        params ["_group", "_veh"];
        isNull _group ||
        {!alive _veh} ||
        {((isTouchingGround _veh || !surfaceIsWater (getPosASL _veh)) && speed _veh < 20)}
    },
    // Dismount
    {
        params ["_group", "_veh", "_targetPos"];

        if (!isNull _group && {(units _group) findIf {alive _x} != -1}) then {
            {deleteWaypoint _x} forEachReversed (waypoints _group);

            private _wpGuard = _group addWaypoint [_targetPos, 0];
            _wpGuard setWaypointType "GUARD";
        };

        [_group, _veh] call lmf_ai_fnc_dismountBoatGroup;
    },
    [_group, _veh, _targetPos]
] call CBA_fnc_waitUntilAndExecute;
