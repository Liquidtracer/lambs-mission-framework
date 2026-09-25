/*
    Create role selector marker
    Creates the crateRoles marker; included by createMissionMarkers.sqf.
*/

if !(isNil "crateRoles") then {
	_gearSelectMkr = createMarker ["mrk_gearSelect", getPosASL crateRoles];
	_gearSelectMkr setMarkerType "b_inf";
	_gearSelectMkr setMarkerSize [0.75,0.75];
	_gearSelectMkr setMarkerColor "ColorBlack";
	_gearSelectMkr setMarkerText "";
	_gearSelectMkr setMarkerAlpha 1;
};

