# Developing Lambs Mission Framework

Development principles and code conventions for LMF. Technical architecture and module contracts are in [architecture.md](architecture.md); practical mission-maker calls are in [mission-maker-reference.md](mission-maker-reference.md). AI/Codex instructions are in [AGENTS.md](../AGENTS.md).

## Project model and layers

The repository root is also the directly runnable Arma 3 development mission `LMF_DEV.Altis/`. Both `framework/` and `settings/` are LMF: the implementation is mainly in `framework/`, while `settings/` is the configuration layer for mission makers. Root files provide integration and the development/test mission; `description.ext` contains both LMF integration and mission setup. Classify content by function, not just folder location.

Inspect settings and their use before classifying them as general or mission-specific. Distinguish framework code, LMF configuration and mission integration. Do not move functionality between layers without considering where it naturally belongs. The development mission should be minimal; temporary test code is normally removed before committing unless it is useful permanent test/integration infrastructure.

`mission.sqm` is owned by Eden Editor and intentionally stored unbinarized. It may be inspected and diffed, but must never be edited directly by Codex. Changes are made only through Eden Editor. Missing Eden context must be described, not replaced with assumptions. Do not automatically revert `mission.sqm`. If Eden has changed it, the current Eden-generated version may normally be included in the next relevant commit. Inspect the diff before staging it. If the diff is unusually large, structurally surprising, or appears unrelated to the intended Eden work, stop and report it before staging. Keep its changes separate from unrelated commits when that improves clarity, but do not require a separate commit for every normal Eden save. Do not hide it using `.gitignore`, `assume-unchanged`, `skip-worktree`, or similar Git index tricks.

Code and configuration describe the current implementation; explicit requirements and agreed design choices describe intended behavior. Where they conflict, the discrepancy must be made explicit. Use existing LMF where it fits rather than building parallel systems.

## Change discipline

Bug fixes, optimization and refactoring should preserve existing gameplay, UI, information flow and user controls by default. Do not introduce design changes as part of technical cleanup. Intentional limitations and specific design choices must not be treated as errors just because another solution seems more general or cleaner.

Describe necessary behavior changes explicitly. Do not hide changes in functionality, appearance or controls behind phrases such as “cleanup” or “improved robustness”.

Before recommending a rebuild of a working system, describe the concrete problem, the smallest useful change and the cost in complexity, migration and testing. Explicitly consider whether the current solution should be retained. Fewer lines of code or a more general architecture are not sufficient justification on their own.

When refactoring, identify the gameplay intent the code serves and which differences must be preserved. If unknown intent is critical to the recommendation, ask one focused question before settling on the solution. Do not assume similar code blocks have the same contract.

When adding new functionality to LMF, treat it as long-term, reusable framework code, but avoid unnecessary abstraction and overengineering.

## Multiplayer and initialization

All missions run on a dedicated server.

All missions must support Join-in-Progress (JIP).

These are fundamental requirements for all technical development in the project.

When proposing, writing or assessing technical solutions, account for Arma 3's actual multiplayer and execution model. The solution must work correctly under real multiplayer conditions, not just in the editor or a simple local test.

Consider relevant aspects such as locality, initialization, execution context, state and JIP without committing the solution to specific mechanisms in advance.

Consider performance, network usage, robustness, readability and maintainability to the extent relevant to the problem.

Do not invent Arma 3 commands, SQF syntax, functions or engine behavior. If technical correctness is uncertain, verify rather than guess.

When debugging, try to identify the actual cause of the problem rather than merely creating a workaround.

### ACE self-action lifetime

Persistent player self-actions should normally be registered once per client as inherited `CAManBase` self-actions (`ace_interact_menu_fnc_addActionToClass`, type 1, inheritance enabled). Use ACE's current `_player` callback argument in conditions/statements that need the acting unit; do not capture the registration-time `player` in action parameters. Conditions that only need shared availability can read that state directly.

Keep state that must survive player-object replacement at client/session lifetime rather than only on the initial unit. Retain existing group/server ownership and replication where appropriate; client-local state is not automatically restored on reconnect/JIP. Class registration alone does not fix unit-bound state or captured parameters. Intentional unit-bound actions/state remain valid: choose the lifetime from the behavior contract, document it, and do not add respawn support merely for consistency. Keep module-specific details in architecture.md and the relevant code.

Reference: [ACE interaction framework](https://ace3.acemod.org/wiki/framework/interactionmenu-framework).

## Technical verification and sources

When a technical assessment depends on what an Arma 3 command, function or engine mechanism actually does, verify the relevant information against the current Bohemia Interactive Community Wiki:

https://community.bohemia.net/wiki/

Do not rely solely on built-in model knowledge when up-to-date documentation can be consulted.

When using or assessing SQF commands, inspect the specific wiki page for the command and check relevant aspects such as:

* syntax and alternative syntax forms
* argument and return types
* locality
* local or global effect
* execution context
* multiplayer behavior
* server and client restrictions
* version requirements and any branch dependency
* documented edge cases and relevant notes

Distinguish between:

* documented command or engine behavior
* community comments and examples on the wiki
* interpretations based on existing LMF code
* assumptions that still require testing

The Community Wiki is a Bohemia-hosted, community-maintained reference and may contain incomplete, unclear or outdated information. If the documentation is ambiguous, contradicts existing code or does not cover the multiplayer situation in question, point out the uncertainty.

When needed, propose a minimal reproduction or a dedicated-server test rather than presenting assumed engine behavior as fact.

When a technical conclusion relies on wiki documentation, identify the command or topic pages used.

For ACE- and CBA-specific behavior, inspect relevant documentation or source code from the respective project. BIKI alone is not sufficient to establish mod-specific contracts. Distinguish current documentation/source code from the mod version the mission actually runs with when this could affect the conclusion.

## Naming in LMF

Active framework helpers and framework state must use the `lmf_` prefix and follow the naming conventions of the relevant module. Mission-specific `a2k_*` helpers must not be renamed as part of general LMF cleanup.

Naming and comment rules apply to new and changed code within the task's scope. Existing deviations outside this scope must not be standardized without agreement.

Folders/actions use camelCase and descriptive whole words with established technical abbreviations. Script/include files have descriptive names without `fn_`; execution context alone is not a sufficient name.

Local variables, parameters and local code variables use `_camelCase`, without internal underscores. This also applies to private settings in `settings/`. Abbreviations are treated as words: `_nvg`, `_apcCamo`, `_groupId`, `_rifleGlAmmo` and `_firedEh`. The same identifier must have the same spelling in definitions and all references, including strings containing variable names or SQF code.

Global LMF names use `lmf_camelCase` or the module's established `lmf_modul_camelCase`. Registered functions use `lmf_modul_fnc_camelCase`, with matching function classes, `fn_*.sqf` files and call sites. Global mission settings retain `var_camelCase`; internal framework state uses `lmf_`. Constants retain `LMF_UPPER_SNAKE_CASE` as an explicit exception.

Established module prefixes are retained. CamelCase standardization does not in itself justify changing terms, HashMap keys, action/event/marker/layer IDs, Eden names or external ACE/CBA/BIS/mod names. Engine- and callback-defined variables retain the names specified by their contracts. When renaming, check include scopes and all relevant references for collisions and breakage; do not change scope, values or execution as part of the rename.

## Comment style and file headers

Comments in `framework/` and `settings/` are written in English, in normal sentence case and with one space after `//`. Comment text, header titles and section names begin with a capital letter and otherwise use normal sentence case. Do not use all caps, all lowercase or title case. Established abbreviations, proper names and code identifiers retain their correct spelling. Avoid decorative banners and generic `INIT`/`RETURN` labels.

A limited exception applies to the three main sections in `framework/XEH_postInit.sqf`: `All machines`, `Server` and `Player clients`. These use one ASCII comment line in the form `// --- All machines ---`, padded with hyphens through column 100. Subsections follow the normal comment style without decorative separators.

Prefer one short comment line directly above the code when sufficient. Combine section names and necessary guidance, and avoid repetition between the file header, section comment and example. Use multiple lines when the contract or rationale requires it; do not compress the text into unreadably long lines.

All code files in `framework/` and `settings/` must have a `/* ... */` file header with a separate, short, human-readable title line, followed by a description of the file's purpose. The header should add purpose or contract information beyond the filename. There must be exactly one blank line after the closing `*/` before code, preprocessor directives or the next comment begins. Document relevant arguments, return values, locality/execution requirements and, where useful, a call example, without mandatory empty fields. For include fragments, describe the inclusion point and inherited assumptions where relevant. Ordinary comments inside the file use `//`.

Explain why, limitations and special values. Remove comments that merely repeat names or self-explanatory code. Retain more guidance in `settings/` than in internal framework code, but consolidate repetition. Document current behavior without ongoing refactoring history, and preserve author and source credits. Intentionally commented-out code must not be activated as part of comment cleanup.

## Simplicity for mission makers

Mission makers mainly work with `settings/`. Prioritize understandable configuration and good defaults. Normal mission setup should not require changes in `framework/`; mission integration still belongs in the mission's own scripts and Eden.

Avoid new settings, compatibility layers and extensive logging without a concrete need. Keep complexity internal when it simplifies normal setup, but do not build general systems for hypothetical needs.

When changing existing function calls or configuration, check relevant call sites and briefly describe any required migration. Do not assume unknown call sites have been verified.

## Testing and reporting

Clearly distinguish between:

* static code review and file-reference checks
* parser/syntax checks
* local testing in Arma
* dedicated-server testing with multiple clients
* JIP testing

State what has actually been checked, what the checks establish and what remains. A passed parser check or local test does not establish correct multiplayer behavior.

Distinguish reported symptoms, errors or risks derived from code and causes confirmed through runtime observation. Do not present a likely cause as runtime-confirmed.

For relevant changes, describe remaining in-game tests briefly and concretely, with the triggering situation and expected result. Summarize what changed and any implications for mission makers.

After major behavior changes, recommend a focused in-game test before the next major rebuild of the same system. Use the reported test situation, expected and actual behavior, and test environment as the basis for further assessment. Ask for missing test details only when they are necessary for the conclusion.

## Documentation maintenance

[README.md](../README.md) is the public entry point. [architecture.md](architecture.md) describes architecture and module contracts, clearly distinguishing agreed design, implementation, reported runtime observation and unresolved behavior. The document does not replace code inspection and must not be used as an ongoing review report, changelog or detailed test plan.

When an agreed implementation changes architecture, initialization, function contracts or documented behavior, update the affected parts of the architecture document. Revise the current description in its primary location and remove outdated duplication; do not add a new change report alongside old text. Preserve design rationale, intentional choices and relevant unresolved limitations.

[mission-maker-reference.md](mission-maker-reference.md) is the canonical practical mission-maker reference. When documented entrypoints, arguments or call requirements change, check and update relevant examples. Detailed contracts also belong alongside the relevant code. Any future presentation of the content should be based on this source, not require a separately maintained reference.

If the documentation contradicts the code, distinguish an incorrect description from an implementation that deviates from agreed design. Significant technical conclusions must be verified against current code, configuration and relevant engine/mod sources.

## Changelog

[CHANGELOG.md](../CHANGELOG.md) is a short, human-readable version overview for LMF, not a work log. After an agreed LMF implementation, consider whether the development version needs a new or updated entry. Maintenance is part of implementation, but not every change requires a log entry.

Log new or removed features, noticeable changes in gameplay or controls, important bug fixes and significant changes to architecture or configuration. Consider the impact on players and mission makers, not the number of changed lines of code. Pure documentation, comment and formatting changes, isolated renames, local code cleanup and small text, UI or timing adjustments are normally not logged.

Use this test: Would this deserve a place in a short “what's new” summary compared with the previous release? If not, omit the item. When in doubt, do not add a new item. Combine related changes into one item and update existing items in the development version rather than logging intermediate steps, follow-on bugs and fine-tuning separately. Log only completed changes, not proposals, plans or reviews.

Write short English items with one of these prefixes:

* **Added:** New functionality.
* **Improved:** Significant improvement to existing functionality or structure.
* **Tweaked:** Intentional adjustment to behavior, balance or defaults.
* **Fixed:** Correction of errors or unintended behavior.
* **Removed:** Removed functionality or support.

Describe the result rather than internal work steps. Do not promise better performance, confirmed multiplayer support or successful testing without evidence. Mission-specific changes do not belong in the LMF changelog.

Keep the newest version at the top, with one Markdown heading per version, for example `## LMF 2.0.0 — Unreleased`. Use bullet lists such as `- **Fixed:** Short description.`, a blank line after headings and between versions, and code formatting around identifiers when needed. Avoid tables, empty categories and empty “Known bugs” sections.

Preserve older version history, including its earlier level of detail and any uncategorized items. Do not move older changes into the development version, invent release dates or assume a historical version was released. Change the version number or mark a version as released only by agreement.
