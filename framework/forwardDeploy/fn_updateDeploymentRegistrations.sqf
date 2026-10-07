/*
	Update deployment registrations
	Removes invalid deployment registrations and updates marker text after callsign changes.
	Author: G4rrus.

	Example:
		[] call lmf_forwardDeploy_fnc_updateDeploymentRegistrations;
*/

if !(isServer) exitWith {};

private _hashGroups = [lmf_forwardDeploy_registry] call CBA_fnc_hashKeys;
private _markerPrefix = "lmf_forwardDeploy_marker_";

// Clean up invalid groups and markers
{
	private _key = [lmf_forwardDeploy_registry, _x] call CBA_fnc_hashGet;
	private _vics = _key select 2;
	private _mrk = _key select 0;
	private _unitAmount = count units _x;

	// Release vehicles and remove the registration when the group is empty.
	if (_unitAmount isEqualTo 0) then {
		{
			_x setVariable ["lmf_forwardDeploy_registration", true, true];
		} forEach _vics;
		[lmf_forwardDeploy_registry, _x] call CBA_fnc_hashRem;
		deleteMarker _mrk;
	};

	// Release unplaced registrations after warmup.
	if !(lmf_warmup_isActive) then {
		if (_mrk isEqualTo "") then {
			{
				_x setVariable ["lmf_forwardDeploy_registration", true, true];
			} forEach _vics;
			[lmf_forwardDeploy_registry, _x] call CBA_fnc_hashRem;
		};
	};

	// Update marker text after a callsign change.
	if !(([lmf_forwardDeploy_registry, _x] call CBA_fnc_hashGet) isEqualType true) then {
		private _groupId = groupId _x;
		private _mrkId = _mrk select [count _markerPrefix, count _mrk];

		if (!(_mrk isEqualTo "") && {!(_groupId isEqualTo _mrkId)}) then {
			private _mrkPos = markerPos _mrk;
			private _mrkDir = markerDir _mrk;
			private _mrkType = markerType _mrk;
			deleteMarker _mrk;

			private _mrkName = format ["%1%2", _markerPrefix, _groupId];
			private _deployMarker = createMarker [_mrkName, _mrkPos];
			_deployMarker setMarkerType _mrkType;
			_deployMarker setMarkerSize [0.75, 0.75];
			_deployMarker setMarkerColor "ColorWest";
			_deployMarker setMarkerText format ["%1", _groupId];
			_deployMarker setMarkerDir _mrkDir;

			[lmf_forwardDeploy_registry, _x, [_mrkName, _mrkDir, _vics]] call CBA_fnc_hashSet;
		} else {
			_mrk setMarkerText format ["%1", _groupId];
		}
	};

	// Remove marker on mission start
	if !(lmf_warmup_isActive) then {
		[{
			params ["_group", "_markerPrefix"];
			deleteMarker format ["%1%2", _markerPrefix, groupId _group];
		}, [_x, _markerPrefix], 10] call CBA_fnc_waitAndExecute;
	};
} forEach _hashGroups;
