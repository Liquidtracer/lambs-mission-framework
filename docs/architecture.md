# Lambs Mission Framework – architecture and project context

LMF 2.0.0 in `LMF_DEV.Altis`. This document describes technical architecture, module contracts and lasting project context. Code/config describes the implementation; user requirements and agreed design choices describe the intent. Development standards are in [development.md](development.md), AI/Codex instructions in [AGENTS.md](../AGENTS.md) and practical calls in [mission-maker-reference.md](mission-maker-reference.md). Code and settings paths in this document are relative to the mission root.

Read **Common project context** before technical work, then the relevant module sections and dependencies in the index. Read the entire document for a broad review or unclear scope. This overview does not replace inspection of the affected code.

**Agreed boundary – Forward Deploy:** The system is retained only for backward compatibility for mission makers who wish to use it. It must not be assessed, reviewed or changed unless the user explicitly requests work on Forward Deploy. This also applies to general LMF surveys, bug reviews and improvement proposals. The existing description is retained as a reference, not as a list of follow-up work. This boundary applies to Forward Deploy, not the shared Paradrop module.

**Agreed boundary – Vehicle Service:** The component is retained, but according to the mission maker it is practically unused. It must not be assessed, reviewed or changed unless the user explicitly requests work on Vehicle Service. This also applies to general LMF surveys, bug reviews and improvement proposals. The existing description is retained as a reference, not as a list of follow-up work. This boundary applies to `framework/vehicleService/`, not other vehicle initialization or asset spawners.

**Evidence:** The descriptions are based on the static survey dated 2026-09-23 and previously documented source/test experience. The documentation editing is not a new full engine, parser or in-game verification. The development mission is reported to have started successfully after repository preparation. Dedicated/JIP behavior has prior reported runtime validation, but has not been regression-tested again specifically after preparation. This does not confirm that all module-specific edge cases have been tested; specific limitations below are retained. Installed mod versions have not been established. “Design” means agreed intent, “Implementation” describes code, “Observation” means reported runtime behavior and “Unresolved” identifies a specific limitation or missing verification. Unlabeled technical descriptions indicate the implementation, not test evidence. Source links are the previous basis; check relevant current documentation when drawing technical conclusions.

## Common project context

### Layers, structure and interfaces

- `framework/`: reusable LMF code, organized by system. Folders do not indicate execution context; guards, initialization points and contracts determine this.
- `settings/`: LMF configuration for mission makers. See the settings table below.
- `description.ext`: the LMF portions register CfgFunctions, XEH, object sorting and notifications and must accompany the framework when transferred. The rest is mission setup.
- `init.sqf`, `initServer.sqf`, `initPlayerLocal.sqf`, `onFlare.sqs` and Eden are mission integration. `initPlayerLocal.sqf` contains only comments and is an available integration point.
- `mission.sqm` is intentionally stored unbinarized as version-controlled Eden output. Agents may read and inspect the file, including Eden names, init fields, triggers and module synchronization. The file must never be edited directly; changes are made only through Eden Editor.

Function names are `lmf_<system>_fnc_<handling>`. Registered function classes match `fn_<handling>.sqf`; subfolders do not change the system tag. Runtime-defined helpers use the same naming pattern, but are defined at their initialization points. Registration is not an API whitelist: public use is determined by contracts, examples and call sites. The absence of public/private labels is accepted design, not a need for rebuilding.

Script/include files have names without `fn_`; XEH files, config headers and settings follow established conventions. Naming and comment rules are in [development.md](development.md).

LMF 2.0.0's system names are not backward compatible, and there are no legacy aliases. When transferring, framework, settings, LMF config, mission calls and any Eden calls must be checked together. Active framework helpers/state use `lmf_`; `a2k_*` under framework exists only in commented-out historical medical code. The mission's own `a2k_*` must not be renamed as LMF cleanup.

### Initialization and wait conditions

Start inspection in `description.ext`, `framework/functions.hpp`, `framework/XEH_preInit.sqf` and `framework/XEH_postInit.sqf`. Scheduled work may continue in parallel; start order is not completion order.

1. **Config/functions:** `description.ext` includes `framework/functions.hpp` and `framework/notifications/CfgNotifications.hpp`. CfgFunctions makes registered functions available on each machine; this is not a broadcast.
2. **CBA preInit:** `framework/XEH_preInit.sqf` includes mission settings and color constants, sets the version/admin UIDs, loads AI settings synchronously and then BFT helpers/server events. Configuration is created locally on each machine.
3. **Mission event scripts:** `initServer.sqf` and `initPlayerLocal.sqf` contain only comments; no mission-specific player initialization or designator is defined there.
4. **CBA postInit:** LMF uses general XEH `init` on all machine types. The common section starts ACRE, conditional Supply Drop/Forward Deploy and AI NVG, and includes curator/medical events. The server section initializes/publishes warmup and the chat channel, starts markers, tripflare and the warmup deadline. Machines without an interface then exit. The player section waits for `player`, sets `AIThinkOnlyLocal`, registers group notifications/EHs/loadout and starts client modules.
5. **CBA InitPost:** CBA drains the startup InitPost queue after Extended PostInit. `description.ext` routes to the five `lmf_objectSorting_fnc_sort*` functions. AI on `var_enemySide` goes to AI init; player gear is initialized explicitly in postInit. The civilian branch sends local `lmf_ai_civ_listener`, with no receiver in this codebase. Vehicles/crates are matched against configured classnames. InitPost for subsequently created objects is deferred to the next frame; code immediately after spawning cannot assume object initialization is complete.
6. **`init.sqf`:** The file contains only a short header and is an available integration point for mission code and temporary tests. Any AI spawning must still be restricted to the server.

Init fragments are textually included and inherit scope/guards; they must not be started separately: `framework/admin/initCuratorEvents.sqf`, `framework/medical/initUnconsciousEvent.sqf`, `framework/warmup/initWarmupState.sqf`, `framework/chat/createChatChannel.sqf`, `framework/chat/initChatMessageHandler.sqf`, `framework/spectator/initSpectatorEvents.sqf` and `framework/respawn/initDeathFeedback.sqf`. The admin diary is included by briefing, marker fragments by marker startup, textures by client postInit.

**Client dependency chain:** The narrative intro sets local `lmf_player_introComplete` → arsenal, object/role actions and `lmf_player_menuInit` can register menus → Mission Info waits for `lmf_player_arsenalInit` when arsenal is enabled and for the entire menu sequence → the info script ends → the intro unit regains simulation. The intro signal does not mean warmup has ended or fade-in is complete. The warmup panel/safety runs in parallel.

`lmf_player_menuInit` registers **BFT → Supply Drop → JIP Teleport → Forward Deploy**. When Supply Drop is enabled, its menu helper registers Supply Drop directly under ACE Self-Interaction. The helpers are defined in module init and called once from the sequence after the required state is available. All four main choices are inherited ACE class self-actions on `CAManBase`. Other mods' ordering is not covered. Equipment menus are separate; spawner/role actions are created on the objects.

**Unresolved:** Waiting for helpers/state has no timeout. A missing helper or replicated state can hold up later menus, fade-in and release. This is a dependency derived from code, not an observed startup failure.

Initialization sources: [BIKI Initialisation Order](https://community.bohemia.net/wiki/Initialisation_Order), [CBA XEH guide](https://github.com/CBATeam/CBA_A3/wiki/Extended-Event-Handlers-%28new%29), [CBA postInit](https://github.com/CBATeam/CBA_A3/blob/master/addons/xeh/fnc_postInit.sqf), [CBA init](https://github.com/CBATeam/CBA_A3/blob/master/addons/xeh/fnc_init.sqf). The CBA source confirms PostInit before InitPost; the actual order with the installed mod set has not been checked at runtime.

### Settings, machines and shared state

| Configuration | Usage and scope |
|---|---|
| `settings/cfg_Mission.sqf` | Included in preInit; global `var_*` variables are created locally on each machine. Not a server-replicated settings object. |
| `settings/cfg_AI.hpp` | Included only by `framework/ai/loadSettings.sqf` in preInit. Private values are collected in local `lmf_ai_config`, with reverse classname lookups. Weapon metadata is cached on use in `lmf_ai_weaponCache`. |
| `settings/cfg_Player.sqf` | Private values are included in loadout, vehicle/supply init and UI. |
| `settings/cfg_Briefing.sqf` | Private data is included and formatted by `framework/briefing/createBriefing.sqf`. |
| `CBA_settings.sqf` | Separate mission configuration enabled from `description.ext`; not part of the settings include flow. |

Private includes depend on the consumer's scope; do not replace them with function calls without assessing the contract. Changes to `var_*` or `lmf_ai_config` at runtime are local until explicitly synchronized over the network. The AI registry's uppercase HashMap keys are not covered by camelCase renaming.

**Design:** The production environment is dedicated with JIP. `lmf_ai_fnc_isSpawner` uses `isServer`; HC spawning is intentionally disabled because the current volume does not justify the complexity. Inactive HC code is retained. Do not assume support for locality transfer of active AI sequences.

| State/system | Writer and distribution |
|---|---|
| `lmf_warmup` | Initialized on the server; manual termination by an admin also sets/publishes from the client. Not purely server-authoritative. |
| `lmf_chatChannel` | The server creates the channel and publishes its ID. |
| BFT `lmf_bft_state` | The server writes public state on the group; clients draw locally. |
| Supply Drop | The server owns the quota and `lmf_supplyDrop_nextRequest`, publishes the count/deadline; the client sends a request. |
| Forward Deploy | Registry in the server's `lmf_deploy_hash`; CBA server events receive requests. |
| `lmf_currentRole` | Gear on the unit's owner; the role is published on the unit. |
| Fire support | Server-local battery state, public `lmf_artilleryBusy` for clients/JIP. |

JIP builds the client's briefing, actions and trackers from startup and current state. Respawn is a separate flow; class actions can survive player-object replacement, but parameter binding to the original unit may still limit availability. One-off messages/delivery sequences are not replayed. Object-bound persistent remote execution is used for spawner deletion and BFT object tracking, among other things; deletion and repeated calls must be assessed against the JIP ID contract, without assuming an order between persistent calls.

`description.ext` has no mission-local `CfgRemoteExec`; the effective engine/server/mod policy determines exposure. Clients with an interface enable `AIThinkOnlyLocal` (documented from Arma 3 2.20); remote AI target data therefore cannot be expected to be available there. Hosted servers also have an interface and are covered; dedicated/HC do not.

External calls exist to CBA, ACE/ACEX, ACRE and LAMBS Danger. ZEN is registered only if the function exists; other dependencies have no equivalent general availability guard. Installed versions have not been established.

Common references: [Functions Library](https://community.bohemia.net/wiki/Arma_3%3A_Functions_Library), [PreProcessor](https://community.bohemia.net/wiki/PreProcessor_Commands), [private](https://community.bohemia.net/wiki/private), [Locality](https://community.bohemia.net/wiki/Locality_in_Multiplayer), [publicVariable](https://community.bohemia.net/wiki/publicVariable), [setVariable](https://community.bohemia.net/wiki/setVariable), [remoteExec](https://community.bohemia.net/wiki/remoteExec), [CfgRemoteExec](https://community.bohemia.net/wiki/CfgRemoteExec), [setMissionOptions](https://community.bohemia.net/wiki/setMissionOptions).

### Module index and integration points

The paths below are starting points, not a complete file inventory. Follow calls to dependencies before changing a contract.

| Module section | Starting point | Also read |
|---|---|---|
| AI init, spawning and garrison | `framework/ai/fn_initUnit.sqf`, `framework/ai/spawning/` | Settings, group management, boat/heli/paradrop according to spawn type |
| AI groups, hunters and boats | `framework/ai/groups/`, `framework/ai/tasks/`, `framework/ai/boats/` | Spawning, BFT for callsigns |
| Helicopter transport | `framework/ai/spawning/fn_spawnVehicleQrf.sqf` | Group management/converge |
| Paradrop and Forward Deploy | `framework/paradrop/`, `framework/forwardDeploy/` | Spawning or Supply Drop for their payloads; Forward Deploy only on explicit request, see the boundary at the top |
| Supply Drop | `framework/supplyDrop/initSupplyDrop.sqf` | Paradrop, AI callsign, BFT, notifications |
| BFT and map | `framework/bft/`, `framework/map/configureMap.sqf` | Init/state, notifications |
| Player setup, asset spawners and service | `framework/equipment/`, `framework/assetSpawner/`, `framework/vehicleService/` | Settings, object sorting, intro; Vehicle Service only on explicit request, see the boundary at the top |
| Warmup, Mission Info and JIP teleport | `framework/warmup/`, `framework/missionInfo/`, `framework/jipTeleport/` | Menu chain, admin, equipment, Supply Drop |
| Respawn, spectator, medical and hit effects | `framework/respawn/`, `framework/spectator/`, `framework/medical/` | Equipment, notifications |
| UI, briefing and group notifications | `framework/notifications/`, `framework/briefing/`, `framework/groupNotifications/` | Intro, CBA player events |
| Admin, chat and radio | `framework/admin/`, `framework/chat/`, `framework/radio/` | Warmup, spectator, remote-exec policy |
| Fire support | `framework/ai/fireSupport/fn_fireSupportAtTarget.sqf` | Radio, BFT |

Eden integration: optional `ammoSpawner`/`ammoPad`, `groundSpawner`/`groundPad`, `airSpawner`/`airPad`, `crateRoles`, `RRR` and `LAMBS_Hospital`; see spawner/marker code. Supply Drop expects the `respawn` marker. Forward Deploy registers the object variable `lmf_deploy_unowned` before postInit. JIP teleport uses the unit's stored start position, not the respawn marker. The mission file can be inspected as text; placements and integration have not been verified in-game. `onFlare.sqs` forwards the engine event to `lmf_ai_fnc_onFlare`.

## Module contracts

### AI init, spawning and garrison

**Files:** `framework/objectSorting/`, `framework/ai/fn_initUnit.sqf`, `framework/ai/fn_initGroundVehicle.sqf`, `framework/ai/fn_initAirVehicle.sqf`, `framework/ai/fn_initWaterVehicle.sqf`, `framework/ai/fn_buildWeaponLoadout.sqf`, `framework/ai/fn_manageNvg.sqf`, `framework/ai/eventHandlers/`, `framework/ai/spawning/`.

- Init continues only for a local unit/vehicle. Classname lookups in the AI registry select role/gear; soldier loadout is built as a Unit Loadout Array and applied together. Attachment/magazine lookups are cached. The hit reaction has a local per-unit cooldown.
- The NVG manager processes existing enemy AI at startup and then at day/night transitions; new AI receives nighttime NVGs in the initial loadout.
- `framework/ai/spawning/spawnDefinitions.sqf` is an include with vehicles/roles, group compositions and private `_typeMaker`. `spawning/` owns group creation; `tasks/` owns registered `task*` entrypoints.
- `lmf_ai_fnc_getPlayerProximityState` is used by infantry QRF/hunters, vehicle QRF and para QRF, not patrol/garrison. It evaluates actual players through the player's vehicle; a nearby grounded player takes priority over a nearby airborne player. The airborne wait accepts `airDistance` or `groundClose`, with the existing 5/10-second checks and no cache between checks.
- Vehicle QRF passes the crew classname as the fifth argument to `BIS_fnc_spawnCrew`: CARARMED/RIFLEMAN, APC/TANK/CREW, HELITRANSPORT/HELIATTACK/PILOT. UAV uses separate `createVehicleCrew`.
- `spawnParadropQrf` is scheduled/server-restricted, owns aircraft/payload/tickets/follow-up and delegates unit/object drops to paradrop. The drop zone is a marker, trigger or location; the only supported array is `[0,0,0]` for autonomous mode. Autonomous mode reads the spawn object's direction before position conversion; an array spawn gets a random direction. A fixed drop zone determines the direction toward the zone. ZEN may broadcast the call; `isSpawner` restricts execution.

**Garrison design and implementation:** Initial stance uses `insideBuilding > 0`; event selection uses `== 1`, with `lmf_ai_fnc_hasOverheadCover` as fallback. The overhead-cover test runs five meters from the eyes, VIEW/FIRE and then FIRE/NONE on a miss; treetops can also count as cover. Initially, standing/kneeling is selected 50/50 under cover and kneeling/prone outside. Event selection under cover gives 50 % standing, 25 % at no more than half the original strength, or 15 % at suppression >= 0.5; otherwise kneeling. Unknown suppression does not change the loss-based choice.

FiredNear applies to non-leaders on foot, with an individual 6–15-second cooldown checked at the event; the first event can trigger a reaction immediately. Outdoor stance selection occurs only on the first FiredNear. EnemyDetected has no such cooldown and gives prone double weight outside. Each hostile FiredNear within 15 meters of the firing position has a separate 5 % chance of movement, independent of cooldown; friendly shots can affect stance, but not this movement. Silence produces no periodic exposure.

`lmf_ai_fnc_clearGarrisonStance` removes FiredNear/stance binding on movement, death, surrender, reassignment and new tasking. Released defenders do not receive new EnemyDetected stances. FiredNear also cleans up on observed external PATH, group, vehicle, locality or captive changes. Pending surrender stops reactions; completed surrender is not automatically reversed.

With group losses, one–two survivors and no support around the killed unit, the shared surrender chance is 25 %. Each candidate must have a living non-captive enemy within 30 meters horizontally both before and after a random wait. Soldiers in vehicles are included; side relations are used without requiring detection/visibility. A rejected candidate does not release group status while others are waiting/have surrendered. Lone survivors without surrender go to group management.

**Unresolved:** Garrison reactions have been statically checked, not parser-verified or verified in-game. State is server-local; HC transfer/hot-reload is not supported. Dynamic Simulation distance is 1250 meters and garrison groups are registered, but the global Eden toggle and other flagged groups must be inspected in Eden.

Sources: [Event Handlers](https://community.bohemia.net/wiki/Arma_3%3A_Event_Handlers), [insideBuilding](https://community.bohemia.net/wiki/insideBuilding), [lineIntersectsSurfaces](https://community.bohemia.net/wiki/lineIntersectsSurfaces), [getSuppression](https://community.bohemia.net/wiki/getSuppression), [nearEntities](https://community.bohemia.net/wiki/nearEntities), [BIS_fnc_sideIsEnemy](https://community.bohemia.net/wiki/BIS_fnc_sideIsEnemy), [Dynamic Simulation](https://community.bohemia.net/wiki/Arma_3_Dynamic_Simulation).

### AI groups, hunters and boats

**Files:** `framework/ai/groups/`, `framework/ai/tasks/fn_taskHunt.sqf`, `framework/ai/tasks/fn_taskConverge.sqf`, `framework/ai/tasks/fn_taskPatrol.sqf`, `framework/ai/boats/`.

`assignCallsign` is server-authoritative, with a local counter per reserved LMF prefix and `setGroupIdGlobal`. An invalid group, empty prefix or non-server call returns an empty string. Names are sequential within the helper; manually named groups are not checked for collisions. Lone supported LMF survivors are ungarrisoned and join the nearest eligible group, otherwise GUARD. `taskConverge` requires a local group; `taskPatrol` selects water positions when the leader is in a Ship.

**Hunters:** `taskHunt` starts scheduled with `spawn`, searches every 30 seconds for the nearest actual non-civilian player whose vehicle is touching the ground within the leader's radius, and issues movement orders. No LAMBS taskRush or rush EHs are used. Spawn protection is 500 meters. The loop requires more than one living soldier. The spawner stores local `lmf_ai_huntScript` and the UnitKilled handler together unscheduled; with at most one survivor, hunting is terminated before reassignment/GUARD, LAMBS disabling is removed and old movement is replaced. A group change is followed by doFollow; hunter groups are not themselves join recipients. No special treatment for single-soldier spawns.

A boat hunter with a target reserves a landing before `landBoatGroup`; hunt orders/GUARD are withheld during landing. After the flag is released and the leader is on foot, landing waypoints are deleted once at the next hunt update, even without a target. Without a target, doMove is issued to the soldiers' own positions; GUARD is not restored after disembarkation. Groups that have not landed retain the GUARD fallback. A failed shoreline search can be retried; a stuck landing has no new timeout.

**Boat flow:** `spawnBoatForGroup` is used by patrol, infantry QRF and hunters for water spawns and calls `initBoatAssault`. Landing from EnemyDetected, converge and hunt reserves `lmf_taskConverge_active` locally before calling the helper. Checking/reservation happens together unscheduled; direct calls to internal `landBoatGroup` must be reserved by the caller. The flag is held through random disembarkation delays until no living group members remain in the boat or the boat is deleted. A deleted group exits without writing state; a failed shoreline search releases the flag and assigns GUARD at the boat.

`findShorelinePosition` searches from 500 meters around the target, doubles up to the caller's limit and uses the first match as the center of an independent 500-meter dispersion search. If dispersion fails, the first match is used; if there is no first match, `[]` is returned. Dispersion can extend beyond the caller's radius. The result is shifted 10 meters toward the boat, height 0. The search does not guarantee the nearest shore, a continuous coastline, a land connection or a navigable approach; boats do not share reservations/landing sites.

`initBoatAssault` also has a five-second local GUARD check: ground contact and absolute speed below 20 km/h trigger reserved `dismountBoatGroup` without a new shoreline search/waypoint change. Other waypoint types and floating boats are not covered. The check ends on triggering, no survivors in the original boat, a destroyed/deleted boat/group or lost locality. Shared disembarkation retains leaveVehicle, AWARE, random delay and smoke. QRF retains GUARD; hunt clears its own landing waypoints.

**Observation/unresolved:** The earlier boat hunter landed, but produced distant locations and lingering GUARD. The current shoreline search/GUARD fix and autonomous disembarkation have not been verified in-game; multiple boats, the last survivor and dedicated/JIP remain unresolved. Support for ownership changes during landing has not been established.

Sources: [terminate](https://community.bohemia.net/wiki/terminate), [isNil](https://community.bohemia.net/wiki/isNil), [BIS_fnc_findSafePos](https://community.bohemia.net/wiki/BIS_fnc_findSafePos), [isTouchingGround](https://community.bohemia.net/wiki/isTouchingGround), [CBA waiting](https://github.com/CBATeam/CBA_A3/blob/master/addons/common/fnc_waitUntilAndExecute.sqf).

### Helicopter transport

**File:** `framework/ai/spawning/fn_spawnVehicleQrf.sqf`, with group/converge helpers. **Design:** Crewed transport continues the insertion attempt; a failed LZ search must never send passengers into retreat.

- The normal route is TR UNLOAD at a dynamic `Land_HelipadEmpty_F`, then MOVE 25 km away with CARELESS/BLUE; the infantry receives GUARD. GETOUT/synchronization/activation for the infantry is commented out. Do not reintroduce this without assessment. Cargo is assigned before moveInCargo; normal insertion has no scripted/forced unloading.
- The scheduled LZ search ranks open areas within 500 meters, without a specific terrain penalty. The candidate is checked against the helicopter type and requires 150–500 meters from the target, land, object clearance and gradient requirements. On a miss, the search repeats after five seconds with no attempt limit/radius expansion. TR UNLOAD → MOVE is built together unscheduled after an LZ is accepted. The helipad is used as a positional reference, not waypointAttachObject.
- The pilot group stores cargo in `lmf_heliTransport_cargo`. `lmf_heliTransport_active` protects pilot waypoints from converge; the infantry's `lmf_heliTransport_vehicle` protects the group while survivors are aboard. The infantry is joinable, but does not receive survivors until the leader is on foot. No special priority for the pilots and no reinstated infantry UnitKilled join handler/light setup.
- Five-second cleanup requires no players within 5 km and no living registered passengers aboard before heli/crew are deleted. An LZ miss does not delete passengers. The helipad is removed on cleanup or a dead/non-local heli. Tickets count original crew even after group changes.
- A server sequence every 10 seconds evacuates a local, immobilized transport with ground contact and 3D speed below 1 m/s, or when all living crew have left it. `lmf_heliTransport_abandoned` aborts the LZ search; crew retain the tasking lock during disembarkation. EHs/waypoints are removed once, AWARE/RED is set and leaveVehicle/unassignVehicle/doGetOut are used without moveOut or repeated orders. Passengers receive exit orders only on the ground at low speed and retain/receive GUARD.
- When all living crew are out, the lock is released and a group search runs once: another living joinable group on `var_enemySide`, leader within 1500 meters and not over water; the transport infantry's leader must be on foot. Crew join the nearest candidate together, otherwise GUARD. No locality takeover.
- The same sequence has a hovering workaround. Two qualifying samples refresh the active TR UNLOAD at the same position. Requirements: active/not evacuated, local living pilot/heli, canMove, pilot WAIT, airborne above 10 m ATL, speed below 1 m/s and landAt mode None/empty. The flag resets after intervention or a condition ceases to hold; persistent cases can be refreshed every 20 seconds.

**Observation:** RPT showed TR UNLOAD/pilot WAIT; manually refreshing the waypoint produced movement. User testing showed better evacuation/crew joining. This does not establish the cause of hovering or completed insertion.

**Unresolved:** The transport is under testing. The automatic workaround, join eligibility and LZ quality have only been statically checked; combined dedicated/JIP testing remains. No guarantee of a suitable LZ, collision-free landing or completion. `canMove` is not a rotor sensor and includes lack of fuel; an overturned helicopter with canMove true is not evacuated. Ground contact varies with the surface. Unconscious/stuck occupants may remain without forced unloading; no new order is issued if crew fail to exit. BIKI's synchronized TR UNLOAD/GETOUT recipe is not this working copy's unsynchronized variant.

Sources: [Waypoints](https://community.bohemia.net/wiki/Waypoints), [selectBestPlaces](https://community.bohemia.net/wiki/selectBestPlaces), [findEmptyPosition](https://community.bohemia.net/wiki/findEmptyPosition), [isFlatEmpty](https://community.bohemia.net/wiki/isFlatEmpty), [canMove](https://community.bohemia.net/wiki/canMove), [getUnitState](https://community.bohemia.net/wiki/getUnitState), [landAt](https://community.bohemia.net/wiki/landAt), [setWaypointPosition](https://community.bohemia.net/wiki/setWaypointPosition).

### Paradrop and Forward Deploy

**Files:** `framework/paradrop/`, `framework/forwardDeploy/initForwardDeploy.sqf`, `framework/forwardDeploy/fn_deployUnitsAndAssets.sqf`.

**Design:** `lmf_paradrop_fnc_paradropPassengers` is the mission entrypoint for an existing AI-controlled, server-local plane/helicopter. Players are supported as passengers; a player pilot is not the intended contract. The aircraft must be local; callsign/BFT requires the current server setup.

The drop zone can be a marker/trigger. The call instance's height is embedded in the waypoint statement. Cargo/FFV units and other occupants outside the pilot's crew group are dropped; flight crew remain. AI spawners pass their own unit lists directly to the helper and do not use this seat selection. The flight sequence owns approach, drop and return; local cleanup has one 3-second CBA PFH per sequence with the existing 5000-meter conditions, separate from disembarkation/return monitoring.

`dropUnit`, `dropUnitLocal`, `dropObject` and `fireCountermeasures` are internal helpers. Remote payloads are routed to object targets without persistent replay. The player profile has a steerable parachute, red chemlight and prone stance after exiting. EJECT players are protected from damage from before ejection until two seconds after detected parachute exit, then allowDamage true without a ground check. This also protects against ordinary damage during descent, but does not remove damage/bouncing. EJECT AI has damage enabled as soon as it is in a parachute; POSITION/BACKPACK have different flows. Para QRF uses an ACE non-steerable backpack and restores backpack/items.

`dropObject` handles objects placed in the air itself; ACE_CARGO delegates release to internal `ace_cargo_fnc_paradropItem`, then orientation/speed/landing/cleanup. ACE_CARGO sets `allowDamage false` on the object's owner before the two monitoring scripts are started, regardless of the immediate damage-reset option. By default, the landing script restores damage one second after detachment and either ground contact or getPos height below 0.5 meters. allowDamage is routed to the current owner if needed. The optional sixth ACE_CARGO data value, manage landing, defaults to true; Supply Drop passes false and owns damage restoration and attached-object cleanup in its common landing sequence. The helper still releases the parachute near the surface. Deleted payloads terminate the landing/release wait. The stuck-in-tree script checks height every five seconds, waits 15 seconds after going below 25 meters and detaches the parachute if the load is still above the caller's height threshold; the damage resets are retained. This assumes unchanged locality during the drop; the sequence is not replayed for JIP. **Dependency caveat:** The ACE source marks the function Public: No. Supply Drop was previously reported working, but this is no guarantee across mod versions.

Forward Deploy owns the server registry/decision; the client's menu is registered only during warmup. Deployment events hide the unit-bound menu and remove vehicle actions. Ground deploy uses existing placement/locality routing; air deploy owns formation/height and delegates payloads to paradrop. JIP after warmup does not receive the option. **Unresolved:** Direct array input/weapon selection for players and EJECT landing margin/damage reactivation require in-game verification; there is no new dedicated/JIP validation.

Sources: [fullCrew](https://community.bohemia.net/wiki/fullCrew), [allowDamage](https://community.bohemia.net/wiki/allowDamage), [ACE Cargo source](https://github.com/acemod/ACE3/blob/master/addons/cargo/functions/fnc_paradropItem.sqf), and the common locality/remoteExec references.

### Supply Drop

**Menu and map selection:** Supply Drop is a top-level ACE self-action with Supplies and optional Vehicles submenus. Local `lmf_supplyDrop_selecting` reserves selection across the confirmation dialog. Only the first click is accepted; map closure cancels even after a quick reopening. Death/unit replacement cancels, and handlers/position/lock are cleared. An already open map is kept open; a map opened by the service is closed. Supply Drop retries position selection after CANCEL and retains the attempt marker for ten seconds after a request is sent. The server decides quota/cooldown.

**Files:** `framework/supplyDrop/initSupplyDrop.sqf`, `framework/supplyDrop/selectDropPosition.sqf`, `framework/supplyDrop/fn_deliverSupplies.sqf`. Also read the payload/ACE contract under Paradrop.

- The inherited CAManBase self-action reads client availability directly; its statement uses ACE's current `_player` argument for map/radio checks and the selection requester. Client-local `lmf_supplyDrop_menuAvailable` is initialized from replicated quota and updated by the existing availability event; death/respawn does not reset it. Each active map-selection attempt remains bound to its requester and cancels on death/replacement. A CBA server event submits the request; the server reserves quota and a shared 30-second cooldown before scheduled delivery. Rejection does not deduct quota or extend the deadline. The client checks `lmf_supplyDrop_nextRequest` before map selection and at confirmation; the server checks again. The confirmation sound plays only after server acceptance.
- `lmf_remainingSuppDrops` and the deadline are published. JIP registers hidden actions when the remaining quota is empty. Starting with a configured quota of 0 does not start the Supply Drop module.
- The delivery receives the server's ATLAS-N; with BFT, the group is registered with the same name/aircraft icon. Parachute delivery uses a server-side landing sequence independent of aircraft return. Once detached from the parachute, ground contact or getPos height below 0.5 meters is accepted; after one second, damage is restored on the payload owner. A deleted payload exits without a marker. With var_bft enabled and var_oldSchoolMap disabled, the server creates one global marker at the landing position, retaining the crate/car/boat icon, ColorWEST and 0.75 size. The marker remains if the payload moves or is deleted. Engine marker replication supplies JIP; no payload tracking or persistent remote execution is used for this marker. BFT and old-school map code are unchanged.
- `var_suppDropPlane` selects the aircraft classname. Planes and helicopters use the same parachute delivery flow, with no separate flight handling. Direct four-argument calls/Zeus bypass the request quota.

**Delivery:** Planes and helicopters use MOVE at the drop point (25-meter completion radius), then MOVE five km ahead. Within 50 meters horizontally, waypoints are cleared and doMove is issued five km ahead before dropObject. Desired flight height is selected once, 125–225 meters, and retained through return; no height condition on release. All configured aircraft are limited to 250 on approach and 100 within one km. The return limit is 999. FLY spawn is raised relatively with modelToWorld, not explicitly ATL. Payload, flare and cleanup are owned by the delivery; passenger logic from paradrop is not used. A living transport that never reaches the drop zone waits without timeout; death also breaks the wait and is not delivery confirmation.

**Observation/unresolved:** Local tests reported that I_supplyCrate_F remained protected because isTouchingGround returned false on the ground; its getPos height was approximately zero. A grounded vehicle returned true for ground contact; a floating boat returned false with a getPos height around -0.17 meters. These observations support the combined predicate for the tested classes. The single parachute delivery flow, damage restoration and fixed markers have only been statically checked; runtime verification with planes and helicopters, dedicated clients and JIP remains outstanding.

Sources: [getPos](https://community.bohemia.net/wiki/getPos), [createMarker](https://community.bohemia.net/wiki/createMarker), [allowDamage](https://community.bohemia.net/wiki/allowDamage), [remoteExec](https://community.bohemia.net/wiki/remoteExec), [flyInHeight](https://community.bohemia.net/wiki/flyInHeight), [limitSpeed](https://community.bohemia.net/wiki/limitSpeed), [CBA clearWaypoints](https://cbateam.github.io/CBA_A3/docs/files/ai/fnc_clearWaypoints-sqf.html), [Waypoints](https://community.bohemia.net/wiki/Waypoints). Some earlier locality lookups were missing; server-owned transport/payload is the implementation assumption, not MP test evidence.

### BFT and map

**Files:** `framework/bft/initGroupState.sqf`, `framework/bft/initGroupTracking.sqf`, `framework/bft/initUnitTracking.sqf`, `framework/bft/fn_trackObject.sqf`, `framework/map/configureMap.sqf`.

**Design:** The hover display's three fields and full member list are retained without an additional alive filter; BFT must not confirm casualties. State belongs to the group, and new groups do not inherit old selections. Old-school map hides new markers from other machines, including script markers; this must not be restricted to user markers.

**Groups:** PreInit defines helpers/server events. `lmf_bft_fnc_setCallsign` takes `[gruppe, standardikon, callsign]`; `setIcon` changes only the override. The server validates the leader and updates together unscheduled. Public `lmf_bft_state = [callsign, standardikon, overstyring]` is the client's only basis; an empty override uses the default, missing/`[]` means not registered. No separate state event, client copy or revision. The client reads on map opening and at 1 Hz with the map open; movement is drawn from render positions. Repeated selection does not republish, but produces a response; server calls without a requester produce no feedback.

The callsign is checked against state and groupId of other groups on the same side with members. **Clarified after dedicated-server observation:** Empty groups do not block it. When taking over the name, a conflicting empty group is renamed to an available LMF EMPTY N and its BFT state is reset publicly. No group is deleted; later members must choose a name. setGroupIdGlobal runs directly in the same server processing without CBA's next-frame deferral. External name setters/Eden are the mission maker's responsibility.

`var_bftInfantry`, `var_bftGroundVehicles`, `var_bftAirVehicles` build Infantry/Vehicles/Air. Infantry gets /6, /1–4, /1V–4V; the others get 1–4. Default icons are b_inf, b_motor_inf, b_armor and b_air; HQ is manual. The Icon menu exists for leaders before a callsign, but rejects selection without a name. A manual icon is retained on name change; Reset icon removes only the override. An empty list hides a category; all empty hides selection, not tracking. Actions are inherited class actions without automatic state reset on JIP/respawn. An ordinary left click anywhere ends follow; Ctrl-click on a group icon starts/switches it.

**Objects:** `trackObject` from the server distributes object-bound persistent startup with a shared end time; direct client calls are local. ItemMap must be assigned. One client list/maintenance PFH and Draw per map control draw with render position/direction. The interval argument controls maintenance/cleanup, minimum 0.1 seconds, not movement updates. Open display/IGUI maps are detected at registration/map opening and every second while tracking exists. A new call replaces the same object's entry. Shadow is a simple outline/text shadow, not identical to native marker shadow.

**Unresolved:** Concurrent selections, empty-group names/JIP, other mod maps and representative performance have not been fully verified in-game. A new mission start is assumed; hot-reload of old EHs is not supported.

Sources: [setGroupIdGlobal](https://community.bohemia.net/wiki/setGroupIdGlobal), [CBA setCallsign](https://github.com/CBATeam/CBA_A3/blob/master/addons/common/fnc_setCallsign.sqf), [ACE interaction framework](https://ace3.acemod.org/wiki/framework/interactionmenu-framework), [drawIcon](https://community.bohemia.net/wiki/drawIcon), and the common state/JIP references.

### Player setup, asset spawners and service

**Files:** `framework/equipment/`, `framework/equipment/roles/`, `framework/playerVehicles/`, `framework/supplyCrates/`, `framework/assetSpawner/`, `framework/vehicleService/fn_serviceVehicle.sqf`.

Gear/role functions require a local unit, use cfg_Player and publish `lmf_currentRole`. Role overrides must follow `applyBaseLoadout`: pilot/helipilot sets onMapSingleClick after the base value; medic sets the trait after the base reset. Role functions, role selection and personal arsenal belong to equipment; objectSorting routes vehicles/crates to their systems.

Personal arsenal offers the starting class's configured headgear and glasses during warmup. The role value `[""]` inherits Rifleman as in `applyBaseLoadout`, including for crew/pilots; the AT assistant uses its own `_ata*` settings. The selection is built once and does not update on later role changes through the role crate. Available Optics uses local `lmf_player_availableOptics`; dedicated crew/pilot roles exit before the optics setup. Arsenal/optics are under Equipment, initialized after the intro signal.

Spawner actions are client-local on Eden objects. `spawnObjectAtPad` runs on the requesting client, checks the area and creates the object there; this differs from server AI/support spawning. The delete action is distributed with object-bound JIP. Role/spawner markers are included in the server's marker sequence; textures in client postInit.

Vehicle service has an initial 0.25-second wait check only when time <= 30 at the call; later calls do not get this pause. **Unresolved:** RRR with driver/gunner on different clients and ownership changes during service have not been resolved in-game; do not generalize this to failure of the entire module.

### Warmup, Mission Info and JIP teleport

**Files:** `framework/warmup/runIntroAndWarmup.sqf`, `framework/warmup/manageTimeAndWeather.sqf`, `framework/warmup/monitorWarmupDeadline.sqf`, `framework/missionInfo/showStartupInfo.sqf`, `framework/jipTeleport/initJipTeleport.sqf`, `framework/jipTeleport/fn_selectTeleportTarget.sqf`, `framework/jipTeleport/fn_hasEmptySeat.sqf`. Read the startup chain before changing intro/menus.

**Warmup:** The server initializes state and stores/restores date/weather; setDate is distributed to everyone on reset. `var_maxWarmupTime` is interpreted as a numeric MM:SS deadline in CBA_missionTime, not a duration from client login. An empty value disables the deadline. The server uses >=, so a skipped second does not miss termination. The panel counts up from mission start; with a deadline, Ends at is shown and color follows the remaining 300/180/60 seconds. Without a deadline, colors follow elapsed 600/900/1200 seconds. Two colon-separated parts are checked, but this is not full numeric validation. JIP does not restart the timer. `lmf_admin_fnc_setPlayerSafety` is used by warmup; no separate administrative Safety On/Off or collective admin teleport exists.

**Mission Info:** Starts once from the intro after the intro signal, including JIP/disabled warmup. Waits for arsenal/menu handles, starts BLACK IN with parameter 5 just before any local BIS_fnc_guiMessage and keeps the intro unit without simulation until the info script ends. No additional five-second wait. Death/empty content omits the message, but should still provide fade-in/release. Damage/weapons/camo are not changed by release. Warmup safety/panel does not wait for the dialog.

Content is built once: arsenal/optics during warmup, configured BFT selection, Forward Deploy during warmup, an active JIP option and enabled Supply Drop. Supply Drop requires positive replicated quota and mentions vehicles only when vehicle drops are enabled/configured. BFT/Forward Deploy explain leader controls to everyone. No reopening menu, respawn hook or ongoing update; information may become outdated while open. LMF_LOGO is defined, but not used here.

**JIP teleport:** Starts only with var_jipTp and didJIP. The option allows one successful teleport within five minutes of initialization, bound to the original unit and local `lmf_jipStartPos`. It expires permanently on deadline, death, unit/locality change or moving over 200 meters from the start, including Zeus teleport. A short-lived CBA wait monitors the option independently of the menu. Respawn/return to spawn does not renew it. Other new arrivals at spawn do not block its creation.

The target is the highest-ranking living non-virtual friendly player outside the start area with an available vehicle seat or a suitable ground position at a slow-moving target on land. The seat helper rejects null/dead vehicles, soldiers and parachutes. Movement happens on the player's owner; failure retains the option only within the original conditions and restores the previous damage state.

**Unresolved:** Dialog layout/UI scale and the startup/JIP chain have not been verified as a whole in-game. JIP controls and competition for the last seat remain to be tested on dedicated. Blocking by the menu wait is described in the common section.

Sources: [BIS_fnc_guiMessage](https://community.bohemia.net/wiki/BIS_fnc_guiMessage), [scriptDone](https://community.bohemia.net/wiki/scriptDone), [didJIP](https://community.bohemia.net/wiki/didJIP), [setDate](https://community.bohemia.net/wiki/setDate), [moveInAny](https://community.bohemia.net/wiki/moveInAny).

### Respawn, spectator, medical and hit effects

**Files:** `framework/respawn/fn_onKilled.sqf`, `framework/respawn/fn_onRespawn.sqf`, `framework/spectator/initSpectatorEvents.sqf`, `framework/spectator/fn_showMedicalInfo.sqf`, `framework/medical/initTreatmentFeedback.sqf`, `framework/medical/initUnconsciousEvent.sqf`, `framework/hitEffects/fn_onHit.sqf`.

The killed handler rejects an outdated player unit before/after delayed spectator startup, so a fast respawn does not reopen spectator. Respawn restores gear, channels, weapon safety, spectator state and camo without full player init. Only the text value TICKETS is tested in the respawn handler; a numeric respawn time skips the ticket message. The quota is initialized from settings and deducted locally on killed. **Design clarification missing:** A persistent quota per UID across reconnects does not exist; per login or per mission must be clarified before changing it.

The ACE Spectator display is stored/cleared on load/unload. The medical display is display-bound, detects target/alive at 20 Hz, reads medical state at 4 Hz and updates only changed display content. Treatment feedback uses ace_treatmentStarted and a local recipient cooldown without published unit state. The entire unconsciousness handler, including the AI branch, is in medical.

Player hit starts scheduled from Hit; qualification/reservation of `lmf_player_isGettingHit` happens together in isNil to prevent parallel sequences. The effect/release itself is scheduled.

**Observation/unresolved:** Moving the ticket message after weapon safety/the five-second fade-in wait resolved a missing message in the mission maker's local test. Type checking, death/respawn display and dedicated/JIP have not been verified as a whole.

### UI, briefing and group notifications

**Files:** `framework/colors.hpp`, `framework/notifications/fn_showAceMessage.sqf`, `framework/notifications/defineNotificationFunctions.sqf`, `framework/notifications/CfgNotifications.hpp`, `framework/briefing/createBriefing.sqf`, `framework/groupNotifications/initGroupNotifications.sqf`.

**Palette:** colors.hpp owns the shared blue/orange/green/gray/red/white. PreInit sets SQF constants locally; notifications config includes the same header. HEX/RGBA must be kept synchronized. Team/map colors, medical scale, warmup steps, panel alpha and effects are module-specific. No network synchronization/settings for the palette.

**ACE feedback:** `lmf_notifications_fnc_showAceMessage` is local and exits without an interface/valid player. The caller owns content, timing and recipient selection. Contract: `[title, text, icon, height, width, sound, iconSize, isError]`; the last is optional and changes only the body text's base color. An empty icon/title omits the associated line break. Height/width are box dimensions, not duration. No queue or JIP replay; ACE messages can replace each other. `showRoleChangeMessage` has one argument and delegates display.

The design is a blue icon/heading, white body text, red error reason and optional white guidance. Error color/sound are independent. Rejection uses addItemFailed, confirmation beep, map instructions taskUpdated and radio TacticalPing4; passive negative messages are silent/red. Complete sentences are separated with br without a trailing break; deliberate value/name lines are retained. BFT reselection is silent with a green value; loadout/group arrival is silent. The ticket message shows the remaining count on its own line and has no explicit five-second clearing. The JIP reminder, Mission Info, warmup, medical and BFT hover/follow have their own displays.

**Briefing:** `_thanks` in cfg_Briefing is `[navn, forklaring]` pairs; an empty explanation omits the hyphen, an empty list does not hide Thanks. People are in settings, not hardcoded in the framework. Technical Info explains the same five static Safe Start fields: Map Access, Map Mode, Blue Force Tracker, Personal Radio and Respawn. Built at briefing/JIP; not an ongoing ticket overview.

**Group notifications:** Synchronous client init with a duplicate-start guard registers the receiver immediately and enables the sender after the intro signal. Normal startup stores the group silently; the first JIP arrival is announced once. The CBA player event `group` follows membership changes; the last locally processed group is retained through respawn. A null group is ignored, the same respawn group produces no new notification, a new group and returning after a registered change are announced. Zeus remote control of other units is ignored. No separate polling/server registry; very brief changes between CBA observations may be missed.

The sender targets a non-persistent CBA event at the current player leader; AI leaders/self-notification are omitted. The receiver checks that it is still the leader/in the group and displays silent name + joined your group without a heading. No queue/history/rerouting; a leader change during delivery may lose the message, concurrent ACE messages may replace it.

**Unresolved:** Group/leader ownership changes, actual JIP delivery and UI scale have not been verified on dedicated. Sources: [ACE displayTextStructured](https://github.com/acemod/ACE3/blob/master/addons/common/functions/fnc_displayTextStructured.sqf), [CBA player EH](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/fnc_addPlayerEventHandler.sqf), [CBA playerEvent](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/fnc_playerEvent.sqf), [CBA targetEvent](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/fnc_targetEvent.sqf).

### Admin, chat and radio

**Files:** `framework/admin/checkAdminAccess.sqf`, `framework/admin/createAdminDiary.sqf`, `framework/chat/registerCommands.sqf`, `framework/chat/fn_bringIntoVehicle.sqf`, `framework/chat/fn_sendChatMessage.sqf`, `framework/radio/`.

**Agreed design:** The fixed UIDs for Alex2k, nkenny and Liquid Tracer are intentional Nopryl configuration for persistent technical/admin access, regardless of who is logged in as server admin. The identities are retained in both `framework/XEH_preInit.sqf` and `description.ext`: the lists serve LMF access and debug console access respectively. They are not scenario leftovers or obsolete defaults and must not be removed, consolidated or changed as part of repository preparation.

PreInit defines local `lmf_admin_uids` for these three. They receive LMF access without admin login; voted/logged-in server admins (> 0) and the local SP/host player are supported. The server looks up the UID on the supplied unit; the client requires its own player. The network status requirement applies only to MP. Zeus is assigned only when Zeus access is selected. `description.ext` has a separate enableDebugConsole list maintained independently.

Chat selects CBA level all only on a fixed admin's own client, otherwise admin with CBA's login/logout check. heal/goto/bring/respawn have only this local authorization; start/victory/defeat/respawnwave/performance delegate to the LMF admin layer's own checks. `/w` and `/zeus` use a non-persistent global CBA event, with a receiver only on interface machines. ACRE channel names are initialized on all machines; `lmf_radio_fnc_hasLongRangeRadio` is used from server and client.

`#bring` on foot teleports as before. From a vehicle, the helper targets the target player's client with remoteExecCall. The same living admin vehicle is required; only an ordinary cargo seat is selected, not driver/turret/FFV. A full vehicle is rejected before movement; someone already aboard remains seated. Other clients' concurrent seat use is not reserved. The respawn-wave dialog uses the active ACE Spectator display as parent; the player selection is retrieved only on OK before a 30-second respawn time is sent. Cancel sends nothing.

**Unresolved:** Admin functions check the supplied unit, but its relationship to any remote sender has not been security-verified. The effective remote-exec policy/server/mod setup determines actual exposure. Access without login, login/logout, respawn/JIP and bring seat competition have not been verified in-game.

Sources: [enableDebugConsole](https://community.bohemia.net/wiki/Description.ext#enableDebugConsole), [CBA chat handler](https://github.com/CBATeam/CBA_A3/blob/master/addons/events/XEH_postInit.sqf), [fullCrew](https://community.bohemia.net/wiki/fullCrew), [remoteExecCall](https://community.bohemia.net/wiki/remoteExecCall).

### Fire support

**File:** `framework/ai/fireSupport/fn_fireSupportAtTarget.sqf`. Scheduled/server-restricted, for server-local AI with MK41 VLS or an artillery computer. The fourth argument `_playerRequested` defaults to false; only player-requested strikes notify existing LRR recipients and receive VLS BFT. The development mission now contains no designator or autonomous init call to the function. Player-controlled/remote turrets and ownership changes have not been established as supported.

The busy lock is acquired together in isNil; battery/target are validated again after preparation. Public `lmf_artilleryBusy` provides client/JIP availability; server-local `lmf_fireSupportState` stores filter/count/times and is removed with the Fired handler before cooldown. Artillery selects a magazine dynamically and counts only the selected magazine; VLS filters weapon_VLS_01 and its associated magazines.

Artillery is released ten seconds after the last shot of a full or observed-ended partial salvo; VLS 60 seconds after the first confirmed launch. Preparation is additional; flight time does not extend the lock. VLS has a separate Splash observer, maximum 300 seconds, without access to the lock. Splash only means the projectile is gone/not alive, not a confirmed hit. Artillery has no flight tracking/Splash.

Shot/Missile away/Round away occurs on the first shot; multi-round artillery gets the actual count in Rounds complete. Battery standing by occurs on release only for a living/local battery. Launch failure releases as soon as the failure is confirmed. Time limits are eight seconds for VLS, 30 for artillery and `30 max (_rounds * 15)` for the salvo. Timeout means missing confirmation, does not cancel engine orders and does not automatically send the remaining salvo. Messages are not replayed; VLS object tracking has JIP.

**Unresolved:** Late firing after timeout, unitReady with a partial salvo, concurrent requests, filter/cooldown/message order and VLS BFT/JIP have not been verified in-game. The earlier BIKI fireAtTarget page lacked locality/effect labels; a server-local implementation alone is not runtime evidence.

Sources: [fireAtTarget](https://community.bohemia.net/wiki/fireAtTarget), [doArtilleryFire](https://community.bohemia.net/wiki/doArtilleryFire), [unitReady](https://community.bohemia.net/wiki/unitReady), [Fired](https://community.bohemia.net/wiki/Arma_3:_Event_Handlers#Fired).
