---
name: omniroute-setup
description: Set up OmniRoute local
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

Fatos que regem o design (descobertos na prática, v3.8.49–3.8.51):

- O picker `/model` do Claude Code (com `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`)
  só mostra ids que começam com `claude`/`anthropic`. Ids do OmniRoute são
  `prefixo/model` (ex. `deepseek/deepseek-v4-flash`), então não passam.
- **Combos** são o truque: nome livre (ex. `claude-deepseek-v4-flash`), aparecem
  no `/v1/models` sem prefixo e roteiam pra qualquer model. **Aliases**
  (`/api/models/alias`) resolvem mas NÃO aparecem no catálogo, ou seja, inúteis pro picker.
- Na 3.8.51 o `POST /api/combos` exige `models` (mín. 1) e descarta o campo `model`
  em silêncio; na 3.8.49 era preciso criar e depois dar `PUT` nos `models`. O script
  cria já com `models` e corrige via `PUT` se o combo voltar diferente.
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
- `omniroute setup --password` sobrescreve a senha existente; o script passa a senha
  por `INITIAL_PASSWORD` (env, fora do argv), que o `setup` só aplica quando ainda não
  há senha.
- O "test" de provider pode dar falso `Invalid API key` (validação local de
  formato); o teste real é uma chamada ao gateway (`setup.sh test`).
- `/healthz` é um 200 estático (~5ms, sem auth); `/v1/models` reconstrói o pool
  inteiro e leva 15s+ com cache frio. Saúde do daemon se mede no `/healthz`.
- CLI headless: npm (`~/.local/bin`) ou AUR `omniroute` (`/usr/bin`); o AUR `omniroute-bin`
  é só o app desktop Electron.

## Script

`~/.claude/skills/omniroute-setup/scripts/setup.sh [check|install|bootstrap|deepseek|test] [--dry-run]`

Stdout é JSON compacto; os passos vão pro stderr (`+` executa, `=` já feito, `!` falhou).
Exit: `0` ok, `1` resultado negativo (não pronto, passo/teste falhou), `2` uso/ambiente.

| Subcomando | O que faz |
|---|---|
| `check` (padrão) | Só leitura, **nunca sobe o daemon**: binário + versão, porta 20128 e `/healthz`, `admin_password`/`cli_api_key` (existem, modo 600). Com o daemon de pé, login de admin e lista: conexão OAuth `claude`, node `deepseek` (+ `baseUrl`), conexão `deepseek`, combos `claude-deepseek-v4-flash\|pro` e seus models; Ollama só informativo. Saída `{binary, files, daemon, config, ollama, todo[], manual[], ready}`; exit 1 também quando a config não pôde ser verificada (daemon fora). |
| `install` | `NPM_CONFIG_PREFIX=~/.local npm install -g omniroute` (~3GB; `~/.local/bin` já vem primeiro no PATH). Pula se já houver `omniroute`. |
| `bootstrap` | Sobe o daemon se preciso (`serve --daemon --no-open --no-tray`, espera `/healthz`), gera `~/.omniroute/admin_password` (`openssl rand -base64 24`, 0600) + `omniroute setup --non-interactive`, provisiona a key `cli-local` (`POST /api/v1/registered-keys`) em `~/.omniroute/cli_api_key` (0600). Pula o que existe. |
| `deepseek` | Lista o que existe e cria só o que falta: node openai-compatible (`prefix: deepseek`, `apiType: chat`, `baseUrl: https://api.deepseek.com/v1`), conexão `deepseek` (só ela exige `$DEEPSEEK_API_KEY`), combos `claude-deepseek-v4-flash\|pro` → `deepseek/deepseek-v4-*`; corrige via `PUT` os models errados. |
| `test` | Com a `cli_api_key`: `GET /v1/models` (os combos aparecem?) + `POST /v1/messages` com `claude-deepseek-v4-flash`, `max_tokens` 48. Resumo pass/fail, sem corpo cru. |

Mutantes sobem o daemon se ele estiver fora e imprimem
`{subcommand, dry_run, ok, steps[{step, status}], warnings[]}`; `--dry-run` mostra o plano
sem mudar nada (com o daemon de pé ainda faz login e lista o estado pra montar o plano).

## Fluxo

1. Rode `check` e mostre ao usuário o que falta (`todo` = subcomandos, `manual` = passos de
   dashboard, `chmod 600`, `baseUrl` errado, config não verificada).
2. Proponha o plano na ordem `install` → `bootstrap` → OAuth Claude → `deepseek` → `test`
   (o `--dry-run` mostra os comandos) e **só rode subcomandos mutantes depois que o usuário
   confirmar**.
3. `deepseek` lê `$DEEPSEEK_API_KEY` do ambiente. Se a variável não estiver na sessão, peça
   ao usuário pra rodar o subcomando no próprio terminal; nunca peça a chave no chat nem num
   comando `!` (o hook de histórico grava esses comandos).
4. Se o `bootstrap` falhar com "already had an admin password", o OmniRoute já tem senha e o
   arquivo sumiu: recuperar o arquivo (0600) ou resetar a senha pelo dashboard, e rodar de novo.
   Uma key `cli-local` antiga continua listada no dashboard; revogue se quiser.

### Claude assinatura (OAuth, manual)

Dashboard `http://localhost:20128` → Providers → **Claude Code (OAuth)** (device
flow), ou `omniroute oauth start --provider claude-code`. (Se o app desktop já
foi usado, a conexão migra sozinha; o `check` mostra em `config.claude_oauth`.)

### Ollama (manual, quando instalado)

Instalar Ollama, puxar models, e no dashboard: node openai-compatible
(`prefix: ollama`, `baseUrl: http://127.0.0.1:11434/v1`, apiType chat) +
credencial (key qualquer, ex. `ollama`) + um combo `claude-ollama-<model>` por
model. A REST rejeita `provider: ollama` na conexão nesta versão; o dashboard
resolve. O `check` mostra o estado em `ollama`.

## Uso

- **`ccr`** abre uma sessão Claude Code via OmniRoute (token em
  `~/.config/zsh/secrets/omniroute-claude-key`, fora do escopo do script); sobe o daemon se preciso.
  Exporta `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`, então o `/model` lista
  Claude (assinatura) e os combos `claude-deepseek-v4-flash|pro` no mesmo picker.
- **`cct`** abre uma sessão via relay leve (porta 4000, fallback manual).
- Sessões gateway usam `ANTHROPIC_AUTH_TOKEN` → connectors do claude.ai ficam
  desabilitados nelas (warning esperado).
- Dashboard: `http://localhost:20128` (senha em `~/.omniroute/admin_password`).

## Secrets

Nunca commitar: `~/.omniroute/` inteiro (SQLite com credenciais criptografadas,
`.env` com chaves de criptografia, `admin_password`, `cli_api_key`) e
`~/.config/zsh/secrets/omniroute-claude-key`. O script lê `admin_password` e
`cli_api_key` só pra autenticar: nunca imprime nem põe em linha de comando; cookies e
respostas ficam num diretório temporário 0700 apagado na saída.
