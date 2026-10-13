
/*
    LMF 2.0 - AI Stress Test
    Branch: refactor/sqf-performance

    200 infantry + Vehicle QRF + Paradrop

    - Runs on server only
    - Starts 10 seconds after first player joins
    - Uses LMF's own AI spawners
    - Starts all 33 operations concurrently
    - Marks all spawn positions on the map
    - Logs AI count, server FPS and queue to RPT

    Temporary development test. Remove before merging.
*/

if (isServer) then {

    [] spawn {

        // ----------------------------------------
        // 1. WAIT FOR MISSION AND PLAYER
        // ----------------------------------------

        waitUntil {
            sleep 1;
            CBA_missionTime > 0
        };

        private _players = [];

        waitUntil {
            sleep 1;

            _players = allPlayers - entities "HeadlessClient_F";

            _players isNotEqualTo []
        };

        sleep 10;


        // ----------------------------------------
        // 2. TEST SETTINGS
        // ----------------------------------------

        private _testVehicles = true;
        private _testParadrop = true;

        // Optional Eden marker: LMF_STRESS_CENTER
        // Otherwise use first player's position.

        private _center = if (
            markerShape "LMF_STRESS_CENTER" != ""
        ) then {
            getMarkerPos "LMF_STRESS_CENTER"
        } else {
            getPosATL (_players # 0)
        };

        // Ensure a 3D position.
        _center set [2, 0];


        // ----------------------------------------
        // 3. PREPARE SPAWN POSITIONS
        // ----------------------------------------

        private _positions = [];

        for "_i" from 0 to 31 do {

            private _direction = (_i * 137.5) mod 360;
            private _distance = 900 + ((_i mod 6) * 130);

            private _candidate = _center getPos [
                _distance,
                _direction
            ];

            private _pos = [
                _candidate,
                0,
                200,
                5,
                0,
                0.5,
                0
            ] call BIS_fnc_findSafePos;

            // BIS_fnc_findSafePos may return [x,y].
            // ACE Garrison expects [x,y,z].
            _pos set [2, 0];

            _positions pushBack _pos;

            // Visible map marker for Zeus.
            private _marker = createMarker [
                format ["LMF_STRESS_SPAWN_%1", _i],
                _pos
            ];

            _marker setMarkerType "mil_dot";
            _marker setMarkerColor "ColorRed";
            _marker setMarkerText format [
                "LMF Stress %1",
                _i
            ];
        };


        // ----------------------------------------
        // 4. BASELINE
        // ----------------------------------------

        private _startTime = diag_tickTime;
        private _startAI = count (units lmf_enemySide);

        private _jobs = [];

        diag_log "================================================";
        diag_log "[LMF STRESS] TEST START";

        diag_log format [
            "[LMF STRESS] Initial AI: %1 | Server FPS: %2",
            _startAI,
            diag_fps
        ];

        diag_log format [
            "[LMF STRESS] Test center: %1",
            _center
        ];

        diag_log "================================================";


        // ----------------------------------------
        // 5. SERVER PERFORMANCE MONITOR
        // ----------------------------------------

        [_startTime] spawn {

            params ["_startTime"];

            // Log every 5 seconds for 3 minutes.
            for "_i" from 0 to 36 do {

                private _elapsed = round (
                    diag_tickTime - _startTime
                );

                private _ai = count (units lmf_enemySide);

                private _queue = count (
                    missionNamespace getVariable [
                        "lmf_ai_spawnQueue",
                        []
                    ]
                );

                diag_log format [
                    "[LMF STRESS] t=%1s | FPS=%2 | FPSmin=%3 | AI=%4 | Queue=%5",
                    _elapsed,
                    round diag_fps,
                    round diag_fpsMin,
                    _ai,
                    _queue
                ];

                sleep 5;
            };
        };


        // ----------------------------------------
        // 6. INFANTRY QRF
        // 12 squads x 8 = 96 AI
        // ----------------------------------------

        for "_i" from 0 to 11 do {

            private _handle = [
                _positions # _i,
                "SQUAD"
            ] spawn lmf_ai_fnc_spawnInfantryQrf;

            _jobs pushBack [
                format ["Infantry QRF %1", _i],
                _handle
            ];
        };


        // ----------------------------------------
        // 7. INFANTRY HUNTERS
        // 6 squads x 8 = 48 AI
        // ----------------------------------------

        for "_i" from 12 to 17 do {

            private _handle = [
                _positions # _i,
                "SQUAD",
                2000
            ] spawn lmf_ai_fnc_spawnInfantryHunters;

            _jobs pushBack [
                format ["Hunter %1", _i],
                _handle
            ];
        };


        // ----------------------------------------
        // 8. INFANTRY PATROLS
        // 4 squads x 8 = 32 AI
        // ----------------------------------------

        for "_i" from 18 to 21 do {

            private _handle = [
                _positions # _i,
                _center,
                "SQUAD",
                300,
                "FAST",
                "STAG COLUMN"
            ] spawn lmf_ai_fnc_spawnPatrol;

            _jobs pushBack [
                format ["Patrol %1", _i],
                _handle
            ];
        };


        // ----------------------------------------
        // 9. GARRISON
        // 6 teams x 4 = 24 AI
        // ----------------------------------------

        for "_i" from 22 to 27 do {

            private _handle = [
                _positions # _i,
                "TEAM",
                120,
                1,
                false
            ] spawn lmf_ai_fnc_spawnGarrison;

            _jobs pushBack [
                format ["Garrison %1", _i],
                _handle
            ];
        };


        // ----------------------------------------
        // 10. VEHICLE QRF
        // ----------------------------------------

        if (_testVehicles) then {

            {
                _x params ["_index", "_category"];

                private _handle = [
                    _positions # _index,
                    _category
                ] spawn lmf_ai_fnc_spawnVehicleQrf;

                _jobs pushBack [
                    format ["Vehicle %1", _category],
                    _handle
                ];

            } forEach [
                [28, "CAR"],
                [29, "TRUCK"],
                [30, "APC"],
                [31, "TANK"]
            ];
        };


        // ----------------------------------------
        // 11. PARADROP
        // ----------------------------------------

        if (_testParadrop) then {

            private _dropCenter = _positions # 27;

            private _marker = createMarker [
                "LMF_STRESS_DZ",
                _dropCenter
            ];

            _marker setMarkerShape "ELLIPSE";
            _marker setMarkerBrush "Border";
            _marker setMarkerSize [450, 450];
            _marker setMarkerColor "ColorRed";

            // Aircraft approaches the drop zone.
            private _airSpawn = _dropCenter getPos [
                2500,
                240
            ];

            _airSpawn set [2, 250];

            private _handle = [
                _airSpawn,
                "LMF_STRESS_DZ",
                200,
                "TANK"
            ] spawn lmf_ai_fnc_spawnParadropQrf;

            _jobs pushBack [
                "Paradrop TANK",
                _handle
            ];
        };


        // ----------------------------------------
        // 12. LOG LAUNCHED JOBS
        // ----------------------------------------

        diag_log format [
            "[LMF STRESS] Launched %1 concurrent spawner jobs",
            count _jobs
        ];

        diag_log "[LMF STRESS] Planned ground infantry: 200";


        // ----------------------------------------
        // 13. AWAIT SPAWNER RESULTS
        // ----------------------------------------

        private _success = 0;
        private _failed = 0;

        {
            _x params ["_name", "_handle"];

            // Native Arma 3 2.22 promise result.
            private _result = waitUntil _handle;

            if (isNull _result) then {

                _failed = _failed + 1;

                diag_log format [
                    "[LMF STRESS] FAILED: %1",
                    _name
                ];

            } else {

                _success = _success + 1;

                diag_log format [
                    "[LMF STRESS] COMPLETED: %1",
                    _name
                ];
            };

        } forEach _jobs;


        // ----------------------------------------
        // 14. FINAL SUMMARY
        // ----------------------------------------

        private _duration = diag_tickTime - _startTime;

        private _finalAI = count (units lmf_enemySide);

        private _remainingQueue = count (
            missionNamespace getVariable [
                "lmf_ai_spawnQueue",
                []
            ]
        );

        diag_log "================================================";
        diag_log "[LMF STRESS] ALL SPAWNER JOBS COMPLETED";

        diag_log format [
            "[LMF STRESS] Successful: %1 | Failed: %2",
            _success,
            _failed
        ];

        diag_log format [
            "[LMF STRESS] Preparation time: %1 seconds",
            _duration
        ];

        diag_log format [
            "[LMF STRESS] Initial AI: %1 | Final AI: %2",
            _startAI,
            _finalAI
        ];

        diag_log format [
            "[LMF STRESS] Remaining queue: %1",
            _remainingQueue
        ];

        diag_log format [
            "[LMF STRESS] Final server FPS: %1",
            diag_fps
        ];

        diag_log "================================================";
    };
};
