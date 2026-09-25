/*
    Minefield identification
    Returns mine positions connected to the 100 m search area by gaps of at most 20 m horizontally.
    Arguments: requested ATL position and a mine-position snapshot. The input arrays are not modified.
    Called once per dispatch in scheduled server context; no network state or mine knowledge is changed.
*/

params ["_targetPos", "_minePositions"];
private _found = [];
private _remaining = [];
{
    private _dx = (_x#0) - (_targetPos#0);
    private _dy = (_x#1) - (_targetPos#1);
    if (_dx * _dx + _dy * _dy <= 10000) then {
        _found pushBack _x;
    } else {
        _remaining pushBack _x;
    };
} forEach _minePositions;

// Each discovered mine is expanded once; remove its neighbours from the unvisited list immediately.
private _index = 0;
while {_index < count _found && {_remaining isNotEqualTo []}} do {
    private _anchor = _found#_index;
    _remaining = _remaining select {
        private _dx = (_x#0) - (_anchor#0);
        private _dy = (_x#1) - (_anchor#1);
        private _connected = _dx * _dx + _dy * _dy <= 400;
        if (_connected) then {_found pushBack _x};
        !_connected
    };
    _index = _index + 1;
};
_found
