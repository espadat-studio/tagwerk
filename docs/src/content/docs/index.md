---
title: tagwerk
description: "Passive time tracker for Hyprland on Arch, nothing to start or stop. Every present minute books to a project: the repo under your kitty terminal, the repo your Claude Code or pi agent works in, or what the focused window implies, so a Slack thread or a Zoom call counts as work too. Built on Omarchy 4."
---

> Work hours that track themselves on a Hyprland desktop, whether you were in a repo, a Slack thread or a Zoom call, with your coding agents' time counted too.

Every CLI time tracker is manual, and manual discipline is what killed the timewarrior setup this one replaces: a forgotten start, a forgotten stop. tagwerk has no start and no stop. On Hyprland it watches which repo your kitty terminal or coding agent sits in, which window has focus, and whether you are idle, then credits every present minute to a project. A repo takes the minute while one is active. Otherwise the focused window decides, so a Slack thread or a Zoom call books to work and an unrecognised window to personal. It answers two questions and no others: what goes on this month's invoice, and whether last week was too long a week.

## Where the minutes come from

| Piece        | What it does                                                                      |
| ------------ | --------------------------------------------------------------------------------- |
| Focus poller | `tagwerk focus` as a systemd user service polls window class, title and kitty cwd |
| hypridle     | `tagwerk idle` and `tagwerk active` from the idle listener and around sleep       |
| Agent hooks  | Claude Code hooks and a pi extension run `tagwerk beat` with the agent's cwd      |
| Ledger       | `~/.local/share/tagwerk/YYYY-MM.jsonl`, append-only, UTC timestamps               |
| Reports      | `day`, `week`, `month`, `invoice`; `fix` appends a span                           |

Nothing in the ledger is ever edited. A fix is a new span appended after the fact, and the latest one wins.

## How a minute is credited

A minute is present when you are not idle and a poll landed within the last 2 minutes. Present minutes are credited exactly once, so a day's total equals wall-clock presence.

An agent beat leases its repo for 10 minutes. A focused kitty cwd, or a window title naming a repo, leases for 1 minute. A leased repo keeps earning while an unrelated window is focused — a browser tab during a long agent turn still books to the repo. Two leased repos split each minute evenly.

With no lease, the focused window decides: a shell sitting at a root books that kind's `general`, a work-pattern title books `work/general`, and anything else books `personal/other`.

Beats while idle book nothing, so an unattended overnight agent adds no hours.

[Concepts](/concepts/) covers presence, the even split and the two catch-alls in full.

## Paid is not invoiced

| kind       | counts toward the week cap | on the invoice |
| ---------- | :------------------------: | :------------: |
| `work`     |            yes             |      yes       |
| `fixed`    |            yes             |       no       |
| `personal` |             no             |       no       |
| `off`      |             no             |       no       |

A fixed-price customer's hours belong in the burnout check and never on an hourly customer's bill. The day cap asks a different question and no kind answers it: it counts every credited minute, `personal` included, because burnout does not care who paid for the hour.

A kind never names the payer.

## Install

```sh
paru -S tagwerk-git
tagwerk init && $EDITOR ~/.config/tagwerk/config.toml
systemctl --user enable --now tagwerk-idle.service tagwerk-focus.service
```

tagwerk itself has no runtime dependencies and tracks master. It is built and tested on Omarchy 4; any Arch Hyprland works once kitty has remote control on for the terminal sensor, and the bar widget is Omarchy only. The Claude Code hooks and the pi extension are part of that install, not an optional extra: without them a minute of background agent work is credited to the focused window instead of the agent's repo. `tagwerk doctor` reports one row per sensor — `live`, `dark` or `unknown` — so a missing hook is easy to tell apart from a repo outside your roots.

[Installation](/getting-started/installation/) covers the units, the hypridle choice and the kitty remote-control requirement; [Verification](/getting-started/verification/) proves each sensor fires.
