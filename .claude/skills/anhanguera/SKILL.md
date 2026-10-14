---
name: anhanguera
description: Levanta no AVA da Anhanguera (via Playwright) tudo o que falta fazer nas disciplinas em andamento (exercícios de unidade, atividades práticas, trabalhos, provas), com prazos e pesos, e monta um plano de estudos priorizado. Use quando o usuário pedir para ver pendências, prazos, notas ou um plano de estudos da faculdade.
---

# Plano de estudos: AVA Anhanguera

Objetivo: descobrir o que está pendente em cada disciplina em andamento, com prazo e peso na
nota, e devolver um plano de estudos priorizado. **Só leitura.**

## Regras invioláveis

- **Nunca clique em nada que inicie ou envie uma avaliação**: "Fazer exercício", "Fazer
  atividade", "Iniciar prova", "Treinar agora", "Enviar", "Refazer". O usuário faz tudo ele mesmo.
  Abrir páginas de disciplina, de notas e expandir unidades pode.
- **Nunca preencha nem toque nos campos de login.** O usuário faz login sozinho na janela do
  navegador.
- **Nunca leia, imprima ou salve headers, cookies, tokens ou `localStorage`.** O script de coleta
  não precisa de nada disso: ele só escuta as respostas que o próprio site já carrega.
- **Não grave dados pessoais em arquivo** (nome, matrícula, IDs de curso/matrícula, notas). O
  resultado fica só na conversa. Não salve snapshots/respostas em arquivo sem necessidade; se
  salvar algo para depurar, apague no fim. Não edite esta skill com dados reais: exemplos usam
  valores fictícios.

## Passo a passo

1. **Abrir o login.** Carregue as ferramentas do Playwright MCP (`ToolSearch` com
   `select:mcp__playwright__browser_navigate,mcp__playwright__browser_run_code_unsafe,mcp__playwright__browser_wait_for,mcp__playwright__browser_snapshot`)
   e navegue para `https://www.anhanguera.com/aluno/ava/login`. Se a página já cair na home
   logada (URL com `/aluno/home/...`), pule para o passo 3.

2. **Esperar o login.** Peça para o usuário fazer login na janela do navegador (captcha/2FA
   inclusos) e avisar quando terminar. Não continue antes disso.

3. **Garantir que está na home do curso.** A URL precisa ter o formato
   `https://www.anhanguera.com/aluno/home/<tipo>/<id-do-curso>`, por exemplo
   `https://www.anhanguera.com/aluno/home/tecnologo/KRT-00000000-0000-0000-0000-000000000000`
   (fictício). Se o usuário tiver mais de um curso e cair na seleção de curso, pergunte qual usar.

4. **Coletar.** Rode o script desta skill com `browser_run_code_unsafe`, passando o caminho
   **absoluto** em `filename` (expanda o `~`):

   ```
   filename: ~/.claude/skills/anhanguera/coletar.js
   ```

   Ele abre a página de cada disciplina em andamento (em abas paralelas que fecha sozinho), captura
   as respostas GraphQL que o site carrega e devolve um JSON resumido. Retornos especiais:
   - `{ precisaLogin: true }`: sessão expirou, volte ao passo 1.
   - `{ erro: ... }`: leia a mensagem; normalmente é por não estar na home do curso.
   - `faltouCapturar` não vazio numa disciplina: a página demorou; rode de novo uma vez. Se
     persistir, abra a página da disciplina manualmente e confira pela interface.

5. **Interpretar** (regras abaixo) e **responder com o plano** (formato abaixo).

## Como interpretar o JSON

Campos por disciplina: `avaliacoes` (trabalhos `ASSIGNMENT` e provas `EXAM`), `unidades` (cada
uma com `exercicios`, que são os `QUIZ`, e `atividadesPraticas`), `calendario` (períodos oficiais),
`pesos`, `notaMinima`, `notaFinal` (pontuação atual), `progresso` (`TIPO feitos/total`).

- **Nota zerada não quer dizer pendência.** Pode ser item em correção ou nota ainda não
  liberada. O critério de pendente é: **lista `tentativas` vazia** e `status` diferente de
  `DONE`. Item com tentativa registrada conta como feito, mesmo com nota 0.
- **Exercício de unidade**: pendente quando `tentativas` está vazio. Se foi feito com nota baixa
  e ainda sobra tentativa (`tentativasPermitidas` > número de tentativas), sugira refazer, citando
  a nota que tirou.
- **Atividade prática**: o site lista a atividade em `unidades[].atividadesPraticas` e a entrega em
  `avaliacoes` do tipo `ASSIGNMENT` (normalmente uma por atividade prática, mas a API não liga as
  duas explicitamente). Entrega sem tentativa = atividade não entregue.
- **Disciplinas de projeto** (extensão, projeto integrado) costumam ter só um `ASSIGNMENT` valendo
  100: é o trabalho inteiro, sem questões.
- **Prazo efetivo**: use sempre a data **mais cedo** entre o `prazo` do item e o período
  correspondente no `calendario`. O calendário costuma fechar antes. Exemplo: trabalho com prazo
  22/12 na avaliação, mas "Período de Trabalho" até 12/12; vale 12/12.
- **Período de estudo** (`calendario`, título "Período de estudo"): é o prazo para assistir às aulas
  (pontos de "Progresso em Aula", ver `ATTENDANCE` em `progresso`). Avise se faltam aulas e o
  período está acabando.
- **Provas**: 1ª chamada no "Período de prova"; existem "Segunda Chamada" e "Recuperação"
  (a recuperação só depois de fazer a 1ª ou 2ª chamada). Planeje para a 1ª chamada; cite a 2ª só
  como plano B.
- **Matemática da nota**: com os `pesos`, calcule quanto cada disciplina já tem, quanto ainda dá
  para ganhar e se os 60 pontos estão em risco. Exercícios rendem poucos pontos e são rápidos;
  trabalho e prova pesam mais.
- Compare tudo com `hoje` (vem no JSON) e calcule os dias restantes.

## Formato da resposta

Em português, direto, sem enrolação. Datas em `dd/mm` com dia da semana quando for próximo.

1. **Urgente (próximos 7 dias)**: o que vence ou abre logo, com data e dias restantes.
2. **Próximas semanas**: provas e entregas seguintes, em ordem cronológica.
3. **Pendências por disciplina**: exercícios (por unidade), atividades práticas, trabalhos e
   provas, com prazo efetivo, mais pontuação atual e quanto ainda dá para ganhar.
4. **Onde focar**: 3 a 5 prioridades justificadas (prazo mais próximo, maior peso, disciplina com
   aprovação em risco, itens rápidos que garantem pontos).
5. **Sugestão de semana**: distribuição leve por dia até a próxima prova/entrega importante. Pergunte
   ao usuário quanto tempo por dia ele tem, se ainda não souber, e ajuste.

Se o usuário pedir algo para guardar ou compartilhar (um calendário, uma página), ofereça um
artifact; não publique por conta própria.
