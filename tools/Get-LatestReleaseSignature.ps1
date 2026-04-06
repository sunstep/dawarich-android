param(
    [string]$RepoPath = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-Git {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $git) {
        throw "git is not installed or not on PATH."
    }
}

function Get-LatestSemverTag {
    param([string]$Path)

    Push-Location $Path
    try {
        # Fetch tags to be sure we're not stale (safe even if already up to date)
        git fetch --tags --quiet | Out-Null

        # Use Git's version sort: v:refname sorts tags like 0.9.0 < 0.10.0 correctly
        $tag = git tag --list --sort=-v:refname | Select-Object -First 1

        if ([string]::IsNullOrWhiteSpace($tag)) {
            throw "No tags found in repository. Create a release tag first (e.g. v0.19.0)."
        }

        return $tag.Trim()
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

$latestTag = Get-LatestSemverTag -Path $RepoPath
$shaFull = Get-TagCommitSha -Path $RepoPath -Tag $latestTag
$shaShort = $shaFull.Substring(0, 7)

Write-Host "Latest release tag : $latestTag"
Write-Host "Commit SHA (full)  : $shaFull"
Write-Host "Commit SHA (short) : $shaShort"