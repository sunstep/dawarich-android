param (
    [Parameter(Mandatory=$true)]
    [string]$Branch
)

$count = git rev-list --count $Branch

Write-Output "Commit count for branch '$Branch': $count"