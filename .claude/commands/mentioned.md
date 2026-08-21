---
description: Reference something you (Claude) or another agent said earlier by quoting it, then act on the instruction that follows
argument-hint: [other] "quoted excerpt" <what to do with it>
---

I want to point back at something **you** (Claude) said earlier, or, with `other`, something
**another agent** said, and then ask you to do something about it.

Everything I passed with the command: `$ARGUMENTS`

## How to read the arguments

- If the **first token** (before the quote) is the literal word **`other`**, the quoted excerpt was
  said by **another agent**, not by you in this conversation: a subagent you spawned, another
  Claude session, or some other AI agent whose output I'm referencing.
- The **first quoted segment** (inside `"..."` or `'...'`) is a **verbatim excerpt of something
  said earlier**, by you, or by that other agent when `other` is present. It is the *mention*, a
  pointer, not a new instruction.
- **Everything after that quote** is the **instruction**: what I want you to do regarding that
  excerpt.
- Example: `/mentioned "i did this" explain what you did` means → find where you said
  "i did this" and then explain what you did.
- Example: `/mentioned other "i did this" explain what it did` means → the excerpt came from
  another agent; find it in that agent's output and explain what that agent did.

## Steps

### 1. Locate the mention
- **Without `other`**: take the quoted excerpt and find it (or the closest matching passage) in
  **your own earlier messages** in this conversation.
- **With `other`**: look for it in **another agent's output** instead (subagent/task results, tool
  outputs from other agents, or pasted content from another session), **not** in your own messages.
- Match on meaning, not just exact characters. The excerpt may be paraphrased, shortened, or have
  slightly different wording/accents than what was actually written.
- If you find it, silently re-read that passage and the surrounding context (what was being done,
  which files/commands were involved) so you know exactly what it refers to.

### 2. Handle the case where you can't find it
- If nothing reasonably matches the quoted excerpt, whether in your earlier messages or in the other
  agent's output when `other` was used, **don't guess**. Tell me you couldn't find where it was
  said, quote back what I referenced, and ask me to clarify or point me to it (e.g. which agent
  said it, or paste the relevant output).

### 3. Carry out the instruction
- With the mention pinned down, do **exactly what the instruction after the quote asks** (explain,
  expand, redo, fix, justify, revert, continue, whatever it says), referring specifically to that
  earlier statement. When `other` was used, keep in mind the statement is the **other agent's**,
  not yours: don't take credit for or ownership of it; analyze/act on it as external output.
- Keep the answer anchored to the mentioned excerpt; don't drift into unrelated parts of the
  conversation.
- If the instruction itself is empty (I only passed the quote), briefly summarize/explain that
  earlier statement and ask what I'd like to do with it.

### 4. Answer in my language
- Respond in the same language I used in the instruction.
