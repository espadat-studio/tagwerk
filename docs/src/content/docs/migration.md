---
title: Migration
description: Import a timewarrior history into the tagwerk ledger, then retire the timewarrior setup.
---

## Arriving from timewarrior

```sh
tagwerk import-timew --work-tag TAG
```

`TAG` is the timewarrior tag that marked an interval as work; `timew tags` lists them. Intervals without it become `personal`. A `project:<repo>` tag becomes the project, anything else lands in `general`.

The import reads `timew export` and refuses to run twice, so run it before uninstalling timew. Every interval arrives as a span, which is exactly what a hand-entered correction is, so imported history and `tagwerk fix` behave identically from then on.

## Retiring the old setup

After a week of trusted numbers:

```sh
systemctl --user disable --now bugwarrior-pull.timer tw-today-reset.timer
sudo rm /usr/lib/systemd/system-sleep/timew-stop
omarchy pkg drop timew
```

The sleep hook belongs to no package and runs `timew stop` on every suspend, so removing the package alone leaves it behind.

Timewarrior's intervals are already in the ledger as spans. Taskwarrior stays.
