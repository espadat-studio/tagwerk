# Present minutes split evenly across leased repos

Superseded by [ADR-0018](0018-a-minute-is-whole-to-each-kind.md): the even split now applies within a kind, and each kind takes a whole minute.

Every present minute is credited exactly once: split evenly across the repos that currently hold a lease, else to the ambient bucket, else to `personal/other`. Totals therefore equal wall-clock presence, which is what both an invoice and a burnout check need. Rejected: wakapi's sequential model, which closes a duration on every project switch and loses the gap between two projects; summing concurrent projects, which over-bills when two agents run at once.

Consequence: an agent beat while the user is present credits its repo even if an unrelated window is focused, and beats while idle book nothing.
