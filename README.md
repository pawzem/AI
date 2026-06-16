# AI — personal library of Claude Code skills & agents

A version-controlled home for the **skills** and **agents** I reuse across
projects. The library lives in the visible `claude/` folder and is **merged into
`~/.claude/` via symlinks**, so everything here is recognized by Claude Code in
**every** project.

## Layout

```
claude/
  skills/        one folder per skill:  <name>/SKILL.md  (+ optional references/ scripts/ assets/)
  agents/        one file per agent:    <name>.md
templates/
  SKILL.md       annotated skill template (copy it to start a new skill)
  agent.md       annotated agent template
```

## How it's wired (merge via symlinks)

`~/.claude/skills` and `~/.claude/agents` are **symlinks** pointing at this
repo's folders:

```
~/.claude/skills  ->  <repo>/claude/skills
~/.claude/agents  ->  <repo>/claude/agents
```

So the repo and your personal Claude folder are the **same directory** — add or
edit a skill here and it's instantly part of `~/.claude`, recognized in every
project the next time you start a session. No copy step, no sync script.

### Set up on a new machine (or after re-cloning)

From the repo root:

```bash
REPO="$(pwd)"
# CAUTION: only do this if ~/.claude/{skills,agents} don't already hold real
# content you want to keep. Back them up first if unsure.
rm -rf ~/.claude/skills ~/.claude/agents
ln -s "$REPO/claude/skills" ~/.claude/skills
ln -s "$REPO/claude/agents" ~/.claude/agents
```

Verify: `ls -la ~/.claude/skills ~/.claude/agents` should show `-> <repo>/claude/...`.

## Add a skill

```bash
mkdir claude/skills/my-skill
cp templates/SKILL.md claude/skills/my-skill/SKILL.md   # then edit
```

- **Folder = name.** `claude/skills/<name>/SKILL.md`; `name` is lowercase-hyphens.
- **`description` is the trigger.** Third person, concrete phrases, e.g.
  `This skill should be used when the user asks to "create X", "configure Y".`
  It is always in context, so it alone decides when the skill loads.
- **Body in imperative form** ("Parse the file", not "You should parse it").
- **Keep it lean** (~1,500–2,000 words); push detail into `references/*.md`.

## Add an agent

```bash
cp templates/agent.md claude/agents/my-agent.md   # then edit
```

- **One file:** `claude/agents/<name>.md`.
- **Frontmatter:** `name`, `description`, `model` (`inherit`), `color`, optional
  `tools` (least-privilege).
- **Body = system prompt**, written in second person ("You are…").

See `templates/` for the annotated references.

## Note on built-in skills

Skills such as `code-review`, `deep-research`, `verify`, `simplify`, `loop`,
`schedule`, `run`, `init`, `review`, `security-review`, `claude-api`,
`update-config`, `keybindings-help`, and `fewer-permission-prompts` ship **inside
Claude Code**. They're already available everywhere and have no source to copy —
don't recreate them here. This library is for **your own** skills/agents.
