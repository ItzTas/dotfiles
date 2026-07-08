---
description: Comita, dá push e abre PR (GitHub) e/ou MR (GitLab) da branch atual para a branch alvo
argument-hint: [branch-alvo]
allowed-tools: Bash(git*), Bash(gh*), Bash(glab*), Bash(yadm*), Read, Glob
---

Abra uma pull request (GitHub) e/ou merge request (GitLab) da branch atual para a branch alvo,
comitando e dando push de todas as mudanças antes.

Argumento recebido (branch alvo): `$1`

Siga exatamente estes passos:

## 1. Determinar a branch alvo
- Se `$1` foi informado, use-o como branch alvo.
- Se `$1` estiver vazio, **pergunte-me** para qual branch devo abrir a PR/MR antes de continuar.
  Não assuma `main`/`master` sozinho.

## 2. Detectar os remotes (GitHub e GitLab)
- Rode `git remote -v` e identifique quais remotes apontam para `github.com` e/ou `gitlab.com`
  (ou instâncias self-hosted equivalentes).
- Guarde o resultado: pode haver **só GitHub**, **só GitLab**, ou **os dois**.
- Se houver os dois, você criará **uma PR no GitHub E uma MR no GitLab**.

## 3. Comitar e dar push de todas as mudanças
- Verifique o estado com `git status` e `git diff`.
- Comite **todas** as mudanças pendentes seguindo as regras do meu `CLAUDE.md`:
  commits atômicos, Conventional Commits, imperativo, **sem** `Co-Authored-By` nem qualquer
  atribuição a você (o commit é só meu).
- Faça `git push` da branch atual (use `-u` se ela ainda não tiver upstream).

## 4. Procurar template no repositório
Procure templates antes de escrever o corpo da PR/MR:
- GitHub: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`,
  `.github/PULL_REQUEST_TEMPLATE/` (pasta), `docs/PULL_REQUEST_TEMPLATE.md`,
  `PULL_REQUEST_TEMPLATE.md` na raiz.
- GitLab: `.gitlab/merge_request_templates/*.md`.
- Se encontrar template, **use-o** como base do corpo, preenchendo as seções com base nas mudanças.
- Se não encontrar, escreva um corpo conciso: resumo do que mudou e por quê.

## 5. Criar a(s) PR/MR
- **GitHub** (se houver remote do GitHub): `gh pr create --base <alvo> --head <branch-atual>`
  com título (Conventional Commits) e corpo (template preenchido ou resumo).
- **GitLab** (se houver remote do GitLab): `glab mr create --target-branch <alvo>
  --source-branch <branch-atual>` com título e corpo equivalentes.
- Se ambos existirem, crie os dois e me mostre os dois links no final.

Ao terminar, mostre um resumo: branch alvo, o que foi comitado, e os links da(s) PR/MR criada(s).
