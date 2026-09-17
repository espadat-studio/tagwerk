---
title: Installation
description: Install tagwerk from the AUR, enable the units, and wire hypridle and the agent hooks.
---

Built and tested on Omarchy 4; any Arch Hyprland works ([ADR-0015](https://github.com/espadat-studio/tagwerk/blob/master/meta/adr/0015-the-supported-environment-is-any-arch-hyprland.md)). The [AUR package](https://aur.archlinux.org/packages/tagwerk-git) pulls `hypridle` and the system Python; tagwerk itself has no runtime dependencies ([ADR-0004](https://github.com/espadat-studio/tagwerk/blob/master/meta/adr/0004-system-python-isolated-shebang.md)) and tracks master ([ADR-0005](https://github.com/espadat-studio/tagwerk/blob/master/meta/adr/0005-aur-only-install-path.md)). The units need Hyprland started through [uwsm](#uwsm); the [terminal cwd](#terminal-cwd) sensor needs nothing configured on any terminal.

```sh
paru -S tagwerk-git
tagwerk init && $EDITOR ~/.config/tagwerk/config.toml
systemctl --user enable --now tagwerk-idle.service tagwerk-focus.service
```

Any AUR helper works: `yay -S tagwerk-git`. Without one, `git clone https://aur.archlinux.org/tagwerk-git.git && cd tagwerk-git && makepkg -si` builds the package and installs it through pacman.

That leaves one piece: the [agent hooks](/getting-started/agent-hooks/) are part of this install, not an optional extra. Without them a present minute of background agent work is credited to the focused window instead of the agent's repo.

## Edit the config

`tagwerk init` writes a template whose only live root is `~/code` as `personal`, so every minute books to personal until you edit it. Uncomment a work root and point it at the directory your work repos are cloned into, then uncomment the `[[title]]` rules and make their patterns match your org's GitHub titles and chat apps. [Configuration](/configuration/) covers every key, its default and how a bad rule is rejected.

`tagwerk doctor` reads a root that is no directory and a `[[title]]` pattern that has never matched as **suspect**, so a rule that cannot fire says so rather than going quiet.

## The units

`tagwerk-focus.service` runs the focus poller. `tagwerk-idle.service` runs hypridle on the packaged `/usr/share/tagwerk/hypridle.conf`, which only feeds the ledger.

Omarchy's shell already runs the screensaver at 150 s and the lock at 300 s, so the packaged listener fires at the same 150 s without input and no minutes fall between screensaver and lock. If you already run `hypridle.service` with your own config, add its `tagwerk idle` and `tagwerk active` lines there and skip `tagwerk-idle.service`.

## uwsm

Both units carry `ConditionEnvironment=HYPRLAND_INSTANCE_SIGNATURE` and `WantedBy=graphical-session.target`. Hyprland started through uwsm supplies both, which is Hyprland's own recommended launch path and what Omarchy uses. Hyprland started bare from a TTY supplies neither, so the units never start at all; `tagwerk doctor` then reads the poll sensor as **dark**, which is the right verdict for the right reason. If you launch Hyprland another way, import `HYPRLAND_INSTANCE_SIGNATURE` into the systemd user environment yourself before the units are wanted.

## terminal cwd

The poller resolves the focused terminal's working directory from two sources, in that order, and needs no list of which terminals you use.

A kitty window answers over its remote-control socket, which stays exact with several tabs or splits open. `/etc/xdg/kitty/kitty.conf` sets `allow_remote_control socket-only` and `listen_on`, and a user `kitty.conf` must not override them. If you run kitty outside Omarchy's config, point `kitty_socket` at your own `listen_on` to keep that precision.

Every other terminal — including foot, which is Omarchy 4's default — resolves from `/proc`: the poller reads the working directory of the window's login shell, checked against `/etc/shells`. A window with more than one shell child resolves to nothing rather than guessing which one you are looking at ([ADR-0016](https://github.com/espadat-studio/tagwerk/blob/master/meta/adr/0016-a-cwd-source-refuses-rather-than-guesses.md)), and so does a shell under tmux or another multiplexer, because that shell is not a direct child of the terminal. `tagwerk doctor` reads a poller that has resolved no cwd at all as **suspect**.

Once everything is in place, [verify it](/getting-started/verification/).
