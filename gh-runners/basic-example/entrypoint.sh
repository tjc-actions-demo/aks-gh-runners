#!/bin/bash
set -euo pipefail

if [[ -z "${GH_TOKEN:-}" || -z "${GH_ORG:-}" || -z "${GH_RUNNER_GROUP_ID:-}" ]]; then
    echo "Error: GH_TOKEN, GH_ORG, and GH_RUNNER_GROUP_ID environment variables must be set."
    exit 1
fi

if [[ -n "${GH_RUNNER_LABELS:-}" ]]; then
  # convert to lowercase and split labels by comma into array
  IFS=',' read -r -a labels_array <<< "${GH_RUNNER_LABELS,,}"
  
  # check if "self-hosted" is already in the array
  if [[ ! " ${labels_array[*]} " =~ " self-hosted " ]]; then
    # add "self-hosted" to the beginning of the array
    labels_array=("self-hosted" "${labels_array[@]}")
  fi
  
  # join array into a string with quotes around each label
  labels_string=$(printf ',"%s"' "${labels_array[@]}")
else
  # if no labels provided, use just "self-hosted"
  labels_array=("self-hosted")
  labels_string=',"self-hosted"'
fi

api_url="https://api.github.com/orgs/${GH_ORG}/actions/runners/generate-jitconfig"
body="{\"name\":\"$(hostname)\", \"labels\": [${labels_string#,}], \"runner_group_id\":${GH_RUNNER_GROUP_ID}}"

echo "Requesting JIT config from GitHub API..."
post_response=$(
    curl -sSL -X POST "$api_url" \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $GH_TOKEN" \
        -d "$body"
)

encoded_jit_config=$(echo "$post_response" | jq -r '.encoded_jit_config')

if [[ -z "$encoded_jit_config" || "$encoded_jit_config" == "null" ]]; then
  echo "Failed to get encoded_jit_config from GitHub API."
  echo "Response: $post_response"
  exit 2
fi

echo "Starting runner with JIT config..."
exec ./run.sh --jitconfig "$encoded_jit_config"
