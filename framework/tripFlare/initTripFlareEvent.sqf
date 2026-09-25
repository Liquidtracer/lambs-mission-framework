/*
    Tripflare event registration
    Registers the tripflare event handler.
*/

["ace_tripflareTriggered", {
	params ["_flareObject", "_flarePos"];

	// Play sound
	playSound3D ["a3\missions_f_oldman\data\sound\flare\flare.wss",_flareObject];

	// Create extra flare
	[
		{
			params ["_flareObject","_flarePos"];
			private _flyPos = [_flarePos, random 10, random 10] call BIS_fnc_relPos;
			private _flare = createVehicle ["ACE_40mm_Flare_white", _flyPos, [], 0, "NONE"];
			_flare setPosATL [getPosATL _flare select 0, getPosATL _flare select 1, 150 + (random 75)];
			_flare setVelocity [0,0,-0.1];
			// playSound3D ["a3\missions_f_beta\data\sounds\showcase_night\flaregun_shoot.wss",_flareObject];
			playSound3D ["a3\missions_f_exp\data\sounds\exp_m04_flare.wss", _flareObject, false, getPosASL _flareObject, 4];
		},
		[_flareObject,_flarePos], (1 + random 2)
	] call CBA_fnc_waitAndExecute;

	// Delete flareobject eventually
	[
		{
			params ["_flareObject","_flarePos"];
			if (!alive _flareObject) exitWith {};
			deleteVehicle _flareObject;
		},
		[_flareObject,_flarePos], (60 + (random 20))
	] call CBA_fnc_waitAndExecute;

	// Exit if players didn't trigger the flare
	private _nearPlayers = allPlayers select {_x distance2D _flarePos < 20};
	if (_nearPlayers isEqualTo []) exitWith {};

	// Make nearest static machine gun suppress the area
	[
		{
			params ["_flareObject","_flarePos"];
			private _machineGuns = vehicles select {side _x == var_enemySide && alive _x && _x isKindOf "StaticMGWeapon"};
			if (_machineGuns isEqualTo []) exitWith {};
			private _nearestMg = [_machineGuns, _flarePos] call BIS_fnc_nearestPosition;
			private _targetPos = (getPosASL _flareObject) vectorAdd [0,0,2];
			_nearestMg doSuppressiveFire _targetPos;
		},
		[_flareObject,_flarePos], (4 + (random 4))
	] call CBA_fnc_waitAndExecute;

	// Make nearest garrisoned group suppress the area
	[
		{
			params ["_flareObject","_flarePos"];
			private _garrisonGroups = allGroups select {side _x == var_enemySide && ((groupID _x) find "Garrison") != -1};
			if (_garrisonGroups isEqualTo []) exitWith {};
			private _nearestGarrisonGroup = [_garrisonGroups, _flarePos] call BIS_fnc_nearestPosition;
			{_x setUnitPos "UP"} forEach (units _nearestGarrisonGroup select {alive _x});
			_nearestGarrisonGroup setBehaviour "COMBAT";
			private _targetPos = (getPosASL _flareObject) vectorAdd [0,0,2];
			(units _nearestGarrisonGroup) doSuppressiveFire _targetPos;

			[
				{
					params ["_nearestGarrisonGroup"];
					{_x setUnitPos "AUTO"} forEach (units _nearestGarrisonGroup select {alive _x});
					_nearestGarrisonGroup setBehaviour "AWARE";
				},
				[_nearestGarrisonGroup], (10 + (random 10))
			] call CBA_fnc_waitAndExecute;

		},
		[_flareObject,_flarePos], (5 + (random 5))
	] call CBA_fnc_waitAndExecute;

	// Make nearest "QRF" or "Patrol" group move towards the flare
	[
		{
			params ["_flareObject","_flarePos"];
			private _qrfGroup = allGroups select {side _x == var_enemySide && (((groupID _x) find "QRF") != -1 || ((groupID _x) find "Patrol") != -1)};
			if (_qrfGroup isEqualTo []) exitWith {};
			private _nearestQrfGroup = [_qrfGroup, _flarePos] call BIS_fnc_nearestPosition;
			if ((leader _nearestQrfGroup) distance2D _flarePos < 800) then {
				(units _nearestQrfGroup select {alive _x}) doMove (_flarePos getPos [random 50, random 360]);
				_nearestQrfGroup setBehaviourStrong "AWARE";
				_nearestQrfGroup setSpeedMode "NORMAL";
			};
		},
		[_flareObject,_flarePos], (10 + (random 10))
	] call CBA_fnc_waitAndExecute;

	// Make nearest mortar fire at the area
	[
		{
			params ["_flareObject","_flarePos"];
			private _mortars = vehicles select {side _x == var_enemySide && alive _x && _x isKindOf "StaticMortar"};
			if (_mortars isEqualTo []) exitWith {};
			private _nearestMortar = [_mortars, _flarePos] call BIS_fnc_nearestPosition;

			// Hold fire if there are units friendly to the mortar in the target area
			private _unitsInRange = _flarePos nearEntities ["Man", 100];
			private _friendlyUnitsInRange = _unitsInRange select {side _x == var_enemySide && alive _x};
			if (count _friendlyUnitsInRange > 1) exitWith {};

			private _targetPos = [[[(getPosASL _flareObject), 40]], []] call BIS_fnc_randomPos;
			_nearestMortar doArtilleryFire [_targetPos, currentMagazine _nearestMortar, 2 + random 2];
		},
		[_flareObject,_flarePos], (20 + (random 20))
	] call CBA_fnc_waitAndExecute;

}] call CBA_fnc_addEventHandler;