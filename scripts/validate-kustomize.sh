#!/usr/bin/env bash
# Build every kustomize overlay. Helm-based apps need helm on PATH and network access.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

fails=0
while IFS= read -r -d '' kust; do
  dir="$(dirname "$kust")"
  # Only build overlays and cluster entrypoints
  case "$dir" in
    */overlays/*|clusters/hub|clusters/ocp|clusters/bootstrap) ;;
    *) continue ;;
  esac

  echo "==> kustomize build ${dir}"
  if ! out="$(kubectl kustomize --enable-helm "$dir" 2>&1)"; then
    # Retry without helm for pure kustomize trees
    if ! out="$(kubectl kustomize "$dir" 2>&1)"; then
      echo "FAIL ${dir}"
      echo "$out" | head -20
      fails=$((fails + 1))
      continue
    fi
  fi
  kinds="$(printf '%s\n' "$out" | grep -c '^kind:' || true)"
  if [[ "${kinds}" -eq 0 ]]; then
    echo "EMPTY ${dir}"
    fails=$((fails + 1))
  else
    echo "OK ${dir} (${kinds} resources)"
  fi
done < <(find infrastructure applications virtualization clusters -name kustomization.yaml -print0 | sort -z)

if [[ "${fails}" -gt 0 ]]; then
  echo "Validation failed: ${fails} overlay(s)"
  exit 1
fi
echo "All overlays built successfully."
