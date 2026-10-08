# LMF · Mission Maker Reference

The canonical practical mission-maker reference for mission scripts and triggers using the LMF 2.0.0 system-based names. Code and settings paths are relative to the mission root. See [architecture.md](architecture.md) for technical context and [development.md](development.md) for development conventions.





## Mission settings

Edit `settings/cfg_Mission.sqf` before starting the mission. It is loaded locally on every machine during preInit; it is not a server-synchronized runtime settings interface. Player loadout details belong in `settings/cfg_Player.sqf`, AI classes and gear in `settings/cfg_AI.hpp`, and briefing content in `settings/cfg_Briefing.sqf`.

### Mission info and enemy side

- `lmf_missionTitle` and `lmf_missionSubtitle` supply the intro/title text; `""` omits the intro subtitle. `lmf_author` supplies the briefing credit.
- `lmf_enemySide` selects the side used by LMF enemy AI initialization, spawning and tasks: `WEST`, `EAST` or `INDEPENDENT`.

### Warmup and respawn

- `lmf_warmup` enables warmup. `lmf_maxWarmupTime` is a mission-time deadline as `"MM:SS"` (for example `"15:00"`), not a timer restarted for JIP. `""` disables automatic termination; admins can still end warmup.
- `lmf_respawnType`: `"OFF"` disables normal automatic respawn; `"WAVE"` uses recurring mission-time intervals; `"TICKETS"` uses the same intervals with a per-player allowance. A number sets a delay in seconds. Other strings are display text only and suppress normal automatic respawn; they do not implement a custom mode. The death handler enforces a minimum delay of 10 seconds.
- `lmf_respawnTime` is the interval in seconds for `"WAVE"` and `"TICKETS"`; use a positive value. `lmf_respawnTickets` is the initial per-player allowance for `"TICKETS"`, deducted on death; `0` allows no further automatic respawns. Tickets are client-session state, not a persistent quota across reconnects.

### Player gear and equipment

- `lmf_playerGear` applies the configured LMF loadouts. With `false`, starting Eden equipment is retained and its startup snapshot is restored on respawn. With custom gear enabled, `lmf_keepRole = true` restores the original slot role on respawn; `false` gives Rifleman.
- `lmf_personalArsenal` enables warmup headgear/glasses selection and Available Optics; it requires both `lmf_playerGear` and `lmf_warmup`. Crew and pilot roles do not receive Available Optics.
- `lmf_personalRadio` gives everyone the configured personal radio (AN/PRC-343 in the current player settings). `lmf_pistolAll` gives everyone a sidearm; disabling it retains role-specific sidearms. `lmf_riflemanLat` gives Rifleman the configured light anti-tank weapon. These gear switches require `lmf_playerGear`.
- `lmf_playerMaps` and `lmf_playerGps`: `0` = everyone, `1` = configured leader and pilot roles, `2` = none. These follow loadout roles, not current group leadership. `lmf_playerNvg`: `0` = everyone, `1` = helicopter/plane pilots, `2` = none. These settings require `lmf_playerGear`.
- `lmf_camoCoef` sets the player's camouflage coefficient; higher values make players easier for AI to spot. `lmf_jipTp` enables one successful JIP teleport to a suitable friendly player within five minutes of offer initialization; leaving the 200 m start area, death or changing unit ends the offer.

### Map and BFT

- `lmf_oldSchoolMap` disables sharing map markers/drawings and hides newly created nonlocal markers, including script markers. `lmf_bft` independently enables Blue Force Tracking.
- With BFT enabled, `lmf_bftInfantry` supplies name families such as `["FOX"]`, producing `FOX/6`, `FOX/1`–`FOX/4` and `FOX/1V`–`FOX/4V`. `lmf_bftGroundVehicles` and `lmf_bftAirVehicles` produce `NAME1`–`NAME4`. An empty array hides that selection category; all three empty hides callsign selection without disabling tracking. See [Blue Force Tracking](#blue-force-tracking) for scripted setup.

### Configured assets

- `lmf_vic1`, `lmf_vic2`, `lmf_vic3`, `lmf_vic4` select ground vehicle classnames; `lmf_air1`, `lmf_air2`, `lmf_air3`, `lmf_air4` select aircraft classnames. `""` omits a menu choice. Spawnpad menus require Eden objects named `groundSpawner` / `groundPad` or `airSpawner` / `airPad` respectively; configuring a classname alone does not spawn an asset.
- `lmf_supSquad`, `lmf_supLarge`, `lmf_supExplosives`, `lmf_supMedical` and `lmf_supVehicle` select supply crate classnames. All five are offered by Supply Drop when nonempty; the `ammoSpawner` / `ammoPad` menu offers squad, explosives and medical crates. `""` omits the corresponding choice.
- These classnames also identify objects for LMF player-vehicle and supply-crate initialization, including Eden-placed objects. That initialization requires `lmf_playerGear`; menu availability itself does not.

### Supply Drop and Forward Deploy

- `lmf_supplyDropLimit` sets the shared mission request quota; `0` disables the player request module. Requests require an assigned map, a supported long-range radio and inactive warmup. Place a marker named `respawn` for the aircraft spawn-position calculation. Accepted requests share a 30-second cooldown.
- `lmf_supplyDropAircraft` selects the transport classname; planes and helicopters use the same fly-over parachute delivery. `lmf_supplyDropVehicles` enables requests for nonempty `lmf_vic1`–`lmf_vic4` entries. Direct [Supply Drop calls](#supply-drop) bypass the player request quota and cooldown.
- `lmf_forwardDeploy` enables group-leader registration during warmup and requires `lmf_warmup`. `lmf_forwardDeploy_height = 0` selects ground deployment; positive values select an airdrop in meters, with values below `100` raised to `100`. See [Forward Deploy](#forward-deploy) for required Eden asset registration and controls.

## AI spawning

Enemy side: settings/cfg\_Mission.sqf · AI classes and equipment: settings/cfg\_AI.hpp



### Shared options

* "SQUAD" — 8 soldiers.
* "ATTEAM" — 4 soldiers.
* "TEAM" — 4 soldiers.
* "AATEAM" — 3 soldiers.
* "SENTRY" — 2 soldiers.
* "MGTEAM" — 4 soldiers.

A positive integer may replace the infantry type to spawn that many randomly selected soldiers.

**One-shot:** Use the existing spawner name with `call` and omit tickets to return the primary group or object. Patrol and Garrison are always one-shot. These calls can run without suspension after LMF preInit has loaded AI settings; they do not wait for mission time or apply wave proximity checks.

```sqf
private _grp = [spawn_1, "TEAM"] call lmf_ai_fnc_spawnInfantryQrf;
```

**Managed waves:** Supply the ticket argument explicitly, including `1`, and use `spawn`. Tickets are the total number of spawns; `0` spawns nothing. Argument presence selects the mode, regardless of `call` or `spawn`. The caller of `spawn` receives a script handle, not the delivery. Managed execution requires a scheduled context: use `spawn`. ZEN function `remoteExec` is already scheduled; unscheduled managed calls exit without spawning.

```sqf
[spawn_1, "TEAM", 3] spawn lmf_ai_fnc_spawnInfantryQrf;
```

Managed QRF/hunter calls retain the mission-start wait and proximity checks through `lmf_ai_fnc_runWaves`, including with one ticket. A nearby grounded player ends the source; an airborne player delays spawning. Ranges are **500 m** for infantry QRF/hunters and **1,000 m** for vehicle/para QRF. Polling is approximately **10 seconds** for infantry QRF and **5 seconds** for the others.

A wave follows only its primary delivery: a group finishes with no living members; an object finishes when dead/deleted. Infantry QRF/hunters have no added respawn delay; Vehicle/Para QRF default to **300 seconds** before a replacement. Null, empty or already-dead initial deliveries end the source without retrying. The controller exits immediately after spawning the final ticket; it waits for delivery completion only when another replacement ticket remains. Transport flight and cleanup continue independently.

### Garrison

Spawns infantry to occupy buildings and available gunner seats in nearby vehicles or static weapons.

**Run on:** Server · **Use:** call · **Returns:** GROUP

**Example**

```sqf
private _grp = [garrison_1, "TEAM", 100, 1, false] call lmf_ai_fnc_spawnGarrison;
```

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **2. Garrison radius, metres** — Number. Default: 100.
* **3. Distribution: 0 evenly, 1 building by building, 2 random** — Number. Default: 1.
* **4. Fill from top to bottom; applies to distribution 0 and 1** — Boolean. Default: false.



### Patrol

Spawns infantry to patrol an area and react to detected threats. Spawning over water creates a boat group.

**Run on:** Server · **Use:** call · **Returns:** GROUP

**Example**

```sqf
private _grp = [spawn_1, "mrk_patrol", "TEAM", 200, "SLOW", "STAG COLUMN"] call lmf_ai_fnc_spawnPatrol;
```

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Patrol centre: object, marker name or position** — Object / String / Array. Default: \[0,0,0].
* **2. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **3. Patrol radius, metres** — Number. Default: 200.
* **4. Patrol preset; see below** — String. Default: "SLOW".
* **5. Formation** — String. Default: "STAG COLUMN".
* "SLOW" — SAFE / LIMITED.
* "FAST" — AWARE / NORMAL.
* "ATTACK" — AWARE / LIMITED; Faster leader animation.



### Infantry QRF

Returns an infantry GROUP with a GUARD task and reactions to detected ground targets. Additional tickets provide replacement groups after losses. Spawning over water creates a boat group.

**Run on:** Server · **Use:** call without tickets / spawn with tickets

**Example**

```sqf
private _grp = [spawn_1, "TEAM"] call lmf_ai_fnc_spawnInfantryQrf;
[spawn_1, "TEAM", 3] spawn lmf_ai_fnc_spawnInfantryQrf;
```

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **2. Total spawn tickets** — Number. Optional: omit for one-shot; supply for managed waves.



### Infantry hunter

Returns an infantry GROUP that actively hunts players within range without needing to detect them first. Spawning over water creates a boat group.

**Run on:** Server · **Use:** call without tickets / spawn with tickets

**Example**

```sqf
private _grp = [spawn_1, "TEAM", 1500] call lmf_ai_fnc_spawnInfantryHunters;
[spawn_1, "TEAM", 1500, 3] spawn lmf_ai_fnc_spawnInfantryHunters;
```

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **2. Hunting radius from the group leader, metres** — Number. Default: 500.
* **3. Total spawn tickets** — Number. Optional: omit for one-shot; supply for managed waves.



### Vehicle QRF

Spawns a QRF vehicle with crew and, where applicable, infantry passengers.

**Run on:** Server · **Use:** call without tickets / spawn with tickets

**Example**

```sqf
private _delivery = [spawn_1, "TANK"] call lmf_ai_fnc_spawnVehicleQrf;
[spawn_1, "HELITRANSPORT", 3, 300] spawn lmf_ai_fnc_spawnVehicleQrf;
```

**Arguments**

* **0. Spawn position; uses object direction or a random direction for arrays** — Object / Array. Default: \[0,0,0].
* **1. Vehicle category; see below** — String. Default: "TRUCK".
* **2. Total spawn tickets** — Number. Optional: omit for one-shot; supply for managed waves.
* **3. Delay after the primary delivery finishes, seconds** — Number. Default: 300.

**Categories:** CAR, CARARMED, TRUCK, APC, TANK, HELITRANSPORT, HELIATTACK, DRONE.

**Primary delivery:** CAR/TRUCK → infantry GROUP; APC/HELITRANSPORT → cargo infantry GROUP; CARARMED/TANK/HELIATTACK/DRONE → vehicle OBJECT. Vehicle completion ignores surviving dismounted crew; infantry completion ignores the surviving transport. HELITRANSPORT retains its independent insertion, evacuation, retreat and cleanup.

Use an LMF category for argument 1. The delay applies with multiple tickets. In LMF 2.0, rename the old `_uav` pool to `_drones` and change `"UAV"` calls to `"DRONE"`; there is no legacy alias.

Configure both air UAVs and ground UGVs in `_drones` in `settings/cfg_AI.hpp`. DRONE randomly selects from this pool for each spawn; use only classes available in your mission's mods/DLCs. Normal armed and unarmed drones use GUARD and Arma AI for movement, scouting and weapon use. Ground drones receive no flight commands. Empty pools spawn nothing; duplicate classnames retain their random selection weighting.

IED UAVs with the `LXWS_IED_DRONE_PYLON` hardpoint use their real loaded payloads, with approximate target positioning, requested search/approach heights of 50–200 m, drop heights of 20–60 m and 30 seconds between drops. Once empty, the special task ends and the living drone retains GUARD as a scout. Destruction during the wait cancels further drops; there is no fake-grenade fallback.

RF drones with `FakeDetonator_RF` use the native RF attack behavior after normal takeoff, against a detected ground target. RF handles the final HE/smoke effect. HE and smoke support were reported working in local runtime tests; the RF documentation itself describes HE. The complete QRF flow still needs dedicated-server/JIP testing.

Zeus **LMF AI → Vehicle QRF → DRONE** exposes the category and randomly selects from `_drones`, using the same spawner as mission calls. Individual drone classnames are not selectable in Zeus:

```sqf
[spawn_1, "DRONE", 3, 300] spawn lmf_ai_fnc_spawnVehicleQrf;
```



### Para QRF

Spawns an aircraft that drops enemy infantry or a crewed vehicle, then departs and is cleaned up. The infantry payload is one MG team plus one AT team.

**Run on:** Server · **Use:** call without tickets / spawn with tickets

**Example**

```sqf
private _grp = [spawn_1, "mrk_dropZone", 200, ""] call lmf_ai_fnc_spawnParadropQrf;
private _tank = [spawn_1, "mrk_dropZone", 200, "TANK"] call lmf_ai_fnc_spawnParadropQrf;
[spawn_1, "mrk_dropZone", 200, "TANK", 3, 300] spawn lmf_ai_fnc_spawnParadropQrf;
```

**Arguments**

* **0. Spawn position; above 20 m or over water selects an airborne start** — Object / Array. Default: \[0,0,0].
* **1. Drop zone: marker, trigger or location; \[0,0,0] selects autonomous mode** — String / Object / Location / Array. Default: \[0,0,0].
* **2. Flight height, metres** — Number. Default: 200.
* **3. Payload: "" for infantry; otherwise vehicle classname or category** — String. Default: "".
* **4. Total delivery tickets** — Number. Optional: omit for one-shot; supply for managed waves.
* **5. Delay after the primary payload finishes, seconds** — Number. Default: 300.

**Returns:** Infantry GROUP or dropped vehicle OBJECT, prepared immediately. Flight, drop, crew creation after vehicle release, GUARD assignment and aircraft cleanup continue asynchronously. A returned payload is not confirmation of a completed drop. Failed preparation returns a null delivery; an undeliverable payload is cleaned up.

**LMF 2.0 migration:** Paradrop arguments are now spawn position, drop zone, flying height, payload, tickets, respawn delay. Update existing mission/Eden calls; the previous order is unsupported.

**Vehicle payload categories:** CAR, CARARMED, TRUCK, APC, TANK. The transport aircraft comes from \_paraVehicle in AI settings.

**Drop zone:** Use a marker, trigger or location for a fixed zone. The only supported array value is \[0,0,0], which selects autonomous mode; ordinary position arrays are unsupported. In autonomous mode, an object spawn position supplies the initial aircraft heading; an array spawn position uses a random heading. A fixed drop zone determines the heading towards that zone.



### Supply drop

Creates a transport, pilot and payload, delivers it by parachute, then sends the aircraft away. After landing, a fixed global marker records the delivery position when BFT is enabled and old-school map is disabled. It remains there if the payload is moved or deleted; joining players receive it automatically.

**Run on:** Server · **Use:** spawn

**Example**

lmf\_supplyDropAircraft configures the aircraft used by player requests. Both plane and helicopter classnames use the same fly-over-and-parachute-drop behavior. Direct calls select the aircraft through argument 2.

\["mrk\_supplySpawn", "mrk\_supplyDrop", "C\_Plane\_Civil\_01\_F", "B\_supplyCrate\_F"] spawn lmf\_supplyDrop\_fnc\_deliverSupplies;

**Arguments**

* **0. Spawn position** — String / Object / Location / Group / Task / Array. Default: objNull.
* **1. Drop position** — String / Object / Location / Group / Task / Array. Default: objNull.
* **2. Transport classname** — String. Default: "C\_Plane\_Civil\_01\_F".
* **3. Crate or vehicle classname** — String. Default: "B\_supplyCrate\_F".

Supply valid positions, such as marker names or \[x,y,z]. Delivery uses ACE Cargo and parachutes. Direct calls bypass the player menu's quota and request cooldown.

If the aircraft is destroyed before cargo release, the delivery is lost and undelivered cargo is deleted. There is no refund, retry or emergency drop. The aircraft, wreck and crew remain for Arma's normal cleanup; LMF only cleans up living aircraft after a completed delivery. Cargo already released continues its landing sequence independently.



### Check the spawner machine

Returns whether the current machine should run LMF spawners. In the current framework, this is the server only.

**Run on:** Any machine · **Use:** call · **Returns:** Boolean

**Example**

private \_isSpawner = \[] call lmf\_ai\_fnc\_isSpawner;

**Arguments:** None.





## AI tasks

For existing AI groups. Run on the server for server-owned AI; the task functions do not automatically transfer execution to another owner.



### Converge task

Sends selected groups on lmf\_enemySide towards a target. Replaces waypoints, releases infantry garrisons and assigns shoreline tasks to boats. Skips ineligible groups, including static weapons and busy transport helicopters.

**Run on:** Server for server-owned AI · **Use:** call

**Example**

\[objective\_1, \["QRF", "Patrol"], 650] call lmf\_ai\_fnc\_taskConverge;

**Arguments**

* **0. Target object or \[x,y,z]** — Object / Array. Required.
* **1. Group-name keywords; case-insensitive. "ALL" or \["ALL"] selects all eligible groups** — String / Array of String. Required.
* **2. Boat shoreline search radius, metres; not a group-selection radius** — Number. Default: 2000.

Only processes groups local to the calling machine.





## Paradrop \& fire support



### Passenger paradrop

Flies an existing aircraft through an approach point to a drop zone and drops its passengers. Supports players and AI in cargo/FFV seats, plus other occupants outside the pilot's group. The pilot remains aboard.

**Run on:** Aircraft owner; use server-owned AI transport for full LMF/BFT setup · **Use:** spawn

**Example**

\[plane\_1, "mrk\_dropZone", "mrk\_dropZone\_WP", 220, 140, false] spawn lmf\_paradrop\_fnc\_paradropPassengers;

**Arguments**

* **0. Existing aircraft with AI pilot** — Object. Required.
* **1. Drop zone: area marker name or trigger** — String / Object. Required.
* **2. Approach waypoint marker name** — String. Required.
* **3. Approach flight height, metres** — Number. Required.
* **4. Drop height after the approach point, metres** — Number. Required.
* **5. Start airborne: move aircraft up and give initial velocity** — Boolean. Required.

**Aircraft control:** Waits for warmup to end, takes over waypoints, fuel and damage protection, then cleans up the transport after departure. Passenger drops are routed to each unit's owner. Do not replay the call for JIP.



### Fire support

Orders a fire mission from server-owned AI artillery or MK41 VLS against a target object. Busy batteries reject new requests.

**Run on:** Server · **Use:** spawn

**Example**

\[art1, target\_1, 10, true, 6] spawn lmf\_ai\_fnc\_fireSupportAtTarget;

**Arguments**

* **0. AI artillery or VLS battery** — Object. Default: objNull.
* **1. Living target object; not a marker or coordinates** — Object. Default: objNull.
* **2. Preparation delay, seconds** — Number. Default: 10.
* **3. Player-requested: enable LR radio messages and VLS BFT** — Boolean. Default: false.
* **4. Artillery rounds; VLS always fires one missile** — Number. Default: 1.

Normal cooldown: **10 seconds** after artillery firing ends, or **60 seconds** after VLS launch. Script completion does not confirm a hit.



## Forward Deploy

Forward Deploy lets group leaders register a deployment position and claim marked assets during warmup. Enable `lmf_warmup` and `lmf_forwardDeploy` in `settings/cfg_Mission.sqf`. Set `lmf_forwardDeploy_height` to `0` for ground deployment or a positive height in meters for an airdrop; positive values below `100` are raised to `100` during deployment.

In Eden, open each claimable vehicle or asset's attributes and enter this in its **Init** field:

```sqf
this setVariable ["lmf_forwardDeploy_registration", true];
```

Mark assets before Forward Deploy initializes in postInit. The registration value contract is:

- Absent: the object is not part of Forward Deploy.
- `true`: the object is eligible and unclaimed.
- GROUP: the object is claimed by that group; Forward Deploy manages this value during registration.

Group leaders use **Self-Interact » Register Forward Deploy**, left-click to place or move the position, Shift + left-click to rotate it, and close the map to confirm. **Unregister Forward Deploy** cancels the group registration. Marked assets provide **Claim Vehicle** and **Unclaim Vehicle** interactions; entry into marked assets is temporarily blocked during warmup and the deployment transition. Deployment begins shortly after warmup ends. Clients joining after warmup do not receive the registration menu.

When updating an existing mission, use the current setting and object-variable names above in mission scripts and Eden init fields. Make Eden changes through the editor. LMF 2.0 provides no legacy aliases.

## Blue Force Tracking

Requires lmf\_bft = true. Use server calls for mission setup. Group state and distributed object tracking support JIP.



### Set callsign

Registers the group's BFT callsign and default icon. Names are uppercased and rejected if used by another non-empty group on the same side. Existing manual icon overrides are retained.

**Run on:** Server for mission setup · **Use:** call

**Example**

\[group leader\_1, "b\_inf", "FOX/1"] call lmf\_bft\_fnc\_setCallsign;

**Arguments**

* **0. Group to register** — Group. Required.
* **1. Default marker type** — String. Default: "b\_inf".
* **2. Callsign; empty names are rejected** — String. Default: "".
* **3. Requester; omit for server setup** — Object. Default: objNull.

A supplied requester must be the living group leader. Client calls are sent to the server and checked against the local player as group leader.



### Track object

Displays a networked object on BFT clients' maps. Players need an assigned map. A new call replaces the object's previous tracker.

**Run on:** Server for all clients and JIP · **Use:** call

**Example**

\[crate\_1, "loc\_container", "ColorWEST", \[0.75, 0.75], "Supplies", 0.25, true, false, -1, false] call lmf\_bft\_fnc\_trackObject;

**Arguments**

* **0. Networked object to track** — Object. Default: objNull.
* **1. Marker type** — String. Default: "mil\_dot".
* **2. CfgMarkerColors class** — String. Default: "ColorWEST".
* **3. Icon scale: \[width, height]** — Array of Number. Default: \[1,1].
* **4. Icon text** — String. Default: "".
* **5. Map-access/cleanup check interval, seconds** — Number. Default: 0.25.
* **6. Stop when the object is no longer alive** — Boolean. Default: true.
* **7. Rotate icon with the object** — Boolean. Default: false.
* **8. Duration, seconds; negative means unlimited** — Number. Default: -1.
* **9. Icon outline and text shadow** — Boolean. Default: false.

Movement is drawn every frame. Duration starts at the server call and does not restart for JIP. Direct client calls remain local. Do not supply the internal deadline argument.





## Messages \& utilities



### ACE message

Displays a local message with title, text, icon and optional sound.

**Run on:** Recipient's client · **Use:** call

**Example**

\["HQ", "Transport is inbound."] call lmf\_notifications\_fnc\_showAceMessage;

**Arguments**

* **0. Title** — String. Required.
* **1. Message; supports structured-text markup** — String. Required.
* **2. Icon path** — String. Default: the radio icon (path below). "" omits the icon and its line.
* **3. Text box height** — Number. Default: 3.3.
* **4. Text box width** — Number. Default: 12.
* **5. Sound name; "" disables sound** — String. Default: "TacticalPing4".
* **6. Icon scale** — Number. Default: 1.45.
* **7. Error body colour** — Boolean. Default: false. Uses the error colour while preserving explicit inline colours.

Height and width are ACE textbox units, not duration. ACE controls the display lifetime.

Use red error text with "addItemFailed" for rejected actions and failures; explanatory text may be white. The error flag controls colour only, so choose the sound explicitly. Passive negative status may remain silent. Use "beep" for confirmations, "taskUpdated" for map-selection instructions and "TacticalPing4" for normal radio messages. Keep titles and system icons blue.

Separate complete sentences with `<br/>` when the message continues, and omit trailing breaks. Names and values may retain deliberate separate lines.

**Default icon path:** A3\\modules\_f\_curator\\data\\portraitradio\_ca.paa

To notify all connected player clients from the dedicated server:

**Example**

\["HQ", "Transport is inbound."] remoteExec \["lmf\_notifications\_fnc\_showAceMessage", -2];

Do not add these messages to the JIP queue.



### Standard notifications

Displays LMF's standard notifications. Victory and defeat notifications **do not end the mission**.

**Run on:** Player's client, after LMF loads defineNotificationFunctions.sqf during post-init · **Use:** call

**Example**

\["New task received"] call lmf\_notifications\_fnc\_showNotification;

\[] call lmf\_notifications\_fnc\_showVictory;

\[] call lmf\_notifications\_fnc\_showDefeat;

* lmf\_notifications\_fnc\_showNotification — **0:** Message — String, required
* lmf\_notifications\_fnc\_showVictory — None
* lmf\_notifications\_fnc\_showDefeat — None



### Long-range radio check

Checks whether a unit carries a supported long-range ACRE radio. Does not check the selected channel or connectivity to another recipient.

**Run on:** Server or client · **Use:** call · **Returns:** Boolean

**Example**

private \_hasLR = \[player] call lmf\_radio\_fnc\_hasLongRangeRadio;

**Arguments**

* **0. Unit to check** — Object. Required.

**Supported families:** ACRE\_PRC148, ACRE\_PRC152, ACRE\_PRC77, ACRE\_PRC117F, ACRE\_SEM70.



### Vehicle service

Rearms, repairs and refuels a vehicle. Stops its engine and removes fuel while servicing.

**Run on:** Vehicle owner · **Use:** spawn

**Example**

\[heli\_1, 4] spawn lmf\_vehicleService\_fnc\_serviceVehicle;

**Arguments**

* **0. Vehicle to service** — Object. Default: objNull.
* **1. Delay per service step, seconds; some steps use twice this value** — Number. Default: 4.

Waits until mission time exceeds 30 seconds. Avoid overlapping service calls. Split driver/gunner ownership and ownership changes during service remain unverified in-game.

