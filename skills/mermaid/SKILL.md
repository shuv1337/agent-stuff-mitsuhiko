---
name: mermaid
description: "Must read guide on creating/editing mermaid charts with valiation tools"
---

# Mermaid Skill

Use this skill to quickly validate Mermaid diagrams by parsing + rendering them with [Pele](https://github.com/obsidianmd/pele), a dependency-free Mermaid-to-SVG renderer (MIT) that needs no headless browser.

## Prerequisites

- git, Node.js 20+ and npm.
- On first run, `tools/setup_pele.sh` clones Pele at the pinned tag `1.6.0`, refuses to build unless the commit is `659c3593ce43794dce7ec7ab45d424ad2de182a5`, then builds it from the upstream lockfile into `~/.cache/pele-1.6.0`. Set `PELE_HOME` to change the location, or `PELE_DIST` to point at an already built `pele.js`.
- The ASCII preview still uses `npx` to fetch `beautiful-mermaid`.

## Tool

### Validate a diagram

```bash
./tools/validate.sh diagram.mmd [output.svg]
```

- Parses and renders the Mermaid source with Pele, which targets Mermaid 12.1.0 syntax and is somewhat stricter than mermaid-cli (for example, it rejects deactivating an inactive participant).
- Non-zero exit = invalid Mermaid syntax.
- Prints an ASCII preview using `beautiful-mermaid` (best-effort; not all diagram types are supported).
- The SVG uses Pele's own style and `--pele-*` CSS variables, so it looks different from mermaid.js output.
- If `output.svg` is omitted, the SVG is rendered to a temp file and discarded.

## Workflow (short)

1. **If the diagram will live in Markdown**: draft it in a standalone `diagram.mmd` first (the tool only validates plain Mermaid files).
2. Write/update `diagram.mmd`.
3. Run `./tools/validate.sh diagram.mmd`.
4. Fix any errors it reports.
5. Once it validates, copy the Mermaid block into your Markdown file.
