# LAMBS Mission Framework

LAMBS Mission Framework **2.0** (LMF) is a reusable Arma 3 mission framework providing AI spawning and tasks, player equipment, briefing, tracking, logistics, respawn, and mission utilities.

`framework/` contains the framework implementation and assets. `settings/` contains mission-maker configuration.

## Requirements

- Arma 3 2.22 or later
- CBA A3
- ACE3
- ACRE2

LMF is designed to work with LAMBS Danger FSM. ZEN integration is also supported.

## Download

Download the latest version from [GitHub Releases](https://github.com/alexandertoftesund/lambs-mission-framework/releases).

## Installation

The repository root is the maintained Eden example mission, `LMF_DEV.Altis`. Its working folder name is retained for ongoing development; versioned GitHub Releases provide a ready-to-use snapshot of the mission, including `mission.sqm`, integration files, `framework/` and `settings/`.

**New missions:** Download the complete LMF 2.0 mission package from [GitHub Releases](https://github.com/alexandertoftesund/lambs-mission-framework/releases) and copy the included mission folder into your Arma 3 missions folder. Open it in Eden Editor. Configure mission options in `settings/cfg_Mission.sqf`, player roles and equipment in `settings/cfg_Player.sqf`, AI in `settings/cfg_AI.sqf` and the example briefing in `settings/cfg_Briefing.sqf`. Move, customize or remove the optional preconfigured Eden building blocks. Keep the objects and markers needed for features you use.

**Existing missions:** Keep your own `mission.sqm`. Copy `framework/` and `settings/` into your mission, adapting settings if you already use LMF. Merge these parts of [description.ext](description.ext) into your existing configuration:

- `CfgFunctions`, including `framework/functions.hpp`.
- `Extended_PreInit_EventHandlers` and `Extended_PostInit_EventHandlers` for LMF initialization.
- `Extended_InitPost_EventHandlers` for unit, vehicle and crate initialization.
- `framework/notifications/CfgNotifications.hpp` (merge notification classes if already present).

Merge existing classes and handlers without discarding your mission's entries. Review mission-level options such as respawn separately; do not overwrite the whole `description.ext`. The root `init.sqf`, `initServer.sqf` and `initPlayerLocal.sqf` are mission integration points, not required LMF initialization files. The included `initServer.sqf` demonstrates adding a configured DMR to the Eden crate `marksmanCrate`. Integrate `onFlare.sqs` if you want the flare reaction. If you retain `cba_settings_hasSettingsFile = 1`, include and configure `CBA_settings.sqf`.

Configured classnames must exist in your loaded mods; the supplied equipment is not limited to the mods listed under Requirements.

For optional Eden features, use the included `crateRoles` object for Role Selector; the `supplySpawner` / `supplyPad`, `groundSpawner` / `groundPad` and `airSpawner` / `airPad` pairs for their menus; and a marker named `respawn` for player-requested Supply Drop. These are not universal LMF requirements. Copy only the components you need into an existing mission using Eden Editor, or set up ordinary Eden objects with the documented variable names. Edit `mission.sqm` only through Eden. See [Eden setup](docs/mission-maker-reference.md#eden-setup-and-release-workflow).

## Quick start

After LMF preInit, run this on the server, for example in `initServer.sqf`:

```sqf
[spawn_1, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf;
```

Here `spawn_1` is an Eden object you named as an example spawn position, not a required LMF component. AI spawning does not require Game Logic objects: use an object (including a trigger) or a position array accepted by the function. `spawn` provides the required scheduled execution; it does not select the server. See [AI spawning](docs/mission-maker-reference.md#ai-spawning) for a direct trigger example, parameter types, results and migration guidance.

## Documentation

- [Mission-maker reference](docs/mission-maker-reference.md)
- [Changelog](CHANGELOG.md)
