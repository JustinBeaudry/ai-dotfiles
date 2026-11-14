# Checks: consolidate public ai-dotfiles

| node | requirement | verdict | evidence |
| --- | --- | --- | --- |
| N1 | Both working trees clean | pass | `git status --short --branch` showed `main...origin/main` for each checkout, with no changes |
| N1 | Public baseline works | pass | `./test.sh` printed `ok` |
| N1 | Public history secret scan | pass | `gitleaks git --no-banner --redact --exit-code 1 .`: no leaks found |
| N1 | Private history secret scan | fail | Scan found one potential secret in a file excluded from the public subset; private history is not imported |
| N2 | Selected skills are portable and reviewed | pass | Five skill directories copied after checking local paths, dependencies, and targeted secret scan |
| N2 | MCP examples contain no local values | pass | Only Context7 and Railway examples included; JSON and TOML parse; no local paths |
| N3 | Single-checkout linking and migration work | pass | `./test.sh` and `./test-single-checkout.sh` passed, including empty-home dry-run, link idempotence, and selected-skill migration |
| N4 | Review and documentation agree with behavior | pass | Review correction for empty-home dry-run tested; README explicitly states omitted skills stay on old checkout |
| N5 | Final checks pass | pass | ShellCheck, both shell tests, `sh -n`, JSON/TOML parse, `git diff --cached --check`, and `gitleaks dir` passed; real home migrated 5 selected links |
| N6 | Public remote verified | unresolved | Pending publication |
| N7 | Private repository retired safely | unresolved | 95 omitted local skills still link to the private checkout; decide whether to preserve local copies or remove those skills before remote/local cleanup |
