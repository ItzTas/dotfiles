---
description: Run a verified analysis (source inventory, investigation, independent fact-check by a separate agent) and deliver only checked claims, with "Como conferir"
argument-hint: <the question> [para <recipient>]
---

I want an analysis I can trust and pass on to other people. The question:

`$ARGUMENTS`

If it ends with `para <someone>`, the result includes a message for that person.

Load `~/.claude/rules/analysis.md` first and follow it the whole way. The steps below are in
order. Don't skip one because it looks unnecessary.

## 1. Terms

List the domain terms the question involves (for example: empenho, estorno, versão, funcional)
with what each one means **here** and where that definition came from (project docs, schema
comments, the source system, me). If a term's meaning isn't clear, ask me before going on.

## 2. Source inventory

A table: **source → how to access it → which claims it can settle**. Include the links and
documents inside the data (URL columns, process numbers, attachments). Mark what the final
recipient can see. If a source is blocked, say what you tried, item by item.

## 3. Investigation

Investigate following the rule. Save every script under `<scratchpad>/analysis/` and keep it
there, because the "Como conferir" section points to it. Check 2–3 rows of each script's output
by hand.

If I interrupt with another request, the analysis is paused, not finished: come back to it
before delivering anything that depends on it.

## 4. Claim list

Write the conclusions as **numbered atomic claims**, one fact each, with the source and location
you used. Hypotheses go in a separate list, as hypotheses.

## 5. Independent check

Start the `fact-checker` agent (`subagent_type: "fact-checker"`, in the foreground) and wait for
its result. Its brief has:

- the question;
- the numbered claims, **without** your reasoning or your conclusion about what they mean;
- the source inventory, with access details (paths, URLs, where credentials live, never the
  secret values);
- what the recipient can see;
- the scratchpad directory it can use;
- **the project rules it must follow**, restated: it starts without any `CLAUDE.md`, so copy the
  ones that matter for the check (sensitive data that must never be printed, how to reach the
  database, read-only systems).

Don't send it your hypotheses as claims, and don't tell it what you expect it to find. Keep the
brief lean: give paths and URLs instead of pasting file contents or query results.

## 6. Reconcile

- **REFUTED**: fix the claim, then re-check every other claim that depended on the same source or
  the same reasoning. If the conclusion changed, run step 5 again on the changed claims.
- **UNVERIFIABLE**: move it to "Não verificado" with the reason. It never appears as fact.
- **Sources not used** in the checker's report: open them, or say why they can't settle anything.

## 7. Deliver

1. **The answer** to the question, built only from confirmed claims.
2. **The claims**, numbered, each with its status and evidence.
3. **Como conferir**: for each main claim, where to look, what you should see there, and the
   command plus script path when it came from a script.
4. **Não verificado**: what's left open and what would settle it.
5. **If there's a recipient**: the message for them, built only from confirmed claims, citing
   places they can open themselves (tab, row, document). Run the `/humanizer:humanizer` skill on
   it before showing it to me.
