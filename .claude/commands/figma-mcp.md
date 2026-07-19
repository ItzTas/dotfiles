---
description: Load my Figma MCP fallback — when the Figma MCP fails (edit-access errors, rate limits), use the Figma REST API with $FIGMA_CLAUDE_TOKEN
---

This is my guide for working around the official Figma MCP server when it isn't working. Load it
whenever a `mcp__figma__*` tool fails or Figma access is blocked.

## Figma MCP fallback

The official Figma MCP server (`https://mcp.figma.com/mcp`) requires **edit** access to a file for
its read tools, and on the Starter plan it is limited to ~6 read calls/month. When it fails with
"you don't have edit access to this file" or a rate-limit error, fall back to the **Figma REST
API** using the personal access token in the **`$FIGMA_CLAUDE_TOKEN`** environment variable — the
REST API only needs view access and has no MCP-style monthly cap.

- **If `$FIGMA_CLAUDE_TOKEN` is unset in the shell** (it often is — tool shells don't inherit
  session exports), ask me to export it with `! export FIGMA_CLAUDE_TOKEN=...`. **Never** echo,
  print, log, or write the token value anywhere — always reference it as `$FIGMA_CLAUDE_TOKEN`.
- The token is **read-only** (scopes: `file_content`, `file_comments`, `file_versions`,
  `library_content`, `file_dev_resources`, `projects`) — don't attempt write operations with it.

**Usage** — authenticate with the `X-Figma-Token` header:

```
curl -s -H "X-Figma-Token: $FIGMA_CLAUDE_TOKEN" "https://api.figma.com/v1/<endpoint>"
```

| Endpoint | Purpose |
|---|---|
| `/v1/files/:fileKey?depth=1` | File overview (name, pages). Raise `depth` for more; full trees can be huge — prefer `depth`/`ids` filters |
| `/v1/files/:fileKey/nodes?ids=1:2,3:4` | Specific nodes only |
| `/v1/images/:fileKey?ids=1:2&format=png&scale=2` | Render nodes to images (returns download URLs) |
| `/v1/teams/:teamId/projects` | List a team's projects — my team id: `1660492678658858326` |
| `/v1/projects/:projectId/files` | List a project's files |

- **fileKey** comes from the URL: `figma.com/design/:fileKey/:name?node-id=X-Y`; a `node-id=12-34`
  URL param becomes API node id `12:34`.
- **Known limitation:** the API returns `404 Not found` for files not explicitly shared with the
  token's account — link-only view access is not enough. The file owner must invite my account
  (view permission suffices for the API). A `403 Invalid scope(s)` means the endpoint needs a
  scope the token doesn't have; tell me instead of regenerating the token yourself.
