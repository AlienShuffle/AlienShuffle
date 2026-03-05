
#!/usr/bin/env bash
set -euo pipefail

# ---- Configuration ----
TMP_DIR="/tmp"
AGE_DAYS=14       # delete files older than this
DRY_RUN=false     # set to true to preview deletions

# ---- Safety checks ----
if [[ "$TMP_DIR" != "/tmp" ]]; then
  echo "Refusing to run on non-/tmp directory"
  exit 1
fi

echo "Cleaning $TMP_DIR (files older than $AGE_DAYS days)"
echo "Dry run: $DRY_RUN"
echo

# ---- Cleanup ----
if $DRY_RUN; then
  find "$TMP_DIR" -mindepth 1 \
    -type f -mtime +"$AGE_DAYS" -print
else
  find "$TMP_DIR" -mindepth 1 \
    -type f -mtime +"$AGE_DAYS" -delete
fi

# ---- Empty old directories ----
find "$TMP_DIR" -mindepth 1 \
  -type d -empty -mtime +"$AGE_DAYS" -delete

echo "Cleanup complete."
