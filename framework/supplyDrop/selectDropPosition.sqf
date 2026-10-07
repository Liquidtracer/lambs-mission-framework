/*
	Supply-drop position selection
	Scheduled client-only selection for a requesting player and a crate classname.
	The caller reserves lmf_supplyDrop_selecting before spawning this script; this script releases it.
	An already open map stays open. Closing the map cancels selection, never an accepted request.
	Quota and cooldown are rechecked before sending the existing server event.
	Author: Alex2k. Contributor: G4rrus.
*/

params ["_requester", "_crate"];
private _mapWasOpen = visibleMap;
lmf_supplyDrop_selectedPosition = [];
lmf_supplyDrop_selectionCancelled = false;
private _mapEh = addMissionEventHandler ["MapSingleClick", {
	params ["_units", "_pos"];
	if (lmf_supplyDrop_selectedPosition isEqualTo [] && {!lmf_supplyDrop_selectionCancelled}) then {
		lmf_supplyDrop_selectedPosition = +_pos;
	};
}];
private _closeEh = addMissionEventHandler ["Map", {
	params ["_opened"];
	if (!_opened) then {lmf_supplyDrop_selectionCancelled = true};
}];
if (!_mapWasOpen) then {openMap true};
["Supply Drop", "Click the map to select a drop zone.<br/>Close the map to cancel selection.", "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", 3, 12, "taskUpdated", 1] call lmf_notifications_fnc_showAceMessage;

private _finished = false;
while {!_finished && {!lmf_supplyDrop_selectionCancelled} && {visibleMap} && {alive _requester} && {player isEqualTo _requester}} do {
	waitUntil {uiSleep 0.1; lmf_supplyDrop_selectionCancelled || {!visibleMap} || {lmf_supplyDrop_selectedPosition isNotEqualTo []} || {!alive _requester} || {player isNotEqualTo _requester}};
	if (!lmf_supplyDrop_selectionCancelled && {visibleMap} && {alive _requester} && {player isEqualTo _requester} && {lmf_supplyDrop_selectedPosition isNotEqualTo []}) then {
		private _pos = +lmf_supplyDrop_selectedPosition;
		// Each attempt owns its marker, including the delayed cleanup after requesting a drop.
		lmf_supplyDrop_selectionId = lmf_supplyDrop_selectionId + 1;
		private _marker = createMarkerLocal [format ["lmf_supplyDrop_selection_%1", lmf_supplyDrop_selectionId], _pos];
		_marker setMarkerTypeLocal "selector_selectedMission";
		_marker setMarkerSizeLocal [0.75, 0.75];
		_marker setMarkerColorLocal "ColorOrange";
		private _distance = _pos distance2D (getMarkerPos "respawn");
		// Estimates travel at 250 km/h, with 72 seconds for the minimum 5 km approach.
		private _delayText = [72 + (_distance / 69.44), "MM"] call BIS_fnc_secondsToString;
		private _confirmText = format ["Request supply drop here?<br/> - ETA: %1 minute(s).<br/> - %2x supply drop(s) available.", _delayText, lmf_remainingSuppDrops];
		private _confirmed = [_confirmText, "Supply Drop", "Request", "Cancel"] call BIS_fnc_guiMessage;
		private _sent = false;
		if (_confirmed && {!lmf_supplyDrop_selectionCancelled} && {visibleMap} && {alive _requester} && {player isEqualTo _requester}) then {
			_finished = true;
			private _remaining = ceil (lmf_supplyDrop_nextRequest - serverTime);
			if (lmf_remainingSuppDrops <= 0) then {
				["Supply Drop", "No supply drops remaining.", "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", 2.6, 10, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
			} else {
				if (_remaining > 0) then {
					["Supply Drop", format ["Supply drop available in %1 seconds.", _remaining], "\A3\ui_f_orange\Data\CfgTaskTypes\airdrop_ca.paa", 3, 10, "addItemFailed", 1, true] call lmf_notifications_fnc_showAceMessage;
				} else {
					["lmf_supplyDrop_request", [_pos, _crate, _requester]] call CBA_fnc_serverEvent;
					_sent = true;
				};
			};
		};
		if (_sent) then {
			[{params ["_marker"]; deleteMarkerLocal _marker}, [_marker], 10] call CBA_fnc_waitAndExecute;
		} else {
			deleteMarkerLocal _marker;
		};
		// Preserve Supply Drop's retry after canceling a confirmation; closing the map ends selection.
		lmf_supplyDrop_selectedPosition = [];
	};
};

removeMissionEventHandler ["MapSingleClick", _mapEh];
removeMissionEventHandler ["Map", _closeEh];
if (!_mapWasOpen) then {openMap false};
lmf_supplyDrop_selectedPosition = [];
lmf_supplyDrop_selectionCancelled = false;
lmf_supplyDrop_selecting = false;
