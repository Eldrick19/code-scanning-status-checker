#!/bin/bash
set -e
trap 'echo "An error occurred. Exiting." >&2' ERR

TOKEN=$1
PR_NUMBER=$2
ORG_REPO=$3

IFS='/' read -ra SPLIT_REPO <<< "$ORG_REPO"
ORG=${SPLIT_REPO[0]}
REPO=${SPLIT_REPO[1]}

gh auth login --with-token <<< "$TOKEN"

get_codeql_conclusion() {
  local response
  response=$(gh api graphql -f query='
    {
        repository(owner: "'$ORG'", name: "'$REPO'") {
        pullRequest(number: '$PR_NUMBER') {
          commits(last: 1) {
            nodes {
              commit {
                checkSuites(first: 1, filterBy: {checkName: "CodeQL"}) {
                  nodes {
                    checkRuns(first: 1) {
                      nodes {
                        name
                        status
                        conclusion
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  ')
  echo $response | jq -r '.data.repository.pullRequest.commits.nodes[0].commit.checkSuites.nodes[0].checkRuns.nodes[0].conclusion'
}

declare -r JOB_SKIPPED=78
declare -r JOB_FAILED=1
declare -r JOB_SUCCESS=0

conclusion=$(get_codeql_conclusion)
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