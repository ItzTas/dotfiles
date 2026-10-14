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
        entry.error = `resposta ilegível: ${err.message}`;
      }
      captured.push(entry);
    });
    return captured;
  };

  const waitFor = async (target, captured, predicate) => {
    const start = Date.now();
    while (Date.now() - start < TIMEOUT_MS) {
      const hit = captured.find(predicate);
      if (hit) return hit;
      await target.waitForTimeout(300);
    }
    return null;
  };

  const match = page.url().match(/\/aluno\/(?:home|ava)\/([^/]+)\/([^/?#]+)/);
  if (!match) return { erro: 'Abra a home do curso (já logado) antes de rodar o script.', url: page.url() };
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
      return { units, calendar, course };
    } finally {
      await tab.close();
    }
  };

  const firstCaptured = capture(page);
  await page.goto(`${base}/minhas-disciplinas`);
  if (page.url().includes('/login')) return { precisaLogin: true };

  // A lista de disciplinas só vem junto da página de uma disciplina; pega o primeiro link de disciplina.
  let course = await waitFor(page, firstCaptured, (c) => c.op === 'GetCourseEnrollmentForPages');
  if (!course) {
    const frame = page.frames().find((f) => f.url().includes('minhas-disciplinas')) ?? page.mainFrame();
    const href = await frame.locator('a[href*="/enrollment/"]').first().getAttribute('href', { timeout: TIMEOUT_MS });
    const firstId = href.split('/enrollment/')[1].split(/[/?#]/)[0];
    course = (await loadSubject(firstId)).course;
  }
  if (!course?.data) return { erro: 'Não consegui capturar a lista de disciplinas.' };

  const enrollment = course.data.data.data;
  const current = enrollment.subjectEnrollments.filter((s) => s.status === 'IN_PROGRESS');
  const details = await Promise.all(current.map((s) => loadSubject(s.id)));

  const attemptsOf = (detail) => (detail?.attempts ?? []).map((a) => a.grade);
  const summarizeAssignment = (a) => ({
    nome: a.detail?.display?.name ?? a.detail?.config?.name,
    tipo: a.detail?.config?.type,
    status: a.status,
    periodo: a.detail?.display?.periodDates,
    inicio: a.detail?.startDate,
    prazo: a.detail?.dueDate,
    tentativas: attemptsOf(a.detail),
  });
  const summarizeUnit = (u) => ({
    ordem: u.order,
    titulo: u.title,
    atividadesPraticas: (u.practicalActivities ?? []).map((p) => p.title),
    exercicios: (u.assignments ?? [])
      .filter((a) => a.detail?.config?.type === 'QUIZ')
      .map((a) => ({
        pontos: `${a.grade}/${a.maxGrade}`,
        tentativasPermitidas: a.detail.config.numberOfAttempts,
        tentativas: attemptsOf(a.detail),
        prazo: a.detail.dueDate,
      })),
  });

  return {
    hoje: new Date().toISOString().slice(0, 10),
    curso: enrollment.course?.name,
    progressoCurso: `${enrollment.subjectsProgress?.passedCourseNumber}/${enrollment.subjectsProgress?.totalCourseNumber}`,
    disciplinas: current.map((s, i) => ({
      nome: s.subject.name,
      inicio: s.startDate,
      fim: s.endDate,
      notaFinal: s.finalGrade,
      notaMinima: s.gradingMethod?.cutOffScore,
      pesos: (s.gradingMethod?.assignmentConfigs ?? []).map((c) => `${c.type} ${c.name}: ${c.weight}`),
      progresso: s.progress?.details?.map((d) => `${d.type} ${d.completed ?? 0}/${d.quantity}`),
      avaliacoes: s.assignments.map(summarizeAssignment),
      unidades: (details[i].units?.data?.data?.data ?? [])
        .slice()
        .sort((a, b) => a.order - b.order)
        .map(summarizeUnit),
      calendario: (details[i].calendar?.data?.data?.getCallendarSubjectEnrollment ?? []).map((c) => ({
        titulo: c.title,
        detalhe: c.subTitle,
        tipo: c.type,
        inicio: c.startDate,
        prazo: c.dueDate,
      })),
      faltouCapturar: ['units', 'calendar'].filter((k) => !details[i][k]?.data),
    })),
  };
}
