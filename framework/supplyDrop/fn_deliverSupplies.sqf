/*
	Supply delivery
	Delivers a crate or vehicle by parachute using the configured aircraft.
	Run scheduled on the server, which owns the aircraft and pilot group.
	Landing restores damage and creates a fixed global marker when BFT permits it.
	Author: Alex2k, G4rrus.

	Arguments:
		0: Spawn position <MARKER, OBJECT, LOCATION, GROUP, TASK or POSITION>
		1: Drop position <MARKER, OBJECT, LOCATION, GROUP, TASK or POSITION>
		2: Aircraft classname <STRING>
		3: Crate or vehicle classname <STRING>
		4: Optional enabled Supply Crate category, overriding argument 3 <STRING>
		   Omit or use "" to deliver the supplied classname directly.

	Example:
		["mrk_supplySpawn", "mrk_supplyDrop", "C_Plane_Civil_01_F", "B_supplyCrate_F"] spawn lmf_supplyDrop_fnc_deliverSupplies;
*/

if !(isServer) exitWith {};
waitUntil {sleep 1; CBA_missionTime > 0};

params [
	["_spawnPos", objNull, [objNull, grpNull, "", locationNull, taskNull, [], 123]],
	["_dropPos", objNull, [objNull, grpNull, "", locationNull, taskNull, [], 123]],
	["_type", "C_Plane_Civil_01_F", [""]],
	["_crate", "B_supplyCrate_F", [""]],
	["_category", ""]
];

if !(_category isEqualTo "") then {
	private _definition = [_category] call lmf_supplyCrates_fnc_getDefinition;
	_crate = if (_definition isEqualTo []) then {""} else {_definition select 1};
};
if (_crate isEqualTo "") exitWith {};

_spawnPos = _spawnPos call CBA_fnc_getPos;
_dropPos = _dropPos call CBA_fnc_getPos;

private _dir = _spawnPos getDir _dropPos;

sleep 5;

// Prepare and spawn the vehicle
private _veh = createVehicle [_type, _spawnPos, [], 0, "FLY"];
_veh setPos (_veh modelToWorld [0, 0, 200]);
_veh setDir _dir;
_veh setVelocityModelSpace [0, 150, 0];

// Fire countermeasures!
_veh addEventHandler ["Hit", {
	params ["_unit"];
	[_unit, 1] spawn lmf_paradrop_fnc_fireCountermeasures;
}];

private _markerType = "b_unknown";
if (_veh isKindOf "Plane") then {_markerType = "b_plane"};
if (_veh isKindOf "Helicopter") then {_markerType = "b_air"};

// Prep pilot
private _grp = [_spawnPos, side (playableUnits + switchableUnits select 0), ["B_Pilot_F"]] call BIS_fnc_spawnGroup;
_grp deleteGroupWhenEmpty true;
_grp setCombatMode "BLUE";
_grp setBehaviourStrong "CARELESS";
[_grp, "ATLAS"] call lmf_ai_fnc_assignCallsign;
_grp addVehicle _veh;
_grp setVariable ["lambs_danger_dangerAI", "disabled"];
{_x setVariable ["lambs_danger_disableAI", true]} count units _grp;
_grp enableAttack false;

if (lmf_bft) then {
	[_grp, _markerType, groupId _grp] call lmf_bft_fnc_setCallsign;
};

private _pilot = units _grp select 0;
_pilot setVariable ["acex_headless_blacklist", true];
_pilot call lmf_equipment_fnc_applyPilot;
_pilot moveInAny _veh;
_pilot disableAI "CHECKVISIBLE";
_pilot disableAI "TARGET";
_pilot disableAI "AUTOTARGET";
_pilot setRank "CAPTAIN";

// Continue through the drop point before returning.
_veh flyInHeight (125 + (random 100));
_veh limitSpeed 250;
[_grp] call CBA_fnc_clearWaypoints;
private _dropWaypoint = _grp addWaypoint [_dropPos, 0];
_dropWaypoint setWPPos _dropPos;
_dropWaypoint setWaypointType "MOVE";
_dropWaypoint setWaypointCompletionRadius 25;

private _exitPosition = _dropPos getPos [5000, _dir];
private _exitWaypoint = _grp addWaypoint [_exitPosition, 0];
_exitWaypoint setWaypointType "MOVE";
_exitWaypoint setWaypointCompletionRadius 500;

// Load cargo
[_veh, 1000] call ace_cargo_fnc_setSpace;
_crate = createVehicle [_crate, [0, 0, 1000]];
_crate allowDamage false;
_crate setDamage 0;

// Clear cargo in case of vehicle drop
if (_category isEqualTo "" && {_crate isKindOf "LandVehicle" || _crate isKindOf "Ship"}) then {
	clearWeaponCargoGlobal _crate;
	clearMagazineCargoGlobal _crate;
	clearItemCargoGlobal _crate;
	clearBackpackCargoGlobal _crate;
};

if (lmf_playerGear && {!(_category isEqualTo "")}) then {
	[_crate] call lmf_supplyCrates_fnc_initSupplyCrate;
};

private _cargoSize = [_crate] call ace_cargo_fnc_getSizeItem;
[_crate, 1] call ace_cargo_fnc_setSize;
[_crate, _veh, true] call ace_cargo_fnc_loadItem;

// Allow time to slow down before passing the release point.
waitUntil {sleep 0.5; (_veh distance2D _dropPos) < 1000 || {!alive _veh}};
_veh limitSpeed 100;

waitUntil {sleep 0.5; (_veh distance2D _dropPos) < 50 || {!alive _veh}};

// A destroyed transport loses the undelivered cargo; the reserved drop is not refunded.
if (!alive _veh) exitWith {
	deleteVehicle _crate;
};

// Release the route before dropping so the aircraft continues straight ahead.
[_grp] call CBA_fnc_clearWaypoints;
private _straightAhead = _veh getRelPos [5000, 0];
_veh doMove _straightAhead;

[_crate, "ACE_CARGO", [_veh, _cargoSize, 1, 1, true, false]] call lmf_paradrop_fnc_dropObject;

sleep 1;

private _flare = createVehicle ["F_20mm_Yellow", _veh modelToWorld [0, 0, 1], [], 0, "CAN_COLLIDE"];
_flare setVelocity [0, 0, -0.1];

// Finish landing independently of the aircraft's return.
[_crate] spawn {
	params ["_cargo"];
	waitUntil {
		sleep 0.1;
		isNull _cargo || {
			isNull attachedTo _cargo && {
				isTouchingGround _cargo || {((getPos _cargo) # 2) < 0.5}
			}
		}
	};
	if (isNull _cargo) exitWith {};
	sleep 1;
	if (isNull _cargo) exitWith {};

	_cargo setDamage 0;
	if (local _cargo) then {
		_cargo allowDamage true;
	} else {
		[_cargo, true] remoteExecCall ["allowDamage", _cargo];
	};
	{deleteVehicle _x} forEachReversed (attachedObjects _cargo);

	if (!lmf_bft || {lmf_oldSchoolMap}) exitWith {};
	private _markerType = "loc_container";
	if (_cargo isKindOf "LandVehicle") then {_markerType = "loc_car"};
	if (_cargo isKindOf "Ship") then {_markerType = "loc_boat"};

	// Reserve a unique name and publish a fixed position; no object tracking or JIP script.
	isNil {
		lmf_supplyDrop_markerId = (missionNamespace getVariable ["lmf_supplyDrop_markerId", 0]) + 1;
		private _marker = createMarker [format ["lmf_supplyDrop_landed_%1", lmf_supplyDrop_markerId], getPosATL _cargo];
		_marker setMarkerColorLocal "ColorWEST";
		_marker setMarkerSizeLocal [0.75, 0.75];
		_marker setMarkerType _markerType;
		_marker setMarkerShadow false;
	};
};

_veh limitSpeed 999;
_veh doMove (_spawnPos getPos [(_spawnPos distance2D _dropPos) + 10000, _dir - 180]);

waitUntil {sleep 0.5; !alive _veh || {allPlayers findIf {_x distance2D _veh < 5000} == -1}};
// Leave destroyed aircraft and their crew to Arma's normal cleanup.
if (!alive _veh) exitWith {};
deleteVehicleCrew _veh;
deleteVehicle _veh;

