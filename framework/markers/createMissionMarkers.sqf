/*
	Mission markers
	Creates mission and framework markers for configured entities.
	Author: Alex2k.
*/

if (getMarkerColor "respawn" != "") then {
	private _rspMkr = createMarker ["lmf_markers_respawnInf", getMarkerPos "respawn"];
	_rspMkr setMarkerType "respawn_inf";
	_rspMkr setMarkerSize [0.75, 0.75];
	_rspMkr setMarkerColor "ColorBlack";
	_rspMkr setMarkerText "";
	_rspMkr setMarkerAlpha 1;

	"respawn" setMarkerAlpha 0;
	"lmf_markers_respawnInf" setMarkerAlpha 0;
};

#include "..\equipment\createRoleSelectorMarker.sqf"

#include "..\assetSpawner\createSpawnerMarkers.sqf"

if !(isNil "RRR") then {
	_rrrMkr = createMarker ["mrk_RRR", getPosASL RRR];
	_rrrMkr setMarkerType "b_maint";
	_rrrMkr setMarkerSize [0.75, 0.75];
	_rrrMkr setMarkerColor "ColorBlack";
	_rrrMkr setMarkerText "";
	_rrrMkr setMarkerAlpha 1;
};

if !(isNil "LAMBS_Hospital") then {
	private _hospMkr = createMarker ["lmf_markers_hospital", getPosASL LAMBS_Hospital];
	_hospMkr setMarkerType "b_med";
	_hospMkr setMarkerSize [0.75, 0.75];
	_hospMkr setMarkerColor "ColorBlack";
	_hospMkr setMarkerText "";
	_hospMkr setMarkerAlpha 1;
};

private _clearMapCoordsMkr = createMarker ["lmf_markers_clearMap", [-1000, -1000]];
_clearMapCoordsMkr setMarkerType "Empty";
