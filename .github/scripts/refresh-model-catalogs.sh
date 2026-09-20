#!/usr/bin/env bash
# Intentionally a no-op in this fork.
#
# Upstream calls this script before building every release to overwrite
# internal/registry/models/models.json (and the Codex client catalog) with the
# remote router-for-me/models catalog. That is wrong here for two reasons:
#
#   1. The remote catalog does not publish the local-only providers (zcode,
#      meta), so a wholesale replace drops their embedded definitions and the
#      built binary answers "unknown provider for model ...".
#   2. This fork does not use Codex, so refreshing and validating the Codex
#      client catalog is dead weight -- and it made every release depend on
#      github.com/router-for-me/models being reachable.
#
# What ships is the catalog committed at the tag. The runtime model updater still
# refreshes it at startup and carries the local-only sections over (see
# carryOverLocalOnlySections in internal/registry/model_updater.go), so freshness
# is not lost.
#
# The call sites in release.yaml / docker-image.yml / pr-test-build.yml are left
# untouched on purpose: editing them would diverge from upstream on three files
# instead of this one.
set -euo pipefail

echo "refresh-model-catalogs: skipped, the fork ships the committed catalog"
