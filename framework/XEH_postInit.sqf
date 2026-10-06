/*
    Framework postInit
    Initializes framework systems for all machines, the server and player clients.
    Contributors: diwako, G4rrus, Alex2k.
*/

// --- All machines --------------------------------------------------------------------------------
enableSaving [false, false];
"Group" setDynamicSimulationDistance 1250;

#include "admin\initCuratorEvents.sqf"

[] execVM "framework\radio\configureAcreChannels.sqf";

#include "medical\initUnconsciousEvent.sqf"

if (var_supplyDropLimit > 0) then {
    [] execVM "framework\supplyDrop\initSupplyDrop.sqf";
};

if (var_forwardDeploy) then {
    [] execVM "framework\forwardDeploy\initForwardDeploy.sqf";
};

[] spawn lmf_ai_fnc_manageNvg;

// --- Server --------------------------------------------------------------------------------------
if (isServer) then {
    #include "warmup\initWarmupState.sqf"

    [] execVM "framework\markers\createMissionMarkers.sqf";

    #include "chat\createChatChannel.sqf"

    // Apply player loadouts to friendly AI during non-dedicated testing.
    if !(isDedicated) then {
        if (var_playerGear) then {
            {
                [_x] call lmf_equipment_fnc_applyRoleFromClass;
            } forEach (playableUnits + switchableUnits) - [player];
        };
    };

    [] execVM "framework\tripFlare\initTripFlareEvent.sqf";

    [] execVM "framework\warmup\monitorWarmupDeadline.sqf";

};

// --- Player clients ------------------------------------------------------------------------------
if !(hasInterface) exitWith {};
waitUntil {!isNull player};

setMissionOptions createHashMapFromArray [ ["AIThinkOnlyLocal", true] ];

call compile preprocessFileLineNumbers "framework\groupNotifications\initGroupNotifications.sqf";

// Initialize spectator, tracking and team colors.
#include "spectator\initSpectatorEvents.sqf"

if (var_bft) then {
    [] execVM "framework\bft\initGroupTracking.sqf";
    [] execVM "framework\bft\initUnitTracking.sqf";
};

[] execVM "framework\teamColors\assignTeamColor.sqf";

// Register player event handlers and apply the starting loadout.
player addEventHandler ["HandleRating", {0}];

player addEventHandler ["Hit", {
    _this spawn lmf_hitEffects_fnc_onHit;
}];

player addEventHandler ["Killed", {
    _this spawn lmf_respawn_fnc_onKilled;
}];

#include "respawn\initDeathFeedback.sqf"

player addEventHandler ["Respawn", {
    _this spawn lmf_respawn_fnc_onRespawn;
}];

if (var_playerGear) then {
    [player] call lmf_equipment_fnc_applyRoleFromClass;
};

// Start briefing and deferred player setup.
[] execVM "framework\briefing\createBriefing.sqf";

[{player setUnitTrait ["camouflageCoef", var_camoCoef];}, [], 5] call CBA_fnc_waitAndExecute;

// Initialize spawner and role actions after the intro signal.
[] spawn {
    waitUntil {uiSleep 0.2; missionNamespace getVariable ["lmf_player_introComplete", false]};
    #include "assetSpawner\initSpawnerActions.sqf"
    #include "equipment\initRoleSelector.sqf"
};

// Start arsenal, JIP teleport and the intro/warmup sequence.
if (var_personalArsenal) then {
    lmf_player_arsenalInit = [] execVM "framework\equipment\initPersonalArsenal.sqf";
};

if (var_jipTp && {didJIP}) then {
    lmf_jipTeleport_init = [] execVM "framework\jipTeleport\initJipTeleport.sqf";
};

// Register LMF self-actions on client.
lmf_player_menuInit = [] spawn {
    waitUntil {uiSleep 0.2; missionNamespace getVariable ["lmf_player_introComplete", false]};

    if (var_bft) then {
        waitUntil {uiSleep 0.2; !isNil "lmf_bft_fnc_registerMenu"};
        [] call lmf_bft_fnc_registerMenu;
    };
    if (var_supplyDropLimit > 0) then {
        waitUntil {uiSleep 0.2; !isNil "lmf_supplyDrop_fnc_registerMenu" && {!isNil "lmf_remainingSuppDrops"} && {!isNil "lmf_supplyDrop_nextRequest"}};
        [] call lmf_supplyDrop_fnc_registerMenu;
    };
    if (var_jipTp && {didJIP}) then {
        waitUntil {uiSleep 0.2; !isNil "lmf_jipTeleport_fnc_registerMenu" || {scriptDone lmf_jipTeleport_init}};
        if (!isNil "lmf_jipTeleport_fnc_registerMenu") then {
            [] call lmf_jipTeleport_fnc_registerMenu;
        };
    };
    if (var_forwardDeploy) then {
        waitUntil {uiSleep 0.2; !isNil "lmf_forwardDeploy_fnc_registerMenu"};
        [] call lmf_forwardDeploy_fnc_registerMenu;
    };
};

[] execVM "framework\warmup\runIntroAndWarmup.sqf";

// Initialize integrations, feedback and client utilities.
if !(isNil "zen_custom_modules_fnc_register") then {
    [] execVM "framework\zen\registerModules.sqf";
};

[] execVM "framework\medical\initTreatmentFeedback.sqf";

#include "chat\initChatMessageHandler.sqf"

[] execVM "framework\chat\registerCommands.sqf";

[] execVM "framework\map\configureMap.sqf";

call compile preprocessFileLineNumbers "framework\notifications\defineNotificationFunctions.sqf";

// Configure communication channels and interaction object textures.
0 enableChannel false; // Global
1 enableChannel true;  // Side
2 enableChannel false; // Command
3 enableChannel true;  // Group
4 enableChannel false; // Vehicle
5 enableChannel false; // Direct

#include "assetSpawner\applySpawnerTextures.sqf"
#include "equipment\applyRoleSelectorTexture.sqf"
