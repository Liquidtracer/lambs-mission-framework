/*
    Drop object
    Handles parachute deployment and landing cleanup for crates and vehicles.
    ACE_CARGO protects the local object before starting monitors; landing restores damage.

    Arguments:
        0: Object to drop <OBJECT>
        1: Drop mode <STRING> (default: "POSITION"; "POSITION" or "ACE_CARGO")
        2: Mode data <ARRAY> (see below)

    Example:
        [crate_1, "POSITION", [[1200, 2400, 200], 90, ""]] spawn lmf_paradrop_fnc_dropObject;

    Modes and data:
        POSITION: [position, direction, attached item]
        ACE_CARGO: [aircraft, original cargo size, stuck altitude, touchdown poll, reset damage immediately]
*/

params [
    ["_object", objNull, [objNull]],
    ["_mode", "POSITION", [""]],
    ["_data", [], [[]]]
];

if (isNull _object) exitWith {false};

if (!local _object) exitWith {
    [_object, _mode, _data] remoteExec ["lmf_paradrop_fnc_dropObject", _object];
    true
};

switch (toUpper _mode) do {
    case "POSITION": {
        _data params [
            ["_position", [0,0,0], [[]], 3],
            ["_direction", 0, [0]],
            ["_attachedItem", "", [""]]
        ];

        _object setPos _position;

        private _attachPoint = [[0,0,abs ((boundingBox _object select 0) select 2)],[0,0,1]] select (_object isKindOf "ReammoBox_F");
        private _parachute = createVehicle ["B_Parachute_02_F", _position, [], 0, "CAN_COLLIDE"];
        _parachute setDir _direction;
        private _velocity = velocity _object;

        _object attachTo [_parachute, _attachPoint];
        _parachute setVelocity _velocity;

        [_object, _parachute] spawn {
            params ["_object", "_parachute"];
            waitUntil {sleep 5; (getPosATL _object) select 2 < 25};
            sleep 15;
            if ((getPosATL _object) select 2 > 1) then {
                _parachute = attachedTo _object;
                playSound3D [
                    "a3\sounds_f\weapons\Flare_Gun\flaregun_1_shoot.wss",
                    _object
                ];
                detach _object;
                sleep 15;
                deleteVehicle _parachute;
            };
        };

        [{
            params ["_object"];
            (getPosATL _object) select 2 < 1 || {isNull _object}
        }, {
            params ["_object", "_attachedItem"];
            if (isNull _object) exitWith {};

            detach _object;
            if (_attachedItem != "") then {
                private _position = getPosATL _object;
                createVehicle [_attachedItem, [_position select 0, _position select 1, 0], [], 0, "CAN_COLLIDE"];
            };
        }, [_object, _attachedItem], 600] call CBA_fnc_waitUntilAndExecute;

        true
    };

    case "ACE_CARGO": {
        _data params [
            ["_aircraft", objNull, [objNull]],
            ["_cargoSize", 0, [0]],
            ["_stuckAltitude", 1, [0]],
            ["_touchdownPoll", 1, [0]],
            ["_resetDamageImmediately", false, [true]]
        ];

        if (isNull _aircraft) exitWith {false};

        private _velocity = velocity _aircraft;
        private _dropped = [_object, _aircraft] call ace_cargo_fnc_paradropItem;

        // Protect once before both monitors; tree recovery must not re-enable protection after landing.
        _object allowDamage false;
        if (_resetDamageImmediately) then {
            _object setDamage 0;
        };

        _object setDir (getDir _aircraft);
        _object setVelocity [(_velocity select 0) * 0.5, (_velocity select 1) * 0.5, -2];
        [_object, -10, 0] call BIS_fnc_setPitchBank;
        [_object, _cargoSize] call ace_cargo_fnc_setSize;

        [_object, _stuckAltitude] spawn {
            params ["_object", "_stuckAltitude"];
            if (isNull _object) exitWith {};

            waitUntil {sleep 5; (getPos _object) select 2 < 25};
            _object setDamage 0;
            private _parachute = attachedTo _object;
            sleep 15;

            if ((getPos _object) select 2 > _stuckAltitude) then {
                playSound3D [
                    "a3\sounds_f\weapons\Flare_Gun\flaregun_1_shoot.wss",
                    _object
                ];
                detach _object;
                sleep 15;
                deleteVehicle _parachute;
            };
            deleteVehicle _parachute;
        };

        [_object, _touchdownPoll] spawn {
            params ["_object", "_touchdownPoll"];
            if (isNull _object) exitWith {};

            waitUntil {sleep 0.1; (getPos _object) select 2 < 2};
            if (!isNull attachedTo _object) then {
                playSound3D [
                    "a3\sounds_f\weapons\Flare_Gun\flaregun_1_shoot.wss",
                    _object
                ];
                detach _object;
            };

            waitUntil {sleep _touchdownPoll; isTouchingGround _object};
            sleep 1;
            _object allowDamage true;
            _object setDamage 0;
            {deleteVehicle _x} forEachReversed (attachedObjects _object);
        };

        _dropped
    };

    default {false};
}
