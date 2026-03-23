param(
    [string]$RepoPath = ".",
    [string]$Tag
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Git {
    $git = Get-Command git -ErrorAction SilentlyContinue

    if ($null -eq $git) {
        throw "git is not installed or not on PATH."
    }
}

function Assert-Repository {
    param([string]$Path)

    Push-Location $Path
    try {
        git rev-parse --is-inside-work-tree > $null 2>&1

        if ($LASTEXITCODE -ne 0) {
            throw "The path '$Path' is not a Git repository."
        }
    }
    finally {
        Pop-Location
    }
}

function Read-TagInput {
    param([string]$CurrentTag)

    if (-not [string]::IsNullOrWhiteSpace($CurrentTag)) {
        return $CurrentTag.Trim()
    }

    $enteredTag = Read-Host "Enter the tag (example: v0.19.0)"

    if ([string]::IsNullOrWhiteSpace($enteredTag)) {
        throw "No tag was entered."
    }

    return $enteredTag.Trim()
}

function Assert-TagExists {
    param(
        [string]$Path,
        [string]$Tag
    )

    Push-Location $Path
    try {
        git fetch --tags --quiet | Out-Null

        git rev-parse --verify "refs/tags/$Tag" > $null 2>&1

        if ($LASTEXITCODE -ne 0) {
            throw "Tag '$Tag' does not exist in this repository."
        }
    }
    finally {
        Pop-Location
    }
}

function Get-TagCommitSha {
    param(
        [string]$Path,
        [string]$Tag
    )

    Push-Location $Path
    try {
        $sha = git rev-list -n 1 $Tag

        if ([string]::IsNullOrWhiteSpace($sha)) {
            throw "Could not resolve tag '$Tag' to a commit SHA."
        }

        return $sha.Trim()
    }
    finally {
        Pop-Location
    }
}

Assert-Git
Assert-Repository -Path $RepoPath

$selectedTag = Read-TagInput -CurrentTag $Tag
Assert-TagExists -Path $RepoPath -Tag $selectedTag

$shaFull = Get-TagCommitSha -Path $RepoPath -Tag $selectedTag
$shaShort = $shaFull.Substring(0, 7)

Write-Host ""
Write-Host "Selected tag      : $selectedTag"
Write-Host "Commit SHA (full) : $shaFull"
Write-Host "Commit SHA (short): $shaShort"
Write-Host ""