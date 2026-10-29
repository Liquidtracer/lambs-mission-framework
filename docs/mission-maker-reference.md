# LMF · Mission Maker Reference

Practical Markdown reference for **LAMBS Mission Framework 2.0**. This follows the same sections, terminology and examples as the **LMF Mission Maker Guide** included in the [latest Release](https://github.com/alexandertoftesund/lambs-mission-framework/releases). Use the HTML guide for the full reading and search experience; use this page for quick lookup and linking from GitHub.

All examples assume the LMF 2.0 example mission and its configuration files. Calls that create AI or deliver supplies must run on the **server**, with `spawn` when scheduled execution is required. Eden example names refer to objects/markers you configure, not special Arma object classes.

## Contents

**Getting started:** [Installation](#installation) · [Your first mission](#first-mission)

**Configuration:** [Mission settings](#configuration) · [Player equipment](#equipment) · [AI equipment](#ai-equipment) · [Briefing](#briefing)

**AI:** [AI spawning](#ai-spawning) · [Garrison](#garrison) · [Patrol](#patrol) · [Infantry QRF](#infantry-qrf) · [Hunters](#hunters) · [Vehicle QRF](#vehicle-qrf) · [Paradrop QRF](#para-qrf) · [AI tasks](#ai-tasks)

**Systems & support:** [Passenger paradrop](#passenger-paradrop) · [Fire support](#fire-support) · [Supply Drop](#supply-drop) · [Forward Deploy](#forward-deploy) · [Blue Force Tracking](#bft) · [Messages & utilities](#utilities)

---

<a id="installation"></a>
## Installation

<a id="installation-requirements"></a>
### Requirements

Arma 3 2.22 or newer, CBA A3, ACE3 and ACRE2. LAMBS Danger FSM is recommended; ZEN is optional.

<a id="installation-copy"></a>
### Start a new mission

The LMF Release includes a ready-to-use Arma 3 example mission. Its `mission.sqm` contains preconfigured Eden objects and markers, alongside `description.ext`, `framework/`, `settings/` and the mission's other integration files.

1. Download LMF from [GitHub Releases](https://github.com/alexandertoftesund/lambs-mission-framework/releases).
2. Copy the complete included example mission into your Arma 3 missions folder.
3. Open the example mission in Eden Editor.
4. Configure the four files in `settings/`: `cfg_Mission.sqf` for mission options, `cfg_Player.sqf` for player equipment, `cfg_AI.sqf` for the enemy faction and AI equipment, and `cfg_Briefing.sqf` for the briefing.
5. Move, customize or remove optional Eden building blocks, then build your mission. Keep the objects and markers needed for the features you use.

<a id="installation-eden-building-blocks"></a>
#### Included Eden building blocks

The example mission already contains these components. The names below are **Variable Names** assigned to ordinary Eden objects, not special object types or modules.

| Variable name | Used for |
| --- | --- |
| `crateRoles` | ACE menu for changing player roles. |
| `supplySpawner` + `supplyPad` | Supply menu and the position where crates appear. |
| `groundSpawner` + `groundPad` | Ground vehicle menu and its spawn position. |
| `airSpawner` + `airPad` | Aircraft menu and its spawn position. |
| `respawn` (map marker) | Required for **player-requested Supply Drops**, not every mission. |

These building blocks are optional unless you use the corresponding feature. You can reposition or remove them in Eden; keep each spawner and its pad together. Other standard LMF objects and markers are also included in the example mission.

The Release download also includes optional Player and AI loadout examples outside the playable mission folder.

<a id="installation-existing"></a>
### Adding LMF to an existing mission?

1. Keep your existing `mission.sqm`, `description.ext`, mission scripts and other mission-specific files. Do not replace them with the example mission's files.
2. Copy the `framework/` and `settings/` folders from the Release into your mission folder. Preserve any settings you have already customized.
3. Merge LMF function registration, event handlers and notifications into your existing `description.ext` without replacing your settings.
4. In Eden Editor, copy the building blocks you need from the example mission, or configure ordinary objects manually with the Variable Names above. Avoid duplicate variable names.
5. Adapt `settings/cfg_Mission.sqf`, `cfg_Player.sqf`, `cfg_AI.sqf` and `cfg_Briefing.sqf` to your mission.

The `description.ext` integration needs `CfgFunctions` (including `framework/functions.hpp`), `Extended_PreInit_EventHandlers`, `Extended_PostInit_EventHandlers`, `Extended_InitPost_EventHandlers` and the `CfgNotifications.hpp` include in `framework/notifications/`. Merge existing class entries instead of defining them twice.

Your existing mission scripts can stay in place. If your `description.ext` enables `cba_settings_hasSettingsFile = 1`, include and configure `CBA_settings.sqf`. Add `onFlare.sqs` only if you want LMF's flare reaction.

<a id="first-mission"></a>
## Your first mission

Create a village with a garrison, a patrol and reinforcements. This example uses three Game Logics to mark where the AI should appear.

Configure the enemy unit classnames in `settings/cfg_AI.sqf` before spawning AI.

<a id="first-mission-eden"></a>
### 1. Mark three spawn positions in Eden

Place three empty **Game Logics** and set their **Variable Name** in Eden:
> _Assets > System(F5) > Logic Entities > Objects > Game Logic_

- `garrison_1` – place it inside the village, near buildings.
- `patrol_1` – place it just outside the village.
- `qrf_1` – place it farther away, out of sight of players.

Game Logics are just one option. LMF spawners can also use other Eden objects or `[x,y,z]` positions. A trigger can serve as a spawn position too.

<a id="first-mission-script"></a>
### 2. Add the script

Open `init.sqf` in your mission folder (create it if needed) and add:

```sqf
if (isServer) then {
    // 8 soldiers defending the village
    [garrison_1, "SQUAD", 75] spawn lmf_ai_fnc_spawnGarrison;

    // 4 soldiers patrolling within 200 m
    [patrol_1, patrol_1, "TEAM", 200] spawn lmf_ai_fnc_spawnPatrol;

    // 4 soldiers with a GUARD task
    [qrf_1, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf;
};
```

`SQUAD` creates eight soldiers and `TEAM` creates four. The values `75` and `200` set the garrison and patrol radii in metres.

<a id="first-mission-markers"></a>
### 3. Add markers

Place relevent markers within your area of operations to inform players of objectives or known threats.
> _Assets > Markers(F6) > Icons_

> [!TIP]
> It's good practice to keep marker variable names memorable as it's useful to reference them within `settings/cfg_Briefing.sqf`

<a id="first-mission-reinforcements"></a>
### 4. Optional: add reinforcements

To create three QRF groups over time instead of one, replace the third line with:

```sqf
[qrf_1, "TEAM", 3] spawn lmf_ai_fnc_spawnInfantryQrf; // 3 groups total
```

After the previous QRF is eliminated, LMF can send the next group. Replacement waves stop if a player on the ground is within 500 m of `qrf_1`. See [Wave rules](#ai-spawning-spawn-once-or-use-waves).

<a id="configuration"></a>
## Mission settings

| File | Responsibility |
| --- | --- |
| [`settings/cfg_Mission.sqf`](#configuration) | Mission name, enemy side, warmup, respawn, BFT, vehicles and supplies. |
| [`settings/cfg_Player.sqf`](#equipment) | Player roles, clothing, weapons and ammunition. |
| [`settings/cfg_AI.sqf`](#ai-equipment) | Enemy infantry, vehicle types, equipment and skill. |
| [`settings/cfg_Briefing.sqf`](#briefing) | Briefing text. |

<a id="configuration-mission-settings"></a>
### General settings

| Setting | Meaning |
| --- | --- |
| `lmf_missionTitle` | Title shown at the start. |
| `lmf_missionSubtitle` | Optional subtitle. Use `""` to hide it. |
| `lmf_author` | Author shown in the briefing. |
| `lmf_enemySide` | Side used for enemy AI: `WEST`, `EAST` or `INDEPENDENT`. |
| `lmf_oldSchoolMap` | When enabled, disables sharing map markers and drawings, and hides new markers placed by others. BFT is controlled separately. |

<a id="configuration-warmup-and-respawn"></a>
### Warmup and respawn

| Setting | What it does |
| --- | --- |
| `lmf_warmup` | Turns warmup on or off. |
| `lmf_maxWarmupTime` | Mission time when warmup ends, in `"MM:SS"` format. Use `""` if an admin should end it manually. |
| `lmf_respawnType` | `"OFF"`: no normal respawn. `"WAVE"`: regular respawn waves. `"TICKETS"`: respawn waves with a limit per player. |
| `lmf_respawnTime` | Seconds between respawn waves. Use a number above 0. |
| `lmf_respawnTickets` | How many times each player can respawn in `TICKETS` mode. Use a whole number (0 or more). |

`WAVE` respawns players at set times. With a 30-second interval, waves occur at roughly 00:30, 01:00 and 01:30 of mission time, regardless of when someone dies. `TICKETS` uses the same timing but limits each player’s respawns. The count may reset when a player reconnects.

If a respawn setting is invalid, LMF turns off normal respawning. Admin commands can still respawn players.

<a id="configuration-player-equipment"></a>
### Player equipment

| Setting | Meaning |
| --- | --- |
| `lmf_playerGear` | Applies LMF loadouts automatically. If disabled, players respawn with the equipment they had when the mission started. |
| `lmf_keepRole` | With LMF loadouts enabled: `true` gives players their original Eden role on respawn; `false` gives them Rifleman. |
| `lmf_personalArsenal` | Lets players customize their role’s equipment in ACE Arsenal during warmup. Requires both `lmf_playerGear` and `lmf_warmup`. |
| `lmf_personalRadio` | Gives every player the configured personal radio. |
| `lmf_pistolAll` | Gives everyone a pistol when enabled. Otherwise, only the configured roles receive one. |
| `lmf_riflemanLat` | Gives Riflemen the configured light anti-tank weapon. |
| `lmf_playerMaps` | Who receives a map and compass: `0` everyone, `1` Platoon Leader, Platoon Sergeant, Squad Leader, Vehicle Platoon Leader, Vehicle Commander, Helicopter Pilot and Pilot, `2` nobody. |
| `lmf_playerGps` | Who receives a GPS: `0` everyone, `1` Platoon Leader, Platoon Sergeant, Squad Leader, Vehicle Platoon Leader, Vehicle Commander, Helicopter Pilot and Pilot, `2` nobody. |
| `lmf_playerNvg` | Who receives night-vision goggles: `0` everyone, `1` pilots, `2` nobody. |
| `lmf_camoCoef` | Camouflage setting. Higher values make players easier for AI to spot. |
| `lmf_jipTp` | Offers a player joining an ongoing mission one teleport to a suitable friendly player shortly after joining. |

<a id="configuration-vehicles"></a>
### Vehicles

List the ground vehicles and aircraft offered in the spawn menus:

```sqf
lmf_groundVehicles = ["B_MRAP_01_F", "B_Quadbike_01_F"];
lmf_airVehicles = ["B_Heli_Light_01_F", "B_Heli_Transport_01_F"];
```

For the vehicle menus, use the `groundSpawner` / `groundPad` and `airSpawner` / `airPad` objects from the starter mission. In your own Eden setup, assign these as **Variable Names** to ordinary objects. The pads mark where vehicles appear.

<a id="configuration-supply-crates"></a>
### Supply crates

For the Supply Spawner menu, use the starter mission’s `supplySpawner` and `supplyPad` objects. The first holds the ACE menu; the second is where crates appear. In an existing mission, give ordinary Eden objects these **Variable Names**.

| Category | Setting |
| --- | --- |
| LARGE | `lmf_supLarge` |
| SMALL | `lmf_supSmall` |
| EXPLOSIVES | `lmf_supExplosives` |
| MEDICAL | `lmf_supMedical` |
| VEHICLE | `lmf_supVehicle` |

Choose a crate classname for each category in `settings/cfg_Mission.sqf`. Use `""` to leave a category out. Give each enabled category a different classname.

Place a crate with one of your configured classnames in Eden, or spawn it from the Supply Spawner menu. With `lmf_playerGear = true`, LMF fills these crates automatically, once per crate. When disabled, the menus still spawn your crates with their existing cargo.

<a id="configuration-add-weapon-to-crate"></a>
#### Add Weapon to Crate

Add weapons from `settings/cfg_Player.sqf` to an existing crate, complete with mounted attachments and ammunition.

In Eden, place an ordinary ammunition box and set its **Variable Name** to `marksmanCrate`. Add this to `initServer.sqf`:

```sqf
[marksmanCrate, "DMR", 1, 8] call lmf_supplyCrates_fnc_addWeaponToCrate;
```

This adds one DMR with mounted attachments, one loaded magazine and eight extra magazines. The `DMR` category does not require a separate Marksman player role.

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Existing cargo crate or container, identified by its Eden Variable Name | Object · required |
| 1 | Exact uppercase weapon category from `cfg_Player.sqf`, such as `"DMR"`, `"LMG"` or `"RIFLE_GL"` | String · required |
| 2 | Number of assembled weapons, each with one full magazine | Positive whole number · default `1` |
| 3 | Total extra magazines added to the crate, **not per weapon** | Whole number (0 or more) · default `0` |

To add two weapon categories to the same crate (with Eden Variable Name `weaponCrate`):

```sqf
[weaponCrate, "RIFLE", 1, 8] call lmf_supplyCrates_fnc_addWeaponToCrate;
[weaponCrate, "PISTOL", 1, 4] call lmf_supplyCrates_fnc_addWeaponToCrate;
```

Run the function on the **server**, for example in `initServer.sqf`. Its cargo changes are shared with all players, including players joining in progress (JIP). Each call **adds** equipment without clearing existing cargo.

Use a regular crate with a different classname from the five automatically filled LMF Supply Crates, which may overwrite its contents. The selected category needs a configured weapon and compatible normal ammunition; empty selections can prevent an addition. Tracer and underbarrel grenade-launcher ammunition are not included.

<a id="configuration-supply-drop"></a>
### Supply Drop

- `lmf_supplyDropLimit`: total number of Supply Drops players can request. `0` turns off player requests.
- `lmf_supplyDropAircraft`: the plane or helicopter used to deliver supplies.
- `lmf_supplyDropVehicles`: lets players request vehicles from `lmf_groundVehicles`.

See [Supply Drop](#supply-drop) for scripted deliveries and player requests.

<a id="equipment"></a>
## Player equipment

Configure player roles and equipment in `settings/cfg_Player.sqf`.

Optional ready-made presets are supplied in `examples/loadouts/Player/`. Copy one into your mission as `settings/cfg_Player.sqf`, then check the required mods and player unit types in Eden.

<a id="equipment-roles"></a>
### Roles

LMF offers 20 configurable player roles, each with its own equipment and display name. At mission start, LMF can identify a player’s role from the unit type assigned to their slot in Eden.

In `settings/cfg_Player.sqf`, each role has a unit classname, a name shown to players and a rank. The classname must match the Eden unit type; give each role a different classname. An unconfigured unit type receives no automatic LMF role.

```sqf
private _medic = ["B_medic_F", "Medic", "CORPORAL"]; // Example: Eden Medic unit becomes the Medic role
```

The starter mission’s `crateRoles` object lets players change roles through ACE interaction. You can move it or provide another Eden object with the same **Variable Name**. The new role applies the equipment defined in `cfg_Player.sqf`.

<a id="equipment-clothing-and-weapon-choices"></a>
### Clothing and weapon choices

Give each role a selection of uniforms, vests, helmets, facewear and backpacks. For clothing, `[""]` uses the fallback role’s choices; `[]` means no choices.

```sqf
_medVest = [""];   // Inherits Rifleman vest pool
_vpsgVest = [""];  // Vehicle Commander inherits VPL vest
```

Vehicle Commander and Vehicle Crew use Vehicle Platoon Commander as their fallback for clothing and weapon category; other roles generally fall back to Rifleman.

Use one of these exact weapon-category names:

`FLARE_GUN` · `PISTOL` · `SMG` · `CARBINE` · `RIFLE` · `RIFLE_GL` · `DMR` · `LMG` · `MMG` · `LAT` · `MAT`

Configure weapons, magazines and attachments for each category in the same file. Supply crates take the **first** entry from their configured item lists.

<a id="equipment-respawn-and-personal-arsenal"></a>
### Respawn and Personal Arsenal

- With LMF loadouts enabled, respawn gives the player their original Eden role or Rifleman, depending on the `lmf_keepRole` setting. Switching roles during the mission does not change that respawn choice.
- With LMF loadouts disabled, respawn restores the player’s starting Eden equipment.
- During warmup, Personal Arsenal lets players select clothing, weapons and attachments allowed for their current role, when enabled in Mission Settings.

Personal Arsenal does not add ammunition or supplies. Moving to smaller containers or switching to incompatible weapons can remove items or magazines that no longer fit.

<a id="ai-equipment"></a>
## AI equipment

Edit `settings/cfg_AI.sqf` to choose your enemy units, their weapons and their vehicles.

Optional AI presets are supplied in `examples/loadouts/AI/`. Copy one into your mission as `settings/cfg_AI.sqf`, then check the required mods and set the appropriate `lmf_enemySide`.

<a id="ai-equipment-units"></a>
### Enemy units

Set the enemy unit classnames near the bottom of the file, such as `_rifleman`, `_squadLeader`, `_medic`, `_crew` and `_pilot`. Choose the enemy side in [Mission settings](#configuration-mission-settings).

<a id="ai-equipment-gear"></a>
### Clothing and weapons

Set `_enemyGear` to `true` for custom AI equipment, or `false` to keep the units’ original gear. You still need to configure the unit and vehicle classnames.

Clothing pools include `_uniform`, `_vest`, `_headgear` and the backpack lists. Helicopter pilots and vehicle crews have their own clothing settings.

Set weapons and magazines with entries such as `_rifle` and `_rifleAmmo`. Use `[]` for an ammunition list if you want LMF to pick compatible magazines.

<a id="ai-equipment-skill"></a>
### AI skill

`_enemySkill` sets the enemy skill preset: `0` untrained, `1` regular, `2` elite.

<a id="ai-equipment-vehicles"></a>
### Vehicles

Set vehicle choices in lists such as `_car`, `_tank` and `_drones`. `_paraVehicle` chooses the transport aircraft for Paradrop QRF.

When a list has multiple classnames, LMF picks one at random. Repeating a classname makes it more likely to be chosen.

<a id="ai-equipment-example"></a>
### Example settings

Change the matching lines already in `cfg_AI.sqf`. These are example entries, not a separate script to run.

```sqf
// Edit these values inside cfg_AI.sqf
private _enemyGear = true; // Equip enemy AI with your chosen gear
private _enemySkill = 1; // Regular (0 = untrained, 2 = elite)
private _rifle = ["arifle_Katiba_F"]; // Rifle used by enemy AI
private _rifleAmmo = []; // Pick compatible magazines automatically
private _tank = ["O_MBT_02_cannon_F"]; // Example tank
```

<a id="briefing"></a>
## Briefing

Write the briefing in `settings/cfg_Briefing.sqf`. Players will find it in their mission diary.

<a id="briefing-structure"></a>
### SMEAC briefing

LMF uses a simplified SMEAC-style briefing: **Situation** describes the setting and the forces involved, **Mission** says what players must accomplish, **Execution** covers the plan, and **Administration** covers transport and supplies.

<a id="briefing-example"></a>
### Example: Atsalis air-defense raid

Here is a shortened mission briefing. Edit the corresponding entries in `cfg_Briefing.sqf` for your own mission.

```sqf
// Situation
private _brfSituation = "CSAT holds an air-defense outpost on Atsalis.";
private _brfEnemyFaction = "CSAT 108th Air Defense Regiment";
private _brfEnemy = [
    ["Composition", "Defenders in fixed positions and on patrol."],
    ["Threats", "An HMG overlooks the landing area."],
    ["Reinforcements", "QRFs may arrive from the mainland."]
];
private _brfFriendFaction = "NATO Task Force Aegis";
private _brfFriend = [
    "FOX: Norwegian Coastal Ranger Platoon (players)",
    "USS Liberty: Destroyer (AI)"
];

// Mission
private _brfMission = "FOX will destroy the radar and two S-400 launchers on Atsalis.";

// Execution
private _brfExecIntent = "Land undetected, destroy the targets and extract.";
private _brfExecConop = [
    "Phase I: Land at <marker name='mrk_ip_a'>IP Alpha</marker>.",
    "Phase II: Destroy the radar and launchers.",
    "Phase III: Return to USS Liberty by RIB."
];
private _brfExecCoord = [
    "Maintain light and sound discipline.",
    "Bring at least three satchel charges."
];

// Administration
private _brfAdministration = [
    "Transport: RIBs aboard USS Liberty.",
    "Supplies: Ordnance crate aboard USS Liberty."
];
```

The marker link in the example makes **IP Alpha** clickable in the briefing. Add a marker named `mrk_ip_a` in Eden for the link to work.

<a id="ai-spawning"></a>
## AI spawning

Run AI spawners on the server, for example from `initServer.sqf` or a trigger with `if (isServer)`. Use `spawn` rather than `call`: these functions need time to create and equip the AI. Garrison and Patrol create one group; QRFs and Hunters can also send replacements.

With optional ZEN, Zeus can also spawn LMF AI, request supply drops, spawn configured vehicles, change player loadouts and use selected admin tools without writing SQF.

<a id="ai-spawning-choose-a-spawner"></a>
### Choose a spawner

- [Garrison](#garrison): defenders in buildings and nearby gun positions.
- [Patrol](#patrol): a group that patrols an area.
- [Infantry QRF](#infantry-qrf): infantry assigned an Arma 3 `GUARD` waypoint, allowing them to respond to known enemy contacts.
- [Hunters](#hunters): infantry that actively pursues players.
- [Vehicle QRF](#vehicle-qrf): vehicles, helicopters and drones.
- [Paradrop QRF](#para-qrf): aircraft delivering infantry or vehicles.

<a id="ai-spawning-infantry-group-sizes"></a>
### Infantry group sizes

| Type | Soldiers |
| --- | --- |
| `SQUAD` | 8 |
| `ATTEAM` | 4 |
| `TEAM` | 4 |
| `AATEAM` | 3 |
| `SENTRY` | 2 |
| `MGTEAM` | 4 |

Instead of a named group size, you can enter a number, such as `6`, to spawn six soldiers.

<a id="ai-spawning-spawn-once-or-use-waves"></a>
### Spawn once or use waves

**One group:** Leave out the ticket count. That group spawns once and receives its task.

**Several waves:** Add a ticket count. The first group counts too, so `3` means three groups in total:

```sqf
[spawn_1, "TEAM", 3] spawn lmf_ai_fnc_spawnInfantryQrf;
```

Waves stop when a player is on the ground near the spawn point. A player in the air nearby delays the next wave. A single spawn is not subject to these checks.

| Rule | Infantry QRF / Hunters | Vehicle / Paradrop QRF |
| --- | --- | --- |
| Nearby player on the ground | Within **500 m** | Within **1,000 m** |
| Replacement delay | No additional delay | Default **300 s** |
| When LMF can send another wave | When all soldiers in the previous infantry group are dead | When all members of the tracked group are dead, or the tracked vehicle is destroyed |

<a id="ai-spawning-eden-trigger"></a>
### Spawn from an Eden trigger

Place an Eden trigger where the QRF should appear. Set activation to the players’ side and **Present**; leave **Repeatable** off.

In the trigger’s **On Activation** field:

```sqf
if (isServer) then {
    [thisTrigger, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf;
};
```

The trigger itself provides the spawn position. When activated, it spawns one four-soldier Infantry QRF at the trigger’s position.

<a id="garrison"></a>
### Garrison

Creates infantry to defend nearby buildings and gun positions, including available weapons on vehicles. Run this on the server with `spawn`.

<a id="garrison-example"></a>
#### Example

```sqf
// Four defenders within 100 m of garrison_1
[garrison_1, "TEAM", 100, 1, false] spawn lmf_ai_fnc_spawnGarrison;
```

<a id="garrison-arguments"></a>
#### Arguments

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Spawn position | Object / [x,y,z] · default `[0,0,0]` |
| 1 | Infantry type or count | String / Number · default `"TEAM"` |
| 2 | Garrison radius in meters | Number · default `100` |
| 3 | How to fill positions: `0` spread evenly, `1` fill one building at a time, `2` random | Number · default `1` |
| 4 | Fill upper floors first (used with options `0` and `1`) | Boolean · default `false` |

<a id="garrison-behavior"></a>
#### Behavior

The four soldiers look for positions in buildings and nearby weapons within 100 m of `garrison_1`. Some defenders may leave their posts when enemies appear. You can send them to another objective with [Converge](#ai-tasks-converge).

<a id="patrol"></a>
### Patrol

Creates infantry to patrol around a marker, object or position. Run this on the server with `spawn`.

<a id="patrol-example"></a>
#### Example

```sqf
// Four soldiers patrol within 200 m of mrk_patrol
[spawn_1, "mrk_patrol", "TEAM", 200, "SLOW", "STAG COLUMN"] spawn lmf_ai_fnc_spawnPatrol;
```

<a id="patrol-arguments"></a>
#### Arguments

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Spawn position | Object / [x,y,z] · default `[0,0,0]` |
| 1 | Center of the patrol area | Object / marker name / position · default `[0,0,0]` |
| 2 | Infantry type or count | String / Number · default `"TEAM"` |
| 3 | Distance the patrol covers around its center, in meters | Number · default `200` |
| 4 | Patrol speed setting (see below) | String · default `"SLOW"` |
| 5 | Formation | String · default `"STAG COLUMN"` |

<a id="patrol-patrol-speed"></a>
#### Patrol speed

| Value | Behavior |
| --- | --- |
| `"SLOW"` | SAFE / LIMITED |
| `"FAST"` | AWARE / NORMAL |
| `"ATTACK"` | AWARE / LIMITED; no animation-speed override |

Four soldiers patrol within 200 m of `mrk_patrol`. After encountering enemies on land, they switch to combat and do not resume their patrol. Over water, LMF spawns a boat group.

<a id="infantry-qrf"></a>
### Infantry QRF

Spawns an infantry group with an Arma 3 `GUARD` waypoint. Rather than staying in place to defend a fixed area, the group can respond to known enemy contacts using Arma’s guard behavior. Add tickets to send replacements after a group is eliminated. Run this on the server with `spawn`.

<a id="infantry-qrf-examples"></a>
#### Examples

```sqf
[spawn_1, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf; // One group of 4
[spawn_1, "TEAM", 3] spawn lmf_ai_fnc_spawnInfantryQrf; // 3 groups over time
```

<a id="infantry-qrf-arguments"></a>
#### Arguments

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Spawn position | Object / [x,y,z] · default `[0,0,0]` |
| 1 | Infantry type or count | String / Number · default `"TEAM"` |
| 2 | Number of groups to spawn in total | Number · **optional**; omit for one-shot, pass for waves |

A one-time spawn gives you the new `GROUP` as a result if needed. For waves, a player on the ground within 500 m of the spawn point can stop further spawning. Over water, LMF spawns a boat group.

<a id="hunters"></a>
### Hunters

Creates infantry that pursues nearby players without needing to spot them first. Run this on the server with `spawn`.

<a id="hunters-examples"></a>
#### Examples

```sqf
[spawn_1, "TEAM", 1500] spawn lmf_ai_fnc_spawnInfantryHunters; // 4 hunters, 1500 m range
[spawn_1, "TEAM", 1500, 3] spawn lmf_ai_fnc_spawnInfantryHunters; // 3 groups over time
```

<a id="hunters-arguments"></a>
#### Arguments

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Spawn position | Object / [x,y,z] · default `[0,0,0]` |
| 1 | Infantry type or count | String / Number · default `"TEAM"` |
| 2 | Maximum distance to search for a player, measured from the group leader | Number · default `500` |
| 3 | Number of groups to spawn in total | Number · **optional**; omit for one-shot |

Hunters pursue the nearest eligible player within 1,500 m in these examples, excluding players in airborne aircraft. When only one Hunter remains, hunting stops and LMF tries to move the survivor into another eligible friendly group.

<a id="vehicle-qrf"></a>
### Vehicle QRF

Creates a vehicle with crew, and with infantry passengers for certain categories. Run this on the server with `spawn`.

<a id="vehicle-qrf-examples"></a>
#### Examples

```sqf
[spawn_1, "TANK"] spawn lmf_ai_fnc_spawnVehicleQrf; // One tank
[spawn_1, "HELITRANSPORT", 3, 300] spawn lmf_ai_fnc_spawnVehicleQrf; // 3 helicopter deliveries
[spawn_1, "DRONE", 3, 300] spawn lmf_ai_fnc_spawnVehicleQrf; // 3 drone waves
```

Each uses the vehicle classnames you selected in AI equipment .

<a id="vehicle-qrf-arguments"></a>
#### Arguments

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Spawn position (object direction, random for arrays) | Object / [x,y,z] · default `[0,0,0]` |
| 1 | Vehicle category | String · default `"TRUCK"` |
| 2 | Number of deliveries in total | Number · optional; omit for one-shot |
| 3 | Wait before spawning the next group or vehicle | Number · default `300` seconds |

<a id="vehicle-qrf-vehicle-categories"></a>
#### Vehicle categories

`CAR` · `CARARMED` · `TRUCK` · `APC` · `TANK` · `HELITRANSPORT` · `HELIATTACK` · `DRONE`

For replacement waves, what counts as the previous wave depends on the vehicle type:

| Category | Result from a single spawn / what triggers the next wave |
| --- | --- |
| `CAR`, `TRUCK` | Infantry group (`GROUP`) |
| `APC`, `HELITRANSPORT` | Passenger group (`GROUP`) |
| `CARARMED`, `TANK`, `HELIATTACK`, `DRONE` | Vehicle (`OBJECT`) |

Infantry dismounts from `CAR`, `TRUCK` and `APC` after nearby ground contact. A `HELITRANSPORT` drops off its passengers and leaves. Waves usually wait 300 seconds after the previous group or vehicle is lost.

<a id="vehicle-qrf-drones"></a>
#### Drones

Add the drone classnames you want to use to `_drones` in `settings/cfg_AI.sqf`. You can mix UAVs and UGVs. LMF chooses a random entry; an empty list spawns no drones.

Compatible IED and RF drones can also use their special attacks.

<a id="para-qrf"></a>
### Paradrop QRF

Creates an aircraft that drops infantry or a vehicle, then departs. Run this on the server with `spawn`.

<a id="para-qrf-examples"></a>
#### Examples

```sqf
[spawn_1] spawn lmf_ai_fnc_spawnParadropQrf; // Autonomous infantry drop
[spawn_1, "mrk_dropZone", 200, ""] spawn lmf_ai_fnc_spawnParadropQrf; // Infantry at a fixed drop zone
[spawn_1, "mrk_dropZone", 200, "TANK", 3, 300] spawn lmf_ai_fnc_spawnParadropQrf; // 3 tank drops
```

Without a drop zone, the aircraft uses an Arma `GUARD` waypoint and drops its infantry when it comes near players. To control the drop location, use a marker or trigger for a fixed drop zone. The third example delivers three tank drops over time.

<a id="para-qrf-arguments"></a>
#### Arguments

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Where the aircraft starts; above 20 m or over water it starts in the air | Object / [x,y,z] · default `[0,0,0]` |
| 1 | Drop zone (optional). Omit for autonomous flight and drop behavior. | String / Object / Location / Array · default `[0,0,0]` |
| 2 | Flight height in meters | Number · default `200` |
| 3 | Payload: empty string for infantry; vehicle classname/category | String · default `""` |
| 4 | Number of drops in total | Number · optional; omit for one-shot |
| 5 | Seconds to wait before the next drop | Number · default `300` |

<a id="para-qrf-payloads-and-drop-zones"></a>
#### Payloads and drop zones

An infantry drop brings one MG team and one AT team. For vehicles, choose `CAR`, `CARARMED`, `TRUCK`, `APC`, `TANK` or a valid vehicle classname.

A fixed drop zone can be a marker name, trigger or location. Leaving it out uses autonomous mode; `[0,0,0]` explicitly selects the same mode. Other position arrays are not supported as drop zones.

For a single drop, the result is the infantry group (`GROUP`) or the vehicle (`OBJECT`). The result can arrive before the drop has landed. With replacement waves, LMF waits for the dropped vehicle to be destroyed before replacing a vehicle payload, even if the infantry has already dismounted.

<a id="ai-tasks"></a>
## AI tasks

<a id="ai-tasks-converge"></a>
### Converge

Send selected LMF enemy groups toward an objective. Choose the groups using **tags**, such as `PATROL` or `GARRISON`. LMF assigns tags automatically when it spawns a group. Group names and callsigns do not affect selection.

Run Converge where the AI groups are owned (normally the server). Use `call` to issue the order; the groups then move toward the objective.

```sqf
// Send patrols and QRFs to the objective
[objective_1, ["PATROL", "QRF"]] call lmf_ai_fnc_taskConverge;

// Send garrison groups instead
[objective_1, "GARRISON"] call lmf_ai_fnc_taskConverge;

// Send all eligible LMF combat groups
[objective_1, "ALL"] call lmf_ai_fnc_taskConverge;
```

When you supply several tags, groups matching any of them are selected. Tags are not case-sensitive.

<a id="ai-tasks-tags"></a>
### Available tags

| Tag | Selects |
| --- | --- |
| `PATROL` | Groups spawned as patrols. |
| `GARRISON` | Groups spawned to defend buildings and gun positions. |
| `HUNTER` | Groups spawned to hunt players. |
| `QRF` | QRF groups, including groups previously redirected with Converge. |
| `INFANTRY` | Infantry groups, including some vehicle passengers. |
| `VEHICLE` | Groups operating ground vehicles. |
| `AIR` | Groups operating aircraft. |
| `BOAT` | Groups operating boats. |
| `DRONE` | UAVs and UGVs. These also have an `AIR` or `VEHICLE` tag. |
| `TRANSPORT` | Transport-only groups. These are excluded from Converge. |

A group can have several tags. For example, an infantry QRF has both `INFANTRY` and `QRF`. A patrol that becomes a QRF keeps its `PATROL` tag.

`ALL` is a special selection option, not a group tag. It selects every eligible LMF combat group. Ordinary Eden-placed groups and transport-only aircraft are excluded, even with `ALL`. Groups still being inserted or prepared are not redirected.

<a id="ai-tasks-arguments"></a>
### Arguments

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Objective: object or `[x,y,z]` position | Object / Array · **required** |
| 1 | One tag, a list of tags, or `ALL` (not group names) | String / String array · **required** |
| 2 | How far boats search for a landing spot | Number · default `2000` m |

The third argument is for boat landing, not a limit on how far away groups can be. Selected groups leave their previous tasks and head toward the objective. Garrison groups abandon their positions, and Hunters stop hunting.

<a id="passenger-paradrop"></a>
### Passenger paradrop

Makes an existing aircraft fly to an approach point, then drop its passengers at the drop zone. The pilot stays aboard. Run this with `spawn` where the aircraft is owned (normally the server), so the flight and drop can continue over time.

```sqf
// Approach the waypoint, then drop passengers over mrk_dropZone
[plane_1, "mrk_dropZone", "mrk_dropZone_WP", 220, 140, false] spawn lmf_paradrop_fnc_paradropPassengers;
```

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Existing aircraft with AI pilot | Object · required |
| 1 | Drop-zone area marker or trigger | String / Object · required |
| 2 | Approach waypoint marker name | String · required |
| 3 | Approach flight height | Number · required, meters |
| 4 | Drop height after approach point | Number · required, meters |
| 5 | Start the aircraft in the air (moves it up and gives it forward speed) | Boolean · required |

Here `plane_1` approaches `mrk_dropZone_WP` and drops its passengers at `mrk_dropZone`. Use an aircraft with an AI pilot. Players and AI can be passengers.

<a id="fire-support"></a>
### Fire support

Orders `art1` to fire at `target_1`. For artillery, this example requests six rounds after a 10-second preparation delay. An MK41 VLS fires one missile regardless of the number of rounds. Run the strike on the server with `spawn` to allow for the delay.

```sqf
// Request 6 artillery rounds at target_1 after preparation
[art1, target_1, 10, true, 6] spawn lmf_ai_fnc_fireSupportAtTarget;
```

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | AI artillery or VLS battery | Object · default `objNull` |
| 1 | Target object. Must pass the Arma `alive` check; not a marker or a position. | Object · default `objNull` |
| 2 | Preparation delay | Number · default `10` s |
| 3 | Mark as a player-requested strike (enables long-range radio messages and VLS BFT tracking) | Boolean · default `false` |
| 4 | Rounds for artillery; MK41 VLS always fires one missile | Number · default `1` |

Use an Eden object for `target_1`, not a marker. The object must return `true` for `alive target_1`; it does not need to be a soldier. Busy batteries reject new orders. Normal cooldown is about 10 seconds for artillery or 60 seconds for VLS.

<a id="supply-drop"></a>
### Supply Drop

Sends an aircraft from a spawn marker to a drop marker, where it parachutes down a crate or vehicle.

<a id="supply-drop-deliver-supplies-from-a-script"></a>
#### Deliver supplies from a script

Run this on the server with `spawn`. The aircraft and delivery are handled over time.

```sqf
// Deliver a crate from mrk_supplySpawn to mrk_supplyDrop
["mrk_supplySpawn", "mrk_supplyDrop", "C_Plane_Civil_01_F", "B_supplyCrate_F"] spawn lmf_supplyDrop_fnc_deliverSupplies;
```

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Spawn position | String / Object / Location / Group / Task / Array · default `objNull` |
| 1 | Drop position | String / Object / Location / Group / Task / Array · default `objNull` |
| 2 | Transport classname | String · default `"C_Plane_Civil_01_F"` |
| 3 | Classname of the crate or vehicle to deliver | String · default `"B_supplyCrate_F"` |
| 4 | Optional configured supply crate category | String · default `""` |

In this example, the aircraft starts at `mrk_supplySpawn` and drops a crate at `mrk_supplyDrop`. To deliver the configured SMALL supply crate, use:

```sqf
["mrk_supplySpawn", "mrk_supplyDrop", lmf_supplyDropAircraft, "", "SMALL"] spawn lmf_supplyDrop_fnc_deliverSupplies;
```

Crate categories are `LARGE`, `SMALL`, `EXPLOSIVES`, `MEDICAL` and `VEHICLE`. The chosen category must be enabled in [Supply Drop settings](#configuration-supply-drop).

<a id="supply-drop-player-requests"></a>
#### Player requests

To let players request Supply Drops, set `lmf_supplyDropLimit` above `0` and add a marker called `respawn`. Players need a map and a supported long-range ACRE radio, and warmup must be over. Requests have a shared 30-second cooldown.

If `lmf_supplyDropVehicles` is enabled, players can request vehicles listed in `lmf_groundVehicles`. Calls made directly from scripts and ZEN deliveries do not use the player-request quota or cooldown.

If the delivery aircraft is destroyed before dropping its cargo, that delivery is lost. Cargo that was already dropped continues descending. With BFT enabled, the landing position can be marked on the map.

<a id="forward-deploy"></a>
### Forward Deploy

Forward Deploy lets group leaders choose where their group will deploy when warmup ends. Groups can also bring vehicles and other registered assets.

<a id="forward-deploy-settings"></a>
#### Mission settings

In `settings/cfg_Mission.sqf`, enable both `lmf_warmup` and `lmf_forwardDeploy`. Set `lmf_forwardDeploy_height` to `0` for ground deployment, or a positive height in metres for an airdrop. Airdrop heights below 100 m are treated as 100 m.

<a id="forward-deploy-eden"></a>
#### Register vehicles and assets in Eden

For each vehicle or other asset that groups can claim, put this in the object's **Init** field in Eden:

```sqf
this setVariable ["lmf_forwardDeploy_registration", true];
```

Objects without this line are not available for Forward Deploy.

<a id="forward-deploy-in-mission"></a>
#### During warmup

Group leaders need a map. They use **ACE Self-Interact → Register Forward Deploy**, then left-click on the map to choose a position. Shift + left-click sets the direction; closing the map confirms it. They can cancel through **Unregister Forward Deploy**.

Registered assets have **Claim Vehicle** and **Unclaim Vehicle** ACE interactions. LMF deploys the registered groups and claimed assets shortly after warmup ends, on the ground or by parachute depending on the height setting.

<a id="bft"></a>
### Blue Force Tracking

Blue Force Tracking (BFT) shows friendly groups and chosen objects on the map. Enable `lmf_bft` in `settings/cfg_Mission.sqf`.

<a id="bft-callsigns"></a>
#### Callsigns

Choose available callsigns in `lmf_bftInfantryCallsigns`, `lmf_bftGroundCallsigns` and `lmf_bftAirCallsigns`. Use an empty list for any category you want to hide from callsign selection; tracking still works.

Group leaders choose their callsign and map icon through ACE self-interaction. LMF shows the available choices from your mission settings.

<a id="bft-track-an-object"></a>
#### Track an object

Track a vehicle, supply crate or other mission object with a map icon that follows its position as it moves. Call this on the server; LMF shares the live tracking with players who have a map and BFT enabled, including players who join later.

```sqf
[vehicle_1, "loc_car", "ColorWEST", [0.75, 0.75], "Vehicle"] call lmf_bft_fnc_trackObject;
```

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Object to track on the map | Object · default `objNull` |
| 1 | Marker type | String · default `"mil_dot"` |
| 2 | Marker color (classname from `CfgMarkerColors`) | String · default `"ColorWEST"` |
| 3 | Icon scale [width, height] | Number array · default `[1,1]` |
| 4 | Icon text | String · default `""` |
| 5 | Seconds between checks to update marker availability and cleanup | Number · default `0.25` |
| 6 | Stop tracking when `alive` becomes `false` for the object | Boolean · default `true` |
| 7 | Rotate with object | Boolean · default `false` |
| 8 | Seconds to show the marker. Use a negative number for no time limit | Number · default `-1` |
| 9 | Draw an outline around the icon and a shadow behind the text | Boolean · default `false` |

Here `vehicle_1` is the Eden variable name of the object being tracked. The icon follows the vehicle rather than marking just its starting position. Set argument 7 to `true` if the icon should also rotate with the object.

<a id="utilities"></a>
### Messages & utilities

<a id="utilities-ace-messages"></a>
#### ACE messages

This displays an “HQ” message on the client running the code, not automatically on every player’s screen:

```sqf
["HQ", "Transport is inbound."] call lmf_notifications_fnc_showAceMessage;
```

| # | Argument | Type / default |
| --- | --- | --- |
| 0 | Title | String · required |
| 1 | Message (structured text supported) | String · required |
| 2 | Icon image path; use an empty string for no icon | String · default radio icon |
| 3 | Message box height in ACE units | Number · default `3.3` |
| 4 | Message box width in ACE units | Number · default `12` |
| 5 | Sound name; empty for silence | String · default `"TacticalPing4"` |
| 6 | Icon scale | Number · default `1.45` |
| 7 | Show the message text in the error color | Boolean · default `false` |

To show the same message to all connected players on a dedicated server, run this on the server instead. The `-2` target sends it to clients, not the server itself:

```sqf
["HQ", "Transport is inbound."] remoteExec ["lmf_notifications_fnc_showAceMessage", -2];
```

Optional arguments set the icon, sound, text box dimensions and error color. ACE controls how long the message appears.

<a id="utilities-standard-notifications"></a>
#### Standard notifications

Use standard notifications for custom messages during the mission. From a server-side script or a server-activated trigger, send the notification to all connected players:

```sqf
// Show a notification on every connected player's screen
["New task received"] remoteExec ["lmf_notifications_fnc_showNotification", -2];
```

`-2` targets clients, not the dedicated server. Use this after LMF has initialized; the message is shown once to players currently connected, not replayed to players joining later. LMF handles victory and defeat notifications as part of ending the mission.
