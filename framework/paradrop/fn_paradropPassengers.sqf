/*
    Paradrop passengers
    Flies an existing aircraft through a paradrop route and drops all passenger units.
    Passengers can contain players, AI, or both. Cargo seats, FFV/person-turrets, and onboard units outside the pilot's crew group are included.

    Arguments:
        0: Aircraft <OBJECT>
        1: Drop zone <MARKER or TRIGGER>
        2: Approach waypoint <MARKER>
        3: Fly height <NUMBER>
        4: Drop height <NUMBER>
        5: Start in air <BOOLEAN>

    Example:
        [plane_1, "mrk_dropZone", "mrk_dropZone_WP", 220, 140, false] spawn lmf_paradrop_fnc_paradropPassengers;
*/

params ["_aircraft", "_dropZone", "_waypoint", "_flyHeight", "_dropHeight", "_startFlying"];

if (!local _aircraft) exitWith {};

private _waypointPosition = getMarkerPos _waypoint;

waitUntil {sleep 1; !isNil "lmf_warmup"};

private _turrets = allTurrets [_aircraft, true];
{_aircraft lockTurret [_x, true]} forEach _turrets;

_aircraft allowDamage false;
_aircraft lockDriver true;
_aircraft setFuel 0;

_aircraft addEventHandler ["Hit", {
    params ["_aircraft"];
    [_aircraft, 2] spawn lmf_paradrop_fnc_fireCountermeasures;
}];

private _group = group _aircraft;
_group setVariable ["lambs_danger_dangerAI", "disabled"];
_group setCombatMode "BLUE";
_group setBehaviourStrong "CARELESS";

private _useDefaultDepartureHeight = _aircraft isKindOf "Helicopter" && {!_startFlying};
if (!_useDefaultDepartureHeight) then {
    _aircraft flyInHeight _flyHeight;
    _aircraft flyInHeightASL [_flyHeight, _flyHeight, _flyHeight];
};

{
    _x allowDamage false;
    _x setRank "CAPTAIN";
    _x disableAI "AUTOCOMBAT";
    _x disableAI "FSM";
    _x setVariable ["lambs_danger_disableAI", true];
} forEach units _group;

if (var_bft) then {
    [_group, "b_plane", [_group, "JINX"] call lmf_ai_fnc_assignCallsign] call lmf_bft_fnc_setCallsign;
};

waitUntil {sleep 1; !lmf_warmup};

_aircraft setFuel 1;
_aircraft engineOn true;

if (_startFlying) then {
    [_aircraft, _flyHeight, getPos _aircraft, "ATL"] call BIS_fnc_setHeight;
    _aircraft setVelocityModelSpace [0, 100, 0];
};

[_group] call CBA_fnc_clearWaypoints;
private _approachWaypoint = _group addWaypoint [_waypointPosition, -1];
_approachWaypoint setWaypointType "MOVE";
_approachWaypoint setWaypointStatements [
    "true",
    format ["if (local (vehicle this)) then {private _vehicle = vehicle this; _vehicle limitSpeed 240; _vehicle flyInHeight %1; _vehicle flyInHeightASL [%1,%1,%1];};", _dropHeight]
];
_approachWaypoint setWaypointCompletionRadius 500;

private _dropZoneCenter = _dropZone call BIS_fnc_position;
private _dropZoneAxes = if (_dropZone isEqualType "") then {
    markerSize _dropZone
} else {
    private _area = triggerArea _dropZone;
    [_area select 0, _area select 1]
};
private _minimumAxis = (_dropZoneAxes select 0) min (_dropZoneAxes select 1);
private _dropWaypointRadius = 25 min (0.5 * _minimumAxis);
private _randomRadius = (_minimumAxis - _dropWaypointRadius - 1) max 0;
private _dropPosition = [_dropZoneCenter, [_randomRadius, _randomRadius, 0, false]] call BIS_fnc_randomPosTrigger;

private _dropWaypoint = _group addWaypoint [_dropPosition, 0];
_dropWaypoint setWPPos _dropPosition;
_dropWaypoint setWaypointType "MOVE";
_dropWaypoint setWaypointCompletionRadius _dropWaypointRadius;

private _exitPosition = _dropPosition getPos [5000, _waypointPosition getDir _dropPosition];
private _exitWaypoint = _group addWaypoint [_exitPosition, 0];
_exitWaypoint setWaypointType "MOVE";
_exitWaypoint setWaypointCompletionRadius 500;

waitUntil {sleep 1; _aircraft inArea _dropZone};

[_group] call CBA_fnc_clearWaypoints;
private _straightAhead = _aircraft getRelPos [5000, 0];
_aircraft doMove _straightAhead;

private _pilot = driver _aircraft;
private _passengers = (fullCrew _aircraft) select {
    private _unit = _x select 0;
    private _role = toLower (_x select 1);
    private _personTurret = _x select 4;
    _unit != _pilot && {
        _role == "cargo" || {_personTurret} || {group _unit != _group}
    }
} apply {_x select 0};

[_aircraft, _passengers] spawn {
    params ["_aircraft", "_passengers"];
    if (!local _aircraft) exitWith {};

    private _delay = 1 / (((speed _aircraft) max 55) / 150);

    {
        [_x, "EJECT", [_aircraft, _delay, "Steerable_Parachute_F"]]
            call lmf_paradrop_fnc_dropUnit;
    } forEach _passengers;
};

[{
    params ["_aircraft", "_group", "_passengers"];
    _passengers findIf {!isNull _x && {vehicle _x == _aircraft}} == -1
}, {
    params ["_aircraft", "_group", "_passengers"];
    [_group] call CBA_fnc_clearWaypoints;
    _aircraft doMove (_aircraft getPos [25000, getDir _aircraft - 180]);
    _aircraft limitSpeed 999;
    _aircraft allowDamage true;
    {_x allowDamage true} forEach units _group;
}, [_aircraft, _group, _passengers]] call CBA_fnc_waitUntilAndExecute;

// Cleanup needs only a coarse proximity check during the return flight.
[{
    params ["_args", "_handle"];
    _args params ["_aircraft", "_group"];
    if !((allPlayers - entities "HeadlessClient_F") findIf {_x distance2D _aircraft < 5000} == -1
        || {!alive _aircraft || {count units _group < 1}}) exitWith {};

    [_handle] call CBA_fnc_removePerFrameHandler;
    if (alive _aircraft && {count units _group > 0}) then {
        {_aircraft deleteVehicleCrew _x} count crew _aircraft;
        deleteVehicle _aircraft;
    };
}, 3, [_aircraft, _group]] call CBA_fnc_addPerFrameHandler;
