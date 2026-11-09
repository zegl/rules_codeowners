#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Called by the bazel-contrib release_ruleset workflow with the tag, e.g. v0.3.0.
TAG=$1
# Match the prefix GitHub uses for its own source archives.
PREFIX="rules_codeowners-${TAG:1}"
ARCHIVE="rules_codeowners-$TAG.tar.gz"

git archive --format=tar --prefix="${PREFIX}/" "${TAG}" | gzip > "$ARCHIVE"

cat << EOF2
## Bzlmod

Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_codeowners", version = "${TAG:1}")
\`\`\`
EOF2
