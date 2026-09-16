# tagwerk

[![AUR](https://img.shields.io/aur/version/tagwerk-git?label=AUR&color=1793d1)](https://aur.archlinux.org/packages/tagwerk-git)

Passive work-hours ledger for one Linux desktop running Hyprland, kitty and Omarchy. Zero manual start or stop: the timewarrior setup it replaces died of manual discipline. Two consumers: a monthly invoice and a burnout check.

| Piece        | What it does                                                                                         |
| ------------ | ---------------------------------------------------------------------------------------------------- |
| Focus poller | `tagwerk focus` as a systemd user service polls window class, title and kitty cwd                    |
| hypridle     | `tagwerk idle` and `tagwerk active` from the idle listener and around sleep                          |
| Agent hooks  | Claude Code hooks and a pi extension run `tagwerk beat` with the agent's cwd                         |
| Ledger       | `~/.local/share/tagwerk/YYYY-MM.jsonl`, append-only, UTC timestamps                                  |
| Attribution  | a present minute is split evenly across leased repos, else the ambient bucket, else `personal/other` |
| Reports      | `day`, `week`, `month`, `invoice`; `fix` appends a span                                              |
| Bar widget   | an Omarchy plugin drawing today's credited hours against the day cap, from `tagwerk day --json`      |

Documentation: [tagwerk.espadat.com](https://tagwerk.espadat.com). Vocabulary: `CONTEXT.md`. Decisions with their trade-offs: `meta/adr/`. Spec and tickets: [issue #4](https://github.com/espadat-studio/tagwerk/issues/4).

## Install

Target: Omarchy 4 with Hyprland and kitty. The [AUR package](https://aur.archlinux.org/packages/tagwerk-git) pulls `hypridle` and the system Python; tagwerk itself has no runtime dependencies (ADR-0004) and tracks master (ADR-0005).

```sh
paru -S tagwerk-git
tagwerk init && $EDITOR ~/.config/tagwerk/config.toml
systemctl --user enable --now tagwerk-idle.service tagwerk-focus.service
```

The agent hooks are part of that install, not an optional extra: without them a present minute of background agent work is credited to the focused window instead of the agent's repo. [Getting started](https://tagwerk.espadat.com/getting-started/installation/) covers the units, the hypridle choice, the kitty remote-control requirement, the agent hooks and the verification steps that prove each sensor fires.

## Configuration

Point `[roots]` at your work org's clone directory as `work` and at your personal code directory as `personal`, and make the `[[title]]` patterns match your org's GitHub titles and chat apps. [Configuration](https://tagwerk.espadat.com/configuration/) covers every key with its default, which kinds are paid and which reach the invoice, and how a rule that cannot work is rejected when the config loads.

## Omarchy bar widget

A cap-proximity cue for the bar, answering one question: am I close to the day cap, or not? A track, a fill running to today's credited minutes with the paid stretch solid inside it, and the cap as a notch you watch the fill close on. One glance, no arithmetic, nothing to read.

```sh
cp -r /usr/share/tagwerk/omarchy ~/.config/omarchy/plugins/espadat.tagwerk
omarchy-shell shell rescanPlugins
omarchy plugin enable espadat.tagwerk
```

| What you see                                                                                                                                                                                                                                      | What it is                                                                                                                                                                                                                                          |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/widget-empty-dark.png"><img alt="an empty track with the cap notched near its right end" src=".github/assets/widget-empty-light.png" width="192"></picture>          | An empty day. The track spans the cap times 1.25, so 10 hours across 40px at an 8-hour cap: 4px per hour, and 30 minutes is 2px. The notch is the cap, always at 80%.                                                                               |
| <picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/widget-personal-dark.png"><img alt="a translucent fill reaching halfway along the track" src=".github/assets/widget-personal-light.png" width="192"></picture>       | 5:00 credited, none of it paid. The translucent fill is every credited minute, `total_minutes`.                                                                                                                                                     |
| <picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/widget-split-dark.png"><img alt="a solid fill, then a translucent one, ending short of the notch" src=".github/assets/widget-split-light.png" width="192"></picture> | 7:20 credited, 5:10 of it paid. The solid stretch is `paid_minutes`; the gap between the two edges is personal.                                                                                                                                     |
| <picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/widget-atcap-dark.png"><img alt="the fill reaching the notch, which still cuts through it" src=".github/assets/widget-atcap-light.png" width="192"></picture>        | 8:00 credited, exactly on the cap. The fill stops flush against the notch, because the cap sits at 80% of a track that runs to 125% of it.                                                                                                          |
| <picture><source media="(prefers-color-scheme: dark)" srcset=".github/assets/widget-over-dark.png"><img alt="a red fill running past the notch" src=".github/assets/widget-over-light.png" width="192"></picture>                                 | 9:00 credited, `over_cap`. Both segments switch to the theme's urgent colour and the notch does not, so the hour past the cap stays readable: the notch is painted above the fill. There is no approaching colour — proximity is the fill's length. |

Hover prints work, personal, presence, and the time left or over. Click opens `tagwerk week` in the themed floating terminal. The widget lands on the right of the bar; `omarchy bar move espadat.tagwerk` relocates it.

It runs `tagwerk day --json` every 300 s and draws four rectangles. Nothing else: it never reads the ledger, never reads your config, and never re-implements the cap rule — `over_cap` arrives already computed (ADR-0011). Change `refreshIntervalSec` in the widget's settings; below 15 minutes the fill moves less than a pixel, so the interval buys the notch crossing and nothing more.

A copy, not a symlink: `omarchy plugin validate` refuses any symlink inside a plugin folder, so a linked install cannot be checked. The directory name must equal the manifest id, because that is how the shell maps a changed file back to its plugin. Re-copy after a `tagwerk-git` update; the shell hot-reloads the widget on the write.

## Migrating from timewarrior

`tagwerk import-timew --work-tag TAG` reads `timew export` once and lands every interval as a span. [Migration](https://tagwerk.espadat.com/migration/) covers the tag mapping and retiring the old setup.

## Commands

`day`, `week`, `month` and `invoice` report; `fix` appends a span; `focus`, `beat`, `idle` and `active` are the sensors; `init` and `doctor` set up and check. [CLI reference](https://tagwerk.espadat.com/cli-reference/) has every command with its flags.

## Attribution

A present minute is split evenly across every repo holding a lease, else it goes to the ambient bucket the focused window implies, else to `personal/other`. [Concepts](https://tagwerk.espadat.com/concepts/) explains presence, leases and the catch-alls; [Troubleshooting](https://tagwerk.espadat.com/troubleshooting/) lists the known ceilings.

## Development

`mise run check` runs the linters, `mise run test` runs pytest then mypy strict. [Development](https://tagwerk.espadat.com/development/) covers the local loop, the test suite and how a change reaches users through the AUR.
