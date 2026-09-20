#!/usr/bin/env bash
set -euo pipefail

models_repository="${MODELS_REPOSITORY_URL:-https://github.com/router-for-me/models.git}"
models_ref="${MODELS_REPOSITORY_REF:-main}"
catalog_dir="${MODEL_CATALOG_DIR:-internal/registry/models}"
codex_catalog="$catalog_dir/codex_client_models.json"
codex_candidate="$(mktemp)"
trap 'rm -f "$codex_candidate"' EXIT

git fetch --depth 1 "$models_repository" "$models_ref"
# models.json is intentionally NOT overwritten from the remote catalog: that
# catalog does not publish the local-only providers (zcode, meta), so a wholesale
# replace would silently drop their embedded definitions and the build would
# answer "unknown provider for model ...". The runtime updater refreshes the
# catalog at startup and carries the local-only sections over, so releasing the
# catalog committed at the tag keeps both freshness and the local-only models.
# (Do not restore this line unless zcode/meta are published to the models repo.)

if git show FETCH_HEAD:codex_client_models.json > "$codex_candidate" &&
  go run ./cmd/validate_codex_models --file "$codex_candidate"; then
	mv "$codex_candidate" "$codex_catalog"
	printf 'Refreshed validated Codex client model catalog.\n'
else
	printf '::warning::Remote Codex client model catalog is missing or invalid; using embedded fallback.\n'
fi

go run ./cmd/validate_codex_models --file "$codex_catalog"
