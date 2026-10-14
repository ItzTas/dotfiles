---
name: anhanguera
description: Uses Playwright to scan the Anhanguera AVA (student portal) for everything still pending in the in-progress subjects (unit quizzes, practical activities, assignments, exams), with deadlines and grade weights, and builds a prioritized study plan. Use when the user asks about pending coursework, deadlines, grades, or a study plan for college.
---

# Study plan: Anhanguera AVA

Goal: find what is pending in each in-progress subject, with its deadline and grade weight, and
return a prioritized study plan. **Read-only.**

## Hard rules

- **Never click anything that starts or submits an assessment**: "Fazer exercício", "Fazer
  atividade", "Iniciar prova", "Treinar agora", "Enviar", "Refazer". The user does all of them
  personally. Opening subject pages, grade pages and expanding units is fine.
- **Never fill in or touch the login fields.** The user logs in alone in the browser window.
- **Never read, print or save headers, cookies, tokens or `localStorage`.** The collector script
  doesn't need any of that: it only listens to responses the site already loads.
- **Don't write personal data to files** (name, student ID, course/enrollment IDs, grades). Results
  stay in the conversation. Don't save snapshots or responses to files unless needed; if you save
  something for debugging, delete it at the end. Never edit this skill with real data: examples use
  fictitious values.

## Steps

1. **Open the login page.** Load the Playwright MCP tools (`ToolSearch` with
   `select:mcp__playwright__browser_navigate,mcp__playwright__browser_run_code_unsafe,mcp__playwright__browser_wait_for,mcp__playwright__browser_snapshot`)
   and navigate to `https://www.anhanguera.com/aluno/ava/login`. If it lands on the logged-in home
   (URL with `/aluno/home/...`), skip to step 3.

2. **Wait for the login.** Ask the user to log in in the browser window (captcha/2FA included) and
   to tell you when done. Don't continue before that.

3. **Make sure you're on the course home.** The URL must look like
   `https://www.anhanguera.com/aluno/home/<type>/<course-id>`, e.g.
   `https://www.anhanguera.com/aluno/home/tecnologo/KRT-00000000-0000-0000-0000-000000000000`
   (fictitious). If the user has more than one course and lands on the course picker, ask which one.

4. **Collect.** Run this skill's script with `browser_run_code_unsafe`, passing the **absolute**
   path in `filename` (expand the `~`):

   ```
   filename: ~/.claude/skills/anhanguera/collect.js
   ```

   It opens each in-progress subject's page (in parallel tabs it closes itself), captures the
   GraphQL responses the site loads and returns a compact JSON. Special results:
   - `{ needsLogin: true }`: session expired, go back to step 1.
   - `{ error: ... }`: read the message; usually it means you weren't on the course home.
   - non-empty `missingCaptures` on a subject: the page was slow even after the script's own
     retry; run it again once. If it persists, open that subject's page manually and check through
     the UI.

5. **Interpret** (rules below) and **reply with the plan** (format below).

## Reading the JSON

Per subject: `assessments` (assignments `ASSIGNMENT` and exams `EXAM`), `units` (each with
`quizzes` and `practicalActivities`), `calendar` (official periods), `weights`, `passingScore`,
`currentScore`, `progress` (`TYPE done/total`).

- **A zero grade does not mean pending.** The item may be awaiting grading or the grade may not be
  released yet. The pending criterion is: **empty `attempts` list** and `status` other than
  `DONE`. An item with a recorded attempt counts as done, even with grade 0.
- **Unit quiz** ("exercício de unidade"): pending when `attempts` is empty. If it was done with a
  low grade and attempts remain (`allowedAttempts` > number of attempts), suggest retaking it,
  citing the grade.
- **Practical activity** ("atividade prática"): the site lists the activity in
  `units[].practicalActivities` and its submission in `assessments` of type `ASSIGNMENT` (usually
  one per practical activity, but the API doesn't link them explicitly). Submission with no attempt
  = activity not delivered.
- **Project subjects** (extension project, integrated project) usually have a single `ASSIGNMENT`
  worth 100: that's the whole work, no quizzes.
- **Effective deadline**: always use the **earliest** date between the item's `due` and the matching
  period in `calendar`. The calendar usually closes first. Example: an assignment due 22/12 in
  `assessments`, but "Período de Trabalho" ends 12/12; 12/12 is the real deadline.
- **Study period** (`calendar` entry "Período de estudo"): deadline for watching lessons (the
  "Progresso em Aula" points, see `ATTENDANCE` in `progress`). Warn if lessons are missing and the
  period is ending.
- **Exams**: first sitting in "Período de prova"; there are also "Segunda Chamada" (second sitting)
  and "Recuperação" (make-up, only after taking the first or second sitting). Plan for the first
  sitting; mention the second only as a fallback.
- **Grade math**: using `weights`, compute what each subject already has, how much is still
  available and whether the passing score is at risk. Quizzes give few points and are quick;
  assignments and exams weigh more.
- Compare everything against `today` (in the JSON) and compute days left.

## Reply format

Reply in the user's language, direct, no filler. Dates as `dd/mm`, with weekday when close.

1. **Urgent (next 7 days)**: what is due or opens soon, with date and days left.
2. **Coming weeks**: upcoming exams and deadlines, in chronological order.
3. **Pending per subject**: quizzes (per unit), practical activities, assignments and exams, with the
   effective deadline, plus current score and how many points are still available.
4. **Where to focus**: 3 to 5 justified priorities (closest deadline, highest weight, subject at
   risk of failing, quick items that secure points).
5. **Suggested week**: a light per-day distribution up to the next important exam/deadline. Ask how
   much time per day the user has, if not known yet, and adjust.

If the user wants something to keep or share (a calendar, a page), offer an artifact; don't publish
on your own.
