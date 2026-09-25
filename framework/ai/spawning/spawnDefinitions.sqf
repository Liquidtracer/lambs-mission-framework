/*
    AI spawn definitions
    Defines vehicles, roles and group compositions used by the AI spawners.
    Includes the private group-type selection helper used by infantry spawners.
*/

private _vehicles = lmf_ai_config get "VEHICLES";
private _roles = lmf_ai_config get "ROLES";

private _car = _vehicles get "CAR";
private _carArmed = _vehicles get "CARARMED";
private _truck = _vehicles get "TRUCK";
private _apc = _vehicles get "APC";
private _tank = _vehicles get "TANK";
private _heliTransport = _vehicles get "HELITRANSPORT";
private _heliAttack = _vehicles get "HELIATTACK";
private _paraVehicle = _vehicles get "PARA_VEHICLE";
private _boat = _vehicles get "BOAT";
private _uav = _vehicles get "UAV";

private _autorifleman = _roles get "AUTORIFLEMAN";
private _crew = _roles get "CREW";
private _grenadier = _roles get "GRENADIER";
private _mmgGunner = _roles get "MMG_GUNNER";
private _marksman = _roles get "MARKSMAN";
private _aaGunner = _roles get "AA_GUNNER";
private _matGunner = _roles get "MAT_GUNNER";
private _pilot = _roles get "PILOT";
private _rifleman = _roles get "RIFLEMAN";
private _riflemanAt = _roles get "RIFLEMAN_AT";
private _squadLeader = _roles get "SQUAD_LEADER";
private _medic = _roles get "MEDIC";

// Infantry pool for numeric group sizes
_soldier = [
	_rifleman,
	_rifleman,
	_rifleman,
	_rifleman,
	_rifleman,
	_riflemanAt,
	_riflemanAt,
	_riflemanAt,
	_grenadier,
	_mmgGunner,
	_marksman,
	_autorifleman,
	_squadLeader,
	_medic
];

// Groups
_squad = [
	[_autorifleman,_squadLeader,_riflemanAt,_grenadier,_rifleman,_rifleman,_rifleman,_riflemanAt],
	[_grenadier,_rifleman,_squadLeader,_riflemanAt,_autorifleman,_rifleman,_riflemanAt,_marksman],
	[_riflemanAt,_rifleman,_rifleman,_squadLeader,_rifleman,_grenadier,_autorifleman,_medic]
	];

_team =	[
	[_grenadier,_rifleman,_riflemanAt,_rifleman],
	[_squadLeader,_rifleman,_riflemanAt,_marksman],
	[_autorifleman,_squadLeader,_grenadier,_rifleman],
	[_squadLeader,_rifleman,_riflemanAt,_riflemanAt],
	[_autorifleman,_squadLeader,_grenadier,_medic]
];

_sentry =	[
	[_grenadier,_rifleman],
	[_marksman,_rifleman]
];

_atTeam =	[
	[_matGunner,_grenadier,_riflemanAt,_rifleman],
	[_rifleman,_riflemanAt,_grenadier,_matGunner]
];

_aaTeam =	[
	[_aaGunner,_grenadier,_riflemanAt],
	[_riflemanAt,_grenadier,_aaGunner]
];

_mgTeam =	[
	[_mmgGunner,_grenadier,_riflemanAt,_rifleman],
	[_rifleman,_riflemanAt,_grenadier,_mmgGunner]
];

_static =	[
	[_rifleman,_rifleman]
];

_vehicleCrew = [_crew,_crew,_crew];
_heliCrew = [_pilot,_pilot];

// Group selection
private _typeMaker = {
	params ["_type"];
	private _selection = [];
	if (_type isEqualType 0) then {
		for "_i" from 1 to (floor (_type)) do {
			_selection pushback (selectRandom _soldier);
		};
	}
	else {
		_type = toUpper _type;
		_selection = selectRandom _team;

		if (_type == "SQUAD") then {_selection = selectRandom _squad};
		if (_type == "SENTRY") then {_selection = selectRandom _sentry};
		if (_type == "ATTEAM") then {_selection = selectRandom _atTeam};
		if (_type == "AATEAM") then {_selection = selectRandom _aaTeam};
		if (_type == "MGTEAM") then {_selection = selectRandom _mgTeam};
		if (_type == "HMG") then {_selection = selectRandom _static};
		if (_type == "MORTAR") then {_selection = selectRandom _static};
		if (_type == "HAT") then {_selection = selectRandom _static};
	};
	_selection
};
