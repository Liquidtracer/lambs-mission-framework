# LAMBS Mission Framework

LAMBS Mission Framework (LMF) is a reusable Arma 3 mission framework with AI spawning and tasks, player equipment, Blue Force Tracking (BFT), supply support, warmup, respawn, and mission utilities.

The current development version is **2.0.0**, marked **Unreleased** in the changelog.

## Requirements

- Arma 3 **2.22 or later**
- CBA A3
- ACE3
- ACRE2

LMF is designed for use with **LAMBS Danger FSM** and uses its AI variables. Its absence does not necessarily prevent the entire framework from starting. **ZEN** is optional; LMF registers its ZEN integration when available.

The defaults in `settings/cfg_AI.sqf` and `settings/cfg_Player.sqf` include CUP and RHS classnames. Those mods are required to use the corresponding classes unchanged; they are not universal LMF requirements. Adjust the configured classes to your mission's mod set.

## Installation

To add LMF to an existing mission:

1. Copy the entire `framework/` folder into your mission folder.
2. Copy the `settings/` folder into your mission folder.
3. Merge the LMF configuration from this repository's [description.ext](description.ext) into your mission's existing `description.ext`:
   - The `CfgFunctions` setup, including `framework/functions.hpp`.
   - `Extended_PreInit_EventHandlers` and `Extended_PostInit_EventHandlers`, which run LMF initialization.
   - `Extended_InitPost_EventHandlers`, which route unit, vehicle, and crate initialization.
   - The `framework/notifications/CfgNotifications.hpp` include.

Preserve your mission-specific settings and merge existing config classes correctly. Do not overwrite your `description.ext` or treat the development mission's entire configuration as mandatory LMF setup. Do not copy its `mission.sqm` as part of installation.

The root `init.sqf`, `initServer.sqf`, and `initPlayerLocal.sqf` files are mission integration points, not required LMF files. Integrate `onFlare.sqs` separately if you want the existing flare reaction.

`CBA_settings.sqf` is separate mission configuration. If you retain `cba_settings_hasSettingsFile = 1` in `description.ext`, include and configure the corresponding `CBA_settings.sqf` file.

## Configuration

Configure LMF for your mission in these four files:

| File | Purpose |
| --- | --- |
| [settings/cfg_Mission.sqf](settings/cfg_Mission.sqf) | Mission information, enemy side, feature settings, warmup, respawn, BFT callsigns, vehicles, and supplies. |
| [settings/cfg_Player.sqf](settings/cfg_Player.sqf) | Player roles, clothing, weapons, and equipment pools. |
| [settings/cfg_AI.sqf](settings/cfg_AI.sqf) | Enemy infantry and vehicle classes, equipment, and skill settings. |
| [settings/cfg_Briefing.sqf](settings/cfg_Briefing.sqf) | Mission briefing content. |

All configured equipment, AI classes, and vehicles must exist in the loaded mod set. Automatic player role assignment matches Eden unit classnames to the roles configured in `cfg_Player.sqf`.

Set up the Eden objects needed by the features you use. Examples include `crateRoles` for Role Selector, `groundSpawner` / `groundPad` for ground vehicles, and `supplySpawner` / `supplyPad` for supplies. Supply Drop requires a marker named `respawn`. See the [mission-maker reference](docs/mission-maker-reference.md) for full settings and Eden requirements.

## Quick start

Place an object in Eden and give it the variable name `spawn_1`. After LMF has initialized, run this on the **server**, for example from your mission's `initServer.sqf`, to spawn an Infantry QRF:

```sqf
[spawn_1, "TEAM"] spawn lmf_ai_fnc_spawnInfantryQrf;
```

AI spawners require scheduled execution; `spawn` provides that context. Run spawning calls on the server only. See [AI spawning](docs/mission-maker-reference.md#ai-spawning) for other spawners, arguments, and result handling.

## Upgrading from LMF 1.x

LMF 2.0 introduces breaking changes. Update mission scripts, Eden calls, configuration, and LMF integration together:

- Functions now use a module-based structure and new API names. There are no legacy aliases.
- Paradrop QRF arguments now place drop zone, height, and payload after the spawn position, before optional tickets and delay.
- BFT callsigns use separate `lmf_bftInfantryCallsigns`, `lmf_bftGroundCallsigns`, and `lmf_bftAirCallsigns` arrays.
- Vehicle settings use `lmf_groundVehicles` and `lmf_airVehicles` arrays.
- AI spawning requires scheduled execution and uses native promises for one-shot results.
- Respawn supports only `OFF`, `WAVE`, and `TICKETS`.
- Supply Crate categories are `LARGE`, `SMALL`, `EXPLOSIVES`, `MEDICAL`, and `VEHICLE`. Check the updated settings and required Eden names, including `supplySpawner` / `supplyPad`.

See the [changelog](CHANGELOG.md) and [mission-maker reference](docs/mission-maker-reference.md) for migration details and current call contracts.

## Documentation

- [Mission-maker reference](docs/mission-maker-reference.md)
- [Changelog](CHANGELOG.md)
