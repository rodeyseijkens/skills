#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/align_skills.sh [--output PATH] [--cache-dir PATH]

Read-only comparison of locally vendored credited skills against recorded
source baselines and current upstream heads. It never changes repository files.

Options:
  --output PATH      Markdown report path (default: /tmp/opencode/skill-alignment-YYYY-MM-DD.md)
  --cache-dir PATH   Bare repository cache (default: ${XDG_CACHE_HOME:-$HOME/.cache}/skill-alignment)
  -h, --help         Show this help

Requirements: Bash 4+, git, jq, awk, diff, and standard coreutils (cmp, find,
grep, head, mktemp, sed, sort). Network access is needed to fetch sources.
USAGE
}

OUTPUT=""
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/skill-alignment"
while (($#)); do
  case "$1" in
    --output)
      (($# >= 2)) || { echo "--output requires a path" >&2; exit 2; }
      OUTPUT=$2; shift 2 ;;
    --cache-dir)
      (($# >= 2)) || { echo "--cache-dir requires a path" >&2; exit 2; }
      CACHE_DIR=$2; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if ((BASH_VERSINFO[0] < 4)); then
  echo "Bash 4 or newer is required." >&2
  exit 1
fi

for dep in git jq awk diff; do
  command -v "$dep" >/dev/null 2>&1 || { echo "Required command not found: $dep" >&2; exit 1; }
done

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Run this script inside the skills repository." >&2; exit 1; }
cd "$ROOT"
[[ -n "$OUTPUT" ]] || OUTPUT="/tmp/opencode/skill-alignment-$(date +%F).md"
mkdir -p "$(dirname "$OUTPUT")" "$CACHE_DIR"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
CREDITS_TSV="$TMP_DIR/credits.tsv"
: > "$CREDITS_TSV"

# The repository's credit metadata has a small, regular YAML shape. Extract only
# those scalar fields; jq is used below for JSON escaping and report generation.
extract_credits() {
  local file=$1
  awk '
    function clean(v) {
      sub(/^[[:space:]]+/, "", v); sub(/[[:space:]]+$/, "", v)
      sub(/^["]/, "", v); sub(/["]$/, "", v)
      sub(/^\047/, "", v); sub(/\047$/, "", v)
      return v
    }
    function emit() {
      if (skill != "") printf "%s\t%s\t%s\t%s\t%s\t%s\n", skill, author, organisation, url, date, commit
      skill=author=organisation=url=date=commit=""
    }
    /^---[[:space:]]*$/ { if (!started) { started=1; next } else exit }
    !started { next }
    /^  credits:[[:space:]]*$/ { in_credits=1; next }
    in_credits && /^  [^[:space:]-]/ { emit(); in_credits=0 }
    in_credits && /^    - skill:/ { emit(); value=$0; sub(/^    - skill:[[:space:]]*/, "", value); skill=clean(value); next }
    in_credits && /^      author:/ { value=$0; sub(/^      author:[[:space:]]*/, "", value); author=clean(value); next }
    in_credits && /^      organisation:/ { value=$0; sub(/^      organisation:[[:space:]]*/, "", value); organisation=clean(value); next }
    in_credits && /^      url:/ { value=$0; sub(/^      url:[[:space:]]*/, "", value); url=clean(value); next }
    in_credits && /^        date:/ { value=$0; sub(/^        date:[[:space:]]*/, "", value); date=clean(value); next }
    in_credits && /^        commit:/ { value=$0; sub(/^        commit:[[:space:]]*/, "", value); commit=clean(value); next }
    END { emit() }
  ' "$file"
}

while IFS= read -r skill_file; do
  extract_credits "$skill_file" >> "$CREDITS_TSV"
done < <(find skills -type f -name SKILL.md -not -path 'skills/local/*' | sort)

if [[ ! -s "$CREDITS_TSV" ]]; then
  echo "No metadata.credits entries found under skills/." >&2
  exit 1
fi

# Build a normalized entry table with exact repository identity and source paths.
ENTRIES_JSON="$TMP_DIR/entries.json"
: > "$ENTRIES_JSON"
while IFS=$'\t' read -r local_name author organisation url baseline_date baseline_commit; do
  [[ -n "$url" ]] || continue
  if [[ ! "$url" =~ ^https://github\.com/([^/]+)/([^/]+)/blob/[^/]+/(.+)$ ]]; then
    printf 'Warning: unsupported credit URL in %s: %s\n' "$local_name" "$url" >&2
    continue
  fi
  owner=${BASH_REMATCH[1]}
  repo=${BASH_REMATCH[2]}
  source_path=${BASH_REMATCH[3]}
  source_dir=${source_path%/*}
  skill_file=$(find skills -type f -name SKILL.md -not -path 'skills/local/*' -print | while IFS= read -r f; do
    if grep -Fq "url: \"$url\"" "$f" || grep -Fq "url: '$url'" "$f" || grep -Fq "url: $url" "$f"; then printf '%s\n' "$f"; fi
  done | head -n1)
  [[ -n "$skill_file" ]] || continue
  local_dir=${skill_file%/SKILL.md}
  jq -cn \
    --arg skill "$local_name" --arg author "$author" --arg organisation "$organisation" \
    --arg url "$url" --arg owner "$owner" --arg repo "$repo" \
    --arg source_path "$source_path" --arg source_dir "$source_dir" \
    --arg local_file "$skill_file" --arg local_dir "$local_dir" \
    --arg date "$baseline_date" --arg commit "$baseline_commit" \
    '{skill:$skill,author:$author,organisation:$organisation,url:$url,owner:$owner,repo:$repo,source_path:$source_path,source_dir:$source_dir,local_file:$local_file,local_dir:$local_dir,baseline_date:$date,baseline_commit:$commit}' >> "$ENTRIES_JSON"
done < "$CREDITS_TSV"

if [[ ! -s "$ENTRIES_JSON" ]]; then
  echo "No supported GitHub blob URLs found in metadata.credits." >&2
  exit 1
fi

# Clone/fetch each credited GitHub repository once. The cache uses bare repos so
# source refs and historical baseline commits stay isolated from the workspace.
declare -A SOURCE_REPO=()
declare -A SOURCE_HEAD=()
declare -A SOURCE_HEAD_REF=()
while IFS=$'\t' read -r owner repo; do
  [[ -n "$owner" ]] || continue
  key="$owner/$repo"
  cache_path="$CACHE_DIR/${owner}__${repo}.git"
  if [[ ! -d "$cache_path" ]]; then
    git clone --quiet --filter=blob:none --bare "https://github.com/$owner/$repo.git" "$cache_path"
  fi
  git -C "$cache_path" fetch --quiet --prune origin '+refs/heads/*:refs/remotes/origin/*'
  default_branch=$(git -C "$cache_path" ls-remote --symref origin HEAD | awk '$1 == "ref:" && $3 == "HEAD" { sub(/^refs\/heads\//, "", $2); print $2; exit }')
  if [[ -z "$default_branch" ]]; then
    echo "Could not determine the default branch for https://github.com/$owner/$repo" >&2
    exit 1
  fi
  head_ref="refs/remotes/origin/$default_branch"
  head_commit=$(git -C "$cache_path" rev-parse "$head_ref^{commit}")
  SOURCE_REPO[$key]=$cache_path
  SOURCE_HEAD[$key]=$head_commit
  SOURCE_HEAD_REF[$key]=$default_branch
done < <(jq -sr '[.[] | .owner + "\t" + .repo] | unique[]' "$ENTRIES_JSON" | sort -u)

# Add the exact credited source paths to a set used to identify uncredited
# candidate skills. Credit URLs, not local directory names, define identity.
CREDITED_PATHS="$TMP_DIR/credited-paths.txt"
jq -r '"\(.owner)/\(.repo)/\(.source_path)"' "$ENTRIES_JSON" | sort -u > "$CREDITED_PATHS"

# Remove metadata from YAML frontmatter for a fair skill-body comparison, while
# retaining name/description and the rest of frontmatter.
normalize_skill() {
  awk '
    NR == 1 && /^---[[:space:]]*$/ { front=1; print; next }
    front && /^---[[:space:]]*$/ { front=0; skip=0; print; next }
    front && /^metadata:[[:space:]]*$/ { skip=1; next }
    front && skip && /^[[:space:]]/ { next }
    front && skip && /^[^[:space:]]/ { skip=0 }
    !skip { print }
  ' "$1"
}

source_file() {
  local repo_path=$1 commit=$2 path=$3
  git -C "$repo_path" show "$commit:$path" 2>/dev/null
}

frontmatter_field() {
  local repo_path=$1 commit=$2 path=$3 key=$4
  git -C "$repo_path" show "$commit:$path" 2>/dev/null | awk -v key="$key" '
    /^---[[:space:]]*$/ { if (!started) { started=1; next } else { if (block) print value; exit } }
    !started { next }
    !block && $0 ~ "^" key ":[[:space:]]*" {
      value=$0; sub("^[^:]+:[[:space:]]*", "", value)
      if (value ~ /^[>|]/ || value == "") { value=""; block=1; next }
      sub(/^["]/, "", value); sub(/["]$/, "", value)
      sub(/^\047/, "", value); sub(/\047$/, "", value)
      print value; exit
    }
    block && /^[[:space:]]/ {
      line=$0; sub(/^[[:space:]]+/, "", line)
      gsub(/[[:space:]]+/, " ", line)
      if (line != "") value=value (value == "" ? "" : " ") line
    }
    block && /^[^[:space:]]/ { print value; exit }
  ' | head -n1
}

# Assemble Markdown in a temporary file so failures do not leave a partial report.
REPORT_TMP="$TMP_DIR/report.md"
cat > "$REPORT_TMP" <<EOF
# Skill alignment comparison — $(date +%F)

- Repository: \`$ROOT\`
- Current branch: \`$(git branch --show-current)\`
- Report is read-only; no repository files were changed.
- Source repositories are fetched into \`$CACHE_DIR\`.

## Summary

- Credited entries: __ENTRY_COUNT__ across __REPO_COUNT__ repositories.
- Upstream skill-body updates since recorded baselines: __SOURCE_CHANGES__.
- Upstream support-file updates since recorded baselines: __SUPPORT_CHANGES__.
- Local skill bodies with drift/adaptations: __LOCAL_DRIFT__.
- Uncredited source skills to review as candidates: __CANDIDATES__.

EOF

entry_count=$(jq -s 'length' "$ENTRIES_JSON")
repo_count=$(jq -sr '[.[] | .owner + "/" + .repo] | unique | length' "$ENTRIES_JSON")
source_changed_entries=0
support_changed_files=0
local_drift_entries=0
candidate_count=0
# Per source entry: determine baseline/head/local states for the skill file and
# compare all support files at the source skill-directory root.
while IFS= read -r entry; do
  local_name=$(jq -r '.skill' <<< "$entry")
  author=$(jq -r '.author' <<< "$entry")
  organisation=$(jq -r '.organisation' <<< "$entry")
  url=$(jq -r '.url' <<< "$entry")
  owner=$(jq -r '.owner' <<< "$entry")
  repo=$(jq -r '.repo' <<< "$entry")
  source_path=$(jq -r '.source_path' <<< "$entry")
  source_dir=$(jq -r '.source_dir' <<< "$entry")
  local_file=$(jq -r '.local_file' <<< "$entry")
  local_dir=$(jq -r '.local_dir' <<< "$entry")
  baseline_date=$(jq -r '.baseline_date' <<< "$entry")
  baseline_commit=$(jq -r '.baseline_commit' <<< "$entry")
  key="$owner/$repo"
  repo_path=${SOURCE_REPO[$key]}
  head_commit=${SOURCE_HEAD[$key]}
  head_ref=${SOURCE_HEAD_REF[$key]}

  printf '\n## `%s` — %s / %s\n\n' "$local_dir" "$author" "$organisation" >> "$REPORT_TMP"
  printf -- '- Local skill file: `%s`\n- Source: [%s](%s)\n- Recorded baseline: `%s` (`%s`)\n- Current source head: `%s` (`%s`)\n' \
    "$local_file" "$owner/$repo/$source_path" "$url" "$baseline_commit" "$baseline_date" "$head_commit" "$head_ref" >> "$REPORT_TMP"

  baseline_ok=true
  if ! git -C "$repo_path" cat-file -e "$baseline_commit^{commit}" 2>/dev/null; then
    if git -C "$repo_path" fetch --quiet origin "$baseline_commit" 2>/dev/null; then :; else baseline_ok=false; fi
  fi

  base_skill="$TMP_DIR/base-skill"
  head_skill="$TMP_DIR/head-skill"
  local_skill="$TMP_DIR/local-skill"
  source_file "$repo_path" "$head_commit" "$source_path" > "$head_skill" || :
  if [[ "$baseline_ok" == true ]]; then source_file "$repo_path" "$baseline_commit" "$source_path" > "$base_skill" || :; else : > "$base_skill"; fi
  normalize_skill "$local_file" > "$local_skill"
  if [[ -s "$base_skill" ]]; then normalize_skill "$base_skill" > "$TMP_DIR/base-normalized"; else : > "$TMP_DIR/base-normalized"; fi
  if [[ -s "$head_skill" ]]; then normalize_skill "$head_skill" > "$TMP_DIR/head-normalized"; else : > "$TMP_DIR/head-normalized"; fi

  if [[ ! -s "$head_skill" ]]; then
    echo '- **Source status:** current source file is missing.' >> "$REPORT_TMP"
  elif [[ ! -s "$base_skill" ]]; then
    echo '- **Source status:** recorded baseline commit/file is unavailable; upstream comparison is incomplete.' >> "$REPORT_TMP"
  elif cmp -s "$TMP_DIR/base-normalized" "$TMP_DIR/head-normalized"; then
    echo '- **Upstream body:** unchanged since the recorded baseline.' >> "$REPORT_TMP"
  else
    ((source_changed_entries+=1))
    echo '- **Upstream body:** changed since the recorded baseline.' >> "$REPORT_TMP"
    echo '' >> "$REPORT_TMP"
    echo '  ```diff' >> "$REPORT_TMP"
    diff -u --label "baseline:$source_path" --label "upstream:$source_path" "$TMP_DIR/base-normalized" "$TMP_DIR/head-normalized" | head -100 | sed 's/^/  /' >> "$REPORT_TMP" || true
    echo '  ```' >> "$REPORT_TMP"
  fi

  if [[ -s "$base_skill" ]] && cmp -s "$local_skill" "$TMP_DIR/base-normalized"; then
    echo '- **Local body:** matches the recorded baseline.' >> "$REPORT_TMP"
  elif cmp -s "$local_skill" "$TMP_DIR/head-normalized"; then
    echo '- **Local body:** matches current upstream.' >> "$REPORT_TMP"
  elif [[ -s "$base_skill" ]]; then
    ((local_drift_entries+=1))
    echo '- **Local body:** differs from both source versions or contains local adaptations; inspect before syncing.' >> "$REPORT_TMP"
    echo '' >> "$REPORT_TMP"
    echo '  ```diff' >> "$REPORT_TMP"
    diff -u --label "baseline:$source_path" --label "local:$local_file" "$TMP_DIR/base-normalized" "$local_skill" | head -100 | sed 's/^/  /' >> "$REPORT_TMP" || true
    echo '  ```' >> "$REPORT_TMP"
  else
    echo '- **Local body:** differs from current upstream; the recorded baseline is unavailable, so treat this as unclassified local drift.' >> "$REPORT_TMP"
  fi

  # Build the file universe from the baseline and current source trees.
  baseline_files="$TMP_DIR/baseline-files"
  current_files="$TMP_DIR/current-files"
  : > "$baseline_files"; : > "$current_files"
  if [[ "$baseline_ok" == true ]]; then git -C "$repo_path" ls-tree -r --name-only "$baseline_commit" "$source_dir" 2>/dev/null | sed "s#^$source_dir/##" > "$baseline_files"; fi
  git -C "$repo_path" ls-tree -r --name-only "$head_commit" "$source_dir" 2>/dev/null | sed "s#^$source_dir/##" > "$current_files"
  cat "$baseline_files" "$current_files" | sort -u > "$TMP_DIR/source-files"

  changed_files=0
  missing_local=0
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    [[ "$rel" == "SKILL.md" ]] && continue
    local_path="$local_dir/$rel"
    base_blob=""; head_blob=""
    if grep -Fxq "$rel" "$baseline_files"; then base_blob=$(git -C "$repo_path" rev-parse "$baseline_commit:$source_dir/$rel" 2>/dev/null || true); fi
    if grep -Fxq "$rel" "$current_files"; then head_blob=$(git -C "$repo_path" rev-parse "$head_commit:$source_dir/$rel" 2>/dev/null || true); fi
    local_exists=false
    [[ -f "$local_path" ]] && local_exists=true

    if [[ "$base_blob" != "$head_blob" ]]; then
      ((changed_files+=1))
      ((support_changed_files+=1))
      printf '\n### Support/source file `%s`\n\n' "$rel" >> "$REPORT_TMP"
      printf -- '- Upstream file changed since baseline. Local file: %s.\n' "$([[ "$local_exists" == true ]] && echo present || echo missing)" >> "$REPORT_TMP"
      if [[ "$local_exists" == true && -n "$head_blob" ]]; then
        git -C "$repo_path" show "$head_commit:$source_dir/$rel" > "$TMP_DIR/support-head"
        if cmp -s "$TMP_DIR/support-head" "$local_path"; then
          echo '- Local file matches current upstream.' >> "$REPORT_TMP"
        elif [[ -n "$base_blob" ]]; then
          git -C "$repo_path" show "$baseline_commit:$source_dir/$rel" > "$TMP_DIR/support-base"
          if cmp -s "$TMP_DIR/support-base" "$local_path"; then
            echo '- Local file still matches the recorded baseline.' >> "$REPORT_TMP"
          else
            echo '- Local file differs from both the recorded baseline and current upstream.' >> "$REPORT_TMP"
          fi
        fi
        if [[ -n "$base_blob" ]]; then
          git -C "$repo_path" show "$baseline_commit:$source_dir/$rel" > "$TMP_DIR/support-base"
          echo '' >> "$REPORT_TMP"; echo 'Upstream change since baseline:' >> "$REPORT_TMP"; echo '```diff' >> "$REPORT_TMP"
          diff -u --label "baseline:$rel" --label "upstream:$rel" "$TMP_DIR/support-base" "$TMP_DIR/support-head" | head -100 >> "$REPORT_TMP" || true
          echo '```' >> "$REPORT_TMP"
          if ! cmp -s "$TMP_DIR/support-head" "$local_path"; then
            echo '' >> "$REPORT_TMP"; echo 'Local copy vs current upstream:' >> "$REPORT_TMP"; echo '```diff' >> "$REPORT_TMP"
            diff -u --label "upstream:$rel" --label "local:$local_path" "$TMP_DIR/support-head" "$local_path" | head -100 >> "$REPORT_TMP" || true
            echo '```' >> "$REPORT_TMP"
          fi
        fi
      elif [[ -z "$base_blob" ]]; then
        echo '- File is new upstream since the recorded baseline.' >> "$REPORT_TMP"
      fi
    elif [[ "$local_exists" == false ]]; then
      ((missing_local+=1))
      printf '\n- Source support file absent locally: `%s`.\n' "$rel" >> "$REPORT_TMP"
    elif [[ -n "$base_blob" ]]; then
      git -C "$repo_path" show "$baseline_commit:$source_dir/$rel" > "$TMP_DIR/support-base"
      if ! cmp -s "$TMP_DIR/support-base" "$local_path"; then
        printf '\n- Local support file differs from recorded source: `%s`.\n' "$rel" >> "$REPORT_TMP"
      fi
    fi
  done < "$TMP_DIR/source-files"
  printf '\n- Support files changed upstream: %s; source support files absent locally: %s.\n' "$changed_files" "$missing_local" >> "$REPORT_TMP"

  # Report local files not represented at the source baseline or current head.
  while IFS= read -r local_path; do
    rel=${local_path#"$local_dir/"}
    if ! grep -Fxq "$rel" "$TMP_DIR/source-files"; then
      printf -- '- Local-only file (preserve unless explicitly approved for removal): `%s`.\n' "$rel" >> "$REPORT_TMP"
    fi
  done < <(find "$local_dir" -type f -print | sort)
done < <(jq -c '.' "$ENTRIES_JSON")

# Candidate inventory: review stable skills from the selected external families.
# The existing alignment decisions keep Cursor out of candidate scope beyond the
# credited unslop skill, and exclude upstream in-progress skills.
echo -e '\n## External skill candidates (review individually)\n' >> "$REPORT_TMP"
while IFS=$'\t' read -r owner repo; do
  [[ "$owner/$repo" == "cursor/plugins" ]] && continue
  key="$owner/$repo"
  repo_path=${SOURCE_REPO[$key]}
  head_commit=${SOURCE_HEAD[$key]}
  while IFS= read -r path; do
    [[ "$path" == */SKILL.md ]] || continue
    [[ "$path" == */in-progress/* ]] && continue
    if grep -Fxq "$owner/$repo/$path" "$CREDITED_PATHS"; then continue; fi
    skill_dir=${path%/SKILL.md}
    name=$(frontmatter_field "$repo_path" "$head_commit" "$path" name)
    description=$(frontmatter_field "$repo_path" "$head_commit" "$path" description | cut -c1-240)
    description=$(jq -Rrn --arg value "$description" '$value | gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;")')
    ((candidate_count+=1))
    printf -- '- **%s: %s** — `%s`\n  - About: %s\n  - Source: https://github.com/%s/%s/blob/%s/%s\n' "$owner/$repo" "${name:-$(basename "$skill_dir")}" "$skill_dir" "${description:-description not parsed}" "$owner" "$repo" "${SOURCE_HEAD_REF[$key]}" "$path" >> "$REPORT_TMP"
  done < <(git -C "$repo_path" ls-tree -r --name-only "$head_commit")
done < <(jq -sr '[.[] | .owner + "\t" + .repo] | unique[]' "$ENTRIES_JSON")

cat >> "$REPORT_TMP" <<'EOF'

## Interpretation

This report is evidence for a decision, not authorization to overwrite local work. Review candidate skills one at a time with the user. Sync only files the user approves, preserve local adaptations and local-only support files by default, and update alignment metadata only after review.
EOF

sed \
  -e "s/__ENTRY_COUNT__/$entry_count/g" \
  -e "s/__REPO_COUNT__/$repo_count/g" \
  -e "s/__SOURCE_CHANGES__/$source_changed_entries/g" \
  -e "s/__SUPPORT_CHANGES__/$support_changed_files/g" \
  -e "s/__LOCAL_DRIFT__/$local_drift_entries/g" \
  -e "s/__CANDIDATES__/$candidate_count/g" \
  "$REPORT_TMP" > "$TMP_DIR/report-final.md"
mv "$TMP_DIR/report-final.md" "$OUTPUT"
printf 'Wrote comparison report: %s\n' "$OUTPUT"
