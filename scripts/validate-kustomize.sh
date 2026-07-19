#!/usr/bin/env bash
# Build every kustomize overlay. Helm-based apps need helm on PATH and network access.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required" >&2
  exit 1
fi

fails=0
while IFS= read -r -d '' kust; do
  dir="$(dirname "$kust")"
  # Only build overlays and cluster entrypoints
  case "$dir" in
    */overlays/*|clusters/hub|clusters/ocp) ;;
    *) continue ;;
  esac

  # Detect helmCharts anywhere in the kustomize tree (overlay or referenced base).
  uses_helm=0
  if grep -R --include='kustomization.yaml' -lE '^\s*helmCharts:' "$dir" >/dev/null 2>&1 \
    || grep -R --include='kustomization.yaml' -lE '^\s*helmCharts:' "$(dirname "$dir")/.." >/dev/null 2>&1; then
    uses_helm=1
  fi
  # Explicit known helm apps (overlay only contains resources: ../../base)
  case "$dir" in
    applications/grafana/*|applications/victoria-metrics/*|applications/victoria-logs/*)
      uses_helm=1
      ;;
  esac

  echo "==> kustomize build ${dir}"
  if [[ "${uses_helm}" -eq 1 ]]; then
    if ! command -v helm >/dev/null 2>&1; then
      echo "FAIL ${dir}"
      echo "helm is required to build this overlay (helmCharts present)"
      fails=$((fails + 1))
      continue
    fi
    if ! out="$(kubectl kustomize --enable-helm "$dir" 2>&1)"; then
      echo "FAIL ${dir}"
      echo "$out" | head -30
      fails=$((fails + 1))
      continue
    fi
  else
    if ! out="$(kubectl kustomize --enable-helm "$dir" 2>&1)"; then
      # Pure kustomize fallback when --enable-helm is unavailable/irrelevant
      if ! out="$(kubectl kustomize "$dir" 2>&1)"; then
        echo "FAIL ${dir}"
        echo "$out" | head -30
        fails=$((fails + 1))
        continue
      fi
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
