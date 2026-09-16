---
title: tagwerk
description: Passive work-hours ledger for one Linux desktop running Hyprland, kitty and Omarchy.
---

Passive work-hours ledger for one Linux desktop running Hyprland, kitty and Omarchy. Zero manual start or stop: the timewarrior setup it replaces died of manual discipline.

It answers two questions and no others — what goes on this month's invoice, and whether last week was too long a week.

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

tagwerk itself has no runtime dependencies and tracks master. The Claude Code hooks and the pi extension are part of that install, not an optional extra: without them a minute of background agent work is credited to the focused window instead of the agent's repo. `tagwerk doctor` reports one row per sensor — `live`, `dark` or `unknown` — so a missing hook is easy to tell apart from a repo outside your roots.

[Installation](/getting-started/installation/) covers the units, the hypridle choice and the kitty remote-control requirement; [Verification](/getting-started/verification/) proves each sensor fires.
