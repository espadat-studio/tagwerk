# tagwerk

[![AUR](https://img.shields.io/aur/version/tagwerk-git?label=AUR&color=1793d1)](https://aur.archlinux.org/packages/tagwerk-git)

> Passive work-hours ledger for one Linux desktop

No manual start or stop. The timewarrior setup tagwerk replaces died of manual discipline. Sensors append events, attribution credits every present minute to a project, and reports answer two questions and no others: what goes on this month's invoice, and whether last week was too long a week.

| Piece        | What it does                                                                                                                                                                            |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Focus poller | `tagwerk focus` as a systemd user service polls window class, title and kitty cwd                                                                                                       |
| hypridle     | `tagwerk idle` and `tagwerk active` from the idle listener and around sleep                                                                                                             |
| Agent hooks  | Claude Code hooks and a pi extension run `tagwerk beat` with the agent's cwd                                                                                                            |
| Ledger       | `~/.local/share/tagwerk/YYYY-MM.jsonl`, append-only, UTC timestamps                                                                                                                     |
| Attribution  | a present minute is split evenly across leased repos, else the ambient bucket, else `personal/other`                                                                                    |
| Reports      | `day`, `week`, `month`, `invoice`; `fix` appends a span                                                                                                                                 |
| Bar widget   | an Omarchy plugin drawing today's credited hours against the day cap, from `tagwerk day --json`; its code lives in [omarchy-tagwerk](https://github.com/espadat-studio/omarchy-tagwerk) |

## Install

```sh
paru -S tagwerk-git
tagwerk init && $EDITOR ~/.config/tagwerk/config.toml
systemctl --user enable --now tagwerk-idle.service tagwerk-focus.service
```

The Claude Code hooks and the pi extension are part of that install, not an optional extra: without them a present minute of background agent work is credited to the focused window instead of the agent's repo. `tagwerk doctor` reports whether each one landed.

## Documentation

Full documentation lives at [tagwerk.espadat.com](https://tagwerk.espadat.com):

- [Installation](https://tagwerk.espadat.com/getting-started/installation/) - the AUR package, the units and the hypridle choice
- [Agent hooks](https://tagwerk.espadat.com/getting-started/agent-hooks/) - wiring Claude Code and pi
- [Verification](https://tagwerk.espadat.com/getting-started/verification/) - proving each sensor reaches the ledger
- [Concepts](https://tagwerk.espadat.com/concepts/) - presence, leases, the even split and the catch-alls
- [Configuration](https://tagwerk.espadat.com/configuration/) - every key with its default
- [CLI reference](https://tagwerk.espadat.com/cli-reference/) - every command with its flags
- [Bar widget](https://tagwerk.espadat.com/bar-widget/) - the Omarchy plugin, with what each state looks like
- [Troubleshooting](https://tagwerk.espadat.com/troubleshooting/) - the known ceilings
- [Migration](https://tagwerk.espadat.com/migration/) - arriving from timewarrior
- [Development](https://tagwerk.espadat.com/development/) - the local loop and packaging

## Requirements

Omarchy 4 with Hyprland and kitty. The AUR package pulls `hypridle` and the system Python; tagwerk itself has no runtime dependencies (ADR-0004) and tracks master (ADR-0005).

## This repo

- [CONTEXT.md](./CONTEXT.md) - the vocabulary every page and commit uses
- [meta/adr/](./meta/adr/) - the decisions with their trade-offs
- [issue #4](https://github.com/espadat-studio/tagwerk/issues/4) - the spec and its tickets
- [Report issues](https://github.com/espadat-studio/tagwerk/issues)
