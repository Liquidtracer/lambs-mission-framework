# LAMBS Mission Framework

LAMBS Mission Framework (LMF) is a reusable Arma 3 mission framework providing AI spawning and tasks, player equipment, briefing, tracking, logistics, respawn, and mission utilities.

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

This repository is the development mission `LMF_DEV.Altis`. Its `mission.sqm` is not a finalized Release starter mission.

**New missions:** The planned LMF 2.0 Release package will include a ready-to-use starter `mission.sqm`, integration files, `framework/` and `settings/`. Its preconfigured Eden components will be organized for moving, customization or removal. The final starter mission and packaging for this workflow are not implemented yet. Until then, create and save a mission in Eden and integrate LMF as described below.

**Existing missions:** Keep your own `mission.sqm`. Copy `framework/` and `settings/` into your mission, adapting settings if you already use LMF. Merge these parts of [description.ext](description.ext) into your existing configuration:

- `CfgFunctions`, including `framework/functions.hpp`.
- `Extended_PreInit_EventHandlers` and `Extended_PostInit_EventHandlers` for LMF initialization.
- `Extended_InitPost_EventHandlers` for unit, vehicle and crate initialization.
- `framework/notifications/CfgNotifications.hpp` (merge notification classes if already present).

Merge existing classes and handlers without discarding your mission's entries. Review mission-level options such as respawn separately; do not overwrite the whole `description.ext`. The root `init.sqf`, `initServer.sqf` and `initPlayerLocal.sqf` are mission integration points, not required LMF initialization files. Integrate `onFlare.sqs` if you want the flare reaction. If you retain `cba_settings_hasSettingsFile = 1`, include and configure `CBA_settings.sqf`.

Configure mission options in `settings/cfg_Mission.sqf`, player roles/equipment in `settings/cfg_Player.sqf`, AI in `settings/cfg_AI.sqf` and briefing in `settings/cfg_Briefing.sqf`. Configured classes must exist in your loaded mods; the supplied equipment is not limited to the mods listed above.

Add only the Eden components needed by your features: `crateRoles` for Role Selector, the relevant spawner/pad pair for supplies or vehicles, and a marker named `respawn` for player Supply Drop. These are not universal LMF requirements. Once the starter mission is available, you can copy components from it into an existing mission; manual setup remains supported. Edit `mission.sqm` only through Eden. See [Eden setup](docs/mission-maker-reference.md#eden-setup-and-release-workflow).

## Quick start

After LMF preInit, run this on the server, for example in `initServer.sqf`:

```sqf
[spawn_1, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf;
```

Here `spawn_1` is an Eden object you named as an example spawn position, not a required LMF component. AI spawning does not require Game Logic objects: use an object (including a trigger) or a position array accepted by the function. `spawn` provides the required scheduled execution; it does not select the server. See [AI spawning](docs/mission-maker-reference.md#ai-spawning) for a direct trigger example, parameter types, results and LMF 2.0 migration notes.

## Documentation

- [Mission-maker reference](docs/mission-maker-reference.md)
- [Changelog](CHANGELOG.md)
