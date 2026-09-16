---
title: CLI reference
description: Every tagwerk command with its flags, and the global options that go before the subcommand.
---

Times are local; `HH:MM` means today. Timestamps in the ledger are UTC.

Every report takes an optional period in its own unit, or `--ago N` counted in that same unit. The two are mutually exclusive. With neither, the report covers the current period.

Running `tagwerk` with no command prints the description, two examples and where to go next. No command is not an error.

## Global options

These go before the subcommand.

| Option            | Does                                                                                                 |
| ----------------- | ---------------------------------------------------------------------------------------------------- |
| `--config PATH`   | read this config; beats `TAGWERK_CONFIG`, which beats `~/.config/tagwerk/config.toml`                |
| `--data-dir PATH` | read and write this ledger directory; beats `TAGWERK_DATA_DIR`, which beats `data_dir` in the config |
| `--version`       | the git revision the package was built from, or `master` from a checkout (ADR-0007)                  |

`init` rejects `--data-dir`: it writes a config, and that config is where `data_dir` belongs.

Reports also take `--no-color`. Reports colour only when both stdout and stderr are terminals; `--no-color`, `NO_COLOR` and `TERM=dumb` each turn it off, and `FORCE_COLOR` overrides all three.

## Reports

### `tagwerk day [YYYY-MM-DD] [--ago N] [--json]`

Hours per `kind/project` for the local day, the paid `work` subtotal, then the total.

`--json` prints the same figures as one object on stdout and never colours:

```json
{
  "day": "2026-09-16",
  "buckets": [
    { "kind": "work", "project": "tagwerk", "minutes": 312 },
    { "kind": "personal", "project": "auberge", "minutes": 47 }
  ],
  "paid_minutes": 312,
  "total_minutes": 359,
  "cap_minutes": 480,
  "over_cap": false
}
```

Buckets come in the table's own order, every minute value is a rounded integer, and `over_cap` compares `total_minutes` against `cap_minutes`, the day cap (ADR-0011). Buckets round one by one and the total rounds the raw sum, so the rows need not add up to it, exactly as in the table.

### `tagwerk week [YYYY-Www] [--ago N]`

One bar per day, Monday to Sunday, with a cap marker. A day turns red over the day cap, or on a weekend with any minutes on it.

### `tagwerk month [YYYY-MM] [--ago N]`

One bar per ISO week, counting only its days inside the month, then hours per `kind/project`.

### `tagwerk invoice [YYYY-MM] [--ago N]`

A markdown table of `work` hours per project in quarter hours. Rows sum to the rounded total. `fixed` never appears (ADR-0006).

## Writing to the ledger

### `tagwerk fix START END PROJECT [--kind KIND]`

Book a span that overrides the sensors for its whole range. `START` and `END` are `HH:MM` for today or `YYYY-MM-DDTHH:MM`. `KIND` is `work` (the default), `fixed`, `personal` or `off`.

```sh
tagwerk fix 14:00 15:00 assets
tagwerk fix 09:00 12:00 auberge --kind fixed
tagwerk fix 2026-09-08T09:00 2026-09-08T10:00 blog --kind personal
tagwerk fix 12:00 13:00 lunch --kind off
```

Nothing in the ledger is ever edited, so a second span over the same range is appended after the first, and the later one wins (ADR-0002).

### `tagwerk import-timew --work-tag TAG [FILE]`

A one-shot import of the timewarrior export as spans; runs `timew export` when `FILE` is omitted. It refuses to run twice. See [Migration](/migration/).

## Sensors

These are run by systemd, hypridle and the agent hooks, not by hand.

| Command                         | Does                                                                                                                         |
| ------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `tagwerk focus [--once]`        | the focus poller; polls window class, title and kitty cwd every `poll_sec`. `--once` writes one poll and exits               |
| `tagwerk beat SRC [--cwd PATH]` | an agent signal from `SRC` (`claude` or `pi`); cwd from `--cwd`, else the `cwd` field of JSON on stdin, else the process cwd |
| `tagwerk idle`                  | mark the start of idle, from the hypridle listener or before sleep                                                           |
| `tagwerk active`                | mark the end of idle, from the hypridle listener or after sleep                                                              |

`tagwerk beat` drops a cwd it cannot resolve to a root and exits 0, so a turn outside your `[roots]` is silent rather than an error.

## Config and checks

### `tagwerk init`

Write the commented config template to `~/.config/tagwerk/config.toml`. It refuses to overwrite an existing one. See [Configuration](/configuration/).

### `tagwerk doctor`

One row per sensor — `poll`, `beat`, `idle mark` — with its last event and a `live`, `dark` or `unknown` verdict. Then whether each agent hook is `wired`. Then any `suspect` root or title pattern.

Exits 2 on a dark sensor and 3 on suspect config alone. [Verification](/getting-started/verification/) reads the whole output.
