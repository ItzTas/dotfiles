---
description: Reference something you (Claude) said earlier by quoting it, then act on the instruction that follows
argument-hint: "quoted excerpt" <what to do with it>
---

I want to point back at something **you** (Claude) said earlier in this conversation and then ask
you to do something about it.

Everything I passed with the command: `$ARGUMENTS`

## How to read the arguments

- The **first quoted segment** (inside `"..."` or `'...'`) is a **verbatim excerpt of something you
  said earlier** in this conversation. It is the *mention* — a pointer, not a new instruction.
- **Everything after that quote** is the **instruction**: what I want you to do regarding that
  excerpt.
- Example: `/mentioned "eu fiz isso" me explique o que vc fez` means → find where you said
  "i did this" and then explain what you did.

## Steps

### 1. Locate the mention
- Take the quoted excerpt and find it (or the closest matching passage) in **your own earlier
  messages** in this conversation.
- Match on meaning, not just exact characters — the excerpt may be paraphrased, shortened, or have
  slightly different wording/accents than what you actually wrote.
- If you find it, silently re-read that part of your message and the surrounding context (what you
  were doing, which files/commands were involved) so you know exactly what it refers to.

### 2. Handle the case where you can't find it
- If nothing in your earlier messages reasonably matches the quoted excerpt, **don't guess**. Tell
  me you couldn't find where you said that, quote back what I referenced, and ask me to clarify or
  point me to it.

### 3. Carry out the instruction
- With the mention pinned down, do **exactly what the instruction after the quote asks** — explain,
  expand, redo, fix, justify, revert, continue, whatever it says — referring specifically to that
  earlier statement.
- Keep the answer anchored to the mentioned excerpt; don't drift into unrelated parts of the
  conversation.
- If the instruction itself is empty (I only passed the quote), briefly summarize/explain that
  earlier statement and ask what I'd like to do with it.

### 4. Answer in my language
- Respond in the same language I used in the instruction (Portuguese if I wrote in Portuguese).
