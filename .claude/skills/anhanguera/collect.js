async (page) => {
  const WANTED_OPS = new Set([
    'GetCourseEnrollmentForPages',
    'FindLearningUnitEnrollments',
    'GetCallendarSubjectEnrollment',
  ]);
  const TIMEOUT_MS = 25000;

  const capture = (target) => {
    const captured = [];
    target.on('response', async (response) => {
      const request = response.request();
      if (request.method() !== 'POST' || !request.url().includes('graphql')) return;
      const raw = request.postData();
      if (!raw || !raw.includes('"operationName"')) return;
      const body = JSON.parse(raw);
      if (!WANTED_OPS.has(body.operationName)) return;
      const entry = { op: body.operationName, vars: body.variables };
      try {
        entry.data = await response.json();
      } catch (err) {
        entry.error = `unreadable response: ${err.message}`;
      }
      captured.push(entry);
    });
    return captured;
  };

  const isLoggedOut = (target) => target.url().includes('/login');

  const waitFor = async (target, captured, predicate) => {
    const start = Date.now();
    while (Date.now() - start < TIMEOUT_MS) {
      if (isLoggedOut(target)) return null;
      const hit = captured.find(predicate);
      if (hit) return hit;
      await target.waitForTimeout(300);
    }
    return null;
  };

  if (isLoggedOut(page)) return { needsLogin: true };
  const match = page.url().match(/\/aluno\/(?:home|ava)\/([^/]+)\/([^/?#]+)/);
  if (!match) return { error: 'Open the course home page (logged in) before running the script.', url: page.url() };
  const [, courseType, courseId] = match;
  const base = `https://www.anhanguera.com/aluno/ava/${courseType}/${courseId}`;
  const context = page.context();

  const loadSubject = async (subjectId) => {
    const tab = await context.newPage();
    const captured = capture(tab);
    try {
      await tab.goto(`${base}/enrollment/${subjectId}`);
      const bySubject = (op) => (c) => c.op === op && c.vars?.subjectEnrollmentId === subjectId;
      const [units, calendar, course] = await Promise.all([
        waitFor(tab, captured, bySubject('FindLearningUnitEnrollments')),
        waitFor(tab, captured, bySubject('GetCallendarSubjectEnrollment')),
        waitFor(tab, captured, (c) => c.op === 'GetCourseEnrollmentForPages'),
      ]);
      return { units, calendar, course, loggedOut: isLoggedOut(tab) };
    } finally {
      await tab.close();
    }
  };

  const loadSubjectWithRetry = async (subjectId) => {
    const first = await loadSubject(subjectId);
    if (first.loggedOut || (first.units && first.calendar)) return first;
    return loadSubject(subjectId);
  };

  const firstCaptured = capture(page);
  await page.goto(`${base}/minhas-disciplinas`);
  const course = await waitFor(page, firstCaptured, (c) => c.op === 'GetCourseEnrollmentForPages');
  if (isLoggedOut(page)) return { needsLogin: true };
  if (!course?.data) return { error: 'Could not capture the subject list from "Minhas Disciplinas".' };

  const enrollment = course.data.data.data;
  const current = enrollment.subjectEnrollments.filter((s) => s.status === 'IN_PROGRESS');
  const details = await Promise.all(current.map((s) => loadSubjectWithRetry(s.id)));
  if (details.some((d) => d.loggedOut)) return { needsLogin: true };

  const attemptsOf = (detail) => (detail?.attempts ?? []).map((a) => a.grade);
  const summarizeAssignment = (a) => ({
    name: a.detail?.display?.name ?? a.detail?.config?.name,
    type: a.detail?.config?.type,
    status: a.status,
    period: a.detail?.display?.periodDates,
    start: a.detail?.startDate,
    due: a.detail?.dueDate,
    attempts: attemptsOf(a.detail),
  });
  const summarizeUnit = (u) => ({
    order: u.order,
    title: u.title,
    practicalActivities: (u.practicalActivities ?? []).map((p) => p.title),
    quizzes: (u.assignments ?? [])
      .filter((a) => a.detail?.config?.type === 'QUIZ')
      .map((a) => ({
        points: `${a.grade}/${a.maxGrade}`,
        allowedAttempts: a.detail.config.numberOfAttempts,
        attempts: attemptsOf(a.detail),
        due: a.detail.dueDate,
      })),
  });

  return {
    today: new Date().toISOString().slice(0, 10),
    course: enrollment.course?.name,
    courseProgress: `${enrollment.subjectsProgress?.passedCourseNumber}/${enrollment.subjectsProgress?.totalCourseNumber}`,
    subjects: current.map((s, i) => ({
      name: s.subject.name,
      start: s.startDate,
      end: s.endDate,
      currentScore: s.finalGrade,
      passingScore: s.gradingMethod?.cutOffScore,
      weights: (s.gradingMethod?.assignmentConfigs ?? []).map((c) => `${c.type} ${c.name}: ${c.weight}`),
      progress: s.progress?.details?.map((d) => `${d.type} ${d.completed ?? 0}/${d.quantity}`),
      assessments: s.assignments.map(summarizeAssignment),
      units: (details[i].units?.data?.data?.data ?? [])
        .slice()
        .sort((a, b) => a.order - b.order)
        .map(summarizeUnit),
      calendar: (details[i].calendar?.data?.data?.getCallendarSubjectEnrollment ?? []).map((c) => ({
        title: c.title,
        detail: c.subTitle,
        type: c.type,
        start: c.startDate,
        due: c.dueDate,
      })),
      missingCaptures: ['units', 'calendar'].filter((k) => !details[i][k]?.data),
    })),
  };
}
