---
title: Verification
description: Prove every sensor reaches the ledger, read the doctor verdicts, and act on the exit codes.
---

After 10 minutes with a kitty window focused for part of them, and one agent turn:

```sh
tagwerk doctor
tagwerk day
```

## What a working sensor looks like

`doctor` prints one row per sensor (`poll`, `beat claude`, `beat pi` and `idle mark`) with when it last appended and a verdict. Four `live` rows mean the focus poller, both agent hooks and the idle listener all reach the ledger, and `day` lists the repo you were in. Each agent gets its own row, so a Claude hook that stops firing shows up even while the pi extension keeps beating.

A row reads `unknown` when no poll proves the machine was ever on, so there is nothing to measure that sensor's silence against. A beat row also reads `unknown` when its agent is not `wired`: an agent you never installed explains its own silence. A row reads `dark` when a sensor has appended nothing while the machine was demonstrably on, for longer than `sensor_dark_h`.

## Wiring

Below the sensors, `doctor` reports the two [agent hook](/getting-started/agent-hooks/) installs: `wired`, `missing` with the command to type, or `unknown` when it cannot read `~/.claude/settings.json`. The settings schema is Anthropic's, so a file that is absent, unreadable or shaped unexpectedly reads `unknown` rather than a false `missing`. Wiring is advisory and never changes the exit code.

## Suspect config

Last, `doctor` lists config that cannot be doing anything: a root that is no directory on disk, and a `[[title]]` pattern that no title in the ledger ever matched. Both read `suspect`, never dark: a root may sit on an unmounted drive, and a pattern may simply describe an app you have not opened. Each row names the path or pattern as your config wrote it, so you can grep for the line, and says where the minutes go instead.

A config straight from `tagwerk init` reads suspect in every root and pattern until you edit it, because the template names an org that is not yours. That is the check working, not a fault, and it is why `tagwerk init && $EDITOR ~/.config/tagwerk/config.toml` is one command in the install.

## Exit codes

They let a shell prompt or a timer alarm on wiring without a suspect pattern lighting it up:

| Code | Means                                              |
| ---: | -------------------------------------------------- |
|    0 | every sensor live and no suspect config            |
|    1 | tagwerk itself failed                              |
|    2 | at least one sensor dark, whatever the config says |
|    3 | every sensor live, but the config is suspect       |

Exit 2 is shared with argparse usage errors, one of the [known ceilings](/troubleshooting/).

## Fixing a dark row

A dark row names what to fix.

- `poll` is the focus poller: check `systemctl --user status tagwerk-focus.service` and `journalctl --user -u tagwerk-focus.service`; systemd restarts it after 5 s.
- `idle mark` is `tagwerk-idle.service`, or hypridle running your own config without the `tagwerk idle` and `tagwerk active` lines.
- `beat claude` or `beat pi` means that agent is wired but nothing reached the ledger, so every turn ran outside your `[roots]`: `tagwerk beat` drops a cwd it cannot resolve and exits 0, so nothing else reports it. An agent that is not wired never reads dark, so a dark beat row always points at `[roots]` rather than at the install.

[Troubleshooting](/troubleshooting/) has the known ceilings.
