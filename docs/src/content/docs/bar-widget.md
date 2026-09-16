---
title: Bar widget
description: "The Omarchy bar plugin: today's credited hours against the day cap, and what each state looks like."
---

A cap-proximity cue for the bar, answering one question: am I close to the day cap, or not? A track, a fill running to today's credited minutes with the paid stretch solid inside it, and the cap as a notch you watch the fill close on. One glance, no arithmetic, nothing to read.

The widget lives in its own repo, [espadat-studio/omarchy-tagwerk](https://github.com/espadat-studio/omarchy-tagwerk), and installs as an Omarchy plugin:

```sh
omarchy plugin add https://github.com/espadat-studio/omarchy-tagwerk --enable
```

Installed it before by copying `/usr/share/tagwerk/omarchy/` out of the package? Remove the copy first, or the add fails with `already installed`:

```sh
omarchy plugin remove espadat.tagwerk
omarchy plugin add https://github.com/espadat-studio/omarchy-tagwerk --enable
```

The copy is not deleted: it moves to a hidden `.espadat.tagwerk.bak.<timestamp>` folder beside it, which the plugin catalog ignores.

| What you see                                                                                                                                                                                                                        | What it is                                                                                                                                                                                                                                          |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="/widget/widget-empty-dark.png"><img alt="an empty track with the cap notched near its right end" src="/widget/widget-empty-light.png" width="192"></picture>          | An empty day. The track spans the cap times 1.25, so 10 hours across 40px at an 8-hour cap: 4px per hour, and 30 minutes is 2px. The notch is the cap, always at 80%.                                                                               |
| <picture><source media="(prefers-color-scheme: dark)" srcset="/widget/widget-personal-dark.png"><img alt="a translucent fill reaching halfway along the track" src="/widget/widget-personal-light.png" width="192"></picture>       | 5:00 credited, none of it paid. The translucent fill is every credited minute, `total_minutes`.                                                                                                                                                     |
| <picture><source media="(prefers-color-scheme: dark)" srcset="/widget/widget-split-dark.png"><img alt="a solid fill, then a translucent one, ending short of the notch" src="/widget/widget-split-light.png" width="192"></picture> | 7:20 credited, 5:10 of it paid. The solid stretch is `paid_minutes`; the gap between the two edges is personal.                                                                                                                                     |
| <picture><source media="(prefers-color-scheme: dark)" srcset="/widget/widget-atcap-dark.png"><img alt="the fill reaching the notch, which still cuts through it" src="/widget/widget-atcap-light.png" width="192"></picture>        | 8:00 credited, exactly on the cap. The fill stops flush against the notch, because the cap sits at 80% of a track that runs to 125% of it.                                                                                                          |
| <picture><source media="(prefers-color-scheme: dark)" srcset="/widget/widget-over-dark.png"><img alt="a red fill running past the notch" src="/widget/widget-over-light.png" width="192"></picture>                                 | 9:00 credited, `over_cap`. Both segments switch to the theme's urgent colour and the notch does not, so the hour past the cap stays readable: the notch is painted above the fill. There is no approaching colour — proximity is the fill's length. |

Hover prints work, personal, presence, and the time left or over. Click opens `tagwerk week` in the themed floating terminal. The widget lands on the right of the bar; `omarchy bar move espadat.tagwerk` relocates it.

It runs `tagwerk day --json` every 300 s and draws four rectangles. Nothing else: it never reads the ledger, never reads your config, and never re-implements the cap rule — `over_cap` arrives already computed (ADR-0011). Change `refreshIntervalSec` in the widget's settings; below 15 minutes the fill moves less than a pixel, so the interval buys the notch crossing and nothing more.

`omarchy plugin update espadat.tagwerk` pulls a newer commit, and the shell hot-reloads the widget on the write. `omarchy plugin disable espadat.tagwerk` keeps it installed and only takes it off the bar; `omarchy plugin remove espadat.tagwerk` deletes it.
