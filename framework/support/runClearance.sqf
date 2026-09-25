/*
    Mine-clearance dispatch
    Scheduled server-only dispatch lifecycle. Spawn coordinates and direction come from the Eden start object.
    Transport has no terrain/routing solver. Engineers use BI's area-clearance waypoint without a work timeout.
    Engineers ignore combat while working. Transport and dismount orders have no abort deadlines.
*/

if (!isServer) exitWith {};
params ["_targetPos", "_startPos", "_startDir"];
lmf_support_config params ["_vehicleClass", "_engineerCount", "_startObjectName", "_unitClass", "_fallbackBackpacks"];
private _radius = lmf_support_state#1;
// Resolve the field once; keep the snapshot private and reuse it when choosing the transport stop.
private _minePositions = allMines apply {getPosATL _x};
private _fieldPositions = [_targetPos, _minePositions] call lmf_support_fnc_findMinefield;
private _fieldFound = _fieldPositions isNotEqualTo [];
if (_fieldFound) then {
    private _minX = (_fieldPositions#0)#0;
    private _maxX = _minX;
    private _minY = (_fieldPositions#0)#1;
    private _maxY = _minY;
    {
        _minX = _minX min (_x#0);
        _maxX = _maxX max (_x#0);
        _minY = _minY min (_x#1);
        _maxY = _maxY max (_x#1);
    } forEach _fieldPositions;
    _targetPos = [(_minX + _maxX) / 2, (_minY + _maxY) / 2, 0];
    _radius = 0;
    // Match BI's 3D distance test, including terrain elevation, and keep boundary mines strictly inside.
    {_radius = _radius max (_x distance _targetPos)} forEach _fieldPositions;
    _radius = _radius + 5;
};
// Preserve the main group and its BFT identity if only the covering gunner survives.
private _group = createGroup [lmf_support_state#2, false];
_group allowFleeing 0;
_group enableAttack false;
_group setVariable ["lambs_danger_disableGroupAI", true];
private _vehicle = createVehicle [_vehicleClass, _startPos, [], 0, "NONE"];
_vehicle setDir _startDir;
private _team = [];
private _gunner = objNull;
private _guardGroup = grpNull;
private _gunnerPath = [];
private _gunnerSeats = (fullCrew [_vehicle, "gunner", true]) select {
    !(_x#4) && {(_vehicle weaponsTurret (_x#3)) isNotEqualTo []}
};
if (_engineerCount >= 2 && {_gunnerSeats isNotEqualTo []}) then {_gunnerPath = (_gunnerSeats#0)#3};
private _hasGunner = _gunnerPath isNotEqualTo [];
private _setupError = "";
if (isNull _group || {isNull _vehicle}) then {_setupError = "Could not create support group or vehicle."};
if (_vehicle emptyPositions "driver" < 1 || {_vehicle emptyPositions "cargo" < (floor _engineerCount) - 1 - ([0, 1] select _hasGunner)}) then {
    _setupError = "Support vehicle has insufficient driver, main gunner and cargo seats for the team.";
};

private _ignoreEnemy = {
    {
        private _unit = _x;
        _unit setVariable ["lambs_danger_disableAI", true];
        {_unit disableAI _x} forEach ["AUTOCOMBAT", "TARGET", "AUTOTARGET", "COVER", "SUPPRESSION", "FSM", "FIREWEAPON", "WEAPONAIM", "RADIOPROTOCOL", "HEARING", "CHECKVISIBLE"];
    } forEach _this;
};

if (_setupError isEqualTo "") then {
    _group addVehicle _vehicle;
    for "_i" from 1 to floor _engineerCount do {
        private _unit = _group createUnit [_unitClass, _startPos, [], 3, "NONE"];
        if (isNull _unit) exitWith {_setupError = "Could not create all engineers."};
        _team pushBack _unit;
        [_unit] call lmf_equipment_fnc_applyRifleman;
        // The covering gunner keeps his combat features while manning the turret.
        if (!(_i == 2 && {_hasGunner})) then {[_unit] call _ignoreEnemy};
        _unit setUnitTrait ["engineer", true];
        _unit setUnitTrait ["explosiveSpecialist", true];
        if (backpack _unit isEqualTo "") then {
            private _backpacks = _fallbackBackpacks select {_x isNotEqualTo ""};
            if (_backpacks isNotEqualTo []) then {_unit addBackpack (selectRandom _backpacks)};
        };
        if (!("ToolKit" in items _unit) && {_unit canAdd "ToolKit"}) then {_unit addItem "ToolKit"};
        if (!("ToolKit" in items _unit)) exitWith {_setupError = format ["Engineer loadout has no room for a ToolKit.<br/><t color='%1'>Adjust its backpack or inventory.</t>", LMF_TEXT_COLOR]};
        if (_i == 1) then {
            _unit assignAsDriver _vehicle;
            _unit moveInDriver _vehicle;
        } else {
            if (_i == 2 && {_hasGunner}) then {
                _gunner = _unit;
                _unit assignAsTurret [_vehicle, _gunnerPath];
                _unit moveInTurret [_vehicle, _gunnerPath];
            } else {
                _unit assignAsCargo _vehicle;
                _unit moveInCargo _vehicle;
            };
        };
        if (vehicle _unit != _vehicle) exitWith {_setupError = "Could not seat every engineer in the support vehicle."};
    };
};
if (_setupError isEqualTo "" && {_hasGunner}) then {
    _guardGroup = createGroup [lmf_support_state#2, false];
    if (isNull _guardGroup) then {_setupError = "Could not create the covering gunner's group."};
};
if (_setupError isNotEqualTo "") exitWith {
    {deleteVehicle _x} forEach _team;
    deleteVehicle _vehicle;
    deleteGroup _group;
    deleteGroup _guardGroup;
    isNil {lmf_support_pending = lmf_support_pending - 1};
    [format ["%1<br/><t color='%2'>No dispatch spent.</t>", _setupError, LMF_TEXT_COLOR]] call lmf_support_fnc_notify;
};

private _coverGunner = _gunner;
private _outboundDriver = driver _vehicle;

private _callsign = "";
isNil {
    lmf_support_pending = lmf_support_pending - 1;
    lmf_support_state set [0, (lmf_support_state#0) - 1];
    publicVariable "lmf_support_state";
    _callsign = [_group, "LUCKY"] call lmf_ai_fnc_assignCallsign;
};
if (var_bft) then {[_group, "b_support", _callsign] call lmf_bft_fnc_setCallsign};
["En route.<br/>Out.", _callsign] call lmf_support_fnc_notify;
_group setBehaviourStrong "AWARE";
_group setCombatMode "YELLOW";

private _aliveTeam = {_team select {alive _x}};
private _movingTeam = {(call _aliveTeam) select {group _x == _group}};
private _cleared = false;
private _originalUnload = getUnloadInCombat _vehicle;
_vehicle setUnloadInCombat [false, false];
private _resetWaypoints = {
    for "_i" from (count waypoints _group - 1) to 0 step -1 do {deleteWaypoint [_group, _i]};
};
private _moveTo = {
    params ["_pos", ["_completionRadius", 15], ["_onCompletion", ""], ["_type", "MOVE"]];
    isNil {
        call _resetWaypoints;
        private _wp = _group addWaypoint [ATLToASL _pos, -1];
        _wp setWaypointType _type;
        _wp setWaypointCompletionRadius _completionRadius;
        _wp setWaypointStatements ["true", _onCompletion];
        _group setCurrentWaypoint _wp;
    };
};
private _lost = {
    _vehicle setUnloadInCombat _originalUnload;
    _guardGroup deleteGroupWhenEmpty true;
    deleteGroup _guardGroup;
    _group deleteGroupWhenEmpty true;
};

// Mine positions are used privately on the server; no mines are revealed to players.
private _stopPos = [_targetPos, _startPos, _radius, _minePositions, _startDir] call lmf_support_fnc_findStopPosition;
_group setVariable ["lmf_support_arrived", false];
// Accept engine waypoint completion even when the vehicle stops outside the proximity threshold.
[_stopPos, 3, "if (isServer) then {group this setVariable ['lmf_support_arrived', true]}"] call _moveTo;
waitUntil {
    sleep 1;
    (_group getVariable ["lmf_support_arrived", false]) || {_vehicle distance2D _stopPos < 5} || {!canMove _vehicle} || {!alive _outboundDriver} || {(call _aliveTeam) isEqualTo []}
};
if ((call _aliveTeam) isEqualTo []) exitWith {call _lost};
// Driver or vehicle loss does not stop surviving engineers from continuing on foot.
call _resetWaypoints;
// Keep one crew group during outbound travel; the guard group does not manage the transport pool.
if (alive _coverGunner) then {
    [_coverGunner] joinSilent _guardGroup;
    _coverGunner assignAsTurret [_vehicle, _gunnerPath];
    _guardGroup allowFleeing 0;
    _guardGroup setBehaviourStrong "AWARE";
    _guardGroup setCombatMode "YELLOW";
};
private _footTeam = {(call _aliveTeam) select {_x != _coverGunner}};
_group setBehaviourStrong "AWARE";
(call _footTeam) allowGetIn false;
(call _footTeam) orderGetIn false;
{unassignVehicle _x} forEach (call _footTeam);
if (isNull _coverGunner) then {_group leaveVehicle _vehicle};
doGetOut (call _footTeam);
waitUntil {sleep 1; (call _footTeam) findIf {vehicle _x != _x} == -1};
if ((call _aliveTeam) isEqualTo []) exitWith {call _lost};

if (_fieldFound && {(call _footTeam) isNotEqualTo []}) then {
    [_targetPos, _radius, "", "HOLD"] call _moveTo;
    _group setVariable ["lmf_support_clearanceResult", false];
    // Start BI's worker explicitly; a waypoint activation is not required to begin work.
    private _clearScript = [_group, _targetPos] execVM "framework\support\clearMinesWaypoint.sqf";
    waitUntil {sleep 1; scriptDone _clearScript};
    _cleared = _group getVariable ["lmf_support_clearanceResult", false];
};
if ((call _aliveTeam) isEqualTo []) exitWith {call _lost};
// Record confirmed clearance, not a live guarantee against mines placed later. Global markers support JIP.
if (_cleared) then {
    private _area = createMarker [format ["lmf_support_cleared_%1", _callsign], _targetPos];
    _area setMarkerShape "ELLIPSE";
    _area setMarkerBrush "FDiagonal";
    _area setMarkerColor "ColorGrey";
    _area setMarkerSize [_radius, _radius];

    // Offset the label northwest within the cleared area, proportional to its radius.
    private _labelPos = [(_targetPos#0) - 0.3 * _radius, (_targetPos#1) + 0.3 * _radius];
    private _label = createMarker [format ["lmf_support_clearedLabel_%1", _callsign], _labelPos];
    _label setMarkerType "mil_dot";
    _label setMarkerColor "ColorGrey";
    _label setMarkerSize [0.5, 0.5];
    _label setMarkerText format ["Cleared! (%1)", _callsign];
};
if (_cleared) then {["Area clear.<br/>Returning.<br/>Out.", _callsign] call lmf_support_fnc_notify};
if (!_fieldFound && {(call _footTeam) isNotEqualTo []}) then {["No mines found.<br/>Returning.<br/>Out.", _callsign] call lmf_support_fnc_notify};
// Covering ends with clearance; the entire team shares the return orders and combat restrictions.
if (alive _coverGunner) then {[_coverGunner] joinSilent _group};
_guardGroup deleteGroupWhenEmpty true;
deleteGroup _guardGroup;
call _resetWaypoints;
(call _movingTeam) call _ignoreEnemy;
_group setBehaviourStrong "AWARE";
{
    // Boarding can stall with FSM disabled; LAMBS and combat restrictions remain disabled separately.
    _x enableAI "FSM";
    _x setUnitPos "UP";
    _x doWatch objNull;
} forEach (call _movingTeam);
// BI leaves a doMove order on every specialist, including the leader; reset the entire formation.
(call _movingTeam) doFollow leader _group;
// The last survivor changes seats immediately instead of dismounting and boarding again.
if (alive _coverGunner && {count (call _aliveTeam) == 1} && {vehicle _coverGunner == _vehicle} && {canMove _vehicle} && {driver _vehicle != _coverGunner} && {!alive driver _vehicle}) then {
    isNil {
        private _oldDriver = driver _vehicle;
        if (!isNull _oldDriver) then {unassignVehicle _oldDriver; moveOut _oldDriver};
        unassignVehicle _coverGunner;
        moveOut _coverGunner;
        _coverGunner assignAsDriver _vehicle;
        _coverGunner moveInDriver _vehicle;
    };
};
if ((call _aliveTeam) isEqualTo []) exitWith {call _lost};
(call _aliveTeam) allowGetIn true;

// Let the engine assign seats and advance from GETIN to the return waypoint.
private _startReturn = {
    if (canMove _vehicle) then {
        _vehicle setUnloadInCombat [false, false];
        _group addVehicle _vehicle;
        (call _movingTeam) allowGetIn true;
        (call _movingTeam) orderGetIn true;
        // Configure both waypoints before the engine can advance the sequence.
        isNil {
            call _resetWaypoints;
            private _getInWp = [];
            if ((call _aliveTeam) findIf {vehicle _x != _vehicle} != -1 || {!alive driver _vehicle}) then {
                _getInWp = _group addWaypoint [getPosASL _vehicle, -1];
                _getInWp setWaypointType "GETIN";
                _getInWp waypointAttachVehicle _vehicle;
            };
            private _homeWp = _group addWaypoint [ATLToASL _startPos, -1];
            _homeWp setWaypointType "MOVE";
            _homeWp setWaypointCompletionRadius 15;
            _group setCurrentWaypoint (if (_getInWp isEqualTo []) then {_homeWp} else {_getInWp});
        };
    } else {
        (call _aliveTeam) allowGetIn false;
        (call _aliveTeam) orderGetIn false;
        {unassignVehicle _x} forEach (call _aliveTeam);
        _group leaveVehicle _vehicle;
        doGetOut (call _aliveTeam);
        (call _movingTeam) doFollow leader _group;
        [_startPos] call _moveTo;
    };
};
call _startReturn;
// Cleanup requires physical arrival, independent of waypoint completion signals.
private _atBase = {
    (call _aliveTeam) findIf {_x distance2D _startPos > 100} == -1
};
private _returnOnFoot = !canMove _vehicle;
waitUntil {
    sleep 1;
    if (!_returnOnFoot && {!canMove _vehicle}) then {
        _returnOnFoot = true;
        call _startReturn;
    };
    call _atBase
};
if ((call _aliveTeam) isEqualTo []) exitWith {call _lost};
_vehicle setUnloadInCombat _originalUnload;
private _deleteTransport = _vehicle distance2D _startPos <= 100;
{deleteVehicle _x} forEach (call _aliveTeam);
if (_deleteTransport && {crew _vehicle findIf {isPlayer _x} == -1}) then {deleteVehicle _vehicle};
deleteGroup _group;
deleteGroup _guardGroup;
