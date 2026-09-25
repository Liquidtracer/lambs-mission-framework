/*
    Squad tracking
    Tracks local squad members on the main map.
*/

if (!hasInterface || {missionNamespace getVariable ["lmf_bft_unitsStarted", false]}) exitWith {};
lmf_bft_unitsStarted = true;

lmf_bft_fnc_attachUnitTracker = {
    private _map = findDisplay 12 displayCtrl 51;
    if (isNull _map || {_map getVariable ["lmf_bft_drawInstalled", false]}) exitWith {};
    _map setVariable ["lmf_bft_drawInstalled", true];
    _map ctrlAddEventHandler ["Draw", {
        params ["_map"];
        if (!visibleMap || {isNull player}) exitWith {};
        private _group = group player;
        private _leader = leader _group;
        // BFT must not filter group membership by death state.
        private _members = units _group;
        if (count _members < 2) exitWith {};
        _members = [_leader] + (_members - [_leader]);
        private _drawnVehicles = [];
        {
            private _unit = _x;
            private _vehicle = vehicle _unit;
            // A shared vehicle needs one marker, with the leader's team color taking priority.
            if (_vehicle == _unit || {!(_vehicle in _drawnVehicles)}) then {
                private _color = switch (assignedTeam _unit) do {
                    case "RED": {[1, 0, 0, 1]};
                    case "GREEN": {[0, 1, 0, 1]};
                    case "BLUE": {[0, 0, 1, 1]};
                    case "YELLOW": {[1, 1, 0, 1]};
                    default {[1, 1, 1, 1]};
                };
                private _icon = "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa";
                private _size = 16;
                if (_vehicle != _unit) then {
                    _drawnVehicles pushBack _vehicle;
                    _icon = "\A3\ui_f\data\map\vehicleicons\iconExplosiveGP_ca.paa";
                    _size = 18;
                } else {
                    if (_unit == _leader) then {_icon = "\A3\ui_f\data\map\vehicleicons\iconManLeader_ca.paa"};
                };
                private _position = getPosASLVisual _vehicle;
                private _direction = getDirVisual _vehicle;
                _map drawIcon [_icon, [0, 0, 0, 0.8], _position, _size + 4, _size + 4, _direction];
                _map drawIcon [_icon, _color, _position, _size, _size, _direction];
            };
        } forEach _members;
    }];
};

// Rebind if the map display is recreated, without stacking Draw handlers on the same control.
addMissionEventHandler ["Map", {
    if (_this select 0) then {[] call lmf_bft_fnc_attachUnitTracker};
}];
[{if (visibleMap) then {[] call lmf_bft_fnc_attachUnitTracker}}, 1] call CBA_fnc_addPerFrameHandler;
