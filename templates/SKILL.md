---
name: skill-name                      # REQUIRED · lowercase, digits, hyphens · matches the folder name
description: This skill should be used when the user asks to "phrase 1", "phrase 2", or "phrase 3".   # REQUIRED · 3rd person · concrete trigger phrases
---

# Skill Name

<!--
This is an annotated TEMPLATE, not a live skill. It lives in templates/, which
Claude does NOT scan, so it never triggers. Copy it to
claude/skills/<name>/SKILL.md, then replace everything below.

HOW SKILLS LOAD (progressive disclosure):
  1. name + description  -> always in context. This alone decides whether the
     skill triggers, so make the description specific and trigger-rich.
  2. THIS body           -> loaded only once the skill triggers. Keep it lean
     (~1,500-2,000 words; <5k hard max).
  3. references/ files   -> loaded by Claude only when needed. Put long material
     (schemas, API docs, edge cases) there, not here.

WRITING STYLE: imperative / verb-first ("Parse the file", "Validate input"),
never second person ("You should...").

DESCRIPTION — do / don't:
  GOOD: This skill should be used when the user asks to "create a hook",
        "add a PreToolUse hook", or mentions hook events (PreToolUse, Stop).
  BAD:  Provides guidance for working with hooks.   (vague, no triggers, wrong person)
-->

State the skill's purpose in 1-3 sentences.

## Steps

1. First action to take.
2. Next action.

## Additional resources

(Optional — create only what the skill needs, and reference it here so Claude
knows it exists.)

- references/<topic>.md — detailed material loaded on demand.
- scripts/<tool>.sh     — deterministic helpers Claude can run.
- assets/<file>         — files used in output (templates, boilerplate, fonts).
