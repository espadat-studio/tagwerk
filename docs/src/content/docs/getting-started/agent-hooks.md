---
title: Agent hooks
description: Wire Claude Code and pi to run tagwerk beat so background agent work books to the agent's repo.
---

An agent turn is work, and it usually happens while an unrelated window is focused. Without these hooks a present minute of background agent work is credited to the focused window instead of the agent's repo, so they are part of the [install](/getting-started/installation/) rather than an extra.

## Claude Code

```sh
jq -s '.[1].hooks as $add | .[0] | .hooks = reduce ($add | keys[]) as $k (.hooks // {}; .[$k] = ((.[$k] // []) + $add[$k] | unique))' \
  ~/.claude/settings.json /usr/share/tagwerk/claude-hooks.json > ~/.claude/settings.json.new \
  && mv ~/.claude/settings.json.new ~/.claude/settings.json
```

`claude-hooks.json` adds `SessionStart`, `UserPromptSubmit`, `PostToolUse` and `Stop` hooks. The jq line appends them to the hooks the settings already hold and is safe to rerun.

`PostToolUse` is not optional: without it a 20 min agentic turn loses minutes 10 to 20 once the beat lease runs out. It carries `"async": true`, because it fires on every tool call — around 33,000 a month on this machine, of which the throttle discards 98% — and waiting on a Python interpreter each time costs about 80 minutes a month. The other three fire once a session or turn, so they stay synchronous with a 5 s timeout and their exit codes still reach you.

> Re-running the jq line over settings that already hold an older copy of the fragment appends the async `PostToolUse` entry beside the blocking one instead of replacing it, because `unique` compares whole objects. Delete the old `PostToolUse` entry by hand.

## pi

```sh
ln -s /usr/share/tagwerk/pi/tagwerk.ts ~/.pi/agent/extensions/tagwerk.ts
```

pi runs under Bun with its own `PATH`, so the extension spawns `/usr/bin/tagwerk` by absolute path. Restart pi to load it.

## Confirm both landed

Both installs fail quietly, which is how this ledger went six months without a single beat. `tagwerk doctor` reports each piece as `wired` or `missing` and reprints the command above for whichever is missing. See [Verification](/getting-started/verification/) for the full output.
