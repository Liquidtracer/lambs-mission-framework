# Lambs Mission Framework

Lambs Mission Framework (LMF) is a reusable Arma 3 mission framework covering AI spawning and tasks, player equipment, briefing, tracking, support services, warmup, respawn and administration.

The repository root intentionally also forms the directly runnable Arma 3 development mission **LMF_DEV.Altis**, so LMF can be opened in Eden and tested in place.

Both `framework/` and `settings/` are part of LMF. `framework/` primarily contains implementation; `settings/` provides mission-maker-facing configuration. The surrounding mission files provide integration and the development/test mission. Some files, especially `description.ext`, contain both LMF integration and mission configuration.

## Repository structure

| Path | Purpose |
|---|---|
| `framework/` | Framework implementation and assets. |
| `settings/` | Mission-maker-facing LMF configuration. |
| `mission.sqm` | Unbinarized, source-controlled Eden output; modify through Eden Editor only. |
| Root mission scripts and configuration | LMF integration and the minimal development/test mission. |
| `docs/` | Architecture, development conventions and practical mission-maker reference. |
| `AGENTS.md` | Instructions for AI/Codex work in this repository. |
| `CHANGELOG.md` | LMF version history. |

## Documentation

- [Architecture and project context](docs/architecture.md)
- [Development guide](docs/development.md)
- [Canonical mission-maker reference](docs/mission-maker-reference.md)
- [Changelog](CHANGELOG.md)

## Status and requirements

The current development version is **2.0.0**, marked **Unreleased** in the changelog. Dedicated-server operation and Join-in-Progress (JIP) support are fundamental LMF development requirements.
