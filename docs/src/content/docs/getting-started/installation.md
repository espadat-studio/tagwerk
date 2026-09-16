---
title: Installation
description: Install tagwerk from the AUR, enable the units, and wire hypridle and the agent hooks.
---

Target: Omarchy 4 with Hyprland and kitty. The [AUR package](https://aur.archlinux.org/packages/tagwerk-git) pulls `hypridle` and the system Python; tagwerk itself has no runtime dependencies (ADR-0004) and tracks master (ADR-0005).

```sh
paru -S tagwerk-git
tagwerk init && $EDITOR ~/.config/tagwerk/config.toml
systemctl --user enable --now tagwerk-idle.service tagwerk-focus.service
```

Any AUR helper works: `yay -S tagwerk-git`. Without one, `git clone https://aur.archlinux.org/tagwerk-git.git && cd tagwerk-git && makepkg -si` builds the package and installs it through pacman.

That leaves one piece: the [agent hooks](/getting-started/agent-hooks/) are part of this install, not an optional extra. Without them a present minute of background agent work is credited to the focused window instead of the agent's repo.

## Edit the config

`tagwerk init` writes a commented template that names an org that is not yours, so it does nothing useful until you edit it. Point `[roots]` at your work org's clone directory as `work` and at your personal code directory as `personal`, and make the `[[title]]` patterns match your org's GitHub titles and chat apps. [Configuration](/configuration/) covers every key, its default and how a bad rule is rejected.

## The units

`tagwerk-focus.service` runs the focus poller. `tagwerk-idle.service` runs hypridle on the packaged `/usr/share/tagwerk/hypridle.conf`, which only feeds the ledger.

Omarchy's shell already runs the screensaver at 150 s and the lock at 300 s, so the packaged listener fires at the same 150 s without input and no minutes fall between screensaver and lock. If you already run `hypridle.service` with your own config, add its `tagwerk idle` and `tagwerk active` lines there and skip `tagwerk-idle.service`.

## kitty remote control

The poller reads the kitty cwd over kitty remote control on Omarchy's per-pid socket. `/etc/xdg/kitty/kitty.conf` already sets `allow_remote_control socket-only` and `listen_on`; a user `kitty.conf` must not override them. A kitty started outside Omarchy's config has no socket; its cwd is written as `null` and the poller keeps running.

Once everything is in place, [verify it](/getting-started/verification/).
