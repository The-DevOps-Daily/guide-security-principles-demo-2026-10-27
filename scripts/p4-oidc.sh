#!/usr/bin/env bash
# Part 4 OIDC claims, in a GitHub Actions job with environment production
# Generated from the guide source: every command below is shown in the guide,
# and its output there comes from the captures this script writes.
set -uo pipefail
source "$(dirname "$(readlink -f "$0")")/lib.sh"
capture p4-oidc-01 0 <<'__CMD__'
curl -sS -H "Authorization: Bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=sts.amazonaws.com" | jq -r .value > id-token.jwt
__CMD__
capture p4-oidc-02 0 <<'__CMD__'
python3 part04/decode-jwt.py id-token.jwt | jq '{iss, aud, sub, repository, repository_id, repository_owner_id, environment, ref, job_workflow_ref, runner_environment}'
__CMD__
capture p4-oidc-03 0 <<'__CMD__'
rm id-token.jwt
__CMD__
finish
