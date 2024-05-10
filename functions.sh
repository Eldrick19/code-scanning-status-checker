#!/bin/bash
get_codeql_api_response() {
    gh api graphql -f query='
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
    '
} 

get_codeql_conclusion() {
    local response="$1"
    echo $response | jq -r '.data.repository.pullRequest.commits.nodes[0].commit.checkSuites.nodes[0].checkRuns.nodes[0].conclusion'
}