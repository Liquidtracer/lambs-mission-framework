# LMF changelog

## LMF 2.0 (v2.0.0)

- **Added:** Startup mission information and group-arrival notifications for leaders.
- **Added:** Zeus Infantry Patrol can target a living player's position at confirmation while spawning at the clicked position.
- **Added:** `lmf_supplyCrates_fnc_addWeaponToCrate` adds configured Player weapons with attachments, loaded ammunition and optional spare magazines to existing crates.
- **Improved:** Rebuilt Personal Arsenal with role-aware clothing, weapon and attachment customization during warmup, replacing the separate Available Optics action and restricting manual inventory management.
- **Improved:** Reorganized LMF into system-based modules with related functions, initialization and configuration kept together. Function names and integration paths have changed.
- **Improved:** Unified player feedback through shared ACE notifications and a common UI color palette.
- **Improved:** Reworked Supply Drop requests with map selection and server-managed availability.
- **Improved:** Supply Spawner, Player and ZEN Supply Drop share LARGE, SMALL, EXPLOSIVES, MEDICAL and VEHICLE crates with unique configured classnames and one-time initialization. Empty classnames disable categories; duplicate configuration disables conflicting categories with an RPT diagnostic. Supply Spawner uses the Eden names `supplySpawner` / `supplyPad`.
- **Improved:** Reworked AI helicopter landing searches and evacuation handling, and boat landing and follow-up tasks.
- **Improved:** Unified UAV/UGV QRF in the configured `_drones`/`DRONE` pool, with native GUARD behavior, real IED payload drops, RF self-destruct attacks and category-based drone spawning in Zeus.
- **Improved:** AI spawners now require scheduled execution and Arma 3 2.22 native promises, returning primary groups or objects after paced preparation. Concurrent spawners share soldier creation pacing; explicit tickets retain shared wave management. Vehicle waves follow their primary infantry or vehicle, and Paradrop now takes drop zone, height and payload before optional tickets and delay.
- **Improved:** BFT now separates callsign and icon selection and reuses callsigns from empty groups. Callsign families use `lmf_bftInfantryCallsigns`, `lmf_bftGroundCallsigns` and `lmf_bftAirCallsigns`; existing mission configs must be updated, with no legacy aliases.
- **Improved:** The admin `#bring` command uses an available passenger seat when the admin is in a vehicle, or cancels with feedback if no seat is available.
- **Improved:** Player roles, weapon distribution, Role Selector, Personal Arsenal, Supply Crates and ZEN now share one equipment configuration registry; Player weapon keys are strings instead of numeric IDs.
- **Improved:** Breaking configuration change: replaced the four ground and four air Player vehicle slots with scalable `lmf_groundVehicles` and `lmf_airVehicles` arrays.
- **Improved:** AI groups have sequential LMF names and persistent origin tags. Converge now selects exact classification tags instead of name fragments; ALL excludes Eden AI and pure transports, and insertion groups remain protected until ready.
- **Tweaked:** Supply deliveries leave a fixed landing-site marker instead of continuously tracking the payload.
- **Tweaked:** Simplified infantry AI: random garrison stances and release without surrender, shared MAT/infantry placement, native GUARD QRF, permanent Patrol-to-QRF transitions, 13–17-second individual hunter pursuit with last-survivor reassignment, and close-contact weapon-light/IR chances. Converge spreads group orders across time and cancels hunting and patrol takeover before retasking.
- **Tweaked:** Simplified Vehicle QRF setup and aligned dismounted infantry with Infantry QRF. Transport helicopters use synchronized TR UNLOAD/GETOUT with forced CARELESS behavior and no WAIT refresh; crash evacuation and passenger-safe cleanup remain. Removed crew reassignment and ground-dismount forced empty magazines/suppression.
- **Fixed:** ZEN AI modules report the first server spawn result, including proximity waiting/cancellation and failure, only to the requesting Zeus.
- **Fixed:** Vehicle Commander and Vehicle Crew inherit clothing and default weapon categories from Vehicle Platoon Commander, with independent overrides.
- **Fixed:** Converge releases Garrison groups from vehicle and static weapon positions, including mounted leaders without drivers. Accepted Garrison groups have Dynamic Simulation disabled without automatic reactivation, clear vehicle assignments, dismount normally and proceed on foot to GUARD.
- **Fixed:** Disabled player gear retains starting Eden equipment on respawn and disables Personal Arsenal; TO&E handles missing LMF roles.
- **Fixed:** Supply aircraft destroyed before release lose only their undelivered cargo without refund or retry; wrecks and crew remain for Arma's normal cleanup.
- **Fixed:** Supply Drop remains available after player respawn while drops remain.
- **Fixed:** Dropped crates and floating boats can finish landing and regain damage when ground-contact detection returns false.
- **Fixed:** AI ground-target validation now checks the detected unit's vehicle instead of only the unit.
- **Fixed:** Vehicle QRF crews use the configured infantry, crew and pilot classes from `cfg_AI.sqf`; APC/TANK select a valid commander as group leader. Paradrop vehicle categories match Vehicle QRF crew/passenger compositions and post-landing infantry behavior, with occupants seated during descent.
- **Fixed:** Failed patrol waypoint searches now fall back to the patrol target instead of distant map positions, including at small patrol radii.
- **Fixed:** JIP teleport uses only unlocked ordinary passenger seats, excluding crew and turret/FFV positions, with the existing safe-ground fallback when no eligible seat is available.
- **Removed:** Legacy admin teleport and standalone administrative Safety On/Off actions. Warmup safety remains unchanged.
- **Removed:** Numeric and custom-string player respawn modes. Only `OFF`, `WAVE` and `TICKETS` are supported; invalid configuration falls back to `OFF`. Waves follow mission-time boundaries without the old 10-second minimum, and intervals display as `MM:SS`.



## LMF 1.42.0

* **Added:** `lmf\\\_bft\\\_fnc\\\_trackObject` for reusable client-local, JIP-compatible tracking of networked objects on the BFT map.
* **Improved:** Reworked the AI loadout system around Unit Loadout Arrays and setUnitLoadout for simpler configuration, faster AI spawning and reduced network traffic.
* **Removed:** Vehicle flip/recovery system.
* **Removed:** `var\\\_backpacksAll` \& `var\\\_giveInsignia` as they were not in use anymore.
* **Improved:** BFT no longer rebroadcasts group marker types whenever the map is opened or clicked, reducing unnecessary network traffic.
* **Improved:** Migrated supply drop and missile tracking to client-local markers, eliminating continuous marker-related network traffic.



## LMF 1.41c

* **Tweaked:** AI NVG management now only updates units during initialization and actual day/night transitions instead of every 30 seconds.
* **Tweaked:** AI NVG management now queries units from the configured enemy side instead of filtering all units.
* **Improved:** Moved shared boat assault, waypoint and shoreline helpers from `cfg\\\_spawn.sqf` into registered AI task functions.
* **Improved:** Moved survivor group selection and joining helpers from `cfg\\\_spawn.sqf` into registered AI group-management functions.
* **Improved:** Enabled AIThinkOnlyLocal on player clients so they no longer process targeting data for remote AI.



## LMF 1.41b

* **Removed:** The system that created a "reinforcement group" when players died. It did not work properly and was not really needed :)
* **Tweaked:** Switched the spectator medical UI from sleep to uiSleep and reduced its update frequency.
* **Tweaked:** Removed unnecessary delays when applying weapon safety after respawn.
* **Tweaked:** Renamed `a2k\\\_entityKilledEH` to `lmf\\\_entityKilledEH`.
* **Tweaked:** Supply drop and Para QRF variables now use explicit private scopes.
* **Tweaked:** Active LMF runtime helpers and state variables now use `lmf\\\_ai\\\_\\\*` and `lmf\\\_player\\\_\\\*` prefixes instead of `a2k\\\_\\\*`.
* **Fixed:** `fn\\\_paradropPlayers.sqf` can now run concurrently with different drop heights.
* **Fixed:** A delayed death script could reopen ACE Spectator after a fast respawn.
* **Fixed:** The FiredNear EH in `fn\\\_garrison.sqf` did not pass all available parameters.
* **Fixed:** The respawn wave confirmation dialog no longer closes the ACE Spectator UI when used by a dead admin.
* **Fixed:** Removed an obsolete spectator toggle after respawn that could cause an ACE Spectator script error.
* **Fixed:** AI spawn proximity checks now correctly account for all players instead of using the result from the last checked player.
* **Improved:** The spectator medical UI now uses the display provided by ACE and correctly prevents duplicate controls.
* **Improved:** Lone survivors from supported LMF-spawned infantry groups will join the nearest eligible group or receive a GUARD waypoint.



## LMF 1.41

* **Added:** Chance for garrison AI to surrender.
* **Added:** `fn\\\_addVehicleFlipAction.sqf`. (This adds an ACE action to player ground vehicles when they are upside down. Allowing players to recover them)
* **Tweaked:** Moved "Available Optics" to the "ACE Equipment" self-interact node.
* **Tweaked:** Rewrite of `fn\\\_paraQRF` (see file for parameters/behavior). Also added support for spawning through Zeus in zenModules.sqf
* **Tweaked:** Added `zen\\\_common\\\_fnc\\\_showMessage` for most things in zenModules.sqf
* **Tweaked:** Added some velocity to crates/vehicles that were dropped with `fn\\\_supplyDrop.sqf`
* **Tweaked:** Simplified `fn\\\_supplyDrop.sqf` a little
* **Tweaked:** Date manipulation during warmup (warmup.sqf \& resetDate.sqf). (Trying to only have the server do the work without remote execution)
* **Fixed:** MAT Optic was not added to AT-Gunner loadout. (`fn\\\_giveWeapon.sqf`).
* **Fixed:** Now deleting \_flareObject from tripFlare.sqf after a while. (Flares living forever might be an ACE3 bug?)



## LMF 1.4

* **Added:** `lmf\\\_common\\\_fnc\\\_distributeItems`. (Distributes items to unit in prioritized ordering)
* **Added:** `lmf\\\_player\\\_fnc\\\_spectatorMedical`. (Shows medical info for unit in focus when in ace spectator)
* **Added:** `lmf\\\_ai\\\_fnc\\\_taskPatrol`. (replaced `CBA\\\_fnc\\\_taskPatrol`)
* **Added:** manageNVG.sqf (makes AI stow away NVG at daytime and re-equip NVG when it's dark)
* **Added:** All AI spawner types with helicopters or planes can now be spawned both on land and over water.
* **Added:** Players can now request vehicles from Supply Drop (also available for Zeus)
* **Added:** `lmf\\\_ai\\\_fnc\\\_taskConverge` (makes AI groups converge on a position)
* **Added:** Parameter that will let aircraft start mid-air when paradropping players with `lmf\\\_common\\\_fnc\\\_paradropPlayers`.
* **Tweaked:** Substantial refactoring of player loadout system.
* **Tweaked:** AI infantry groups spawned over water(they are automatically given a boat) work better. They will much more often find a suitable shoreline to land on.
* **Tweaked:** Supply Drop now has a much shorter cooldown before players can request another. (\~10s)
* **Tweaked:** Reworked infantry garrison code for performance and made garrisoned units move around a little less.
* **Tweaked:** AI transport helicopters will take more chances by landing at more diverse positions.
* **Tweaked:** Player loadout: lowered the amount of medical items in the medics backpack.
* **Fixed:** Supply Drop bug (parachutes upside down sometimes)
* **Fixed:** AI Tank, APC and helicopters don't spawn unnecessary crew anymore.
* **Fixed:** warmupMaxTimer.sqf would run forever if mission started before warmup hit max time.
* **Fixed:** Death messages while in spectator overlapped if two or more players died at the same time.
* **Fixed:** Hunter AI used the wrong getPos command. (getPosASL -> getPosATL)
* **Fixed:** Hopefully fixed players sometimes dying when being ejected from aircraft with `lmf\\\_common\\\_fnc\\\_paradropEject`.
* **Fixed:** Fixed the issue with misfiring "`a2k\\\_entityKilledEH`" mission EH.
* **Removed:** Stopped using CBA settings file. (Using the servers settings is generally better)



## LMF 1.33b

* Removed "waitUntil {time > 1};" from groupTracker.
* Fixed hitEH problem where it wouldn't completely clear effects after hit.
* Made sure hitEH effects work in NVG mode.
* Added proper BFT support for AI supply drop



## LMF 1.33a

* Removed superfluous remoteExec from respawnWave. Added local message in killedEH instead.
* Fixed spawning height of boat when groups are spawned over water.
* AI units now get out of trucks, cars and APCs faster.
* Added hint that tells the unconscious player if there are nearby friendly units(and the distance to them)
* BFT: hover over group window now dynamically resizes depending on number of units in group.
* Removed some unused code from mapTweaks
* Simplified hitEH FX + added "blinking" on knockdown
* Cleaned up `cfg\\\_spawn` a little(more needed) + tweaked garrison.sqf
* Removed DIDJIP entry from toeBriefing.sqf
* Now stops playing AI "hit sound" on death.
* Tweaked warmup.sqf (removed warmup zone + some cleanup)
* Some cleanup of hunter/taskhunt



## LMF 1.33

* Removed MAT AI unit from random pool of units, now only spawned through manual placing or specific teams/squads.
* Updated UAV to randomize flyinheight once in a while.
* Updated UAV to explode after being destroyed and falling to the ground.
* Made sure UAV scripts terminate on UAV death.
* Fixed a bug in JIP teleport
* Fixed a bug in BFT where group icons did not update after the first time they were changed.
* Fixed the namespace bug in BFT
* BFT now can use different marker types
* Tweaked the BFT self-interact system
* Introduced dynamic simulation to garrison groups.
* Introduced global color variables and made many features use it.
* Improved death messages when in spectator to not remote exec to all dead players, instead use EH entitykilled.

