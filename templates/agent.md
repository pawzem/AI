---
name: agent-name            # REQUIRED · lowercase, digits, hyphens · 3-50 chars
description: Use this agent when <conditions>. Typical triggers include <scenario 1>, <scenario 2>, and <scenario 3>. See "When to invoke" in the agent body.   # REQUIRED
model: inherit              # inherit | sonnet | opus | haiku   (inherit recommended)
color: blue                # blue | cyan | green | yellow | magenta | red
# tools: ["Read", "Grep", "Glob"]   # OPTIONAL · omit for all tools (least-privilege recommended)
---

<!--
Annotated TEMPLATE — copy to claude/agents/<name>.md, then replace everything below.

The body becomes the agent's SYSTEM PROMPT — write it in SECOND person
("You are...", "You will..."). The `description` is the most important field:
it decides when the agent is dispatched, so name 2-4 concrete trigger scenarios.

tools: omit for full access, or list the minimum needed. Common sets:
  read-only analysis -> ["Read", "Grep", "Glob"]
  code generation    -> ["Read", "Write", "Grep"]
-->

You are <role> specializing in <domain>.

## When to invoke

- **<Scenario>.** <What the situation looks like and what to do.>
- **<Scenario>.** <...>

**Your core responsibilities:**
1. <...>
2. <...>

**Process:**
1. <...>
2. <...>

**Output format:**
- <What to return and how to structure it.>
