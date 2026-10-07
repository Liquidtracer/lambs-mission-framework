/*
	Object tracking
	Tracks one networked object with a local map icon on each player client.
	Requires BFT to be enabled and the local player to have an assigned map.
	Call on the server (also SP/hosted); it distributes an object-bound JIP entry.
	One active tracker per object and client. A new call replaces the previous tracker.

	Arguments:
		0: Object to track <OBJECT>
		1: Marker type <STRING>
		2: Marker color <STRING>
		3: Marker size <ARRAY>
		4: Marker text <STRING>
		5: Map access / cleanup interval in seconds; movement is drawn every frame <NUMBER>
		6: Stop tracking when the object is no longer alive <BOOLEAN>
		7: Track object direction <BOOLEAN>
		8: Maximum tracking duration in seconds; negative means unlimited <NUMBER>
		9: Icon outline and text shadow <BOOLEAN>

	Example:
		[crate_1, "loc_container", "ColorWEST", [0.75, 0.75], "Supplies", 0.25, true, false, -1, false] call lmf_bft_fnc_trackObject;
*/

params [
	["_object", objNull, [objNull]],
	["_markerType", "mil_dot", [""]],
	["_markerColor", "ColorWEST", [""]],
	["_markerSize", [1, 1], [[]], 2],
	["_markerText", "", [""]],
	["_interval", 0.25, [0]],
	["_trackWhileAlive", true, [true]],
	["_trackDirection", false, [true]],
	["_maxDuration", -1, [0]],
	["_markerShadow", false, [true]],
	["_endTime", -2, [0]] // Internal absolute serverTime deadline; -2 means a new request.
];

if (isNull _object) exitWith {};

// Stamp the deadline once, before distributing it, so JIP does not restart a finite duration.
if (isServer && {_endTime == -2}) exitWith {
	if (!var_bft) exitWith {};
	private _deadline = if (_maxDuration < 0) then {-1} else {serverTime + _maxDuration};
	[
		_object, _markerType, _markerColor, _markerSize, _markerText, _interval,
		_trackWhileAlive, _trackDirection, _maxDuration, _markerShadow, _deadline
	] remoteExec ["lmf_bft_fnc_trackObject", [0, -2] select isDedicated, _object];
};

if (!hasInterface) exitWith {};
if (!canSuspend) exitWith {_this spawn lmf_bft_fnc_trackObject};

// A direct call on a client remains local; distributed calls already carry their deadline.
if (_endTime == -2) then {_endTime = if (_maxDuration < 0) then {-1} else {serverTime + _maxDuration}};

// Reserve a local generation before waiting for JIP initialization.
private _generation = 0;
isNil {
	lmf_bft_objectCounter = (missionNamespace getVariable ["lmf_bft_objectCounter", 0]) + 1;
	_generation = lmf_bft_objectCounter;
	_object setVariable ["lmf_bft_trackerGeneration", _generation];
	if (!isNil "lmf_bft_objectDrawData") then {
		lmf_bft_objectDrawData = lmf_bft_objectDrawData select {(_x select 0) != _object};
	};
};

// Persistent remote execution can run early for a JIP client.
waitUntil {
	sleep 0.1;
	isNull _object || {!isNil "var_bft" && {!isNull player}}
};

if (isNull _object || {!var_bft} || {_trackWhileAlive && {!alive _object}}) exitWith {};

// Resolve textures, profile-based marker colors and dimensions once, outside Draw.
private _markerConfig = configFile >> "CfgMarkers" >> _markerType;
private _color = getArray (configFile >> "CfgMarkerColors" >> _markerColor >> "color");
if (!isClass _markerConfig || {count _color != 4}) exitWith {};
_color = _color call BIS_fnc_colorConfigToRGBA;
private _size = getNumber (_markerConfig >> "size");
private _drawArgs = [
	getText (_markerConfig >> "icon"), _color, [0, 0, 0],
	_size * (_markerSize select 0), _size * (_markerSize select 1), 0,
	_markerText, [0, 1] select _markerShadow
];
// drawIcon's built-in icon outline only works at angle 0. Use LMF's backdrop approach.
private _outlineArgs = [];
if (_markerShadow) then {
	_outlineArgs = [
		_drawArgs select 0, [0, 0, 0, _color select 3], [0, 0, 0],
		(_drawArgs select 3) + 2, (_drawArgs select 4) + 2, 0
	];
};

isNil {
	// A newer call may have replaced this one while it waited for player/JIP init.
	if (isNull _object || {(_object getVariable ["lmf_bft_trackerGeneration", -1]) != _generation}
		|| {_trackWhileAlive && {!alive _object}}
		|| {_endTime >= 0 && {serverTime >= _endTime}}) exitWith {};

	if (isNil "lmf_bft_objectDrawData") then {
		lmf_bft_objectDrawData = [];
		lmf_bft_nextObjectMapRefresh = 0;

		lmf_bft_fnc_attachObjectTracker = {
			if (lmf_bft_objectDrawData isEqualTo []) exitWith {};
			disableSerialization;
			// Include GPS/IGUI maps as well as the main map and other open map displays.
			{
				{
					if (ctrlType _x in [100, 101] && {!(_x getVariable ["lmf_bft_objectDrawInstalled", false])}) then {
						_x setVariable ["lmf_bft_objectDrawInstalled", true];
						_x ctrlAddEventHandler ["Draw", {
							params ["_map"];
							if (isNull player || {lmf_bft_objectDrawData isEqualTo []}) exitWith {};
							private _mapDir = ctrlMapDir _map;
							{
								_x params ["_object", "_drawArgs", "_outlineArgs", "_trackDirection"];
								if ((_x select 8) && {!isNull _object}) then {
									private _position = getPosASLVisual _object;
									private _direction = if (_trackDirection) then {getDirVisual _object} else {0};
									_direction = _direction + _mapDir;
									if !(_outlineArgs isEqualTo []) then {
										_outlineArgs set [2, _position];
										_outlineArgs set [5, _direction];
										_map drawIcon _outlineArgs;
									};
									_drawArgs set [2, _position];
									_drawArgs set [5, _direction];
									_map drawIcon _drawArgs;
								};
							} forEach lmf_bft_objectDrawData;
						}];
					};
				} forEach allControls _x;
			} forEach (allDisplays + (uiNamespace getVariable ["IGUI_displays", []]));
		};

		addMissionEventHandler ["Map", {
			if (_this select 0) then {[] call lmf_bft_fnc_attachObjectTracker};
		}];

		// One light maintenance pass for all objects; no position updates with maps closed.
		[{
			if (lmf_bft_objectDrawData isEqualTo []) exitWith {};
			private _now = diag_tickTime;
			private _hasMap = "ItemMap" in assignedItems player;
			lmf_bft_objectDrawData = lmf_bft_objectDrawData select {
				_x params ["_object", "", "", "", "_trackWhileAlive", "_endTime", "_nextCheck", "_interval"];
				_now < _nextCheck || {
					_x set [6, _now + _interval];
					_x set [8, _hasMap];
					!isNull _object && {!_trackWhileAlive || {alive _object}}
						&& {_endTime < 0 || {serverTime < _endTime}}
				}
			};
			if (_now >= lmf_bft_nextObjectMapRefresh) then {
				[] call lmf_bft_fnc_attachObjectTracker;
				lmf_bft_nextObjectMapRefresh = _now + 1;
			};
		}, 0.1] call CBA_fnc_addPerFrameHandler;
	};

	lmf_bft_objectDrawData pushBack [
		_object, _drawArgs, _outlineArgs, _trackDirection, _trackWhileAlive, _endTime,
		diag_tickTime + (_interval max 0.1), _interval max 0.1, "ItemMap" in assignedItems player
	];
	[] call lmf_bft_fnc_attachObjectTracker;
};
