# Architecture decision records

One file per decision, numbered from `0001`, named `NNNN-kebab-case-title.md`.

## Format

Use the template at [`notes/templates/adr.md`](../../notes/templates/adr.md).

## Status values

| Status | Meaning |
|---|---|
| Proposed | Written, not yet accepted. |
| Accepted | In force. |
| Superseded by ADR-NNN | Replaced. Keep the file; add the pointer. |

## When a record gets written

An ADR is written when a decision is **settled and consequential** — it constrains future work, and a reasonable engineer could later wonder why the code looks like this.

A decision that only matters to the current change belongs in the commit, not in an ADR. A decision that changes what the project is belongs in `docs/reviews/decision-log.md` and here.

## Current records

None yet. The design interview has not finished, so no architecture is settled enough to record. The decisions taken so far live in [`docs/reviews/decision-log.md`](../reviews/decision-log.md) and are summarised in [`notes/project/open-questions.md`](../../notes/project/open-questions.md).

## Relationship to the decision log

| Record | Holds | Lifetime |
|---|---|---|
| `docs/reviews/decision-log.md` | Every decision, including the prompt that produced it. | Permanent. Append only. |
| `docs/adr/` | Architecture decisions that constrain the code. | Permanent. Superseded records stay. |
| `docs/reviews/change-inventory.md` | Every changed file, with how it was verified. | Permanent. Append only. |
