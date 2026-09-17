---
title: Configuration
description: Every tagwerk config key with its default, the roots and title rules, and how a bad rule is rejected.
---

`tagwerk init` writes a commented template to `~/.config/tagwerk/config.toml`; it refuses to overwrite one. `--config PATH` beats `TAGWERK_CONFIG`, which beats that default path.

Every key below ships with a default, so a config that sets only `[roots]` works.

## Keys

| Key                 | Default                                       | What it does                                                                                                                                                                                               |
| ------------------- | --------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `data_dir`          | `~/.local/share/tagwerk`                      | where the monthly ledger files live; `--data-dir` and `TAGWERK_DATA_DIR` beat it                                                                                                                           |
| `poll_sec`          | `15`                                          | how often the focus poller appends a poll                                                                                                                                                                  |
| `poll_stale_min`    | `2`                                           | a poll this recent proves the machine was on; older and the minute is absent                                                                                                                               |
| `beat_lease_min`    | `10`                                          | how long an agent beat leases its repo                                                                                                                                                                     |
| `beat_throttle_sec` | `60`                                          | one beat per source and cwd per this gap; the rest are dropped                                                                                                                                             |
| `focus_lease_min`   | `1`                                           | how long a focused terminal's cwd or a GitHub repo title leases its repo                                                                                                                                   |
| `poll_dark_h`       | `168`                                         | a week; `tagwerk doctor` calls the focus poller this quiet dark, measured from the last poll                                                                                                               |
| `beat_dark_h`       | `48`                                          | two days; an agent hook falls silent faster than a desktop does, and its minutes reach an invoice                                                                                                          |
| `idle_dark_h`       | `168`                                         | a week; the same for the idle listener                                                                                                                                                                     |
| `kitty_socket`      | `unix:${XDG_RUNTIME_DIR}/omarchy-kitty-{pid}` | the kitty remote-control socket; `{pid}` is the focused kitty's pid. Match it to your own `listen_on` if you run kitty outside Omarchy's config; any other terminal resolves from `/proc` and needs no key |
| `day_cap_h`         | `8`                                           | the day cap: `week` labels turn red above it, and `day --json` reports `over_cap`                                                                                                                          |
| `week_cap_h`        | `40`                                          | the week cap: the `week` footer and the `month` week bars turn red above it                                                                                                                                |

Caps change colours, never numbers.

## `[roots]`

A root maps every path beneath it to one kind.

```toml
[roots]
"~/code/work-org" = "work"
"~/memories/work" = "work"
"~/code/fixed-price-client" = "fixed"
"~/code" = "personal"
```

The longest root wins, counted in path components, so `~/code/work-org` beats `~/code`. The project is the first directory below the root, cut at its first dot, so `assets.8467` and `assets` are one project.

Point `work` at your work org's clone directory and `personal` at your own code. A fixed-price customer's directory is `fixed`: paid, so it counts toward the week cap, but never on the hourly customer's invoice.

### Kinds

| kind       | counts toward the week cap | on the invoice |
| ---------- | :------------------------: | :------------: |
| `work`     |            yes             |      yes       |
| `fixed`    |            yes             |       no       |
| `personal` |             no             |       no       |
| `off`      |             no             |       no       |

The day cap asks a different question and no kind answers it: it counts every credited minute, `personal` included ([ADR-0011](https://github.com/espadat-studio/tagwerk/blob/master/meta/adr/0011-the-day-cap-measures-presence-the-week-cap-paid.md)).

A kind never names the payer. It says whether minutes are paid and whether they are invoiced, nothing else: two customers under the same kind are two projects, not two kinds.

`off` belongs to a span, not to a root or a title rule. The config rejects it in either place; `tagwerk fix --kind off` books it.

## `[[title]]`

Title rules are consulted only when the cwd resolves to nothing: a browser, a chat app, a meeting. The first matching rule wins.

```toml
[[title]] # a GitHub title names the repo it is on
pattern = 'work-org/(?P<project>[\w.-]+)'
kind = "work"

[[title]] # everything else that is plainly work
pattern = '(?i)slack|work-org|zoom|meet\.google|bitbucket'
kind = "work"
project = "general"
```

`pattern` is a Python regex searched anywhere in the window title, so it needs no anchors. The project comes from a literal `project` key, or from a `(?P<project>...)` capture group when there is no literal one.

Each rule is its own `[[title]]` block, double brackets. A single `[title]` table is rejected.

## `[rename]`

A retired project name folds into its current one at resolution, for all time, past months included.

```toml
[rename]
"old-repo-name" = "new-repo-name"
```

The kind is never rewritten, so minutes credited as `personal` stay personal even if the project now sits under a work root ([ADR-0010](https://github.com/espadat-studio/tagwerk/blob/master/meta/adr/0010-a-rename-folds-a-retired-project-name.md)). A rename keys on the project name, not the path, so one entry reaches spans and window titles as well as cwds.

## Rejection

A config that cannot work is rejected when it loads, not silently ignored. Every message names the offending rule by its position and its pattern, or the offending root or rename by its key.

| Rejected                                           | Message says                                                                  |
| -------------------------------------------------- | ----------------------------------------------------------------------------- |
| a `[[title]]` rule with no `pattern`               | a rule needs `pattern = '...'` to match a title against                       |
| a `[[title]]` rule with no `kind`                  | give it one of `work`, `fixed`, `personal`                                    |
| a `pattern` that is no regex                       | the regex error, and to escape any literal metacharacter                      |
| nothing to name the project with                   | add a `(?P<project>...)` group, or `project = "general"`                      |
| a kind outside `work`, `fixed` or `personal`       | names the three that are allowed; book off time with `tagwerk fix --kind off` |
| `[title]` as one table                             | every title rule is its own `[[title]]`                                       |
| a rename touching `general` or `other`             | those are catch-alls, not repos; only a repo can be renamed                   |
| a rename pointing at a name that is itself renamed | point every old name at the current one; a rename is one hop                  |

A config that loads and still does nothing is a different problem: `tagwerk doctor` reports a root that is no directory and a `[[title]]` pattern that has never matched as `suspect`. See [Verification](/getting-started/verification/).
