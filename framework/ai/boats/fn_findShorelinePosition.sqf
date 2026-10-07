/*
	Find shoreline position
	Finds nearby coast, then spreads the landing within 500 meters of that position.
	Returns [] when no coast is found. Run on the AI owner, normally scheduled.

	Arguments: boat position, target position, maximum initial search radius in meters.
	The spread may extend beyond the initial radius. The final offset is 10 meters toward the boat.
*/

params ["_boatPos", "_targetPos", "_radius"];

private _fallback = [-1, -1];
private _searchRadius = 500 min (_radius max 0);
private _shorePos = _fallback;

// Prefer nearby coast before opening the search to the full target radius.
while {true} do {
	_shorePos = [
		_targetPos, 0, _searchRadius,
		3, 0, 0.75, 1, [],
		[_fallback, _fallback]
	] call BIS_fnc_findSafePos;

	if (_shorePos isNotEqualTo _fallback || {_searchRadius >= _radius}) exitWith {};
	_searchRadius = (_searchRadius * 2) min _radius;
};

if (_shorePos isEqualTo _fallback) exitWith {[]};

// Each boat picks independently; retain the found coast if the spread search fails.
_shorePos = [
	_shorePos,
	0,
	500,
	3, // Minimum distance to terrain objects.
	0, // Land only.
	0.75, // Allow steep terrain.
	1, // Shoreline.
	[],
	[_shorePos, _shorePos]
] call BIS_fnc_findSafePos;

private _pos = _shorePos getPos [10, _shorePos getDir _boatPos];
_pos set [2, 0];
_pos
