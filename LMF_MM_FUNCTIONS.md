# LMF · Mission Maker Reference

Practical function calls for mission scripts and triggers using the LMF 2.0.0 system-based names.





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

**Tickets** are the total number of spawns, including the first. 1 spawns once; 0 spawns nothing.

**QRF and hunter proximity checks** apply even with one ticket. A nearby grounded player stops the spawner; an airborne player delays it. The radius is **500 m** for infantry QRF/hunters and **1,000 m** for vehicle/para QRF.



### Garrison

Spawns infantry to occupy buildings and available gunner seats in nearby vehicles or static weapons.

**Run on:** Server · **Use:** spawn

**Example**

\[garrison\_1, "TEAM", 100, 1, false] spawn lmf\_ai\_fnc\_spawnGarrison;

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **2. Garrison radius, metres** — Number. Default: 100.
* **3. Distribution: 0 evenly, 1 building by building, 2 random** — Number. Default: 1.
* **4. Fill from top to bottom; applies to distribution 0 and 1** — Boolean. Default: false.



### Patrol

Spawns infantry to patrol an area and react to detected threats. Spawning over water creates a boat group.

**Run on:** Server · **Use:** spawn

**Example**

\[spawn\_1, "mrk\_patrol", "TEAM", 200, "SLOW", "STAG COLUMN"] spawn lmf\_ai\_fnc\_spawnPatrol;

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

Spawns infantry with a GUARD task and reactions to detected ground targets. Additional tickets provide replacement groups after losses. Spawning over water creates a boat group.

**Run on:** Server · **Use:** spawn

**Example**

\[spawn\_1, "TEAM", 1] spawn lmf\_ai\_fnc\_spawnInfantryQrf;

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **2. Total spawn tickets** — Number. Default: 1.



### Infantry hunter

Spawns infantry that actively hunts players within range without needing to detect them first. Spawning over water creates a boat group.

**Run on:** Server · **Use:** spawn

**Example**

\[spawn\_1, "TEAM", 500, 1] spawn lmf\_ai\_fnc\_spawnInfantryHunters;

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **2. Hunting radius from the group leader, metres** — Number. Default: 500.
* **3. Total spawn tickets** — Number. Default: 1.



### Vehicle QRF

Spawns a QRF vehicle with crew and, where applicable, infantry passengers.

**Run on:** Server · **Use:** spawn

**Example**

\[spawn\_1, "HELITRANSPORT", 3, 300] spawn lmf\_ai\_fnc\_spawnVehicleQrf;

**Arguments**

* **0. Spawn position; uses object direction or a random direction for arrays** — Object / Array. Default: \[0,0,0].
* **1. Vehicle category; see below** — String. Default: "TRUCK".
* **2. Total spawn tickets** — Number. Default: 1.
* **3. Delay after the replacement condition is met, seconds** — Number. Default: 300.

**Categories:** CAR, CARARMED, TRUCK, APC, TANK, HELITRANSPORT, HELIATTACK, UAV.

Use an LMF category, not a classname. The delay applies with multiple tickets. UAV uses the grenade-dropping task described under UAV task.



### Para QRF

Spawns an aircraft that drops enemy infantry or a crewed vehicle, then departs and is cleaned up. The infantry payload is one MG team plus one AT team.

**Run on:** Server · **Use:** spawn

**Example**

\[spawn\_1, 1, 300, "mrk\_dropZone", 200, ""] spawn lmf\_ai\_fnc\_spawnParadropQrf;

**Arguments**

* **0. Spawn position; above 20 m or over water selects an airborne start** — Object / Array. Default: \[0,0,0].
* **1. Total delivery tickets** — Number. Default: 1.
* **2. Delay after the next-delivery condition is met, seconds** — Number. Default: 300.
* **3. Drop zone: marker, trigger or location; \[0,0,0] selects autonomous mode** — String / Object / Location / Array. Default: \[0,0,0].
* **4. Flight height, metres** — Number. Default: 200.
* **5. Payload: "" for infantry; otherwise vehicle classname or category** — String. Default: "".

**Vehicle payload categories:** CAR, CARARMED, TRUCK, APC, TANK. The transport aircraft comes from \_para\_Vehicle in AI settings.

**Drop zone:** Use a marker, trigger or location for a fixed zone. The only supported array value is \[0,0,0], which selects autonomous mode; ordinary position arrays are unsupported. In autonomous mode, an object spawn position supplies the initial aircraft heading; an array spawn position uses a random heading. A fixed drop zone determines the heading towards that zone.



### Supply drop

Creates a transport, pilot and payload, parachutes the payload into the drop point, then sends the aircraft away. The payload receives BFT tracking when enabled.

**Run on:** Server · **Use:** spawn

**Example**

\["mrk\_supplySpawn", "mrk\_supplyDrop", "C\_Plane\_Civil\_01\_F", "B\_supplyCrate\_F"] spawn lmf\_supplyDrop\_fnc\_deliverSupplies;

**Arguments**

* **0. Spawn position** — String / Object / Location / Group / Task / Array. Default: objNull.
* **1. Drop position** — String / Object / Location / Group / Task / Array. Default: objNull.
* **2. Transport classname** — String. Default: "C\_Plane\_Civil\_01\_F".
* **3. Crate or vehicle classname** — String. Default: "B\_supplyCrate\_F".

Supply valid positions, such as marker names or \[x,y,z]. Payload delivery uses ACE Cargo. Direct calls bypass the player menu's quota and active-delivery lock.



### Check the spawner machine

Returns whether the current machine should run LMF spawners. In the current framework, this is the server only.

**Run on:** Any machine · **Use:** call · **Returns:** Boolean

**Example**

private \_isSpawner = \[] call lmf\_ai\_fnc\_isSpawner;

**Arguments:** None.





## AI tasks

For existing AI groups. Run on the server for server-owned AI; the task functions do not automatically transfer execution to another owner.



### Converge task

Sends selected groups on var\_enemySide towards a target. Replaces waypoints, releases infantry garrisons and assigns shoreline tasks to boats. Skips ineligible groups, including static weapons and busy transport helicopters.

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



## Blue Force Tracking

Requires var\_bft = true. Use server calls for mission setup. Group state and distributed object tracking support JIP.



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

