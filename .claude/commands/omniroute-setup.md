---
description: Set up OmniRoute local (Claude assinatura + DeepSeek + Ollama num /model só, on-demand, porta 20128)
---

# OmniRoute setup

Configura o **OmniRoute** (gateway local, porta 20128) expondo **Claude
(assinatura via OAuth armazenado), DeepSeek e Ollama** atrás de um endpoint
Anthropic único, com start on-demand e stop-on-idle pelos wrappers. Convive com
o relay leve (skill `relay-setup`), que fica como fallback.

Use esta skill em máquina nova ou pra reconfigurar. Flags equivalentes: `--setup` = `-setup` = `-s`.

## Arquitetura

```
claude/ccr/deepseek ── Anthropic /v1/messages ──▶ OmniRoute (127.0.0.1:20128)
                                                    ├─▶ conexão OAuth "claude" (assinatura claude.ai)
                                                    ├─▶ combo claude-deepseek-v4-* ─▶ node deepseek ─▶ api.deepseek.com/v1
                                                    └─▶ (futuro) combos claude-ollama-* ─▶ node ollama ─▶ 127.0.0.1:11434/v1
```

Fatos que regem o design (descobertos na prática, v3.8.49):

- O picker `/model` do Claude Code (com `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`)
  só mostra ids que começam com `claude`/`anthropic`. Ids do OmniRoute são
  `prefixo/model` (ex. `deepseek/deepseek-v4-flash`), então não passam.
- **Combos** são o truque: nome livre (ex. `claude-deepseek-v4-flash`), aparecem
  no `/v1/models` sem prefixo e roteiam pra qualquer model. **Aliases**
  (`/api/models/alias`) resolvem mas NÃO aparecem no catálogo, ou seja, inúteis pro picker.
- Providers `openai`/`anthropic` têm endpoint **fixo** (campo `url` no
  `POST /api/providers` é descartado silenciosamente). Endpoint custom = **provider
  node** (`/api/provider-nodes`, tipo openai-compatible, com `prefix` + `apiType:
  "chat"` + `baseUrl`).
- Credencial de um node resolve pela conexão cujo `provider` == `prefix` do node;
  a validação só aceita provider conhecido do catálogo (`deepseek` passa, `ollama`
  não nesta versão; usar dashboard pro Ollama).
- `customHeaders` de node proíbe headers de auth.
- CLI: flags globais `--api-key`/`--base-url` **colidem** com as flags homônimas
  de subcommands (`setup`, `nodes add`); pra essas operações, usar a REST API
  com cookie de admin.
- O "test" de provider pode dar falso `Invalid API key` (validação local de
  formato); o teste real é uma chamada `/v1/chat/completions`.

## Passos

### 1. Instalar (CLI/server via npm; ~3GB)

```bash
NPM_CONFIG_PREFIX="$HOME/.local" npm install -g omniroute
```

`~/.local/bin` já vem primeiro no PATH. (O pacote AUR `omniroute-bin` é só o app
desktop Electron; não serve de daemon headless.)

### 2. Bootstrap (senha admin + API key local)

```bash
omniroute serve --daemon --no-open --no-tray
umask 077
openssl rand -base64 24 > ~/.omniroute/admin_password
omniroute setup --password "$(cat ~/.omniroute/admin_password)" --non-interactive

# login por cookie e provisionamento da key (CLI tem colisão de flags; REST direto)
CJ=$(mktemp)
curl -s -c "$CJ" -X POST http://127.0.0.1:20128/api/auth/login \
  -H 'content-type: application/json' \
  -d "{\"password\":\"$(cat ~/.omniroute/admin_password)\"}"
curl -s -b "$CJ" -X POST http://127.0.0.1:20128/api/v1/registered-keys \
  -H 'content-type: application/json' -d '{"name":"cli-local"}'
# salvar o campo "key" (ork_...) em ~/.omniroute/cli_api_key com chmod 600
```

### 3. Claude assinatura (OAuth)

Dashboard `http://localhost:20128` → Providers → **Claude Code (OAuth)** (device
flow), ou `omniroute oauth start --provider claude-code`. (Se o app desktop já
foi usado, a conexão migra sozinha; verificar com `GET /api/providers`.)

### 4. DeepSeek (node + conexão + combos)

```bash
# node openai-compatible apontando pro endpoint OpenAI da DeepSeek
curl -s -b "$CJ" -X POST http://127.0.0.1:20128/api/provider-nodes \
  -H 'content-type: application/json' \
  -d '{"provider":"deepseek","prefix":"deepseek","apiType":"chat","baseUrl":"https://api.deepseek.com/v1","name":"deepseek"}'

# credencial (provider deepseek é aceito pela validação)
curl -s -b "$CJ" -X POST http://127.0.0.1:20128/api/providers \
  -H 'content-type: application/json' \
  -d "{\"provider\":\"deepseek\",\"name\":\"DeepSeek\",\"apiKey\":\"$DEEPSEEK_API_KEY\",\"isActive\":true}"

# combos com nome claude-* (passam no filtro do picker e listam no /v1/models)
for m in flash pro; do
  ID=$(curl -s -b "$CJ" -X POST http://127.0.0.1:20128/api/combos \
    -H 'content-type: application/json' \
    -d "{\"name\":\"claude-deepseek-v4-$m\",\"model\":\"deepseek/deepseek-v4-$m\",\"strategy\":\"priority\"}" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])')
  curl -s -b "$CJ" -X PUT "http://127.0.0.1:20128/api/combos/$ID" \
    -H 'content-type: application/json' \
    -d "{\"models\":[\"deepseek/deepseek-v4-$m\"]}"
done
```

### 5. Ollama (quando instalado)

Instalar Ollama, puxar models, e no dashboard: node openai-compatible
(`prefix: ollama`, `baseUrl: http://127.0.0.1:11434/v1`, apiType chat) +
credencial (key qualquer, ex. `ollama`) + um combo `claude-ollama-<model>` por
model. A REST rejeita `provider: ollama` na conexão nesta versão; o dashboard
resolve.

### 6. Testar

```bash
KEY=$(cat ~/.omniroute/cli_api_key)
curl -s http://127.0.0.1:20128/v1/models -H "Authorization: Bearer $KEY"   # claude/* + deepseek/* + combos claude-deepseek-*
curl -s http://127.0.0.1:20128/v1/messages -H "Authorization: Bearer $KEY" \
  -H 'content-type: application/json' -H 'anthropic-version: 2023-06-01' \
  -d '{"model":"claude-deepseek-v4-flash","max_tokens":48,"messages":[{"role":"user","content":"oi"}]}'
```

## Uso

- **`ccr`** abre uma sessão Claude Code via OmniRoute (token em
  `~/.config/zsh/secrets/omniroute-claude-key`); sobe o daemon se preciso, para no idle.
  Exporta `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`, então o `/model` lista
  Claude (assinatura) e os combos `claude-deepseek-v4-flash|pro` no mesmo picker.
- **`cct`** abre uma sessão via relay leve (porta 4000, fallback manual).
- Sessões gateway usam `ANTHROPIC_AUTH_TOKEN` → connectors do claude.ai ficam
  desabilitados nelas (warning esperado).
- Dashboard: `http://localhost:20128` (senha em `~/.omniroute/admin_password`).

## Secrets

Nunca commitar: `~/.omniroute/` inteiro (SQLite com credenciais criptografadas,
`.env` com chaves de criptografia, `admin_password`, `cli_api_key`) e
`~/.config/zsh/secrets/omniroute-claude-key`.
