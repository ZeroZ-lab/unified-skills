#!/usr/bin/env bash
# update-lock.sh — Recompute hashes for a single skill and update skills-lock.json
# Usage: bash scripts/update-lock.sh <skill-name>
# Example: bash scripts/update-lock.sh build-quality-tdd
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: bash scripts/update-lock.sh <skill-name>" >&2
  exit 1
fi

SKILL_NAME="$1"
SKILL_DIR="skills/${SKILL_NAME}"
LOCK_FILE="skills-lock.json"

# Validate skill directory exists
if [ ! -d "$SKILL_DIR" ]; then
  echo "ERROR: Skill directory not found: $SKILL_DIR" >&2
  exit 1
fi

# Validate SKILL.md exists
if [ ! -f "${SKILL_DIR}/SKILL.md" ]; then
  echo "ERROR: SKILL.md not found in: $SKILL_DIR" >&2
  exit 1
fi

# Validate skills-lock.json exists
if [ ! -f "$LOCK_FILE" ]; then
  echo "ERROR: skills-lock.json not found" >&2
  exit 1
fi

# Compute SHA-256 for SKILL.md
compute_hash() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d' ' -f1
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    echo "ERROR: Neither shasum nor sha256sum found" >&2
    exit 1
  fi
}

NEW_SKILL_HASH=$(compute_hash "${SKILL_DIR}/SKILL.md")

# Collect auxiliary .md files (excluding SKILL.md)
AUXILIARY_FILES=()
for f in "${SKILL_DIR}"/*.md; do
  [ -f "$f" ] || continue
  basename_f=$(basename "$f")
  [ "$basename_f" = "SKILL.md" ] && continue
  AUXILIARY_FILES+=("$basename_f")
done

# Build auxiliary hashes associative structure
AUX_JSON="{}"
for aux in ${AUXILIARY_FILES[@]+"${AUXILIARY_FILES[@]}"}; do
  aux_hash=$(compute_hash "${SKILL_DIR}/${aux}")
  AUX_JSON=$(python3 -c "
import json, sys
d = json.loads(sys.argv[1])
d[sys.argv[2]] = sys.argv[3]
print(json.dumps(d))
" "$AUX_JSON" "$aux" "$aux_hash")
done

# Update skills-lock.json using python3 for reliable JSON manipulation
python3 - "$LOCK_FILE" "$SKILL_NAME" "$NEW_SKILL_HASH" "$AUX_JSON" <<'PY'
import json
import sys

lock_path = sys.argv[1]
skill_name = sys.argv[2]
new_hash = sys.argv[3]
aux_json = sys.argv[4]

lock = json.load(open(lock_path, encoding="utf-8"))
skills = lock.get("skills", {})

if skill_name not in skills:
    print(f"ERROR: Skill '{skill_name}' not found in skills-lock.json", file=sys.stderr)
    sys.exit(1)

entry = skills[skill_name]

# Print old hashes for reference
old_hash = entry.get("computedHash", "none")
old_aux = entry.get("auxiliaryHashes", {})
print(f"Skill: {skill_name}")
print(f"  computedHash: {old_hash} -> {new_hash}")
for k, v in json.loads(aux_json).items():
    old_v = old_aux.get(k, "none")
    marker = " (new)" if old_v == "none" else ""
    print(f"  auxiliary {k}: {old_v} -> {v}{marker}")

# Update
entry["computedHash"] = new_hash
entry["auxiliaryHashes"] = json.loads(aux_json)

with open(lock_path, "w", encoding="utf-8") as f:
    json.dump(lock, f, indent=2, ensure_ascii=False)
    f.write("\n")

print(f"Updated skills-lock.json for {skill_name}")
PY
