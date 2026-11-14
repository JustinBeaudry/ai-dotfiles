# Graph: consolidate public ai-dotfiles

## Inputs

- **TASK:** Consolidate the public `ai-dotfiles` and private `ai-dotfiles-private` repositories into one public `ai-dotfiles` repository.
- **OUTPUT:** A portable public repository containing the installer, a curated skill subset, MCP examples, and documentation. The old private remote is retired only after the new public state is verified.
- **CHECKS:** No private history or credentials published; selected skills are self-contained; MCP examples parse and use placeholders where local values are needed; linker works from the single checkout; existing and new tests pass; public remote contains the reviewed result.
- **SOURCES:** Current checkouts at `../ai-dotfiles` and `../ai-dotfiles-private`, their READMEs, MCP snapshots, and skill directories.
- **SCOPE:** Edit `ai-dotfiles` only until publication and migration are verified. Read `ai-dotfiles-private`; retain it as a recoverable source until final cleanup.
- **LIMIT:** One consolidation pass, with up to three corrections per failed check.

## Decisions proposed for approval

1. Keep `JustinBeaudry/ai-dotfiles` as the sole public repository. Copy selected files into its existing history; never push the private repository's commits or merge its Git history.
2. Start with these ten skills: `task-graph`, `browser-routing`, `playwright-cli`, `react-nextjs`, `railway`, `use-railway`, `start-timer`, `stop-timer`, `tracking-status`, and `use-spark`. Check each for local paths, secrets, and references to omitted files before inclusion. Drop or adapt any that fail portability checks.
3. Publish only portable MCP examples for `context7` and `railway`, with setup instructions for Claude, Codex, and Cursor. Keep project-specific servers, private paths, local app integrations, and live harness settings out of Git.
4. Change `ai-dotfiles link` to source `skills/` from this repo. Preserve nonmatching home skills and existing harness configs. Include a migration path for symlinks pointing at the private checkout.
5. After public verification, decide how to handle skills not selected for the public repo. Retire the private GitHub repository only after the local links are safely migrated or deliberately removed. Preserve a recoverable copy until the user approves final irreversible cleanup.

## Nodes

| id | kind | reads | writes | check | depends on |
| --- | --- | --- | --- | --- | --- |
| N1 | code | Both tracked trees and baseline tests | `checks.md` baseline rows | Clean status, baseline test, inventory, and secret scan recorded | none |
| N2 | model | Selected private skills and MCP snapshots | `skills/`, `mcp/`, README draft | Every selected file is reviewed for secrets, private paths, external dependencies, and license | N1 |
| N3 | code | Public installer and tests, N2 file layout | `ai-dotfiles`, `test.sh` | Single-checkout linking and safe migration scenarios pass | N2 |
| N4 | model | Consolidated diff | README and review fixes | Documentation matches behavior; review findings resolved | N3 |
| N5 | code | Saved diff and test output | `checks.md`, `progress.md` | Shell tests, JSON validation, static checks, secret scan, and status inspection pass | N4 |
| N6 | code | Verified public tree | Public Git commit/PR and remote verification | Public remote contains only reviewed files; private remote untouched until cleanup approval | N5 |
| N7 | code | Verified publication and link migration | Private remote/local retirement | No installed link depends on old checkout; recoverable backup recorded; private remote retired | N6 |

## Parallel groups

N1 is the baseline. N2 and N3 are sequential because the installer needs the chosen file layout. Independent read-only checks inside N1 and N5 may run concurrently.

## Code nodes

N1 inventory and scan; N3 linker changes and tests; N5 validation; N6 Git publication; N7 cleanup.

## Rules learned

- The current public linker assumes `../ai-dotfiles-private/skills`.
- The private checkout contains about 100 skill directories, while its global MCP snapshots list four servers.
- The private Git history has a secret-scan finding; private history must not be merged into public history.

## Decisions log

- 2026-11-14: Approved the initial ten-skill, two-MCP plan.
- 2026-11-14: Reduced the public set to five self-contained skills after the portability audit. Timer wrappers relied on an omitted skill; the two Railway skills overlapped and one contained fixed project IDs. Railway remains available as an MCP example.
- 2026-11-14: Review found that 95 omitted local skill links still depend on the private checkout. Retain the checkout until a separate local migration decision is made.
