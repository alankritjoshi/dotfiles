---
name: html-brief
description: Build an annotatable HTML brief (TLDR/Context/Problem/Solution via Mermaid diagrams) instead of writing long chat explanations. Use whenever an explanation, investigation readout, design proposal, root-cause analysis, or review would exceed 300 words in chat.
---

# HTML Brief

Any nontrivial explanation goes in an HTML brief, not chat. Diagrams carry the content; prose is framing only.

## Workflow

1. Create `~/sites/<short-name>/index.html` (single self-contained file).
2. Serve as a background job: `python3 -m http.server <port> --directory ~/sites/<short-name>` (pick a free port in 4600-4699; check with `lsof -nP -iTCP:<port> -sTCP:LISTEN`).
3. Start the annotate bridge (`annotate_start`) so the user can comment on the page.
4. Chat reply = the URL + at most 3 lines. Nothing else.
5. Iterate via annotate items (`annotate_list` -> edit -> `annotate_resolve`).

## Structure (in order)

1. **TLDR** - one or two sentences, the verdict/answer up front.
2. **Context** - diagram of the system/situation as it is.
3. **Problem** - diagram annotated with the failure/causal step.
4. **Solution** - diagram of the fix/proposal; label current vs proposed.
5. **Caveats** - one minimal list of caveats and unresearched items at the very end. No paragraphs about them.

Cut any section that adds nothing. One primary idea per visual block.

## Diagram rules

- Mermaid (`https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js`) is the default; annotate nodes with the causal step, failure, or fix - arrows must not need surrounding prose.
- Prefer top-to-bottom diagrams over wide left-to-right.
- Use small CSS/JS animations when they clarify queueing, concurrency, or state transitions.
- Tables only for scenarios/status/examples; prefer stacked visual scenes over dense tables.
- No large paragraphs or long bullet lists anywhere. Short framing sentences only.

## Layout

- Catppuccin Mocha palette: `--base:#1e1e2e --mantle:#181825 --crust:#11111b --surface:#313244 --text:#cdd6f4 --sub:#a6adc8 --green:#a6e3a1 --red:#f38ba8 --yellow:#f9e2af --blue:#89b4fa --mauve:#cba6f7 --peach:#fab387 --teal:#94e2d5`.
- Narrow reading column, vertical flow, generous spacing; scrolling beats compression.
- Stack cards instead of fitting 2-4 across; never force horizontal overflow.
- Copy the head/CSS from an existing brief in `~/sites/` (e.g. `dp-access-explain`) rather than restyling from scratch.

## Source

Alankrit, 2026-08-07, Pi session: consolidate repeated brief instructions. Layout rules from knowledge/visual-brief-layout.md (2026-08-05) and knowledge/design-doc-style.md (2026-07-13).
