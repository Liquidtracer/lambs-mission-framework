/*
    Deploy units and assets
    Forward deploys troops. Call on the server.
    Author: G4rrus.

    Arguments:
        0: Deployment entries <ARRAY> (each entry: [troops, [position, direction, assets]]; troops = unit, group or unit array; assets = object array)
        1: Deployment height in meters <NUMBER> (default: 120; 0 = ground deployment)

    Example:
        [[[grp1, [[1200, 2400, 0], 90, []]]], 200] call lmf_forwardDeploy_fnc_deployUnitsAndAssets;
*/

if !(isServer) exitWith {};

params [
	["_paramArrays",[],[[]]],
	["_height",120,[123]]
];

if (_height > 0 && {_height < 100}) then {
	_height = 100;
};

if (_paramArrays isEqualTo []) exitWith {};

// Deploy
// Ground
if (_height isEqualTo 0) exitWith {
	{

		_x params [
			["_units",grpNull,[objNull,grpNull,[]]],
			["_data",[[0,0,0],0,[]],[[]],3]
		];
		_data params [
			["_pos",objNull,[objNull,grpNull,"",locationNull,taskNull,[],123]],
			["_dir",0,[123]],
			["_vics",[],[[]]]
		];

		private _pos = _pos call CBA_fnc_getPos;
		if (!(isNull _units) && {!(_pos isEqualTo [0,0,0])}) then {
			_units = switch (typeName _units) do {
				case "GROUP": {units _units};
				case "OBJECT": {units group _units};
				case "ARRAY": {_units};
			};

			private _relDist = (count _units) * 5 / 2;
			private _startPos = _pos getPos [_relDist,_dir - 90];
			private _startPosVic = _startPos getPos [15,_dir - 180];
			private _dirRight = _dir + 90;

			// Units
			{
				if !(vehicle _x isEqualTo _x) then {
					moveOut _x;
					[_x] call ace_medical_fnc_fullHeal;
				};

				[_x,_dir] remoteExec ["setDir",_x];
				[_x,"PlayerProne"] remoteExec ["playActionNow",_x];
				_x setPos _startPos;
				_x selectWeapon (primaryWeapon _x);

				_startPos = _startPos getPos [2,_dirRight];
			} forEach _units;

			// Vehicles
			if !(_vics isEqualTo []) then {
				{
					private _minDist = ((boundingBoxReal _x) select 2) * 0.8;
					_minDist = _minDist max 10;
					_startPosVic =  _startPosVic getPos [_minDist,_dirRight];

					while {(nearestObject _startPosVic) distance2D _startPosVic < _minDist} do {
						_startPosVic = _startPosVic getPos [0.5,_dirRight];
					};

					_x enableSimulationGlobal false;
					[_x,_dir] remoteExec ["setDir",_x];
					_x setPos _startPosVic;
					private _surfaceNormal = surfaceNormal position _x;
					[_x,_surfaceNormal] remoteExec ["setVectorUp",_x];
					[{
						_vic = _this select 0;
						_vic enableSimulationGlobal true;
					},[_x],5] call CBA_fnc_waitAndExecute;
				} forEach _vics;
			};
		};
	} forEach _paramArrays;
};

// Air
{

	_x params [
		["_units",grpNull,[objNull,grpNull,[]]],
		["_data",[[0,0,0],0,[]],[[]],3]
	];
	_data params [
		["_pos",objNull,[objNull,grpNull,"",locationNull,taskNull,[],123]],
		["_dir",0,[123]],
		["_vics",[],[[]]]
	];

	private _pos = _pos call CBA_fnc_getPos;
	if (!(isNull _units) && {!(_pos isEqualTo [0,0,0])}) then {
		_units = switch (typeName _units) do {
			case "GROUP": {units _units};
			case "OBJECT": {units group _units};
			case "ARRAY": {_units};
		};

		private _relDist = ((count _units) + (count _vics)) * 20 / 2;
		private _startPos = _pos getPos [_relDist,_dir];
		private _dirRel = _dir + 90;
		private _dirBack = _dir - 180;

		// Units
		{
			if !(vehicle _x isEqualTo _x) then {
				moveOut _x;
				[_x] call ace_medical_fnc_fullHeal;
			};

			private _randomOffset = [random 30, random -30] select (random 100 < 50);
			private _finalPos = (_startPos getPos [_randomOffset,_dirRel]) vectorAdd [0,0,_height + (random 15)];

			_x setPos _finalPos;
			[_x,"POSITION",[_finalPos,_dir,"Steerable_Parachute_F"]] call lmf_paradrop_fnc_dropUnit;

			_startPos = _startPos getPos [30,_dirBack];
		} forEach _units;

		_startPos = _startPos getPos [25,_dirBack];

		// Vehicles
		if !(_vics isEqualTo []) then {
			{
				private _randomOffset = [random 30, random -30] select (random 100 < 50);
				private _finalPos = (_startPos getPos [_randomOffset,_dirRel]) vectorAdd [0,0,_height + (random 15)];

				_x setPos _finalPos;
				[_x,"POSITION",[_finalPos,_dir,""]] call lmf_paradrop_fnc_dropObject;

				_startPos = _startPos getPos [60,_dirBack];
			} forEach _vics;
		};
	};
} forEach _paramArrays;

