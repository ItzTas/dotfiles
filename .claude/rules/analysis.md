These are my rules for analyses and factual claims. Load this file **before** investigating data,
systems, or code to answer a factual question (why a number is off, what a record contains, where
two sources disagree, how much something adds up to), and **always before drafting text that states
facts for someone else** (a message, issue, report, or reply I'll forward). I pass these analyses on
to other people. A wrong claim there costs me credibility and wastes other people's time.

## Every claim needs a source you actually read

- **Trace each claim to a primary source read in this session.** Name it: the system, file, tab,
  column, row, query, or API call, plus the date of the data. A script's output, an earlier
  snapshot, or your memory of the domain does not count as a source on its own.
- **Point to the place the reader will look, and confirm the fact is visible there.** If the
  recipient will open tab `EMPENHOS`, the value you cite has to be in tab `EMPENHOS`. Never
  attribute to one source a field you got from another (e.g. a classification that only exists in
  the external API, cited as if it were in the spreadsheet). "Where is that? I can't see it" from
  the recipient means this rule was broken.
- **Use current data.** If you worked from a cache, a previous load, or a local copy, re-check
  against the live source before the claim leaves the session, and state the as-of date.

## Get the numbers right before interpreting them

- **Settle the semantics first**: gross or net (reversals, cancellations, refunds), which version
  (latest only?), duplicates, units, the time window. Say which one you used.
- **Don't trust your own scripts blindly.** Before relying on a result, check 2–3 rows by hand
  against the raw source. Look for the usual traps: null/`NaN` treated as truthy, joins that
  multiply rows, filters applied at the wrong level, type coercion. A result that looks too clean
  (every row "yes", everything zero, a perfectly round total) is a reason to re-check, not a finding.
- **Search for the evidence that would disprove the claim** before stating "X is wrong". A
  divergence produced by the rule in your own audit script is not a divergence in the data.

## Hypotheses are not findings

- **When there are competing explanations, test each one before presenting any of them.** Don't
  write "it may be A or B" and let me forward it. If you can't test them, say plainly that it's
  an open question and what would settle it.
- **Label every claim**: *verified* (with the source), *inferred* (with the reasoning), or
  *not checked*. Only *verified* claims go into text for someone else as statements of fact.
- **Go deep enough to answer the actual question.** If the investigation stopped early (a
  blocked source, missing access, a time limit), say exactly where it stopped and what remains
  unknown, instead of filling the gap with a plausible guess.

## Text for someone else

- **Verification gate before drafting.** When I ask to turn findings into a message for someone,
  re-verify every claim in it against the live sources first, even if you verified it earlier in
  the session. Then draft.
- **Write each claim so the recipient can check it with what they have access to.** They have
  the spreadsheet/system UI, not our database or scripts, so cite tab, row, and value in their
  terms.
- **If one claim turns out wrong, re-check all the others in the same analysis**, not just the
  one I pointed out. One error means the method had a gap.

## Always end with "how to check it yourself"

At the end of every analysis reply to me, add a section **"Como conferir"** with, for each main
claim:

1. **Where to look**: system/URL, tab or screen, filter, row or record id.
2. **What you should see there**: the expected value or text.
3. **How to reproduce it** when it came from a query or script: the exact command, with the path
   to the script in the scratchpad (and keep that script there).

Prefer steps I can follow in the tools I and the recipient already use (the spreadsheet, the
system's UI, the panel) over steps that only work with your scripts. List separately any claim
you could **not** verify, with the reason.
