#!/bin/bash

TOKEN=$1
PR_NUMBER=$2
ORG=$3
REPO=$4

gh auth login --with-token <<< "$TOKEN"

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

conclusion=$(echo $response | jq -r '.data.repository.pullRequest.commits.nodes[0].commit.checkSuites.nodes[0].checkRuns.nodes[0].conclusion')
if [ "$conclusion" != "SUCCESS" ]; then
  echo "CodeQL check failed"
  exit 1
fi