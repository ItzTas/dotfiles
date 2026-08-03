---
description: Set up the LiteLLM gateway (DeepSeek via Claude Code, socket-activated, on-demand)
---

# LiteLLM gateway setup

Configura o gateway LiteLLM local que roteia o **DeepSeek** para o Claude Code via
gateway model discovery, com ciclo de vida on-demand (socket activation do systemd):
sobe no primeiro uso, para quando a última sessão encerra. Claude real (assinatura
claude.ai) NÃO passa pelo gateway — roda direto via `claude` (OAuth próprio).

Use esta skill em uma máquina nova (ou pra reconfigurar) e replique os passos.
Convenções de flags: aceita `-setup` igual a `--setup`.

## Por que essa arquitetura

- Claude Code só mostra no `/model` (gateway discovery) IDs que começam com
  `claude`/`anthropic`. Por isso os modelos DeepSeek são expostos como
  `anthropic/deepseek-*` (model_name) roteando pra DeepSeek (litellm_params).
- DeepSeek já fala Anthropic nativo (`https://api.deepseek.com/anthropic`) — o
  wrapper `deepseek` tem fallback pra esse endpoint direto se o gateway cair.
- LiteLLM sem API key da Anthropic NÃO roteia Claude real. Só assinatura claude.ai?
  Gateway serve só DeepSeek; `claude` fica direto.
- `StopWhenUnused=` NÃO existe no systemd 261 (`Unknown key`). O stop-on-idle é
  feito pelo wrapper `deepseek` (para o serviço quando a última sessão encerra).

## Pré-requisitos

- `python3` com `venv`
- `DEEPSEEK_API_KEY` disponível (env)
- systemd user rodando: `systemctl --user is-system-running`
- Porta 4000 livre

## Passos

### 1. Instalar litellm

```bash
python3 -m venv "$HOME/.local/share/litellm-venv"
"$HOME/.local/share/litellm-venv/bin/pip" install -U 'litellm[proxy]'
# Python 3.14 instala fastapi novo demais; pinar:
"$HOME/.local/share/litellm-venv/bin/pip" install 'fastapi<0.116'
```

Caveat: sem o pin `fastapi<0.116`, o proxy quebra com
`ImportError: cannot import name 'get_flat_dependant'`.

### 2. Config

`~/.config/litellm/config.yaml`:

```yaml
model_list:
  - model_name: anthropic/deepseek-v4-flash
    litellm_params:
      model: deepseek/deepseek-v4-flash
      api_base: https://api.deepseek.com
      api_key: os.environ/DEEPSEEK_API_KEY
  - model_name: anthropic/deepseek-v4-pro
    litellm_params:
      model: deepseek/deepseek-v4-pro
      api_base: https://api.deepseek.com
      api_key: os.environ/DEEPSEEK_API_KEY

general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
```

`~/.config/litellm/master_key` (0600) + `~/.config/litellm/.env` (0600):

```bash
umask 077
MK=$(openssl rand -hex 32)
printf '%s\n' "$MK" > ~/.config/litellm/master_key
printf 'LITELLM_MASTER_KEY=%s\nDEEPSEEK_API_KEY=%s\n' "$MK" "$DEEPSEEK_API_KEY" > ~/.config/litellm/.env
chmod 600 ~/.config/litellm/.env ~/.config/litellm/master_key
```

### 3. Wrapper socket-activation

`~/.local/share/litellm-venv/bin/litellm-fd` (executável; shebang aponta pro python do venv):

```python
#!/home/<USER>/.local/share/litellm-venv/bin/python3
import os

import uvicorn
from litellm.proxy.proxy_server import app


def main() -> None:
    fd = int(os.environ.get("LITELLM_FD", "3"))
    uvicorn.run(app, fd=fd, log_level="info", access_log=False)


if __name__ == "__main__":
    main()
```

### 4. Systemd user units

`~/.config/systemd/user/litellm.socket`:

```ini
[Unit]
Description=LiteLLM proxy socket (on-demand)

[Socket]
ListenStream=127.0.0.1:4000
Accept=no

[Install]
WantedBy=sockets.target
```

`~/.config/systemd/user/litellm.service`:

```ini
[Unit]
Description=LiteLLM proxy (socket-activated)
Requires=litellm.socket
After=litellm.socket

[Service]
Type=simple
WorkingDirectory=%h/.cache/litellm
EnvironmentFile=%h/.config/litellm/.env
Environment=CONFIG_FILE_PATH=%h/.config/litellm/config.yaml
ExecStart=%h/.local/share/litellm-venv/bin/litellm-fd
Restart=no
```

O config é carregado via `CONFIG_FILE_PATH` no lifespan do `proxy_server` — não
precisa passar `--config`.

### 5. Wrapper `deepseek`

`~/.local/bin/deepseek` (executável): ativa o gateway no primeiro uso (curl dispara
socket activation), aponta o Claude Code pro gateway com `anthropic/*` models, e
para o serviço quando a última sessão encerra. Fallback: endpoint nativo da DeepSeek.

```bash
#!/bin/bash
GATEWAY="http://127.0.0.1:4000"

f() {
    MK="$(cat "$HOME/.config/litellm/master_key" 2>/dev/null || true)"

    if [ -n "$MK" ] && curl -sf -m 30 -o /dev/null "$GATEWAY/v1/models" -H "Authorization: Bearer $MK"; then
        export ANTHROPIC_BASE_URL="$GATEWAY"
        export ANTHROPIC_AUTH_TOKEN="$MK"
        export ANTHROPIC_MODEL="anthropic/deepseek-v4-flash"
        export ANTHROPIC_DEFAULT_OPUS_MODEL="anthropic/deepseek-v4-pro"
        export ANTHROPIC_DEFAULT_SONNET_MODEL="anthropic/deepseek-v4-pro"
        export ANTHROPIC_DEFAULT_HAIKU_MODEL="anthropic/deepseek-v4-flash"
        export CLAUDE_CODE_SUBAGENT_MODEL="anthropic/deepseek-v4-flash"
    else
        export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
        export ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_API_KEY"
        export ANTHROPIC_MODEL="deepseek-v4-flash"
        export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro"
        export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro"
        export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
        export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
    fi

    claude "$@"

    if [ "$ANTHROPIC_BASE_URL" = "$GATEWAY" ] && ! ss -tnp 2>/dev/null | grep -q ':4000'; then
        systemctl --user stop litellm.service 2>/dev/null || true
    fi
}

f "$@"
```

### 6. Ativar e testar

```bash
systemctl --user daemon-reload
systemctl --user enable --now litellm.socket

MK=$(cat ~/.config/litellm/master_key)
curl -s http://127.0.0.1:4000/v1/models -H "Authorization: Bearer $MK"        # discovery
curl -s http://127.0.0.1:4000/v1/messages -H "Authorization: Bearer $MK" \
  -H "content-type: application/json" -H "anthropic-version: 2023-06-01" \
  -d '{"model":"anthropic/deepseek-v4-flash","max_tokens":100,"messages":[{"role":"user","content":"oi"}]}'
```

- `/v1/models` deve listar `anthropic/deepseek-v4-flash` e `anthropic/deepseek-v4-pro`.
- `/v1/messages` retorna resposta do DeepSeek (usar `max_tokens` >= 100; tokens vão
  pro bloco `thinking` primeiro, com `max_tokens` baixo pode vir só thinking).
- Ciclo de vida: `systemctl --user stop litellm.service` para; o próximo curl
  re-ativa (socket continua escutando).

## Operação

| Ação | Comando |
|---|---|
| Gateway sobe | automático (socket activation no primeiro uso) |
| Gateway para | automático (fim da última sessão `deepseek`) |
| Forçar parar | `systemctl --user stop litellm.service` |
| Logs | `journalctl --user -u litellm.service -f` |
| Config | `~/.config/litellm/config.yaml` (tracked no yadm) |

## Secretas

- `.env` e `master_key` contêm segredos — **nunca** adicionar ao yadm/git.
- `config.yaml` não tem segredos (usa `os.environ/...`) — pode ir pro yadm:
  `yadm add ~/.config/litellm/config.yaml`.
