#!/bin/bash
set -euo pipefail

if [[ -z "${GH_TOKEN:-}" || -z "${GH_ORG:-}" || -z "${GH_RUNNER_GROUP_ID:-}" ]]; then
    echo "Error: GH_TOKEN, GH_ORG, and GH_RUNNER_GROUP_ID environment variables must be set."
    exit 1
fi

api_url="https://api.github.com/orgs/${GH_ORG}/actions/runners/generate-jitconfig"
body="{\"name\":\"$(hostname)\", \"labels\": [\"self-hosted\"], \"runner_group_id\":${GH_RUNNER_GROUP_ID}}"

echo "Requesting JIT config from GitHub API..."
echo $body

encoded_jit_config=$(
    curl -sSL -X POST "$api_url" \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GH_TOKEN" \
        -d "$body" \
        | jq -r '.encoded_jit_config'
)

if [[ -z "$encoded_jit_config" || "$encoded_jit_config" == "null" ]]; then
  echo "Failed to get encoded_jit_config from GitHub API."
  exit 2
fi

echo "Starting runner with JIT config..."
exec ./run.sh --jitconfig "$encoded_jit_config"
