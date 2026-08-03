---
description: Set up the local Claude relay (Claude + DeepSeek + Ollama num /model só, socket-activated, on-demand)
---

# Claude relay setup

Configura o relay local (`~/.local/bin/claude-relay`) que expõe **Claude (assinatura),
DeepSeek e Ollama local** atrás de um endpoint Anthropic único na porta 4000, com
ciclo de vida on-demand (socket activation do systemd): sobe no primeiro uso, para
quando a última sessão encerra. Substitui o antigo gateway LiteLLM (skill
`litellm-setup`, aposentada).

Use esta skill em uma máquina nova (ou pra reconfigurar) e replique os passos.
Convenções de flags: aceita `-setup` igual a `--setup`.

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
  `127.0.0.1:11434/api/tags` (timeout 2s) — models do Ollama aparecem no `/model`
  automaticamente quando o daemon está de pé.
- `count_tokens` de models Ollama é respondido localmente (estimativa) — o daemon
  não implementa e pode travar com esse endpoint.
- Sem auth própria no relay (localhost only): claude-* repassa o token que chegou
  (OAuth da assinatura funciona), deepseek usa a chave do `.env` do serviço.
- `StopWhenUnused=` NÃO existe no systemd 261 (`Unknown key`). O stop-on-idle é
  feito pelo wrapper `deepseek` (para o serviço quando a última sessão encerra).

## Arquivos (já tracked no yadm — vêm no clone)

| Arquivo | Papel |
|---|---|
| `~/.local/bin/claude-relay` | relay (python; shebang aponta pro venv) |
| `~/.local/bin/deepseek` | wrapper: sessão Claude Code apontada pro relay, default deepseek, fallback endpoint nativo, stop-on-idle |
| `~/.config/systemd/user/relay.socket` | socket 127.0.0.1:4000, `Accept=no` |
| `~/.config/systemd/user/relay.service` | serviço socket-activated, `EnvironmentFile=~/.config/litellm/.env` |

## Passos numa máquina nova

### 1. Venv com as deps do relay

```bash
python3 -m venv "$HOME/.local/share/litellm-venv"   # nome histórico; só o python do relay
"$HOME/.local/share/litellm-venv/bin/pip" install fastapi httpx uvicorn
```

(Não precisa de litellm nem do pin `fastapi<0.116` — aquilo era do gateway antigo.)

### 2. Secret

`~/.config/litellm/.env` (0600), fora do yadm (`~/.gitignore` já bloqueia):

```bash
umask 077
mkdir -p ~/.config/litellm ~/.cache/litellm
printf 'DEEPSEEK_API_KEY=%s\n' "$DEEPSEEK_API_KEY" > ~/.config/litellm/.env
chmod 600 ~/.config/litellm/.env
```

### 3. Ativar e testar

```bash
systemctl --user daemon-reload
systemctl --user enable --now relay.socket

curl -s http://127.0.0.1:4000/v1/models   # claude-* + anthropic/deepseek-* (+ ollama se daemon up)
curl -s http://127.0.0.1:4000/v1/messages \
  -H "content-type: application/json" -H "anthropic-version: 2023-06-01" \
  -d '{"model":"anthropic/deepseek-v4-flash","max_tokens":100,"messages":[{"role":"user","content":"oi"}]}'
```

- `max_tokens` >= 100 no teste: tokens vão pro bloco `thinking` primeiro.
- Ciclo de vida: `systemctl --user stop relay.service` para; o próximo request
  re-ativa (socket continua escutando).

### 4. Ollama (opcional)

Instalar Ollama >= 0.14 (endpoint Anthropic nativo) e puxar um model. Nada a
configurar no relay: com o daemon de pé, os models entram no `/v1/models` como
`anthropic/ollama/<nome>` e aparecem no `/model`. Recomendado model com contexto
>= 32k pra Claude Code.

## Uso

- `deepseek` — sessão com relay: abre em DeepSeek, `/model` mostra e troca entre
  Claude (assinatura), DeepSeek e Ollama.
- `claude` — Claude real direto, intocado (sem relay).

## Operação

| Ação | Comando |
|---|---|
| Relay sobe | automático (socket activation no primeiro uso) |
| Relay para | automático (fim da última sessão `deepseek`) |
| Forçar parar | `systemctl --user stop relay.service` |
| Logs | `journalctl --user -u relay.service -f` |

## Secretas

- `~/.config/litellm/.env` contém a chave DeepSeek — **nunca** adicionar ao
  yadm/git (`~/.gitignore` já cobre `.env` e o obsoleto `master_key`).
