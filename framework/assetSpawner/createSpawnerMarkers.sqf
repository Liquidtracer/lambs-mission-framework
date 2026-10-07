/*
	Create spawner markers
	Creates markers for configured asset spawners; included by createMissionMarkers.sqf.
*/

if !(isNil "ammoSpawner") then {
	_crateSpawnMkr = createMarker ["lmf_assetSpawner_supplyMarker", getPosASL ammoSpawner];
	_crateSpawnMkr setMarkerType "b_service";
	_crateSpawnMkr setMarkerSize [0.75, 0.75];
	_crateSpawnMkr setMarkerColor "ColorBlack";
	_crateSpawnMkr setMarkerText "";
	_crateSpawnMkr setMarkerAlpha 1;
	};

if !(isNil "groundSpawner") then {
	_vehSpawnMkr = createMarker ["lmf_assetSpawner_groundMarker", getPosASL groundSpawner];
	_vehSpawnMkr setMarkerType "b_motor_inf";
	_vehSpawnMkr setMarkerSize [0.75, 0.75];
	_vehSpawnMkr setMarkerColor "ColorBlack";
	_vehSpawnMkr setMarkerText "";
	_vehSpawnMkr setMarkerAlpha 1;
};

if !(isNil "airSpawner") then {
	_vehSpawnMkr = createMarker ["lmf_assetSpawner_airMarker", getPosASL airSpawner];
	_vehSpawnMkr setMarkerType "b_air";
	_vehSpawnMkr setMarkerSize [0.75, 0.75];
	_vehSpawnMkr setMarkerColor "ColorBlack";
	_vehSpawnMkr setMarkerText "";
	_vehSpawnMkr setMarkerAlpha 1;
};

