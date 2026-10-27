#!/usr/bin/env bash
# Runs every aws command from the guide (cli/aws-commands.tsv) without credentials.
# Reaching the credentials error means the CLI parsed every argument; a usage or
# parameter error fails the job.
set -uo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."
export AWS_EC2_METADATA_DISABLED=true AWS_DEFAULT_REGION=eu-west-1 AWS_PAGER=
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE
fail=0; n=0
while IFS=$'\t' read -r dir cmd; do
  n=$((n + 1))
  out=$(cd "$dir" && eval "$cmd" 2>&1 </dev/null)
  if grep -q -E 'Unable to locate credentials|NoCredentialsError' <<<"$out"; then
    echo "ok   [$dir] $cmd"
  else
    echo "FAIL [$dir] $cmd"; echo "$out" | head -5; fail=1
  fi
done < cli/aws-commands.tsv
echo "$n commands checked"
exit "$fail"
