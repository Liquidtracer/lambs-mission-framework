/*
    Mine-clearance worker
    Scheduled worker started by runClearance on the server-owned support group.
    The current HOLD waypoint supplies the clearance radius to BI.
    Run BI in its own script scope: its implementation uses non-private local variables.
    A result is recorded only after BI returns. Its no-specialist exit is not clearance success.
*/

if (!isServer) exitWith {};
private _supportGroup = _this select 0;
private _supportPosition = _this select 1;
private _supportRadius = waypointCompletionRadius [_supportGroup, currentWaypoint _supportGroup];
private _workScript = _this spawn BIS_fnc_wpDemine;
waitUntil {
    sleep 1;
    // Keep the assignment check and correction together so BI cannot change mines between them.
    isNil {
        if (!scriptDone _workScript) then {
            {
                private _unit = _x;
                private _mine = _unit getVariable ["BIS_fnc_wpDemine_mine", objNull];
                // BI handles stopped units and deactivation; only redirect movement away from an assigned mine.
                if (local _unit && {alive _unit} && {!isNull _mine} && {currentCommand _unit == "MOVE"} && {speed _unit > 0} && {_unit distance _mine > 2} && {((expectedDestination _unit)#0) distance2D _mine > 5}) then {
                    _unit doMove getPosATL _mine;
                };
            } forEach units _supportGroup;
        };
    };
    scriptDone _workScript || {units _supportGroup findIf {alive _x} == -1}
};
// End the worker after total losses even if dead units are still present in the group's member list.
if (!scriptDone _workScript) then {terminate _workScript};
private _remainingMines = allMines select {_x distance _supportPosition < _supportRadius};
private _survivors = units _supportGroup select {alive _x};
private _cleared = _survivors isNotEqualTo [] && {_remainingMines isEqualTo []};
// One diagnostic per unsuccessful worker completion, including total losses of the engineers.
if (!_cleared) then {
    private _specialists = _survivors select {
        (_x getUnitTrait "engineer" || {_x getUnitTrait "explosiveSpecialist"}) && {
            (items _x) findIf {getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "type") == 620} != -1
        }
    };
    diag_log format ["LMF support: clearance unconfirmed for %1; position=%2 radius=%3 remainingMines=%4 survivors=%5 equippedSpecialists=%6", groupId _supportGroup, _supportPosition, _supportRadius, count _remainingMines, count _survivors, count _specialists];
};
_supportGroup setVariable ["lmf_support_clearanceResult", _cleared];
