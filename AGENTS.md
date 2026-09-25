# Instructions for AI/Codex

## Collaboration and task scope

Treat the user as an experienced Arma 3 mission maker and technical collaborator. Do not explain basic concepts unless asked. Keep responses relatively concise, but explain important tradeoffs and limitations.

When reviewing, assessing, explaining or proposing, do not change files unless implementation has already been agreed. When implementing, proceed within the agreed scope without unnecessary confirmations. Do not perform unrelated refactoring, cleanup, modernization or redesign.

Preserve existing gameplay, UI, information flow and controls unless a behavior change is explicitly requested. Describe necessary behavior changes clearly; do not hide them as “cleanup” or “robustness”. Intentional design choices are not errors just because another solution seems more general.

Before recommending a rebuild, identify the concrete problem, the smallest useful change and the cost in complexity, migration and testing. Consider whether the current solution should be retained. When refactoring, preserve gameplay intent and differences between contracts; ask one focused question if essential intent is unknown.

Treat suggestions during exploration as hypotheses, not decisions. Challenge them with reasoning, distinguish technical possibility from recommendation, and explain why a recommendation changes, if it does.

## Documents to read

- Follow [docs/development.md](docs/development.md) for development principles, naming, comments, file headers, testing and documentation/changelog policy.
- Before technical work involving SQF, LMF, initialization, integration, locality, multiplayer or JIP: read the common section of [docs/architecture.md](docs/architecture.md), then the affected module sections and dependencies. Read the entire document for a broad architecture review or unclear scope.
- Use [docs/mission-maker-reference.md](docs/mission-maker-reference.md) when working with mission-maker-facing calls and configuration. This is the canonical practical reference.
- Unchanged content already available in context does not need to be read again. The architecture document is not mandatory for tasks that clearly do not affect technical mission functionality.

Documentation does not replace code inspection. Update affected documents for agreed contract/behavior changes according to the development guide. For assessment-only work, propose documentation corrections rather than implementing them. Do not create new documentation files, review reports, changelogs or test plans without an explicit request; deliver such results in the conversation by default.

## Critical technical requirements

Dedicated server operation and Join-in-Progress (JIP) are fundamental requirements. Account for actual locality, initialization, execution context, state and network usage; a solution that only works in the editor is not sufficient.

Inspect the relevant LMF code before describing or changing it. Use the existing framework rather than assuming a parallel system must be built. Code/config describes the implementation; user requirements and agreed design choices describe the intent. Make contradictions and missing context explicit rather than guessing. When debugging, seek the actual cause rather than just a workaround.

Do not invent Arma 3 commands, SQF syntax, functions, engine or mod behavior. When an assessment depends on engine behavior, inspect the specific page in the current [Bohemia Interactive Community Wiki](https://community.bohemia.net/wiki/), including relevant syntax, locality, execution, MP and version conditions. For ACE/CBA-specific behavior, use relevant project documentation or source code and distinguish the current upstream source from the installed mod version.

Identify the source pages used. Distinguish documented contracts, community comments, interpretations derived from code and untested assumptions. Point out ambiguous or incomplete documentation; propose a minimal reproduction or dedicated-server test when needed.

Explicitly distinguish static code/reference checks, parser/syntax checks, local runtime tests, dedicated-server tests with multiple clients and JIP tests. Report only checks actually performed and what they establish. A local test or parser check does not prove correct multiplayer behavior. Distinguish reported symptoms, risks derived from code and runtime-confirmed causes; give short, concrete remaining tests when relevant.

## Project boundaries and protected configuration

Both `framework/` and `settings/` are LMF: implementation and mission-maker configuration. Root files also provide the development mission and integration; `description.ext` is mixed. Classify by content, not just location. Do not move functionality between layers as unrelated cleanup.

`mission.sqm` is owned by Eden Editor and intentionally unbinarized. It may be inspected and diffed, but must never be edited directly. Describe necessary Eden changes to the user; identify missing context rather than assuming the contents. Do not revert it automatically. Do not stage or commit it unless the user explicitly asks to capture the current Eden-generated version. Incidental changes from opening or saving the development mission in Eden must be left untouched and excluded from unrelated commits. When the user explicitly approves a new version, inspect the diff first and keep the change separate from unrelated documentation or framework changes where practical. Do not add `mission.sqm` to `.gitignore` or hide it with Git index flags such as `assume-unchanged` or `skip-worktree`.

Forward Deploy and Vehicle Service must not be reviewed or changed without an explicit request, including in broad surveys. This boundary does not apply to the shared Paradrop module or other vehicle initialization and asset spawners. Preserve documented design rationale and intentional choices.

The configured Nopryl UIDs provide intentional persistent technical/admin access. The lists in `framework/XEH_preInit.sqf` and `description.ext` serve different access systems. Do not remove, consolidate or change them as cleanup.
