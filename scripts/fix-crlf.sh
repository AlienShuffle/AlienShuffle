#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./fix-crlf.sh [root_dir]
# Defaults to current directory.
root="${1:-.}"

# Find regular files, ask `file` which ones have CRLF line terminators,
# then strip the trailing carriage return on each line in-place.
#
# Notes:
# - Uses NUL delimiters to handle spaces/newlines in filenames safely.
# - Uses sed -i, with a BSD/macOS-compatible fallback.
# - Skips binaries implicitly because we're only acting on files where `file`
#   explicitly says "with CRLF line terminators". [1](https://www.baeldung.com/linux/find-convert-files-with-crlf)

# Detect whether sed supports "sed -i" with no backup extension (GNU) or requires one (BSD/macOS).
sed_inplace() {
  # $1 = filename
  if sed --version >/dev/null 2>&1; then
    # GNU sed
    sed -i 's/\r$//' "$1"
  else
    # BSD/macOS sed requires a backup extension argument (empty string = no backup)
    sed -i '' 's/\r$//' "$1"
  fi
}

export -f sed_inplace

# Build a NUL-separated list of files that `file` says are CRLF-terminated.
# Example from `file`: "ASCII text, with CRLF line terminators" [1](https://www.baeldung.com/linux/find-convert-files-with-crlf)
mapfile -d '' crlf_files < <(
  find "$root" -type f -print0 |
  while IFS= read -r -d '' f; do
    # `file -b` = brief (no filename prefix)
    # If it mentions CRLF line terminators, convert it.
    if file -b "$f" | grep -q 'CRLF line terminators' ||
    file -b "$f" | grep -q 'CRLF, LF line terminators'; then
      printf '%s\0' "$f"
    fi
  done
)

count="${#crlf_files[@]}"
if (( count == 0 )); then
  echo "No CRLF-terminated text files found under: $root"
  exit 0
fi

echo "Found $count CRLF-terminated text file(s). Converting to LF…"

# Convert each file
for f in "${crlf_files[@]}"; do
  sed_inplace "$f"
done

echo "Done."