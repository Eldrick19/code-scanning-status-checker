 #!/bin/bash
 SCRIPT_DIR="$(dirname "$0")"
 chmod +x "$SCRIPT_DIR/functions.sh"
 source "$SCRIPT_DIR/functions.sh"
 set -e
 trap 'echo "An error occurred. Exiting." >&2' ERR

TOKEN=$1
PR_NUMBER=$2
ORG_REPO=$3

IFS='/' read -ra SPLIT_REPO <<< "$ORG_REPO"
ORG=${SPLIT_REPO[0]}
REPO=${SPLIT_REPO[1]}

gh auth login --with-token <<< "$TOKEN"

declare -r JOB_SKIPPED=78
declare -r JOB_FAILED=1
declare -r JOB_SUCCESS=0

response=$(get_codeql_api_response)
conclusion=$(get_codeql_conclusion "$response")
exit_status=$JOB_SUCCESS

if [ "$conclusion" == "SUCCESS" ]; then
  echo "CodeQL check succeeded"
elif [ "$conclusion" == "FAILURE" ]; then
  echo "CodeQL check failed"
  exit_status=$JOB_FAILED
else
  echo "Unexpected CodeQL conclusion received: $conclusion. Please check the CodeQL job for more details. Skipping job."
  exit_status=$JOB_SKIPPED
fi

exit $exit_status