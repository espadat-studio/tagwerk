---
title: Concepts
description: "How tagwerk turns sensor events into credited minutes: presence, leases, the even split, the ambient bucket and the catch-alls."
---

Sensors append events. Attribution turns those events into credited minutes. Reports render the totals. Nothing in the ledger is ever edited, so attribution is a fresh reading of the same events every time (ADR-0002).

## A minute is present, absent or idle

A minute is **present** when you are not idle and a poll landed within the last `poll_stale_min`. Present minutes are credited exactly once, so a day's total equals wall-clock presence.

A minute is **absent** when no poll proves the machine was on: powered off, suspended, or the poller is dead. A minute is **idle** between an `idle` event and the next `active` event from the idle listener. Suspend is idle. Neither is ever credited.

Idle inhibitors are honoured, so a video call with your hands off the keyboard stays present.

## Leases and the even split

A repo signal grants that repo a **lease**: a period during which it is eligible for credit.

| Signal                       | Leases for        |
| ---------------------------- | ----------------- |
| an agent beat                | `beat_lease_min`  |
| a focused terminal's cwd     | `focus_lease_min` |
| a window title naming a repo | `focus_lease_min` |

A lease is what lets a leased repo keep earning while an unrelated window is focused: a browser tab read during a long agent turn still books to the repo the agent is working in.

When two repos hold a lease over the same present minute, they split it evenly (ADR-0003). Three repos split it three ways. The split is even because no signal tagwerk can see says which of two concurrent agent turns deserved more of the minute, and inventing a weight would be inventing a number.

Beats while idle book nothing, so an unattended overnight agent adds no hours. Credit resumes on the still-valid lease when you return.

## The ambient bucket

With no repo holding a lease, the focused window decides, and what it implies is the **ambient bucket**. It is credited only when no repo holds a lease, because a repo signal always wins over the window in front of you.

- A shell sitting at a root books that kind's `general`.
- A title matching a `[[title]]` rule books what that rule says, so Slack, Zoom, Meet or your org's GitHub books `work/general`.
- Anything else books `personal/other`.

## The two catch-alls

`general` and `other` are the only projects that are not repos.

`general` means inside a kind's territory with no repo to name: a shell at the root of your work org's clone directory, or a work-pattern window title. `other` means no recognisable signal at all.

`personal/other` is where an unrecognised window lands. An abandoned video call stays present and books there, which inflates the chart and never the invoice. Only repos take leases, so a catch-all never competes in the even split.

## Paid is not invoiced

`work` and `fixed` are both paid: both drive the week cap and both land in the `work` subtotal that the `day` and `month` tables print. Only `work` reaches `tagwerk invoice`, so fixed-price hours show up in the burnout check and never on an hourly customer's bill (ADR-0006).

The day cap measures every credited minute instead, `personal` included, because burnout does not care who paid for the hour (ADR-0011).

A kind never names the payer. Two customers billed differently are two projects under one kind, not two kinds.

## Spans win, renames fold

A span overrides the sensors for its whole range, with no partial merge, and the latest appended span wins on overlap. An `off` span removes its range from every report.

A rename folds a retired project name into its current one at resolution, so a repo you renamed keeps one row in every report, past months included. It never touches the kind: minutes credited while the repo sat under a personal root stay personal (ADR-0010). [Configuration](/configuration/) has the syntax.
