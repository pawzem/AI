#!/usr/bin/env bash
# Render a mermaid diagram to SVG, with graceful fallbacks.
#
# Usage:   render-svg.sh <input.mmd> [output.svg]
# Input:   a .mmd file, OR a .md file containing a ```mermaid fenced block
#          (the first such block is extracted).
# Output:  defaults to <input>.svg next to the input.
#
# Strategy: mmdc (mermaid-cli) if installed → else `npx -y @mermaid-js/mermaid-cli`
#           → else print manual fallbacks and exit non-zero.

set -euo pipefail

in="${1:-}"
[ -z "$in" ] && { echo "usage: render-svg.sh <input.mmd|input.md> [output.svg]" >&2; exit 2; }
[ -f "$in" ] || { echo "no such file: $in" >&2; exit 2; }

out="${2:-${in%.*}.svg}"

# If given a markdown file, extract the first ```mermaid ... ``` block to a temp .mmd
src="$in"
case "$in" in
  *.md|*.markdown)
    tmp="$(mktemp -t feature-stormer-XXXX).mmd"
    awk '/^```mermaid/{f=1;next} /^```/{if(f)exit} f{print}' "$in" > "$tmp"
    [ -s "$tmp" ] || { echo "no \`\`\`mermaid block found in $in" >&2; exit 2; }
    src="$tmp"
    ;;
esac

render() { "$@" -i "$src" -o "$out" -b transparent >/dev/null 2>&1; }

if command -v mmdc >/dev/null 2>&1; then
  render mmdc && { echo "wrote $out (mmdc)"; exit 0; }
fi

if command -v npx >/dev/null 2>&1; then
  echo "mmdc not found; trying npx @mermaid-js/mermaid-cli (may download on first run)…" >&2
  render npx -y @mermaid-js/mermaid-cli && { echo "wrote $out (npx mermaid-cli)"; exit 0; }
fi

cat >&2 <<'EOF'
Could not render SVG automatically (no mmdc, and npx unavailable or failed).
Fallbacks — pick one:
  • Install once:   npm i -g @mermaid-js/mermaid-cli   then re-run this script.
  • IDE preview:    open the .mmd / .md in an editor with a Mermaid preview
                    (VS Code "Markdown Preview Mermaid Support", JetBrains Mermaid plugin)
                    and export/screenshot the SVG.
  • Web:            paste the diagram into https://mermaid.live and export SVG.
  • Often enough:   split the joined diagram into per-process diagrams — smaller
                    diagrams usually render readably inline without any SVG step.
EOF
exit 1
