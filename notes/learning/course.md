---
title: The MCP course
type: learning
tags:
  - course
  - mcp
  - learning-method
updated: 2026-11-20
---

# The MCP course

Six modules. Each one turns a reference note into a taught module with labs, quizzes and a review schedule.

The reference notes in this folder are the *what*. The modules in [`modules/`](modules/) are the *how to learn it*. Read the module first. Open the reference note only when you need the full table.

## The modules

| # | Module | Reference note | Outcome |
|---|---|---|---|
| 01 | [MCP from the wire up](modules/module-01-mcp-protocol.md) | [mcp-protocol.md](mcp-protocol.md) | You can read a raw MCP session byte by byte. |
| 02 | [Plain tools vs code mode](modules/module-02-plain-tools-vs-code-mode.md) | [plain-tools-vs-code-mode.md](plain-tools-vs-code-mode.md) | You can argue for a tool surface without hand-waving. |
| 03 | [Node vs Bun vs Python](modules/module-03-node-vs-bun-vs-python.md) | [runtime-node-vs-bun-vs-python.md](runtime-node-vs-bun-vs-python.md) | You can justify the runtime choice from requirements. |
| 04 | [Building for an API that changes](modules/module-04-building-for-an-api-that-changes.md) | [building-for-an-api-that-changes.md](building-for-an-api-that-changes.md) | You can detect backend drift instead of guessing. |
| 05 | [Obsidian vault craft](modules/module-05-obsidian-vault-craft.md) | [obsidian-vault.md](obsidian-vault.md) | You can work in the vault without Obsidian running. |

Module 06 is written later. It is the project design itself: the tool surface, the breakage layers, the auth path, and the ride lifecycle. It depends on the grill settling the open questions.

## Why this order

Each module assumes the previous one.

- 01 first. Every later module uses the word "tool", "schema" and "round trip". You need the wire model before you can judge an interface shape.
- 02 before 03. The interface shape decides what the runtime must support.
- 03 before 04. The runtime decides where the decoder boundary and the type gate live.
- 04 before 06. The breakage design decides how much of the project is a decoder layer instead of a tool layer.
- 05 last. Vault mechanics are cheap to learn once the notes have content worth storing.

## The method, and why each part exists

| Method | What it does | Why it works |
|---|---|---|
| **Dual coding** | Every concept gets a table, a diagram or a code block next to the prose. | Two representations beat one. A table you can scan and a sentence you can read use different memory paths. |
| **Worked example** | One complete case, fully solved, before any exercise. | Novices learn from worked examples first. Studying solutions beats studying problems. |
| **Contrast cases** | Every idea is compared against its nearest neighbour. | Categories form by contrast, not by definition. "Tool vs resource vs prompt" sticks because the differences are named. |
| **Misconception clinic** | Four wrong beliefs per module, each with the reason it fails. | Errors are predictable. Naming the wrong model stops it from forming. |
| **Retrieval practice** | Five closed-book questions per module. | Recalling beats rereading. Rereading feels productive and teaches almost nothing. |
| **Spaced repetition** | Review on Day 0, 1, 3, 7, 14, 30, 60. | Memory needs re-retrieval at expanding intervals. One pass is not learning. |
| **Interleaving** | Every review session mixes modules, not one module at a time. | Mixed practice builds discrimination. Blocked practice builds familiarity. |
| **Feynman check** | You explain the module to a non-programmer in 150 words. | If you cannot explain it simply, you do not own it yet. |
| **Desirable difficulty** | Quizzes are not all easy. Some questions need two facts. | Effortful retrieval builds stronger memory than easy review. |
| **Generation effect** | You build something in the lab, not just read it. | Self-generated material is remembered far better than provided material. |

## The study loop

Do these five steps per module. Twenty minutes of study is worth an hour of reading.

1. **Read the module.** Read "Why this matters" and "The core content". Skip the rest on the first pass.
2. **Do the lab.** Type the commands. Do not paste. Break them on purpose.
3. **Answer the quiz closed-book.** Write your answers down before opening the answer key.
4. **Read the answer key.** Mark each question right, wrong or partial. Write the reason for every wrong one.
5. **Make the flashcards.** Add any question you got wrong to your own deck, in your own words.

Then come back on Day 1, Day 3, Day 7, Day 14, Day 30 and Day 60. On those days, answer the quiz again without notes. That second attempt is where the learning happens.

## Mastery

A module is mastered when all three hold.

- You score 4 or 5 out of 5 on the quiz twice, on different days, without notes.
- You can answer the Feynman prompt in under 150 words, and all three required sentences are in it.
- You can name the module's four misconceptions and say why each is wrong.

Anything less is not mastery yet. Re-review on the schedule.

## Progress

| Module | Quiz 1 | Quiz 2 | Feynman | Mastered |
|---|---|---|---|---|
| 01 MCP protocol | | | | |
| 02 Plain tools vs code mode | | | | |
| 03 Node vs Bun vs Python | | | | |
| 04 Building for an API that changes | | | | |
| 05 Obsidian vault craft | | | | |
| 06 The project design | | | | |

Fill the date in the cell the day you hit the criterion. A blank cell is a request to yourself, not a failure.

## Where the answers live

| What | Where |
|---|---|
| Module notes | [`modules/`](modules/) |
| Reference notes | this folder |
| Quiz answers you wrote | your own deck, or a scratch note |
| Project decisions | [`docs/reviews/decision-log.md`](../../docs/reviews/decision-log.md) |
| Architecture records | [`docs/adr/`](../../docs/adr/) |
| Shared vocabulary | [`CONTEXT.md`](../../CONTEXT.md) |
| The project itself | [The server we are building](../project/rapido-mcp-server.md) |

## See also

- [How this vault works](obsidian-vault.md)
- [Open questions](../project/open-questions.md)
