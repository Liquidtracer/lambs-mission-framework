/*
    Mine-clearance stop position
    Returns an ATL ground point with 20 m horizontal clearance from the supplied mine positions.

    Arguments: requested position, start position, search radius, mine-position snapshot, fallback heading.
    Selects the mine nearest the start within the requested area; without one, backs off 40 m from the request.
    Checks all supplied mines, including those outside the work area. This does not validate terrain or the driving route.
*/

params ["_targetPos", "_startPos", "_radius", "_minePositions", ["_startDir", 0]];
private _anchor = +_targetPos;
private _offset = 40;
private _nearestDistance = 1e30;
{
    private _dx = (_x#0) - (_targetPos#0);
    private _dy = (_x#1) - (_targetPos#1);
    if (_dx * _dx + _dy * _dy <= _radius * _radius) then {
        _dx = (_x#0) - (_startPos#0);
        _dy = (_x#1) - (_startPos#1);
        private _distance = _dx * _dx + _dy * _dy;
        if (_distance < _nearestDistance) then {
            _nearestDistance = _distance;
            _anchor = +_x;
            _offset = 20;
        };
    };
} forEach _minePositions;

private _dx = (_startPos#0) - (_anchor#0);
private _dy = (_startPos#1) - (_anchor#1);
private _length = sqrt (_dx * _dx + _dy * _dy);
private _backX = -sin _startDir;
private _backY = -cos _startDir;
if (_length > 0.001) then {_backX = _dx / _length; _backY = _dy / _length};
private _stopX = (_anchor#0) + _offset * _backX;
private _stopY = (_anchor#1) + _offset * _backY;

// Project each 20 m exclusion circle onto the retreat ray, then leave any overlapping intervals.
private _intervals = [];
{
    _dx = (_x#0) - _stopX;
    _dy = (_x#1) - _stopY;
    private _along = _dx * _backX + _dy * _backY;
    private _acrossSquared = 0 max (_dx * _dx + _dy * _dy - _along * _along);
    if (_acrossSquared < 400) then {
        private _halfWidth = sqrt (400 - _acrossSquared);
        if (_along + _halfWidth >= 0) then {
            _intervals pushBack [0 max (_along - _halfWidth), _along + _halfWidth + 0.1];
        };
    };
} forEach _minePositions;
private _retreat = 0;
private _overlap = _intervals findIf {_x#0 <= _retreat && {_x#1 > _retreat}};
while {_overlap != -1} do {
    // Each step passes one interval's end permanently, so there are at most count _intervals steps.
    _retreat = (_intervals#_overlap)#1;
    _overlap = _intervals findIf {_x#0 <= _retreat && {_x#1 > _retreat}};
};
[_stopX + _retreat * _backX, _stopY + _retreat * _backY, 0]
