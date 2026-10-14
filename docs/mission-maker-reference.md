# LMF · Mission Maker Reference

The canonical practical mission-maker reference for mission scripts and triggers using the LMF 2.0.0 system-based names. Code and settings paths are relative to the mission root. See [architecture.md](architecture.md) for technical context and [development.md](development.md) for development conventions.





## Mission settings

Edit `settings/cfg_Mission.sqf` before starting the mission. It is loaded locally on every machine during preInit; it is not a server-synchronized runtime settings interface. Player loadout details belong in `settings/cfg_Player.sqf`, AI classes and gear in `settings/cfg_AI.sqf`, and briefing content in `settings/cfg_Briefing.sqf`.

### Mission info and enemy side

- `lmf_missionTitle` and `lmf_missionSubtitle` supply the intro/title text; `""` omits the intro subtitle. `lmf_author` supplies the briefing credit.
- `lmf_enemySide` selects the side used by LMF enemy AI initialization, spawning and tasks: `WEST`, `EAST` or `INDEPENDENT`.

### Warmup and respawn

- `lmf_warmup` enables warmup. `lmf_maxWarmupTime` is a mission-time deadline as `"MM:SS"` (for example `"15:00"`), not a timer restarted for JIP. `""` disables automatic termination; admins can still end warmup.
- `lmf_respawnType` accepts exactly `"OFF"`, `"WAVE"` or `"TICKETS"` (case-sensitive). `"OFF"` disables normal automatic respawn; `"WAVE"` uses recurring mission-time intervals; `"TICKETS"` uses the same intervals with a per-player allowance. Numeric modes and custom strings are unsupported.
- `lmf_respawnTime` is a positive finite numeric interval in seconds for `"WAVE"` and `"TICKETS"`. Waves recur on the `CBA_missionTime` schedule, not at a fixed delay after each death. The delay is `interval - ((floor CBA_missionTime) % interval)`, without an LMF minimum delay. With an interval of 30 seconds, deaths at mission times 12 and 29 target the wave at approximately 30, while a death at 31 targets approximately 60. Exact synchronization remains subject to the existing rounding and engine/scheduler timing. Safe Start and briefing show intervals as `MM:SS` (`00:30` or `15:00`).
- `lmf_respawnTickets` must be a non-negative finite integer for `"TICKETS"`. A death with tickets available consumes one and permits the timed respawn; `0` prevents further automatic respawns and shows the existing no-tickets notification. Remaining tickets are shown after respawn. The count remains local to the client session across ordinary respawns; JIP initializes it from configuration and reconnecting can reset the allowance. There is no persistent server/UID quota.
- Settings are validated during preInit. An invalid mode or invalid setting required by the selected mode falls back to `"OFF"` with an RPT diagnostic identifying the setting. Configure these values before mission start; no compatibility aliases are provided.
- Explicit admin overrides bypass normal `"OFF"` and exhausted `"TICKETS"` restrictions: `#respawn` and ZEN **Respawn Single Player** retain their 5-second override; `#respawnwave` and the admin diary **Respawn Wave** action retain the confirmation dialog and 30-second override. Overrides do not charge or refund tickets beyond normal death-based consumption.

### Player gear and equipment

- `lmf_playerGear` applies the configured LMF loadouts. With `false`, starting Eden equipment is retained and its startup snapshot is restored on respawn. With custom gear enabled, `lmf_keepRole = true` restores the original slot role on respawn; `false` gives Rifleman.
- `lmf_personalArsenal` enables role-aware ACE customization during warmup; it requires both `lmf_playerGear` and `lmf_warmup`.
- `lmf_personalRadio` gives everyone the configured personal radio (AN/PRC-343 in the current player settings). `lmf_pistolAll` gives everyone a sidearm; disabling it retains role-specific sidearms. `lmf_riflemanLat` gives Rifleman the configured light anti-tank weapon. These switches are applied whenever an LMF role/base loadout is applied, including explicit calls with automatic custom gear disabled.
- `lmf_playerMaps` and `lmf_playerGps`: `0` = everyone, `1` = configured leader and pilot roles, `2` = none. These follow loadout roles, not current group leadership. `lmf_playerNvg`: `0` = everyone, `1` = helicopter/plane pilots, `2` = none. These settings also apply to explicit LMF loadout calls with automatic custom gear disabled.
- `lmf_camoCoef` sets the player's camouflage coefficient; higher values make players easier for AI to spot. `lmf_jipTp` enables one successful JIP teleport to a suitable friendly player within five minutes of offer initialization; leaving the 200 m start area, death or changing unit ends the offer.

### Map and BFT

- `lmf_oldSchoolMap` disables sharing map markers/drawings and hides newly created nonlocal markers, including script markers. `lmf_bft` independently enables Blue Force Tracking.
- With BFT enabled, `lmf_bftInfantryCallsigns` supplies name families such as `["FOX"]`, producing `FOX/6`, `FOX/1`–`FOX/4` and `FOX/1V`–`FOX/4V`. `lmf_bftGroundCallsigns` and `lmf_bftAirCallsigns` produce `NAME1`–`NAME4`. An empty array hides that selection category; all three empty hides callsign selection without disabling tracking. See [Blue Force Tracking](#blue-force-tracking) for scripted setup.

### Configured assets

`lmf_groundVehicles` and `lmf_airVehicles` are ordered arrays of vehicle classname strings with no fixed entry limit:

```sqf
lmf_groundVehicles = ["CUP_M1240_OGPK_M240_NATO", "B_Quadbike_01_F"];
lmf_airVehicles = ["B_Heli_Light_01_dynamicLoadout_F", "B_Heli_Transport_01_pylons_F"];
```

Use `[]` to disable either category independently. Empty strings and classnames absent from `CfgVehicles` are omitted from vehicle menus; the configured arrays are not modified. Use canonical classname spelling, including case, for exact Player vehicle initialization matching.

- Asset Spawner and ZEN Vehicle Spawn offer these lists in configured order, with names from `CfgVehicles`. Spawnpad menus require Eden objects named `groundSpawner` / `groundPad` or `airSpawner` / `airPad` respectively; configuring a classname alone does not spawn an asset.
- Supply Drop vehicle requests and ZEN Supply Drop use only `lmf_groundVehicles`. ZEN delivery remains independent of the player request toggle, quota and cooldown.
- These are vehicle class lists, separate from the BFT callsign arrays `lmf_bftGroundCallsigns` and `lmf_bftAirCallsigns`.
- The vehicle arrays select exact classnames for local Player ground/air vehicle initialization through CBA InitPost, for both Eden-placed and newly created vehicles. Automatic vehicle and Supply Crate initialization require `lmf_playerGear`; menu availability itself does not.

### Supply Crates

Configure five independent classname strings in `settings/cfg_Mission.sqf`. Supply Spawner (`supplySpawner` / `supplyPad`), Player Supply Drop and ZEN Supply Drop offer the enabled categories in this order, using the same labels:

| Category | Setting | Default classname | Display name |
| --- | --- | --- | --- |
| LARGE | `lmf_supLarge` | `I_supplyCrate_F` | Large Supplies |
| SMALL | `lmf_supSmall` | `Box_IND_Ammo_F` | Small Supplies |
| EXPLOSIVES | `lmf_supExplosives` | `Box_IND_AmmoOrd_F` | Explosives |
| MEDICAL | `lmf_supMedical` | `ACE_medicalSupplyCrate` | Medical |
| VEHICLE | `lmf_supVehicle` | `Box_IND_AmmoVeh_F` | Vehicle Supplies (RRR) |

`""` disables a category in all three menus and prevents initialization through that category. Disabling all five leaves Spare Wheel and Spare Track available at Supply Spawner. These are independent utility objects. VEHICLE is a supply crate; actual vehicle deliveries remain separate choices from `lmf_groundVehicles`.

Every enabled category must use a unique classname (case-insensitive). Classname identifies the canonical crate type and its contents. Duplicate configuration produces an RPT diagnostic during preInit and disables all conflicting categories in menus and initialization; their crates keep existing cargo. Other categories remain available. Use a different model or `""` to resolve a conflict.

Configured Eden/direct-spawn crates deriving from `ReammoBox_F` initialize automatically through CBA InitPost. Automatic initialization, including LMF menu spawns, requires `lmf_playerGear`; with it disabled, menus still spawn the configured objects with their original cargo. A crate is filled only once; repeated calls and JIP must not refill inventories. There are no object category tags or Eden category overrides.

For explicit scripted initialization, call `[crate_1] call lmf_supplyCrates_fnc_initSupplyCrate` on the object's owner. The crate must have an enabled configured classname. Explicit calls are independent of `lmf_playerGear`; there is no category argument or refill operation.

**LMF 2.0 integration:** Use SMALL / `lmf_supSmall` and the Eden variable names `supplySpawner` / `supplyPad`, without legacy aliases. Update existing spawner/pad variable names manually in Eden. The shared definitions array is internal; mission makers configure only the five classname settings.

### Supply Drop and Forward Deploy

- `lmf_supplyDropLimit` sets the shared mission request quota; `0` disables the player request module. Requests require an assigned map, a supported long-range radio and inactive warmup. Place a marker named `respawn` for the aircraft spawn-position calculation. Accepted requests share a 30-second cooldown.
- `lmf_supplyDropAircraft` independently selects the delivery transport classname; it does not use `lmf_airVehicles`. Planes and helicopters use the same fly-over parachute delivery. `lmf_supplyDropVehicles` enables requests for usable `lmf_groundVehicles` entries; the vehicle submenu is omitted when none exist. Direct [Supply Drop calls](#supply-drop) bypass the player request quota and cooldown.
- `lmf_forwardDeploy` enables group-leader registration during warmup and requires `lmf_warmup`. `lmf_forwardDeploy_height = 0` selects ground deployment; positive values select an airdrop in meters, with values below `100` raised to `100`. See [Forward Deploy](#forward-deploy) for required Eden asset registration and controls.

## Player equipment

Configure Player gear in `settings/cfg_Player.sqf` before mission start. The loader builds a machine-local registry; loadout functions, Role Selector, ZEN, Personal Arsenal and Supply Crates read it through the lazy accessor. Do not edit the registry directly or include the settings file in custom consumers. AI gear uses the separate `settings/cfg_AI.sqf` configuration.

### Roles and clothing

Each of the 20 role definitions is `[classname, display name, rank]`. Use a unique Eden unit classname per role; matching ignores classname case. An empty classname has no automatic assignment, and an unconfigured classname receives no automatic LMF role. The display name is used for the current role and selection menus. Explicit role selection does not change the unit's classname.

The role's `*Uniform`, `*Vest`, `*Headgear`, `*Goggles` and `*Backpack` arrays provide selection pools. For example, `_medVest = [""]` inherits `_rVest`. Only the exact one-element array `[""]` inherits. Vehicle Commander and Vehicle Crew inherit each slot from Vehicle Platoon Commander (`_vpl*`), including its resolved Rifleman fallback. For example, `_vpsgVest = [""]` inherits `_vplVest`; an explicit vest pool overrides it independently. Vehicle Platoon Commander, other roles (including helicopter crew and pilots), and direct `applyBaseLoadout` calls retain Rifleman fallback. `[]` does **not** inherit or provide fallback equipment. Mixed arrays and duplicate entries are retained; duplicates retain their random-selection weighting.

Set each role's `*Weapon` value to one of these exact uppercase keys:

`FLARE_GUN`, `PISTOL`, `SMG`, `CARBINE`, `RIFLE`, `RIFLE_GL`, `DMR`, `LMG`, `MMG`, `LAT`, `MAT`.

For example, `_rWeapon = "RIFLE"` and `_gWeapon = "RIFLE_GL"`. Vehicle Commander (`_vpsgWeapon`) and Vehicle Crew (`_vcWeapon`) default to `_vplWeapon`; replace either assignment with an explicit key to override it independently. Role-specific extras such as the AT gunner's MAT launcher remain part of the role function.

### Weapon pools and supplies

Edit each category's weapon, ammunition, optic, attachment and bipod pools in the Weapons section. For example, `_rifle` selects the rifle, `_rifleAmmo` and `_rifleAmmoT` select normal/tracer magazines, and `_rifleOptic`, `_rifleAttach1`, `_rifleAttach2`, `_rifleBipod` select its attachments. Selections are independent; use mutually compatible classes. Both pistol attachment pools are applied, MAT uses its optic in the secondary weapon slot, and `_rifleGlUgl1`–`_rifleGlUgl4` remain separate ammunition pools with fixed distribution quantities.

Flare gun settings `_flareGun` and `_flareGunAmmo` remain scalar strings. Radio, binocular and NVG settings are also scalar strings. Grenade and weapon optic pools are arrays. Clothing inheritance does not apply to weapon/attachment pools: `[""]` supplies an empty classname, and `[]` receives no fallback or validation.

Supply Crates use the first classname in the relevant configured weapon/ammunition/grenade pool, not a random choice or every variant. A first entry of `""` skips that supply; keep a one-element `[""]` pool for an unused entry rather than `[]`. Crate quantities and fixed medical, explosive and vehicle supplies are defined by the existing crate initializer.

### Assignment and respawn

With `lmf_playerGear = true`, startup assigns the role matching the player's Eden classname. Place an object named `crateRoles` to offer the 20 roles through ACE interaction. It uses configured display names, applies the selected role to the interacting player and is not restricted to warmup.

Run direct calls on the unit's owner after LMF initialization. For a local player:

```sqf
[player] call lmf_equipment_fnc_applyMedic;
[player] call lmf_equipment_fnc_applyRoleFromClass;
```

The first call explicitly selects Medic; the second reapplies the classname role and requires an interface client. ZEN **LMF Utility → Apply New Loadout** sends the selected role to the unit's owner. **Reload Original Loadout** reapplies the classname role; it does not restore an inventory snapshot.

Explicit role calls, the role crate and ZEN remain available with `lmf_playerGear = false`. PreInit then skips Player configuration, but consumers load it synchronously when needed. With custom gear enabled, `lmf_keepRole = true` reapplies the original slot role on respawn; false gives Rifleman. It does not preserve the last role selected manually or through ZEN. With custom gear disabled, respawn restores the startup Eden loadout snapshot regardless of `lmf_keepRole` or later manual equipment changes.

Personal Arsenal requires `lmf_playerGear`, `lmf_personalArsenal` and `lmf_warmup`, and is available only during active warmup after the intro, including after respawn. It reads the current `lmf_currentRoleKey` on each opening, so Role Selector, ZEN and explicit role calls change its clothing and weapon/attachment options. Missing/invalid roles cannot open it. Optics use the current role's weapon category and its `OPTICS` pool, also used by the loadout system. Joining after warmup does not offer the action.

Personal Arsenal offers clothing, weapon variants and attachments from the current role configuration; ammunition and supplies are not virtualized. Face, Voice, Insignia, Radio, Map, Watch, Navigation/Compass and Terminal/GPS categories are disabled and visibly dimmed. The ITEMS: ALL / ITEMS: FAVORITES toggle is disabled and locked to ALL in Personal Arsenal, regardless of ACE's Favorites default. Uniform, Vest, Backpack and Binoculars hide the entire right panel. Weapon categories show only Optics, Rail Attachments, Muzzle Attachments and Bipods; cargo and loaded-magazine choices are hidden. Other left categories retain their existing behavior. Equipment lists on both sides omit Empty, including weapons, clothing, accessories and loaded magazines; an already empty slot stays empty until the player selects equipment. Existing inventory uses ACE unique-item handling, while loadout/import and manual cargo-add/remove UI paths are restricted locally. These are UI restrictions, not an inventory enforcement system. ACE may normalize weapon variants into the same entry and discard incompatible magazines during weapon switching. Smaller containers cannot be guaranteed to preserve contents that no longer fit. LMF does not snapshot or restore inventory during customization. These ACE/Arma inventory limitations also apply to the finished Personal Arsenal feature; check the configured equipment combinations and UI compatibility when updating ACE.

### Give a configured weapon

**Run on:** Unit owner · **Use:** call

```sqf
[player, "RIFLE"] call lmf_equipment_fnc_giveWeapon;
[player, "PISTOL"] call lmf_equipment_fnc_giveWeapon;
[player] call lmf_equipment_fnc_giveWeapon; // Uses CARBINE
```

Argument 0 is the unit (default `objNull`); argument 1 is an exact uppercase weapon key (default `"CARBINE"`). The function distributes that category's weapon, ammunition and attachments; it does not apply a complete role or clothing. Null/nonlocal units are rejected. Unknown keys and supplied non-string values distribute nothing. Numeric Player weapon IDs are no longer supported; update custom mission calls as well as role settings. Do not use the return value as a success indicator.

Custom scripts should normally use the documented equipment functions above and configure equipment in `settings/cfg_Player.sqf`. The Player registry and its accessor are internal LMF implementation details, not supported custom-script APIs.

## AI spawning

Enemy side: settings/cfg\_Mission.sqf · AI classes and equipment: settings/cfg_AI.sqf



### Shared options

* "SQUAD" — 8 soldiers.
* "ATTEAM" — 4 soldiers.
* "TEAM" — 4 soldiers.
* "AATEAM" — 3 soldiers.
* "SENTRY" — 2 soldiers.
* "MGTEAM" — 4 soldiers.

A positive integer may replace the infantry type to spawn that many randomly selected soldiers.

**Arma 3 2.22+ is required. All six AI spawners require scheduled server execution after LMF preInit.** Use `spawn` for both one-shot and managed spawning; unscheduled calls return a null delivery without spawning. A `call` from an already scheduled script also works and suspends that script until the function returns. ZEN's existing function `remoteExec` calls are scheduled and remain supported.

**One-shot:** Omit tickets (Patrol and Garrison are always one-shot). `spawn` returns a native script-handle promise; its result is the primary GROUP or OBJECT once preparation finishes. One-shot spawning has no player-distance checks and no mission-time startup wait. Placement and visibility remain the mission maker's responsibility.

```sqf
private _handle = [spawn_1, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf;
_handle continueWith {
	private _grp = _this;
	if (!isNull _grp) then {
		_grp setGroupIdGlobal ["Reinforcements"];
	};
};
```

`continueWith` runs **unscheduled**. Keep callbacks short; spawn any suspending or expensive follow-up work. From scheduled code, await the same native result:

```sqf
private _handle = [spawn_1, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf;
private _grp = waitUntil _handle;
```

For a request originating on a client, target the server with `[spawn_1, "TEAM"] remoteExec ["lmf_ai_fnc_spawnInfantryQrf", 2]`. `remoteExec` does not send a server-local promise result back to the caller. Do not replay spawning for JIP.

**Readiness and pacing:** One shared server queue spaces actual soldier creation by at least approximately 0.1 seconds, including concurrent spawners and the Supply Drop pilot. Under load preparation takes longer; there is no catch-up burst. Drone `createVehicleCrew` remains an atomic engine operation, admitted through the same queue; its internal crew members are not individually paced. Curator logic and editor-placed units are outside this soldier queue.

Groups stay excluded from Converge and survivor joining during preparation. A one-shot result means all surviving prepared soldiers have passed LMF's CBA InitPost route and any deferred gear attempt, and the spawner has installed its initial task/handlers. The existing ten-second weapon-switch gear timeout can retain the original loadout; completion does not guarantee successful custom gear application or completion of unrelated mods' asynchronous work. Vehicle insertion, paradrop landing, recurring tasks and cleanup continue independently. Vehicles are held with simulation disabled during preparation, then restored before delivery. Paradrop vehicle occupants are prepared hidden/inactive before flight and seated at release, so queue pressure cannot leave a descending payload awaiting creation. Paradrop infantry's existing 1.25 skill multiplier is now applied after LMF skill initialization, rather than racing InitPost.

**Managed waves:** Supply tickets explicitly, including `1`. Tickets are the total number of deliveries; `0` creates none. Argument presence selects the mode. The script completes with no combined delivery result after preparing the final ticket, on proximity cancellation, or on preparation failure; completion does not mean the final delivery has died or landed.

```sqf
[spawn_1, "TEAM", 3] spawn lmf_ai_fnc_spawnInfantryQrf;
```

Managed QRF/hunter calls retain the mission-start wait and proximity checks through `lmf_ai_fnc_runWaves`, including with one ticket. A nearby grounded player ends the source; an airborne player delays spawning. Ranges are **500 m** for infantry QRF/hunters and **1,000 m** for vehicle/para QRF. Polling is approximately **10 seconds** for infantry QRF and **5 seconds** for the others.

A wave follows only its primary delivery: a group finishes with no living members; an object finishes when dead/deleted. Infantry QRF/hunters have no added respawn delay; Vehicle/Para QRF default to **300 seconds** before a replacement. Null, empty or already-dead initial deliveries end the source without retrying. The controller exits immediately after spawning the final ticket; it waits for delivery completion only when another replacement ticket remains. Transport flight and cleanup continue independently.

Garrison, Patrol, Infantry QRF and Hunters start with weapon lights and IR lasers off. A detection within 75 meters can allow group weapon lights (30%, Auto) and individual nearby IR lasers (25%). Hunter tracking alone does not activate lights. No recurring distance check or automatic switch-off is used. Normal LAMBS assault tactics can still override IR-laser discipline outside hunting.

### Garrison

Spawns infantry to occupy buildings and available gunner seats in nearby vehicles or static weapons, with MAT gunners using the same candidate pool as other soldiers. Soldiers actually placed in ACE Garrison start with an equally random UP/MIDDLE/DOWN stance; unused building candidates retain normal stance control. EnemyDetected chooses equally between UP and MIDDLE for eligible garrisoned soldiers on foot, without geometry checks; within 75 meters each defender has a 10% chance to leave ACE Garrison. No surrender routine is used. Dynamic Simulation and last-survivor reassignment remain.

**Run on:** Server · **Use:** call · **Returns:** GROUP

**Example**

```sqf
private _handle = [garrison_1, "TEAM", 100, 1, false] spawn lmf_ai_fnc_spawnGarrison;
```

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **2. Garrison radius, metres** — Number. Default: 100.
* **3. Distribution: 0 evenly, 1 building by building, 2 random** — Number. Default: 1.
* **4. Fill from top to bottom; applies to distribution 0 and 1** — Boolean. Default: false.



### Patrol

Spawns infantry to patrol an area. Relevant ground contact on land permanently changes the same group to QRF with GUARD and AWARE/FULL; it does not resume patrolling. Its new group name contains QRF but not Patrol. The separate light/IR reaction remains active after transition or convergence. Spawning over water creates a boat group using the shared landing flow.

**Run on:** Server · **Use:** call · **Returns:** GROUP

**Example**

```sqf
private _handle = [spawn_1, "mrk_patrol", "TEAM", 200, "SLOW", "STAG COLUMN"] spawn lmf_ai_fnc_spawnPatrol;
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
* "ATTACK" — AWARE / LIMITED; no animation-speed override.



### Infantry QRF

Returns an infantry GROUP with a GUARD task; Arma and LAMBS handle combat without LMF moving its waypoints on contact. Additional tickets provide replacement groups after losses. Spawning over water creates a boat group.

**Run on:** Server · **Use:** spawn

**Example**

```sqf
private _handle = [spawn_1, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf;
[spawn_1, "TEAM", 3] spawn lmf_ai_fnc_spawnInfantryQrf;
```

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **2. Total spawn tickets** — Number. Optional: omit for one-shot; supply for managed waves.



### Infantry hunter

Returns an infantry GROUP that actively hunts the nearest living non-civilian player within range without prior detection. Individual movement orders use the player's 3D position immediately and then every 13–17 seconds, including upper floors; actual navigation depends on the building. Hunters use FULL speed and normal Arma combat AI while LAMBS group and individual reactions are disabled during hunting. When casualties leave one survivor, hunting stops and the soldier joins an eligible friendly group or receives GUARD. An initially single-soldier spawn still hunts. Airborne aircraft are excluded. Spawning over water creates a boat group using the shared landing flow.

**Run on:** Server · **Use:** spawn

**Example**

```sqf
private _handle = [spawn_1, "TEAM", 1500] spawn lmf_ai_fnc_spawnInfantryHunters;
[spawn_1, "TEAM", 1500, 3] spawn lmf_ai_fnc_spawnInfantryHunters;
```

**Arguments**

* **0. Spawn position: object or \[x,y,z]** — Object / Array. Default: \[0,0,0].
* **1. Infantry type or soldier count** — String / Number. Default: "TEAM".
* **2. Hunting radius from the group leader, metres** — Number. Default: 500.
* **3. Total spawn tickets** — Number. Optional: omit for one-shot; supply for managed waves.



### Vehicle QRF

Spawns a QRF vehicle with crew and, where applicable, infantry passengers.

**Run on:** Server · **Use:** spawn

**Example**

```sqf
private _handle = [spawn_1, "TANK"] spawn lmf_ai_fnc_spawnVehicleQrf;
[spawn_1, "HELITRANSPORT", 3, 300] spawn lmf_ai_fnc_spawnVehicleQrf;
```

**Arguments**

* **0. Spawn position; uses object direction or a random direction for arrays** — Object / Array. Default: \[0,0,0].
* **1. Vehicle category; see below** — String. Default: "TRUCK".
* **2. Total spawn tickets** — Number. Optional: omit for one-shot; supply for managed waves.
* **3. Delay after the primary delivery finishes, seconds** — Number. Default: 300.

**Categories:** CAR, CARARMED, TRUCK, APC, TANK, HELITRANSPORT, HELIATTACK, DRONE.

**Primary delivery:** CAR/TRUCK → infantry GROUP; APC/HELITRANSPORT → cargo infantry GROUP; CARARMED/TANK/HELIATTACK/DRONE → vehicle OBJECT. Vehicle completion ignores surviving dismounted crew; infantry completion ignores the surviving transport. HELITRANSPORT retains its independent insertion, evacuation, retreat and cleanup.

CAR/TRUCK/APC keep automatic combat unloading disabled. Their infantry dismounts through LMF on relevant ground contact within 500 meters, releases the original transport assignment and retargets GUARD toward that contact. Dismounted infantry uses Infantry QRF behavior, including close-contact light/IR chances and last-survivor reassignment; pure vehicle crews do not reassign. HELITRANSPORT uses synchronized TR UNLOAD/GETOUT at a searched helipad before infantry GUARD and helicopter retreat. TR UNLOAD uses forced CARELESS behavior. The existing ten-second monitor handles crash evacuation; no WAIT/anti-stuck refresh is used. Ground-vehicle dismount no longer empties the soldier's weapon or forces suppression.

Use an LMF category for argument 1. The delay applies with multiple tickets. In LMF 2.0, rename the old `_uav` pool to `_drones` and change `"UAV"` calls to `"DRONE"`; there is no legacy alias.

Configure both air UAVs and ground UGVs in `_drones` in `settings/cfg_AI.sqf`. DRONE randomly selects from this pool for each spawn; use only classes available in your mission's mods/DLCs. Normal armed and unarmed drones use GUARD and Arma AI for movement, scouting and weapon use. Ground drones receive no flight commands. Empty pools spawn nothing; duplicate classnames retain their random selection weighting.

IED UAVs with the `LXWS_IED_DRONE_PYLON` hardpoint use their real loaded payloads, with approximate target positioning, requested search/approach heights of 50–200 m, drop heights of 20–60 m and 30 seconds between drops. Once empty, the special task ends and the living drone retains GUARD as a scout. Destruction during the wait cancels further drops; there is no fake-grenade fallback.

RF drones with `FakeDetonator_RF` use the native RF attack behavior after normal takeoff, against a detected ground target. RF handles the final HE/smoke effect. HE and smoke support were reported working in local runtime tests; the RF documentation itself describes HE. The complete QRF flow still needs dedicated-server/JIP testing.

Zeus **LMF AI → Vehicle QRF → DRONE** exposes the category and randomly selects from `_drones`, using the same spawner as mission calls. Individual drone classnames are not selectable in Zeus:

```sqf
[spawn_1, "DRONE", 3, 300] spawn lmf_ai_fnc_spawnVehicleQrf;
```



### Para QRF

Spawns an aircraft that drops enemy infantry or a crewed vehicle, then departs and is cleaned up. The infantry payload is one MG team plus one AT team.

**Run on:** Server · **Use:** spawn

**Example**

```sqf
private _infantryHandle = [spawn_1, "mrk_dropZone", 200, ""] spawn lmf_ai_fnc_spawnParadropQrf;
private _vehicleHandle = [spawn_1, "mrk_dropZone", 200, "TANK"] spawn lmf_ai_fnc_spawnParadropQrf;
[spawn_1, "mrk_dropZone", 200, "TANK", 3, 300] spawn lmf_ai_fnc_spawnParadropQrf;
```

**Arguments**

* **0. Spawn position; above 20 m or over water selects an airborne start** — Object / Array. Default: \[0,0,0].
* **1. Drop zone: marker, trigger or location; \[0,0,0] selects autonomous mode** — String / Object / Location / Array. Default: \[0,0,0].
* **2. Flight height, metres** — Number. Default: 200.
* **3. Payload: "" for infantry; otherwise vehicle classname or category** — String. Default: "".
* **4. Total delivery tickets** — Number. Optional: omit for one-shot; supply for managed waves.
* **5. Delay after the primary payload finishes, seconds** — Number. Default: 300.

**Promise result:** Infantry GROUP or dropped vehicle OBJECT after paced preparation. Flight, drop, seating prepared vehicle occupants at release, GUARD assignment and aircraft cleanup continue asynchronously. A returned payload is not confirmation of a completed drop. Failed preparation returns a null delivery; an undeliverable payload is cleaned up.

**LMF 2.0 migration:** Paradrop arguments are now spawn position, drop zone, flying height, payload, tickets, respawn delay. Update existing mission/Eden calls; the previous order is unsupported.

**Vehicle payload categories:** CAR, CARARMED, TRUCK, APC, TANK. The transport aircraft comes from \_paraVehicle in AI settings.

Vehicle payloads match Vehicle QRF: CAR normally has six infantry including its driver, TRUCK twelve, APC a separate crew plus eight infantry, and CARARMED/TANK crew only. Available seats cap infantry numbers. APC/TANK select a valid vehicle commander as crew-group leader. Crew and passengers are created through the shared queue before flight, held hidden/inactive and damage-protected, then seated together at vehicle release; GUARD, combat AI and infantry contact/dismount handlers activate after landing and parachute detachment. Automatic combat unloading stays disabled: CAR/TRUCK/APC infantry remains aboard until LMF contact dismount releases the original transport assignment. Vehicle release briefly disables the transport aircraft's collision on the server for three seconds, then restores its previous setting (Arma 3 2.18+).

Direct classnames found in one of these five configured vehicle categories use that category's setup. Other classnames receive configured CREW units in the actual crew seats, with no extra infantry. Use the configured category pools when a particular infantry composition is required.

Vehicle payloads always return and track the vehicle OBJECT. For CAR/TRUCK/APC, a surviving empty vehicle delays replacement even if the infantry is dead; destroying the vehicle permits replacement even if infantry survives. Vehicle QRF instead tracks the infantry group for these categories. Tickets, respawn delay and proximity checks otherwise retain the shared wave rules.

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
* **4. Optional Supply Crate category** — String. Default: `""`. An enabled canonical category overrides argument 3 with its configured classname. Unknown/disabled categories abort delivery before spawning an aircraft.

Supply valid positions, such as marker names or \[x,y,z]. Delivery uses ACE Cargo and parachutes. Direct calls bypass the player menu's quota and request cooldown.

Existing four-argument calls remain supported. Without a category, an enabled configured crate classname initializes automatically through CBA InitPost; disabled or conflicting classnames keep their original cargo. Automatic filling still requires `lmf_playerGear`. For a category-specific delivery:

```sqf
["mrk_supplySpawn", "mrk_supplyDrop", lmf_supplyDropAircraft, "", "SMALL"] spawn lmf_supplyDrop_fnc_deliverSupplies;
```

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

Sends selected groups on lmf\_enemySide towards a target. Replaces waypoints, releases infantry garrisons and assigns shoreline tasks to boats. Busy transport helicopters remain excluded. Static-weapon leaders and driverless vehicles are accepted for groups created by `spawnGarrison`; other groups retain their existing exclusions. Accepted land groups also release garrisoned soldiers on foot when their leader is mounted. Released soldiers regain AUTO stance and PATH/MOVE; AUTO still allows natural crouching or crawling during combat.

Garrison uses vehicle and static weapons defensively, without assigning a driver at spawn. When Converge accepts the group, it disables Dynamic Simulation before release and movement orders, with no automatic reactivation. Other AI groups keep their existing Dynamic Simulation setting. At Converge, it abandons land vehicles and proceeds on foot to GUARD, including when its leader is a gunner without a driver. Vehicle-pool and individual seat assignments are cleared before normal dismount orders, preventing reassignment to the abandoned weapons. AUTO/PATH/MOVE and the initial doFollow reset are retained. After GUARD is activated, living Garrison soldiers already on foot receive doStop followed by doMove to the same target, so they can move independently of a stuck leader. This releases formation following; no automatic formation restoration or retry loop is added. Mounted soldiers keep the existing dismount flow. There are no boarding waypoints, transport selection, driver assignments, timers or forced exits. Repeated Converge replaces the target using the latest accepted order. Normal dismount/pathfinding remains subject to engine limitations; incapacitated soldiers are not forcibly moved. Vehicle QRF, transport helicopters, boats, Garrison stances and MAT handling are unchanged.

**Run on:** Server for server-owned AI · **Use:** call

**Example**

\[objective\_1, \["QRF", "Patrol"], 650] call lmf\_ai\_fnc\_taskConverge;

**Arguments**

* **0. Target object or \[x,y,z]** — Object / Array. Required.
* **1. Group-name keywords; case-insensitive. "ALL" or \["ALL"] selects all eligible groups** — String / Array of String. Required.
* **2. Boat shoreline search radius, metres; not a group-selection radius** — Number. Default: 2000.

Returns before orders finish. One scheduled worker per call spaces groups by approximately 0.1 seconds. Newer calls supersede older pending orders for the same group; eligibility, locality, living leader and transport state are rechecked when each order is applied. Partially prepared groups are excluded. Only processes groups local to the calling machine. Stops hunter orders and removes patrol contact takeover before assigning the new task. Land groups can receive another convergence task later; boats remain temporarily reserved while landing/dismounting.





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

