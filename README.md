# CodeQL Status Checker

The Actions is meant to help you if you're using both GitHub Merge Queue and GitHub Advanced Security. It is a workaround to functionality that will be native to GitHub

At the time of creation of this Action, the ability to do **all** of the following is **not** possible:
1. Have Merge Queue on a repo
2. Have Code Scanning from GitHub Advanced Security activated on a repo
3. Enforce Code Scanning's CodeQL as a required status check for pull requests.

This is a very simple Action that will act as a substitute required status check for Code Scanning once you have merge queue enabled. It will force Code Scanning to pass at the Pull Request and allow you to skip it in your repo's merge group.

## Why?

If you want more details as to why this workaround exists see [here](). 

## How does it work?

The action uses the GraphQL API to call the Status Checks API. It grabs the status of the CodeQL analysis (which should have already been run) in a PR. If the CodeQL status check fails, this action will fail, acting as a security gate.

## How to use?
1. Add it in a separate job to your workflow:

  ````yaml
  check_codeql_status:
      name: Force CodeQL Status Check
      needs: <your code scanning job>
      permissions: 
        contents: read
        checks: read
        pull-requests: read
      runs-on: ubuntu-latest
      if: ${{ github.event_name == 'pull_request' }}
      steps:
      - name: Check Code Scanning Status
        uses: eldrick19/codeql-status-checker@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          pr_number: ${{ github.event.pull_request.number }}
          repo: ${{ github.repository }}
  ````

  <details>
  <summary>For example, your workflow could look like:</summary>
  <br/>
    
  ````yaml
  name: "CodeQL"
  
  on:
    pull_request:
      branches: [ "main" ]
    merge_group:
  
  jobs:
    analyze:
      name: Analyze
      runs-on: ${{ (matrix.language == 'swift' && 'macos-latest') || 'ubuntu-latest' }}
      timeout-minutes: ${{ (matrix.language == 'swift' && 120) || 360 }}
      permissions:
        actions: read
        contents: read
        security-events: write
  
      strategy:
        fail-fast: false
        matrix:
          language: [ 'javascript-typescript' ]
  
      steps:
      - name: Checkout repository
        uses: actions/checkout@v3
  
      # Initializes the CodeQL tools for scanning.
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v2
        with:
          languages: ${{ matrix.language }}
  
      - name: Autobuild
        uses: github/codeql-action/autobuild@v2
  
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v2
        with:
          category: "/language:${{matrix.language}}"
  
     check_codeql_status:
      name: Force CodeQL Status Check
      needs: analyze
      permissions: 
        contents: read
        checks: read
        pull-requests: read
      runs-on: ubuntu-latest
      if: ${{ github.event_name == 'pull_request' }}
      steps:
      - name: Check Code Scanning Status
        uses: eldrick19/codeql-status-checker@v1
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          pr_number: ${{ github.event.pull_request.number }}
          repo: ${{ github.repository }}
  ````
  </details>

2. Once added, instead of making your "CodeQL" job required, make the "Force Code Scanning Check" job mandatory
3. Now, this job will check if Code Scanning
