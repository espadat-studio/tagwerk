---
title: Development
description: The local loop, the test suite, the linters and how a change reaches users through the AUR.
---

```sh
mise install
hk install --mise
mise run check
mise run test
```

`check` runs dprint and ruff. `test` runs pytest, then mypy strict.

## The test suite

Tests drive the CLI with `TAGWERK_CONFIG` and `TAGWERK_DATA_DIR` pointed at a temp directory, and with fake `hyprctl` and `kitten` executables on `PATH`. They never touch the real ledger.

That matters when working on tagwerk with an agent: a manual `tagwerk` run with no environment set appends to your actual ledger, so point both variables somewhere disposable first.

## Packaging

`contrib/aur/` holds the PKGBUILD. A push to master that touches it publishes `tagwerk-git` to the AUR; code changes reach users through `paru -Syu --devel` with no publish at all.

The package builds master, so a renamed `contrib` file and its PKGBUILD line have to ship in the same pull request. `makepkg -f --nodeps` inside `contrib/aur` builds it locally.

Docs-only pushes are excluded from the AUR workflow: `pkgver()` counts commits, so publishing on a docs change would make every user rebuild for nothing.
