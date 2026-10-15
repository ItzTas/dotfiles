---
name: relay-setup
description: Set up the local Claude relay (Claude + DeepSeek + Ollama num /model só, socket-activated, on-demand)
---

# Claude relay setup

Configura o relay local (`~/.local/bin/claude-relay`) que expõe **Claude (assinatura),
DeepSeek e Ollama local** atrás de um endpoint Anthropic único na porta 4000, com
ciclo de vida on-demand (socket activation do systemd): sobe no primeiro uso, para
quando a última sessão encerra. Substitui o antigo gateway LiteLLM (skill
`litellm-setup`, aposentada).

Use esta skill em uma máquina nova (ou pra reconfigurar).
Convenções de flags, equivalentes: `--setup` = `-setup` = `-s`.

## Arquitetura

```
Claude Code ── Anthropic /v1/messages ──▶ relay (127.0.0.1:4000)
                                            ├─▶ api.anthropic.com        (claude-*; repassa OAuth da assinatura)
                                            ├─▶ api.deepseek.com/anthropic (anthropic/deepseek-*; DEEPSEEK_API_KEY do relay)
                                            └─▶ 127.0.0.1:11434          (anthropic/ollama/*; Ollama local, v0.14+)
```

- Roteamento por model id; upstreams recebem o nome puro (prefixos são só pro
  discovery do Claude Code, cujo filtro descarta ids que não começam com
  `claude`/`anthropic`).
- Ollama antes de DeepSeek na precedência: `ollama/deepseek-r1` local tem
  "deepseek" no nome mas mora no Ollama.
- `GET /v1/models` lista Claude + DeepSeek estáticos e consulta
  `127.0.0.1:11434/api/tags` (timeout 2s). Os models do Ollama aparecem no `/model`
  automaticamente quando o daemon está de pé.
- `count_tokens` de models Ollama é respondido localmente (estimativa): o daemon
  não implementa e pode travar com esse endpoint.
- Sem auth própria no relay (localhost only): claude-* repassa o token que chegou
  (OAuth da assinatura funciona), deepseek usa a chave do `.env` do serviço.
- `StopWhenUnused=` NÃO existe no systemd 261 (`Unknown key`). O stop-on-idle é
  feito pelo wrapper `cct` (para o serviço quando a última sessão encerra).

## Arquivos (já tracked no yadm, vêm no clone)

| Arquivo | Papel |
|---|---|
| `~/.local/bin/claude-relay` | relay (python; shebang aponta pro venv) |
| função zsh `cct` (`~/.config/zsh/config/functions`) | sessão Claude Code apontada pro relay, stop-on-idle |
| `~/.config/systemd/user/relay.socket` | socket 127.0.0.1:4000, `Accept=no` |
| `~/.config/systemd/user/relay.service` | serviço socket-activated, `EnvironmentFile=~/.config/litellm/.env` |

## Script

`~/.claude/skills/relay-setup/scripts/setup.sh [check|venv|secret|enable|test] [--probe] [--force] [--dry-run]`

Stdout é JSON compacto; os passos vão pro stderr (`+` executa, `=` já feito, `!` recusado).
Exit: `0` ok, `1` resultado negativo (não pronto, teste falhou, recusa), `2` uso/ambiente.

| Subcomando | O que faz |
|---|---|
| `check` (padrão) | Só leitura: venv + deps, binário/shebang, `.env` (existe, modo 600, tem `DEEPSEEK_API_KEY=`; nunca o conteúdo), units, `relay.socket`/`relay.service`, Ollama (só consulta `:11434` se estiver rodando). Saída `{venv, relay_bin, secret, units, systemd, ollama, endpoint, todo[], manual[], ready}`. `--probe` também faz `GET :4000/v1/models`, o que **sobe o relay**. |
| `venv` | Cria `~/.local/share/litellm-venv` (nome histórico; só o python do relay) e instala o que falta de `fastapi httpx uvicorn`. Não precisa de litellm nem do pin `fastapi<0.116` (eram do gateway antigo). |
| `secret` | Grava `~/.config/litellm/.env` (0600; dirs `~/.config/litellm` e `~/.cache/litellm` 0700) a partir de `$DEEPSEEK_API_KEY`. Recusa variável vazia; recusa sobrescrever sem `--force`. |
| `enable` | `systemctl --user daemon-reload` + `enable --now relay.socket` (pula se já ativo). |
| `test` | `GET /v1/models` + `POST /v1/messages` com `anthropic/deepseek-v4-flash`, `max_tokens` 100 (os tokens vão pro bloco `thinking` primeiro). Resumo pass/fail, sem corpo cru. |

Mutantes imprimem `{subcommand, dry_run, ok, steps[{step, status}], warnings[]}`;
`--dry-run` mostra o plano sem mudar nada.

## Fluxo

1. Rode `check` e mostre ao usuário o que falta (`todo` = subcomandos, `manual` = o que
   o script não resolve: binário/units do yadm, `chmod 600`).
2. Proponha o plano na ordem `venv` → `secret` → `enable` → `test` (o `--dry-run` mostra
   os comandos) e **só rode subcomandos mutantes depois que o usuário confirmar**.
   `test` e `check --probe` também precisam de confirmação: sobem o relay.
3. `secret` lê `$DEEPSEEK_API_KEY` do ambiente. Se a variável não estiver na sessão, peça
   ao usuário pra rodar o `secret` no próprio terminal; nunca peça a chave no chat nem
   num comando `!` (o hook de histórico grava esses comandos).
4. Ciclo de vida: `systemctl --user stop relay.service` para; o próximo request
   re-ativa (o socket continua escutando).

### Ollama (opcional)

Instalar Ollama >= 0.14 (endpoint Anthropic nativo) e puxar um model. Nada a
configurar no relay: com o daemon de pé, os models entram no `/v1/models` como
`anthropic/ollama/<nome>` e aparecem no `/model` (o `check` mostra `ollama.models`).
Recomendado model com contexto >= 32k pra Claude Code.

## Uso

- `cct` abre uma sessão com relay: `/model` mostra e troca entre Claude (assinatura),
  DeepSeek e Ollama (quando o daemon estiver de pé).
- `claude` é o Claude real direto, intocado (sem relay).
- Setup principal hoje é o OmniRoute (`ccr`, skill `omniroute-setup`); o relay
  fica de fallback.

## Operação

| Ação | Comando |
|---|---|
| Relay sobe | automático (socket activation no primeiro uso) |
| Relay para | automático (fim da última sessão `cct`) |
| Forçar parar | `systemctl --user stop relay.service` |
| Logs | `journalctl --user -u relay.service -f` |

## Secretas

- `~/.config/litellm/.env` contém a chave DeepSeek, então **nunca** adicionar ao
  yadm/git (`~/.gitignore` já cobre `.env` e o obsoleto `master_key`). O script nunca
  imprime o conteúdo nem põe a chave em linha de comando.
