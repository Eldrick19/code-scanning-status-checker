#!/usr/bin/env bats
source ./functions.sh

@test "get_codeql_conclusion with neutral.json" {
    # Read the contents of neutral.json
    response=$(cat test/sample-graphql-responses/neutral.json)
    # Call get_codeql_conclusion with the contents of neutral.json
    result=$(get_codeql_conclusion "$response" | tr '[:lower:]' '[:upper:]')
    # Check if the output is "NEUTRAL"
    [ "$result" == "NEUTRAL" ]
}

@test "get_codeql_conclusion with failure.json" {
    # Read the contents of failure.json
    response=$(cat test/sample-graphql-responses/failure.json)
    # Call get_codeql_conclusion with the contents of failure.json
    result=$(get_codeql_conclusion "$response" | tr '[:lower:]' '[:upper:]')
    # Check if the output is "FAILURE"
    [ "$result" == "FAILURE" ]
}

@test "get_codeql_conclusion with success.json" {
    # Read the contents of success.json
    response=$(cat test/sample-graphql-responses/success.json)
    # Call get_codeql_conclusion with the contents of success.json
    result=$(get_codeql_conclusion "$response" | tr '[:lower:]' '[:upper:]')
    # Check if the output is "SUCCESS"
    [ "$result" == "SUCCESS" ]
}

@test "get_codeql_conclusion with empty payload" {
    # Set an empty payload
    response=""
    # Call get_codeql_conclusion with the empty payload
    result=$(get_codeql_conclusion "$response" | tr '[:lower:]' '[:upper:]')
    # Check if the output is empty
    [ -z "$result" ]
}