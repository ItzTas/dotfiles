---
description: Generate a Mermaid diagram (arch, flow, sequence, class/ER, state) accurate to the actual code; optionally save or render it
argument-hint: [flow|arch|sequence|class|er|state] [path|module]
allowed-tools: Read, Glob, Grep, Bash(rg*), Bash(git*), Bash(mmdc*), Bash(npx*), Write, Edit
---

Produce a Mermaid diagram of the code so I can see the shape of it: the architecture, a control
flow, a call sequence, the data model, or a state machine. Base it strictly on what the code actually
does.

Argument (`$ARGUMENTS`):
- an optional **kind**: `arch` (module/component overview, default), `flow` (flowchart of a function
  or process), `sequence` (call/interaction sequence), `class`, `er` (data model), `state`.
- an optional **path or module** to diagram (default: infer the most useful subject for the repo).

Separately, I may include **other requests** in the same message; those are not the argument, so do
them first, then diagram.

Follow exactly these steps:

## 0. Handle any extra requests first
- If I asked for other changes in the same message (before or after `/mermaid`), do those and get
  them working before diagramming.

## 1. Decide what to diagram
- Resolve the kind and subject from the argument. If it's ambiguous what would be most useful, pick
  the highest-value view (usually an `arch` overview of the main modules) and tell me what you chose,
  or ask if it's genuinely unclear.

## 2. Read the real structure
- Actually read the relevant code (`Glob`/`Grep`/`Read`): entry points, modules and their
  dependencies, the call relationships for a `flow`/`sequence`, the types/tables for a `class`/`er`,
  the states/transitions for a `state`.
- **Ground the diagram in the code**, and don't invent components or edges. If you infer something, say
  so.

## 3. Build the Mermaid diagram
- Emit valid Mermaid syntax for the chosen kind (`flowchart`, `sequenceDiagram`, `classDiagram`,
  `erDiagram`, `stateDiagram-v2`, etc.), with clear labels.
- Keep it at a **readable altitude**: summarize and group rather than dumping every node/edge. If the
  subject is too big for one diagram, focus on the important part and **say what you left out**;
  don't silently truncate.

## 4. Validate (and optionally render)
- If `mmdc` (mermaid-cli) is available, syntax-check the diagram; offer to render it to SVG/PNG
  (`mmdc -i … -o …`). Don't require it; the Mermaid source is the primary output.

## 5. Output
- Print the diagram in a ```mermaid fenced block``` so it renders in Markdown.
- Offer, opt-in only: save it to a docs file or embed it in the README (`Write`/`Edit`). Don't modify
  files unless I say yes.
