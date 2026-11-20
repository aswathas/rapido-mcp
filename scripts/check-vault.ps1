#Requires -Version 5.1
<#
.SYNOPSIS
    Checks the Obsidian vault for broken links, missing frontmatter and wikilinks.

.DESCRIPTION
    The vault root is the repo root. Every tracked .md file is a note.
    This script proves three properties the vault contract depends on:

    1. Every relative Markdown link in every note resolves to a file on disk.
    2. Every note opens with YAML frontmatter that has a title and a type.
    3. No note uses [[wikilinks]], because GitHub does not render them.

    Exit code 0 means clean. Exit code 1 means at least one problem was found.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts/check-vault.ps1
    powershell -ExecutionPolicy Bypass -File scripts/check-vault.ps1 -RepoPath C:\path\to\vault
#>
[CmdletBinding()]
param(
    [string]$RepoPath = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepoPath)) {
    $scriptPath = $MyInvocation.MyCommand.Path
    if ([string]::IsNullOrWhiteSpace($scriptPath)) {
        Write-Output 'FAIL cannot resolve the script path, pass -RepoPath explicitly'
        exit 1
    }
    $RepoPath = Split-Path -Parent (Split-Path -Parent $scriptPath)
}

if (-not (Test-Path -LiteralPath $RepoPath)) {
    Write-Output "FAIL repo path not found: $RepoPath"
    exit 1
}

$notes = Get-ChildItem -LiteralPath $RepoPath -Recurse -Filter *.md -File |
    Where-Object { $_.FullName -notmatch '\\(\.git|node_modules|dist|build|\.venv|__pycache__)\\' }

$linkPattern = '\]\(([^)\s]+)\)'
$problems = New-Object System.Collections.Generic.List[string]
$linkCount = 0

foreach ($note in $notes) {
    $text = [System.IO.File]::ReadAllText($note.FullName)
    $relative = $note.FullName.Substring($RepoPath.Length).TrimStart('\', '/')

    # Prose only. Fenced code blocks and inline code spans show syntax on purpose,
    # so a link or a wikilink inside them is an example, not a defect.
    $prose = [regex]::Replace($text, '(?s)```.*?```', ' ')
    $prose = [regex]::Replace($prose, '(?s)~~~.*?~~~', ' ')
    $prose = [regex]::Replace($prose, '`[^`\r\n]*`', ' ')

    # 3. no wikilinks
    if ($prose -match '\[\[') {
        $problems.Add("$relative : uses a wikilink, GitHub will not render it")
    }

    # 2. frontmatter with title and type. Only notes/ carries properties.
    #    Repo-level docs such as README.md and AGENTS.md are documents, not notes.
    $isNote = $relative -match '^(notes\\|notes/)'
    if ($isNote) {
        if (-not $text.StartsWith('---')) {
            $problems.Add("$relative : no YAML frontmatter")
        }
        else {
            $end = $text.IndexOf("`n---", 3)
            if ($end -lt 0) {
                $problems.Add("$relative : frontmatter is never closed")
            }
            else {
                $front = $text.Substring(3, $end - 3)
                if ($front -notmatch '(?m)^title:\s*\S') { $problems.Add("$relative : frontmatter has no title") }
                if ($front -notmatch '(?m)^type:\s*\S') { $problems.Add("$relative : frontmatter has no type") }
            }
        }
    }

    # 1. relative links resolve
    foreach ($match in [regex]::Matches($prose, $linkPattern)) {
        $target = $match.Groups[1].Value
        if ($target -match '^(https?:|mailto:|#)') { continue }
        $linkCount++
        $target = $target.Split('#')[0]
        if ([string]::IsNullOrWhiteSpace($target)) { continue }
        $decoded = [System.Uri]::UnescapeDataString($target)
        $resolved = [System.IO.Path]::GetFullPath((Join-Path $note.DirectoryName $decoded))
        if (-not (Test-Path -LiteralPath $resolved)) {
            $problems.Add("$relative : broken link -> $target")
        }
    }
}

Write-Output "notes checked : $($notes.Count)"
Write-Output "links checked : $linkCount"

if ($problems.Count -eq 0) {
    Write-Output "RESULT: clean"
    exit 0
}

Write-Output "RESULT: $($problems.Count) problem(s)"
foreach ($p in $problems) { Write-Output "  $p" }
exit 1
