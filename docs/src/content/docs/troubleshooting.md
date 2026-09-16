---
title: Troubleshooting
description: The known ceilings, what tagwerk knowingly does not do, and what to do about the ones that have a remedy.
---

Every item here is known and deliberate. A dark sensor is a different problem: [Verification](/getting-started/verification/) covers reading and fixing those.

## Attribution

- Poll granularity is `poll_sec`, with a re-poll every 60 s. Hyprland's event socket was rejected as the trigger: it cannot see a `cd` inside a terminal, and it emits a title event per spinner frame.
- A repo whose name contains a dot is truncated at it, because the project is cut at its first dot. Give such a repo its own root, or rename the directory and add a `[rename]` entry so the old minutes follow.
- A directory that holds worktrees books every worktree under it to the container's name, for the same reason. Give the container its own root: the longest match then picks it, and the repo name below it becomes the project.
- Because a rename keys on the project name rather than the path, two repos sharing a name under different roots fold together. A rename is also single-hop, so renaming twice means pointing both old names at the current one.
- Idle inhibitors are honoured, so an abandoned video call stays present and books `personal/other`. That reaches the chart and never the invoice. If it bothers you, copy `/usr/share/tagwerk/hypridle.conf`, set `ignore_dbus_inhibit = true` in the copy, and point hypridle's `--config` at it with `systemctl --user edit tagwerk-idle.service`.
- Spans written before `ts` carried microseconds resolve by file order when two of them share a second across month files. Their append order was never recorded, so no rewrite can fix it (ADR-0009).

## doctor

- It cannot tell a sensor that is deliberately unwired from one with a wiring fault, so a machine that runs no agents reports `beat` dark for good. Raise `sensor_dark_h` or read past that row.
- It judges a root by whether it is a directory right now, so a root on an unmounted drive reads `suspect` until you mount it. That costs a row and exit 3, never a number in a report.
- It tests each `[[title]]` pattern against every title on its own, so a pattern permanently shadowed by an earlier one still reads clear. Attribution takes the first match, and replaying that order across the whole ledger would cost more than the typo it would catch.
- Exit 2 is shared with argparse, which spends it on a usage error, so `tagwerk doctor --bogus` alarms a shell prompt exactly as a dark sensor does.

## Reports

- Colours come from five hues that pass the contrast check, so past five work repos two projects share one.
- Reports rescan the month files on every run. A month is about 43k minutes and a few thousand events, which is fine for years of data.
- `day --json` judges `over_cap` on the whole minutes it prints, while the `week` bar reddens on the raw total. A day landing within half a minute of the cap can read over in one and under in the other. Self-consistent JSON was worth more than agreement at that boundary.

## Bar widget

- It notches the day cap alone. `week_cap_h` is arguably the better burnout signal, but `--json` is `day` alone, so a 38-hour week reads quiet there on Friday morning.
- It redraws on a timer, so it trails the true minute by up to `refreshIntervalSec`: 300 s by default, which is a fifth of a pixel of fill.

## By design

One machine, no web UI, no sync, no notifications. `--json` is `day` alone; every other report is text for a human to read.
