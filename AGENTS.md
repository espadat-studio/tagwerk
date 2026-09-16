## Agent skills

### Issue tracker

Issues live in GitHub Issues for `espadat-studio/tagwerk` via the `gh` CLI. See `meta/agents/issue-tracker.md`.

### Triage labels

Default five-role vocabulary; each label string equals its role name. See `meta/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` and `meta/adr/` at the repo root. See `meta/agents/domain.md`.

### Docs layout

Internal material lives under `meta/`: decisions in `meta/adr/`, research in `meta/research/`, agent-facing operational reference in `meta/agents/`. The root holds `AGENTS.md`, `CONTEXT.md`, `README.md` and code.

`docs/` is the Starlight site at tagwerk.espadat.com, matching `auberge`, `dublette` and `colporteur`. A build directory; pages in `docs/src/content/docs/`. Nothing internal goes there.
