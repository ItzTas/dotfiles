This is my guide for working with Figma. Load it whenever you're about to touch Figma in any way —
`mcp__figma__*` tools, a figma.com URL, design files, FigJam, design systems, or design↔code work.

## Working with Figma

- **Primary path: the official Figma MCP server** (`mcp__figma__*` tools). Use it to read designs
  (`get_design_context`, `get_screenshot`, `get_metadata`, `get_figjam`), write/generate designs
  (`use_figma`, `generate_figma_design`, `create_new_file`), create diagrams
  (`generate_diagram`), and bridge code↔design via Code Connect.
- **Load the MCP's own skills before acting** — `/figma-use` is **mandatory** before any
  `use_figma` call; use `/figma-generate-design`, `/figma-generate-library`,
  `/figma-code-connect`, and `/figma-use-figjam` for their respective tasks (fallbacks live at
  `skill://figma/<skill>/SKILL.md`).
- **URL anatomy:** `figma.com/design/:fileKey/:name?node-id=X-Y` — the **fileKey** comes from the
  URL path, and a `node-id=12-34` URL param becomes node id `12:34` in tools/API calls.
- **When the MCP fails** (edit-access/permission errors, rate limits), apply the REST API fallback
  below.

## Figma MCP fallback (REST API)

The official Figma MCP server (`https://mcp.figma.com/mcp`) requires **edit** access to a file for
its read tools, and on the Starter plan it is limited to ~6 read calls/month. When it fails with
"you don't have edit access to this file" or a rate-limit error, fall back to the **Figma REST
API** using the personal access token stored in my **gnome-keyring**, retrieved at call time with
`secret-tool` — the REST API only needs view access and has no MCP-style monthly cap.

- **Always resolve the token inline, in a command substitution** —
  `$(secret-tool lookup service figma account claude)`. Never export it, never assign it to a
  variable you later echo, and **never** print, log, or write the token value anywhere. Don't rely
  on a `$FIGMA_CLAUDE_TOKEN` env var: each Bash tool call is a fresh shell, so `export` doesn't
  persist between calls.
- **If the lookup returns empty** (keyring locked or entry missing), ask me to store it with
  `! secret-tool store --label='Figma Claude token' service figma account claude` — it reads the
  token from stdin, so the value never reaches the shell history or this transcript.
- The token is **read-only** (scopes: `file_content`, `file_comments`, `file_versions`,
  `library_content`, `file_dev_resources`, `projects`) — don't attempt write operations with it.

**Usage** — authenticate with the `X-Figma-Token` header:

```
curl -s -H "X-Figma-Token: $(secret-tool lookup service figma account claude)" \
  "https://api.figma.com/v1/<endpoint>"
```

| Endpoint | Purpose |
|---|---|
| `/v1/files/:fileKey?depth=1` | File overview (name, pages). Raise `depth` for more; full trees can be huge — prefer `depth`/`ids` filters |
| `/v1/files/:fileKey/nodes?ids=1:2,3:4` | Specific nodes only |
| `/v1/images/:fileKey?ids=1:2&format=png&scale=2` | Render nodes to images (returns download URLs) |
| `/v1/teams/:teamId/projects` | List a team's projects — my team id: `1660492678658858326` |
| `/v1/projects/:projectId/files` | List a project's files |

- **Known limitation:** the API returns `404 Not found` for files not explicitly shared with the
  token's account — link-only view access is not enough. The file owner must invite my account
  (view permission suffices for the API). A `403 Invalid scope(s)` means the endpoint needs a
  scope the token doesn't have; tell me instead of regenerating the token yourself.
