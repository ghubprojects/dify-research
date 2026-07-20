<#
.SYNOPSIS
Runs repository Markdown static QA and returns a nonzero exit code on failure.

.DESCRIPTION
Checks UTF-8/mojibake, fenced blocks, local links, governance registers, source
coverage, chapter headings, control IDs, and the expected 29 basic Mermaid
blocks. This is a static validator: it does not fetch external URLs or render
Mermaid in the target wiki.

.PARAMETER Path
Optional assembled final Markdown file. Every H2-H6 in that file must have an
explicit, unique anchor using a front/doc, part, ch00-ch19, or appendix/app
namespace. The final must also have one H1 and exactly 29 Mermaid blocks.

.EXAMPLE
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate-markdown.ps1

.EXAMPLE
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate-markdown.ps1 -Path docs/releases/dify-research-final.md
#>
[CmdletBinding()]
param(
    # Optional assembled final document. Relative paths are resolved from the repository root.
    [Parameter(Position = 0)]
    [string]$Path
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$script:RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$script:DocsRoot = Join-Path $script:RepoRoot 'docs'
$script:GuideRoot = Join-Path $script:DocsRoot 'dify-technical-guide'
$script:WorkingRoot = Join-Path $script:DocsRoot 'working'
$script:Failures = New-Object 'System.Collections.Generic.List[string]'
$script:DocumentCache = @{}
$script:AnchorCache = @{}
$script:Utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$script:TableCount = 0
$script:RelativeLinkCount = 0
$script:InlineLinkPattern = [regex]'!?\[[^\]]*\]\((?<target><[^>]+>|[^\s\)]+)(?:\s+["''][^"'']*["''])?\)'
$script:ReferenceLinkPattern = [regex]'^\s*\[[^\]]+\]:\s*(?<target><[^>]+>|\S+)'
$script:HtmlLinkPattern = [regex]'(?i)\b(?:href|src)\s*=\s*["''](?<target>[^"'']+)["'']'
$script:HtmlAnchorPattern = [regex]'(?i)<[A-Za-z][^>]*\s(?:id|name)\s*=\s*["''](?<id>[A-Za-z0-9][A-Za-z0-9._:-]*)["''][^>]*>'
$script:AttributeAnchorPattern = [regex]'\{#(?<id>[A-Za-z0-9][A-Za-z0-9._:-]*)\}'

function Add-Failure {
    param([string]$Message)

    [void]$script:Failures.Add($Message)
}

function Get-DisplayPath {
    param([string]$FilePath)

    $fullPath = [System.IO.Path]::GetFullPath($FilePath)
    $rootPrefix = $script:RepoRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if ($fullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($rootPrefix.Length).Replace('\', '/')
    }

    return $fullPath
}

function Parse-FencedDocument {
    param(
        [string]$FilePath,
        [string[]]$Lines
    )

    $outside = New-Object System.Collections.ArrayList
    $blocks = New-Object System.Collections.ArrayList
    $current = $null

    for ($index = 0; $index -lt $Lines.Count; $index++) {
        $line = $Lines[$index]
        $fenceMatch = [regex]::Match($line, '^\s{0,3}(?<fence>`{3,}|~{3,})(?<rest>.*)$')

        if ($null -eq $current) {
            if ($fenceMatch.Success) {
                $fence = $fenceMatch.Groups['fence'].Value
                $current = [pscustomobject]@{
                    Character = $fence.Substring(0, 1)
                    Length = $fence.Length
                    Info = $fenceMatch.Groups['rest'].Value.Trim()
                    StartLine = $index + 1
                    Content = New-Object System.Collections.ArrayList
                }
            }
            else {
                [void]$outside.Add([pscustomobject]@{
                    Number = $index + 1
                    Text = $line
                })
            }

            continue
        }

        $isClosingFence = $false
        if ($fenceMatch.Success) {
            $candidate = $fenceMatch.Groups['fence'].Value
            $rest = $fenceMatch.Groups['rest'].Value
            $isClosingFence = (
                $candidate.Substring(0, 1) -eq $current.Character -and
                $candidate.Length -ge $current.Length -and
                [string]::IsNullOrWhiteSpace($rest)
            )
        }

        if ($isClosingFence) {
            [void]$blocks.Add([pscustomobject]@{
                FilePath = $FilePath
                Info = $current.Info
                StartLine = $current.StartLine
                EndLine = $index + 1
                Content = @($current.Content.ToArray())
            })
            $current = $null
        }
        else {
            [void]$current.Content.Add($line)
        }
    }

    if ($null -ne $current) {
        Add-Failure ("{0}:{1}: unclosed {2}-character Markdown fence" -f (Get-DisplayPath $FilePath), $current.StartLine, $current.Length)
    }

    return [pscustomobject]@{
        Outside = @($outside.ToArray())
        Blocks = @($blocks.ToArray())
    }
}

function Read-MarkdownDocument {
    param([string]$FilePath)

    $fullPath = [System.IO.Path]::GetFullPath($FilePath)
    if ($script:DocumentCache.ContainsKey($fullPath)) {
        return $script:DocumentCache[$fullPath]
    }

    try {
        $text = [System.IO.File]::ReadAllText($fullPath, $script:Utf8Strict)
    }
    catch {
        Add-Failure ("{0}: file is not valid UTF-8 ({1})" -f (Get-DisplayPath $fullPath), $_.Exception.Message)
        $text = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
    }

    $lines = [regex]::Split($text, "\r\n|\n|\r")
    $fences = Parse-FencedDocument -FilePath $fullPath -Lines $lines
    $document = [pscustomobject]@{
        FilePath = $fullPath
        Text = $text
        Lines = $lines
        Outside = $fences.Outside
        Blocks = $fences.Blocks
    }
    $script:DocumentCache[$fullPath] = $document
    return $document
}

function Get-AnchorSlug {
    param([Parameter(Mandatory = $true)][string]$Text)

    $plain = $Text -replace '<[^>]+>', ''
    $plain = $plain -replace '!\[([^\]]*)\]\([^)]*\)', '$1'
    $plain = $plain -replace '\[([^\]]+)\]\([^)]*\)', '$1'
    $plain = $plain -replace '[`*_~]', ''
    $plain = $plain.Replace([char]0x0111, 'd').Replace([char]0x0110, 'D')
    $decomposed = $plain.Normalize([System.Text.NormalizationForm]::FormD)
    $builder = New-Object System.Text.StringBuilder

    foreach ($character in $decomposed.ToCharArray()) {
        $category = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($character)
        if ($category -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$builder.Append($character)
        }
    }

    $slug = $builder.ToString().Normalize([System.Text.NormalizationForm]::FormC).ToLowerInvariant()
    $slug = [System.Text.RegularExpressions.Regex]::Replace($slug, '[^a-z0-9]+', '-')
    $slug = $slug.Trim('-')
    if ([string]::IsNullOrWhiteSpace($slug)) {
        return 'section'
    }
    return $slug
}

function Get-MarkdownAnchorMap {
    param([Parameter(Mandatory = $true)]$Document)

    if ($script:AnchorCache.ContainsKey($Document.FilePath)) {
        return $script:AnchorCache[$Document.FilePath]
    }

    $anchors = @{}
    $slugCounts = @{}
    $anchorNamespace = $null
    $leafName = [System.IO.Path]::GetFileName($Document.FilePath)
    if ($leafName -match '^(?<number>\d{2})-') {
        $anchorNamespace = 'ch' + $Matches['number']
    }
    elseif ($leafName -match '^(?<letter>[a-fA-F])-') {
        $anchorNamespace = 'app' + $Matches['letter'].ToLowerInvariant()
    }
    foreach ($line in $Document.Outside) {
        $headingMatch = [regex]::Match(
            $line.Text,
            '^\s{0,3}#{1,6}[ \t]+(?<text>.*?)(?:[ \t]+#+[ \t]*)?$'
        )
        if ($headingMatch.Success) {
            $baseSlug = Get-AnchorSlug -Text $headingMatch.Groups['text'].Value.Trim()
            if (-not $slugCounts.ContainsKey($baseSlug)) {
                $slugCounts[$baseSlug] = 0
            }
            else {
                $slugCounts[$baseSlug]++
            }

            $slug = $baseSlug
            if ([int]$slugCounts[$baseSlug] -gt 0) {
                $slug = '{0}-{1}' -f $baseSlug, $slugCounts[$baseSlug]
            }
            $anchors[$slug.ToLowerInvariant()] = $true
            if (-not [string]::IsNullOrWhiteSpace($anchorNamespace)) {
                $anchors[("$anchorNamespace-$slug").ToLowerInvariant()] = $true
            }
        }

        foreach ($match in $script:HtmlAnchorPattern.Matches($line.Text)) {
            $anchors[$match.Groups['id'].Value.ToLowerInvariant()] = $true
        }
        foreach ($match in $script:AttributeAnchorPattern.Matches($line.Text)) {
            $anchors[$match.Groups['id'].Value.ToLowerInvariant()] = $true
        }
    }

    $script:AnchorCache[$Document.FilePath] = $anchors
    return $anchors
}

function Test-MarkdownFragment {
    param(
        [Parameter(Mandatory = $true)][string]$SourceFile,
        [Parameter(Mandatory = $true)][int]$LineNumber,
        [Parameter(Mandatory = $true)][string]$TargetFile,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Fragment
    )

    if ([string]::IsNullOrWhiteSpace($Fragment) -or
        [System.IO.Path]::GetExtension($TargetFile) -notmatch '(?i)^\.md$' -or
        -not [System.IO.File]::Exists($TargetFile)) {
        return
    }

    try {
        $decodedFragment = [System.Uri]::UnescapeDataString($Fragment).Trim()
    }
    catch {
        Add-Failure ("{0}:{1}: invalid percent-encoding in fragment '#{2}'" -f (Get-DisplayPath $SourceFile), $LineNumber, $Fragment)
        return
    }
    if ([string]::IsNullOrWhiteSpace($decodedFragment)) {
        return
    }

    $targetDocument = Read-MarkdownDocument $TargetFile
    $targetAnchors = Get-MarkdownAnchorMap -Document $targetDocument
    $candidateKeys = @(
        $decodedFragment.ToLowerInvariant(),
        (Get-AnchorSlug -Text $decodedFragment).ToLowerInvariant()
    ) | Select-Object -Unique
    foreach ($candidateKey in $candidateKeys) {
        if ($targetAnchors.ContainsKey($candidateKey)) {
            return
        }
    }

    Add-Failure ("{0}:{1}: unresolved Markdown fragment '#{2}' in '{3}'" -f
        (Get-DisplayPath $SourceFile),
        $LineNumber,
        $Fragment,
        (Get-DisplayPath $TargetFile))
}

function Split-MarkdownTableRow {
    param([string]$Line)

    $body = $Line.Trim()
    if ($body.StartsWith('|')) {
        $body = $body.Substring(1)
    }
    if ($body.EndsWith('|')) {
        $body = $body.Substring(0, $body.Length - 1)
    }

    return @([regex]::Split($body, '(?<!\\)\|') | ForEach-Object { $_.Trim() })
}

function Test-RegisterTableShape {
    param([string]$FilePath)

    $document = Read-MarkdownDocument $FilePath
    $lines = $document.Lines

    for ($index = 0; $index -lt ($lines.Count - 1); $index++) {
        if (-not $lines[$index].TrimStart().StartsWith('|')) {
            continue
        }

        $headerCells = Split-MarkdownTableRow $lines[$index]
        $separatorCells = Split-MarkdownTableRow $lines[$index + 1]
        $isSeparator = $separatorCells.Count -gt 0
        foreach ($cell in $separatorCells) {
            if ($cell -notmatch '^:?-{3,}:?$') {
                $isSeparator = $false
                break
            }
        }

        if (-not $isSeparator) {
            continue
        }

        $script:TableCount++
        if ($separatorCells.Count -ne $headerCells.Count) {
            Add-Failure ("{0}:{1}: table separator has {2} cells; header has {3}" -f (Get-DisplayPath $FilePath), ($index + 2), $separatorCells.Count, $headerCells.Count)
        }

        $rowIndex = $index + 2
        while ($rowIndex -lt $lines.Count -and $lines[$rowIndex].TrimStart().StartsWith('|')) {
            $cells = Split-MarkdownTableRow $lines[$rowIndex]
            if ($cells.Count -ne $headerCells.Count) {
                Add-Failure ("{0}:{1}: table row has {2} cells; expected {3}" -f (Get-DisplayPath $FilePath), ($rowIndex + 1), $cells.Count, $headerCells.Count)
            }
            $rowIndex++
        }

        $index = $rowIndex - 1
    }
}

function Get-DefinitionIds {
    param(
        [string]$FilePath,
        [string]$Prefix
    )

    $document = Read-MarkdownDocument $FilePath
    $ids = New-Object System.Collections.ArrayList
    $pattern = '^\|\s*(?<id>' + [regex]::Escape($Prefix) + '-\d{3})\s*\|'
    $possiblePattern = '^\|\s*' + [regex]::Escape($Prefix) + '[^|]*\|'

    foreach ($line in $document.Outside) {
        $match = [regex]::Match($line.Text, $pattern)
        if ($match.Success) {
            [void]$ids.Add($match.Groups['id'].Value.ToUpperInvariant())
        }
        elseif ($line.Text -match $possiblePattern) {
            $firstCell = (Split-MarkdownTableRow $line.Text)[0]
            if ($firstCell -notmatch '(?i)\bID$') {
                Add-Failure ("{0}:{1}: malformed {2} definition ID" -f (Get-DisplayPath $FilePath), $line.Number, $Prefix)
            }
        }
    }

    $duplicates = @($ids | Group-Object | Where-Object { $_.Count -gt 1 })
    foreach ($duplicate in $duplicates) {
        Add-Failure ("{0}: duplicate {1} definition {2} ({3} rows)" -f (Get-DisplayPath $FilePath), $Prefix, $duplicate.Name, $duplicate.Count)
    }

    if ($ids.Count -eq 0) {
        Add-Failure ("{0}: no {1} definitions found" -f (Get-DisplayPath $FilePath), $Prefix)
    }

    return @($ids.ToArray())
}

function Test-GovernanceReferences {
    param(
        [Parameter(Mandatory = $true)][object[]]$Documents,
        [Parameter(Mandatory = $true)][hashtable]$Definitions
    )

    $pattern = [regex]::new(
        '(?<![A-Za-z0-9-])(?<id>(?:C|G|D|V)-\d{3}|CFG-[A-Z0-9]+-\d{3})(?![A-Za-z0-9-])',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
    foreach ($document in $Documents) {
        foreach ($line in $document.Outside) {
            foreach ($match in $pattern.Matches($line.Text)) {
                $id = $match.Groups['id'].Value.ToUpperInvariant()
                if (-not $Definitions.ContainsKey($id)) {
                    Add-Failure ("{0}:{1}: governance reference {2} is not defined" -f
                        (Get-DisplayPath $document.FilePath), $line.Number, $id)
                }
            }
        }
    }
}

function Test-RelativeTarget {
    param(
        [string]$SourceFile,
        [int]$LineNumber,
        [string]$RawTarget
    )

    $target = $RawTarget.Trim()
    if ($target.StartsWith('<') -and $target.EndsWith('>')) {
        $target = $target.Substring(1, $target.Length - 2)
    }
    if ([string]::IsNullOrWhiteSpace($target)) {
        return
    }
    if ($target -match '^[A-Za-z][A-Za-z0-9+.-]*:' -or $target.StartsWith('//')) {
        return
    }
    if ([System.IO.Path]::IsPathRooted($target)) {
        return
    }

    $fragment = $null
    $pathAndQuery = $target
    $hashIndex = $target.IndexOf('#')
    if ($hashIndex -ge 0) {
        $pathAndQuery = $target.Substring(0, $hashIndex)
        $fragment = $target.Substring($hashIndex + 1)
    }

    $pathOnly = $pathAndQuery.Split('?')[0]
    if ([string]::IsNullOrWhiteSpace($pathOnly)) {
        if ($null -ne $fragment) {
            $script:RelativeLinkCount++
            Test-MarkdownFragment -SourceFile $SourceFile -LineNumber $LineNumber `
                -TargetFile $SourceFile -Fragment $fragment
        }
        return
    }

    try {
        $decodedPath = [System.Uri]::UnescapeDataString($pathOnly)
        $candidate = [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $SourceFile) $decodedPath))
    }
    catch {
        Add-Failure ("{0}:{1}: invalid relative link target '{2}'" -f (Get-DisplayPath $SourceFile), $LineNumber, $target)
        return
    }

    $script:RelativeLinkCount++
    if (-not (Test-Path -LiteralPath $candidate)) {
        Add-Failure ("{0}:{1}: missing relative link target '{2}'" -f (Get-DisplayPath $SourceFile), $LineNumber, $target)
        return
    }
    if ($null -ne $fragment) {
        Test-MarkdownFragment -SourceFile $SourceFile -LineNumber $LineNumber `
            -TargetFile $candidate -Fragment $fragment
    }
}

function Test-RelativeLinks {
    param([object[]]$Documents)

    foreach ($document in $Documents) {
        foreach ($line in $document.Outside) {
            foreach ($match in $script:InlineLinkPattern.Matches($line.Text)) {
                Test-RelativeTarget -SourceFile $document.FilePath -LineNumber $line.Number -RawTarget $match.Groups['target'].Value
            }
            foreach ($match in $script:ReferenceLinkPattern.Matches($line.Text)) {
                Test-RelativeTarget -SourceFile $document.FilePath -LineNumber $line.Number -RawTarget $match.Groups['target'].Value
            }
            foreach ($match in $script:HtmlLinkPattern.Matches($line.Text)) {
                Test-RelativeTarget -SourceFile $document.FilePath -LineNumber $line.Number -RawTarget $match.Groups['target'].Value
            }
        }
    }
}

function Test-Mojibake {
    param([object[]]$Documents)

    # Common signatures of UTF-8 bytes decoded as Windows-1252/Latin-1, plus U+FFFD.
    $pattern = [regex]'(?:[\u00c2\u00c3\u00c4\u00c6][\u0080-\u00bf\u2010-\u203a]|\u00e1[\u00a0-\u00bf\u2010-\u203a]|\u00e2[\u0080-\u00bf\u2010-\u203a]|\u00ef\u00bb\u00bf|\ufffd)'

    foreach ($document in $Documents) {
        for ($lineIndex = 0; $lineIndex -lt $document.Lines.Count; $lineIndex++) {
            $match = $pattern.Match($document.Lines[$lineIndex])
            if ($match.Success) {
                $codePoints = @($match.Value.ToCharArray() | ForEach-Object { 'U+{0:X4}' -f [int]$_ }) -join ' '
                Add-Failure ("{0}:{1}: possible mojibake signature ({2})" -f (Get-DisplayPath $document.FilePath), ($lineIndex + 1), $codePoints)
                break
            }
        }
    }
}

function Test-ChapterContract {
    param([System.IO.FileInfo[]]$GuideFiles)

    $contractEscaped = @(
        'M\u1ee5c ti\u00eau',
        'Ph\u1ea1m vi v\u00e0 gi\u1ea3 \u0111\u1ecbnh',
        'C\u01a1 ch\u1ebf ho\u1ea1t \u0111\u1ed9ng',
        'Ki\u1ebfn tr\u00fac/lu\u1ed3ng d\u1eef li\u1ec7u',
        'H\u01b0\u1edbng d\u1eabn ho\u1eb7c v\u00ed d\u1ee5 tri\u1ec3n khai',
        'Quy\u1ebft \u0111\u1ecbnh v\u00e0 trade-off',
        'Security v\u00e0 operations implications',
        'Failure modes v\u00e0 troubleshooting',
        'Checklist x\u00e1c nh\u1eadn',
        'Gi\u1edbi h\u1ea1n/version caveats',
        'Ngu\u1ed3n tham kh\u1ea3o'
    )
    $contract = @($contractEscaped | ForEach-Object { [regex]::Unescape($_) })
    $chapterMap = @{}

    foreach ($file in $GuideFiles) {
        if ($file.Name -match '^(?<number>0[0-9]|1[0-9])-.*\.md$') {
            $number = $Matches['number']
            if (-not $chapterMap.ContainsKey($number)) {
                $chapterMap[$number] = New-Object System.Collections.ArrayList
            }
            [void]$chapterMap[$number].Add($file)
        }
    }

    for ($chapterNumber = 0; $chapterNumber -le 19; $chapterNumber++) {
        $number = '{0:D2}' -f $chapterNumber
        if (-not $chapterMap.ContainsKey($number)) {
            Add-Failure ("main chapter {0}: file not found" -f $number)
            continue
        }
        if ($chapterMap[$number].Count -ne 1) {
            Add-Failure ("main chapter {0}: expected one file, found {1}" -f $number, $chapterMap[$number].Count)
            continue
        }

        $file = $chapterMap[$number][0]
        $document = Read-MarkdownDocument $file.FullName
        $h1 = @($document.Outside | Where-Object { $_.Text -match '^#(?!#)\s+\S' })
        if ($h1.Count -ne 1) {
            Add-Failure ("{0}: expected exactly one H1, found {1}" -f (Get-DisplayPath $file.FullName), $h1.Count)
        }
        elseif ($h1[0].Text -notmatch ('^#\s+' + [regex]::Escape($number) + '\.')) {
            Add-Failure ("{0}:{1}: H1 does not start with chapter number {2}" -f (Get-DisplayPath $file.FullName), $h1[0].Number, $number)
        }

        $h2 = New-Object System.Collections.ArrayList
        foreach ($line in $document.Outside) {
            $headingMatch = [regex]::Match($line.Text, '^##(?!#)\s+(?<title>.*?)\s*#*\s*$')
            if ($headingMatch.Success) {
                [void]$h2.Add($headingMatch.Groups['title'].Value.Trim())
            }
        }

        if ($h2.Count -ne $contract.Count) {
            Add-Failure ("{0}: expected {1} H2 headings, found {2}" -f (Get-DisplayPath $file.FullName), $contract.Count, $h2.Count)
            continue
        }

        for ($headingIndex = 0; $headingIndex -lt $contract.Count; $headingIndex++) {
            if ($h2[$headingIndex] -cne $contract[$headingIndex]) {
                Add-Failure ("{0}: H2 contract mismatch at position {1}; expected '{2}', found '{3}'" -f (Get-DisplayPath $file.FullName), ($headingIndex + 1), $contract[$headingIndex], $h2[$headingIndex])
            }
        }
    }

    return $chapterMap.Count
}

function Test-MermaidBlocks {
    param(
        [object[]]$Documents,
        [int]$ExpectedCount,
        [string]$ScopeName
    )

    $mermaidBlocks = New-Object System.Collections.ArrayList
    $types = @{}

    foreach ($document in $Documents) {
        foreach ($block in $document.Blocks) {
            if ($block.Info.ToLowerInvariant() -eq 'mermaid') {
                [void]$mermaidBlocks.Add($block)
            }
        }
    }

    if ($mermaidBlocks.Count -ne $ExpectedCount) {
        Add-Failure ("{0}: expected {1} Mermaid blocks, found {2}" -f $ScopeName, $ExpectedCount, $mermaidBlocks.Count)
    }

    foreach ($block in $mermaidBlocks) {
        $firstLine = $null
        foreach ($contentLine in $block.Content) {
            if (-not [string]::IsNullOrWhiteSpace($contentLine)) {
                $firstLine = $contentLine.Trim()
                break
            }
        }

        if ($null -eq $firstLine) {
            Add-Failure ("{0}:{1}: empty Mermaid block" -f (Get-DisplayPath $block.FilePath), $block.StartLine)
            continue
        }

        $type = $null
        if ($firstLine -match '^flowchart\s+(LR|RL|TB|BT|TD)\s*$') {
            $type = 'flowchart'
        }
        elseif ($firstLine -match '^sequenceDiagram\s*$') {
            $type = 'sequenceDiagram'
        }
        elseif ($firstLine -match '^stateDiagram-v2\s*$') {
            $type = 'stateDiagram-v2'
        }
        else {
            Add-Failure ("{0}:{1}: Mermaid block must start with basic flowchart, sequenceDiagram, or stateDiagram-v2 syntax; found '{2}'" -f (Get-DisplayPath $block.FilePath), ($block.StartLine + 1), $firstLine)
            continue
        }

        if (-not $types.ContainsKey($type)) {
            $types[$type] = 0
        }
        $types[$type]++
    }

    return [pscustomobject]@{
        Count = $mermaidBlocks.Count
        Types = $types
    }
}

function Get-MetadataScalar {
    param([AllowEmptyString()][string]$RawValue)

    $value = $RawValue.Trim()
    if ($value.Length -ge 2) {
        $first = $value.Substring(0, 1)
        $last = $value.Substring($value.Length - 1, 1)
        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            return $value.Substring(1, $value.Length - 2)
        }
    }
    return $value
}

function Get-AssembledMetadata {
    param([Parameter(Mandatory = $true)]$Document)

    $metadata = @{}
    if ($Document.Lines.Count -lt 3 -or $Document.Lines[0].Trim() -ne '---') {
        Add-Failure ("{0}: assembled final must start with YAML front matter" -f (Get-DisplayPath $Document.FilePath))
        return $metadata
    }

    $closingIndex = -1
    for ($index = 1; $index -lt $Document.Lines.Count; $index++) {
        if ($Document.Lines[$index].Trim() -eq '---') {
            $closingIndex = $index
            break
        }

        $line = $Document.Lines[$index]
        if ([string]::IsNullOrWhiteSpace($line) -or $line.TrimStart().StartsWith('#')) {
            continue
        }
        $match = [regex]::Match($line, '^(?<key>[A-Za-z][A-Za-z0-9_]*):\s*(?<value>.*)$')
        if (-not $match.Success) {
            Add-Failure ("{0}:{1}: unsupported assembled metadata syntax" -f (Get-DisplayPath $Document.FilePath), ($index + 1))
            continue
        }

        $key = $match.Groups['key'].Value.ToLowerInvariant()
        if ($metadata.ContainsKey($key)) {
            Add-Failure ("{0}:{1}: duplicate assembled metadata key '{2}'" -f (Get-DisplayPath $Document.FilePath), ($index + 1), $key)
            continue
        }
        $metadata[$key] = Get-MetadataScalar -RawValue $match.Groups['value'].Value
    }

    if ($closingIndex -lt 0) {
        Add-Failure ("{0}: assembled final has unclosed YAML front matter" -f (Get-DisplayPath $Document.FilePath))
        return $metadata
    }

    $requiredKeys = @(
        'title',
        'document_version',
        'document_status',
        'release_class',
        'deployment_validation_status',
        'baseline_product',
        'baseline_commit',
        'docs_snapshot',
        'baseline_lock_date',
        'version_drift_checked_at',
        'build_date',
        'source_tree_commit',
        'source_tree_dirty',
        'build_schema',
        'build_id',
        'build_manifest',
        'source_count'
    )
    foreach ($key in $requiredKeys) {
        if (-not $metadata.ContainsKey($key) -or [string]::IsNullOrWhiteSpace([string]$metadata[$key])) {
            Add-Failure ("{0}: assembled metadata is missing required key '{1}'" -f (Get-DisplayPath $Document.FilePath), $key)
        }
    }

    if ($metadata.ContainsKey('source_count') -and [string]$metadata['source_count'] -ne '26') {
        Add-Failure ("{0}: assembled metadata source_count must be 26; found '{1}'" -f (Get-DisplayPath $Document.FilePath), $metadata['source_count'])
    }
    if ($metadata.ContainsKey('build_schema') -and [string]$metadata['build_schema'] -ne '3') {
        Add-Failure ("{0}: unsupported assembled build_schema '{1}'" -f (Get-DisplayPath $Document.FilePath), $metadata['build_schema'])
    }
    if ($metadata.ContainsKey('build_id') -and [string]$metadata['build_id'] -notmatch '^sha256:[0-9a-f]{64}$') {
        Add-Failure ("{0}: assembled metadata build_id must be a lowercase SHA-256 identifier" -f (Get-DisplayPath $Document.FilePath))
    }
    foreach ($shaKey in @('baseline_commit', 'docs_snapshot')) {
        if ($metadata.ContainsKey($shaKey) -and [string]$metadata[$shaKey] -notmatch '^[0-9a-fA-F]{40}$') {
            Add-Failure ("{0}: assembled metadata {1} must be a full 40-character SHA" -f (Get-DisplayPath $Document.FilePath), $shaKey)
        }
    }
    if ($metadata.ContainsKey('source_tree_commit') -and
        [string]$metadata['source_tree_commit'] -notmatch '^(?:unknown|[0-9a-fA-F]{40})$') {
        Add-Failure ("{0}: assembled metadata source_tree_commit must be 'unknown' or a full SHA" -f (Get-DisplayPath $Document.FilePath))
    }
    if ($metadata.ContainsKey('source_tree_dirty') -and
        [string]$metadata['source_tree_dirty'] -notmatch '^(?:true|false|unknown)$') {
        Add-Failure ("{0}: assembled metadata source_tree_dirty must be true, false, or unknown" -f (Get-DisplayPath $Document.FilePath))
    }
    foreach ($dateKey in @('baseline_lock_date', 'version_drift_checked_at', 'build_date')) {
        if ($metadata.ContainsKey($dateKey) -and [string]$metadata[$dateKey] -notmatch '^\d{4}-\d{2}-\d{2}$') {
            Add-Failure ("{0}: assembled metadata {1} must use YYYY-MM-DD" -f (Get-DisplayPath $Document.FilePath), $dateKey)
        }
    }
    if ($metadata.ContainsKey('document_status') -and
        [string]$metadata['document_status'] -notin @('working-draft', 'review-candidate', 'review-ready', 'final')) {
        Add-Failure ("{0}: invalid assembled document_status '{1}'" -f (Get-DisplayPath $Document.FilePath), $metadata['document_status'])
    }
    if ($metadata.ContainsKey('release_class') -and
        [string]$metadata['release_class'] -notin @('core-guide', 'deployment-profile')) {
        Add-Failure ("{0}: invalid assembled release_class '{1}'" -f (Get-DisplayPath $Document.FilePath), $metadata['release_class'])
    }
    if ($metadata.ContainsKey('deployment_validation_status') -and
        [string]$metadata['deployment_validation_status'] -notin @('not-validated', 'partially-validated', 'deployment-validated')) {
        Add-Failure ("{0}: invalid assembled deployment_validation_status '{1}'" -f (Get-DisplayPath $Document.FilePath), $metadata['deployment_validation_status'])
    }
    if ($metadata.ContainsKey('build_manifest')) {
        $manifestValue = ([string]$metadata['build_manifest']).Replace('\', '/')
        if ([System.IO.Path]::IsPathRooted($manifestValue) -or $manifestValue -match '(^|/)\.\.(/|$)') {
            Add-Failure ("{0}: assembled build_manifest must be repository-relative" -f (Get-DisplayPath $Document.FilePath))
        }
        else {
            $manifestCandidate = [System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot $manifestValue))
            if (-not [System.IO.File]::Exists($manifestCandidate)) {
                Add-Failure ("{0}: assembled build_manifest does not exist: '{1}'" -f (Get-DisplayPath $Document.FilePath), $manifestValue)
            }
        }
    }

    return $metadata
}

function Get-HeadingExplicitAnchorId {
    param(
        [Parameter(Mandatory = $true)]$Document,
        [Parameter(Mandatory = $true)][int]$OutsideIndex
    )

    $line = $Document.Outside[$OutsideIndex]
    $inlineMatch = $script:AttributeAnchorPattern.Match($line.Text)
    if ($inlineMatch.Success) {
        return $inlineMatch.Groups['id'].Value
    }

    $previousIndex = $OutsideIndex - 1
    while ($previousIndex -ge 0 -and [string]::IsNullOrWhiteSpace($Document.Outside[$previousIndex].Text)) {
        $previousIndex--
    }
    if ($previousIndex -ge 0) {
        $precedingMatch = $script:HtmlAnchorPattern.Match($Document.Outside[$previousIndex].Text)
        if ($precedingMatch.Success) {
            return $precedingMatch.Groups['id'].Value
        }
    }
    return $null
}

function Test-AssembledLinks {
    param(
        [Parameter(Mandatory = $true)]$Document,
        [Parameter(Mandatory = $true)][hashtable]$ExplicitAnchors
    )

    foreach ($line in $Document.Outside) {
        $targets = New-Object System.Collections.ArrayList
        foreach ($pattern in @($script:InlineLinkPattern, $script:ReferenceLinkPattern, $script:HtmlLinkPattern)) {
            foreach ($match in $pattern.Matches($line.Text)) {
                [void]$targets.Add($match.Groups['target'].Value)
            }
        }

        foreach ($rawTarget in $targets) {
            $target = ([string]$rawTarget).Trim()
            if ($target.StartsWith('<') -and $target.EndsWith('>')) {
                $target = $target.Substring(1, $target.Length - 2)
            }
            if ([string]::IsNullOrWhiteSpace($target) -or
                $target -match '^[A-Za-z][A-Za-z0-9+.-]*:' -or
                $target.StartsWith('//')) {
                continue
            }

            $fragment = $null
            $pathAndQuery = $target
            $hashIndex = $target.IndexOf('#')
            if ($hashIndex -ge 0) {
                $pathAndQuery = $target.Substring(0, $hashIndex)
                $fragment = $target.Substring($hashIndex + 1)
            }
            $pathOnly = $pathAndQuery.Split('?')[0]
            if ($pathOnly -match '(?i)\.md$') {
                Add-Failure ("{0}:{1}: assembled final must not contain a local Markdown link '{2}'" -f
                    (Get-DisplayPath $Document.FilePath), $line.Number, $target)
            }

            if ([string]::IsNullOrWhiteSpace($pathOnly) -and $null -ne $fragment -and
                -not [string]::IsNullOrWhiteSpace($fragment)) {
                try {
                    $decodedFragment = [System.Uri]::UnescapeDataString($fragment).Trim().ToLowerInvariant()
                }
                catch {
                    Add-Failure ("{0}:{1}: invalid assembled fragment '#{2}'" -f (Get-DisplayPath $Document.FilePath), $line.Number, $fragment)
                    continue
                }
                if (-not $ExplicitAnchors.ContainsKey($decodedFragment)) {
                    Add-Failure ("{0}:{1}: assembled internal link targets missing explicit anchor '#{2}'" -f
                        (Get-DisplayPath $Document.FilePath), $line.Number, $fragment)
                }
            }
        }
    }
}

function Test-AssembledFinal {
    param([string]$FinalPath)

    if ([string]::IsNullOrWhiteSpace($FinalPath)) {
        return $null
    }

    if (-not [System.IO.Path]::IsPathRooted($FinalPath)) {
        $FinalPath = Join-Path $script:RepoRoot $FinalPath
    }
    $FinalPath = [System.IO.Path]::GetFullPath($FinalPath)
    if (-not (Test-Path -LiteralPath $FinalPath -PathType Leaf)) {
        Add-Failure ("assembled final not found: {0}" -f (Get-DisplayPath $FinalPath))
        return $null
    }

    $document = Read-MarkdownDocument $FinalPath
    $metadata = Get-AssembledMetadata -Document $document
    $h1 = @($document.Outside | Where-Object { $_.Text -match '^#(?!#)\s+\S' })
    if ($h1.Count -ne 1) {
        Add-Failure ("{0}: assembled final must contain exactly one H1; found {1}" -f (Get-DisplayPath $FinalPath), $h1.Count)
    }

    $anchorOccurrences = New-Object System.Collections.ArrayList
    $namespacePattern = [regex]'^(?:(?:doc|front)(?:-[a-z0-9]+)+|part-?[1-3](?:-[a-z0-9]+)*|ch(?:apter)?-?(?:0[0-9]|1[0-9])(?:-[a-z0-9]+)*|app(?:endix)?-?[a-f](?:-[a-z0-9]+)*)$'

    foreach ($line in $document.Outside) {
        foreach ($match in $script:HtmlAnchorPattern.Matches($line.Text)) {
            [void]$anchorOccurrences.Add([pscustomobject]@{ Id = $match.Groups['id'].Value; Line = $line.Number })
        }
        foreach ($match in $script:AttributeAnchorPattern.Matches($line.Text)) {
            [void]$anchorOccurrences.Add([pscustomobject]@{ Id = $match.Groups['id'].Value; Line = $line.Number })
        }
    }

    foreach ($duplicate in @($anchorOccurrences | Group-Object { $_.Id.ToLowerInvariant() } | Where-Object { $_.Count -gt 1 })) {
        $locations = @($duplicate.Group | ForEach-Object { $_.Line }) -join ', '
        Add-Failure ("{0}: duplicate explicit anchor '{1}' at lines {2}" -f (Get-DisplayPath $FinalPath), $duplicate.Group[0].Id, $locations)
    }

    foreach ($anchor in $anchorOccurrences) {
        if (-not $namespacePattern.IsMatch($anchor.Id)) {
            Add-Failure ("{0}:{1}: explicit anchor '{2}' is not namespaced (expected front/doc, part, ch00-ch19, or appendix/app prefix)" -f (Get-DisplayPath $FinalPath), $anchor.Line, $anchor.Id)
        }
    }

    $explicitAnchors = @{}
    foreach ($anchor in $anchorOccurrences) {
        $explicitAnchors[$anchor.Id.ToLowerInvariant()] = $true
    }
    Test-AssembledLinks -Document $document -ExplicitAnchors $explicitAnchors

    $expectedRootKeys = @()
    0..19 | ForEach-Object { $expectedRootKeys += ('ch{0:d2}' -f $_) }
    @('a', 'b', 'c', 'd', 'e', 'f') | ForEach-Object { $expectedRootKeys += "app$_" }
    $rootAnchors = @{}
    $rootOrder = New-Object System.Collections.ArrayList
    $tocOutsideIndex = -1

    for ($index = 0; $index -lt $document.Outside.Count; $index++) {
        $line = $document.Outside[$index]
        if ($line.Text -notmatch '^#{2,6}\s+\S') {
            continue
        }

        $headingAnchorId = Get-HeadingExplicitAnchorId -Document $document -OutsideIndex $index
        if ([string]::IsNullOrWhiteSpace($headingAnchorId)) {
            Add-Failure ("{0}:{1}: assembled H2-H6 heading lacks an explicit namespaced anchor" -f (Get-DisplayPath $FinalPath), $line.Number)
            continue
        }

        if ($line.Text -notmatch '^##(?!#)\s+\S') {
            continue
        }

        $normalizedHeadingAnchor = $headingAnchorId.ToLowerInvariant()
        if ($normalizedHeadingAnchor -eq 'front-toc') {
            if ($tocOutsideIndex -ge 0) {
                Add-Failure ("{0}:{1}: assembled final contains more than one front TOC heading" -f (Get-DisplayPath $FinalPath), $line.Number)
            }
            else {
                $tocOutsideIndex = $index
            }
            continue
        }

        $rootMatch = [regex]::Match(
            $normalizedHeadingAnchor,
            '^(?<key>ch(?:0[0-9]|1[0-9])|app[a-f])(?:-[a-z0-9]+)+$'
        )
        if (-not $rootMatch.Success) {
            Add-Failure ("{0}:{1}: unexpected assembled H2 root anchor '{2}'" -f (Get-DisplayPath $FinalPath), $line.Number, $headingAnchorId)
            continue
        }

        $rootKey = $rootMatch.Groups['key'].Value
        [void]$rootOrder.Add($rootKey)
        if ($rootAnchors.ContainsKey($rootKey)) {
            Add-Failure ("{0}:{1}: duplicate assembled source root '{2}'" -f (Get-DisplayPath $FinalPath), $line.Number, $rootKey)
        }
        else {
            $rootAnchors[$rootKey] = $normalizedHeadingAnchor
        }
    }

    foreach ($rootKey in $expectedRootKeys) {
        if (-not $rootAnchors.ContainsKey($rootKey)) {
            Add-Failure ("{0}: assembled final is missing source root '{1}'" -f (Get-DisplayPath $FinalPath), $rootKey)
        }
    }
    if ($rootOrder.Count -ne $expectedRootKeys.Count) {
        Add-Failure ("{0}: assembled final must contain exactly 26 ordered source roots; found {1}" -f (Get-DisplayPath $FinalPath), $rootOrder.Count)
    }
    else {
        for ($rootIndex = 0; $rootIndex -lt $expectedRootKeys.Count; $rootIndex++) {
            if ([string]$rootOrder[$rootIndex] -cne [string]$expectedRootKeys[$rootIndex]) {
                Add-Failure ("{0}: assembled source root order mismatch at position {1}; expected '{2}', found '{3}'" -f
                    (Get-DisplayPath $FinalPath),
                    ($rootIndex + 1),
                    $expectedRootKeys[$rootIndex],
                    $rootOrder[$rootIndex])
                break
            }
        }
    }

    if ($tocOutsideIndex -lt 0) {
        Add-Failure ("{0}: assembled final is missing the front TOC heading" -f (Get-DisplayPath $FinalPath))
    }
    else {
        $tocTargets = New-Object System.Collections.ArrayList
        for ($tocIndex = $tocOutsideIndex + 1; $tocIndex -lt $document.Outside.Count; $tocIndex++) {
            $tocLine = $document.Outside[$tocIndex]
            if ($tocLine.Text.Trim() -eq '---') {
                break
            }
            foreach ($match in $script:InlineLinkPattern.Matches($tocLine.Text)) {
                $target = $match.Groups['target'].Value.Trim()
                if ($target.StartsWith('#') -and $target.Length -gt 1) {
                    try {
                        [void]$tocTargets.Add(
                            [System.Uri]::UnescapeDataString($target.Substring(1)).Trim().ToLowerInvariant()
                        )
                    }
                    catch {
                        Add-Failure ("{0}:{1}: invalid percent-encoding in TOC target '{2}'" -f (Get-DisplayPath $FinalPath), $tocLine.Number, $target)
                    }
                }
            }
        }

        $expectedTocTargets = @(
            $expectedRootKeys |
                Where-Object { $rootAnchors.ContainsKey($_) } |
                ForEach-Object { $rootAnchors[$_] }
        )
        if ($tocTargets.Count -ne $expectedRootKeys.Count) {
            Add-Failure ("{0}: front TOC must contain exactly 26 internal source links; found {1}" -f (Get-DisplayPath $FinalPath), $tocTargets.Count)
        }
        elseif ($expectedTocTargets.Count -eq $expectedRootKeys.Count) {
            for ($tocTargetIndex = 0; $tocTargetIndex -lt $expectedTocTargets.Count; $tocTargetIndex++) {
                if ([string]$tocTargets[$tocTargetIndex] -cne [string]$expectedTocTargets[$tocTargetIndex]) {
                    Add-Failure ("{0}: front TOC target mismatch at position {1}; expected '#{2}', found '#{3}'" -f
                        (Get-DisplayPath $FinalPath),
                        ($tocTargetIndex + 1),
                        $expectedTocTargets[$tocTargetIndex],
                        $tocTargets[$tocTargetIndex])
                    break
                }
            }
        }
    }

    $mermaid = Test-MermaidBlocks -Documents @($document) -ExpectedCount 29 -ScopeName 'assembled final'
    return [pscustomobject]@{
        FilePath = $FinalPath
        AnchorCount = $anchorOccurrences.Count
        Mermaid = $mermaid
        Metadata = $metadata
    }
}

try {
    foreach ($requiredDirectory in @($script:GuideRoot, $script:WorkingRoot)) {
        if (-not (Test-Path -LiteralPath $requiredDirectory -PathType Container)) {
            Add-Failure ("required directory not found: {0}" -f (Get-DisplayPath $requiredDirectory))
        }
    }

    $markdownFiles = @(
        Get-ChildItem -LiteralPath $script:RepoRoot -Recurse -File -Filter '*.md' |
            Where-Object { $_.FullName -notmatch '[\\/](?:\.git|node_modules)[\\/]' } |
            Sort-Object FullName
    )
    if ($markdownFiles.Count -eq 0) {
        Add-Failure 'no Markdown files found'
    }

    $documents = @($markdownFiles | ForEach-Object { Read-MarkdownDocument $_.FullName })
    Test-Mojibake -Documents $documents
    Test-RelativeLinks -Documents $documents

    $registerFiles = @(
        'source-register.md',
        'claim-evidence-matrix.md',
        'assumptions-and-gaps.md',
        'decision-log.md',
        'validation-log.md',
        'chapter-status.md'
    )
    foreach ($registerName in $registerFiles) {
        $registerPath = Join-Path $script:WorkingRoot $registerName
        if (-not (Test-Path -LiteralPath $registerPath -PathType Leaf)) {
            Add-Failure ("required register not found: {0}" -f (Get-DisplayPath $registerPath))
            continue
        }
        Test-RegisterTableShape $registerPath
    }

    $sourceRegisterPath = Join-Path $script:WorkingRoot 'source-register.md'
    $sourceDocument = Read-MarkdownDocument $sourceRegisterPath
    $sourceRows = New-Object System.Collections.ArrayList
    foreach ($line in $sourceDocument.Outside) {
        if ($line.Text -match '^\|\s*S[^|]*\|') {
            $cells = Split-MarkdownTableRow $line.Text
            if ($cells.Count -gt 0 -and $cells[0] -notmatch '^Source ID$' -and $cells[0] -notmatch '^S-\d{3}$') {
                Add-Failure ("{0}:{1}: malformed source definition ID '{2}'" -f (Get-DisplayPath $sourceRegisterPath), $line.Number, $cells[0])
            }
            elseif ($cells.Count -ge 3 -and $cells[0] -match '^S-\d{3}$') {
                [void]$sourceRows.Add([pscustomobject]@{
                    Id = $cells[0].ToUpperInvariant()
                    Url = $cells[2]
                    Line = $line.Number
                })
            }
        }
    }

    foreach ($duplicate in @($sourceRows | Group-Object Id | Where-Object { $_.Count -gt 1 })) {
        Add-Failure ("{0}: duplicate source ID {1} ({2} rows)" -f (Get-DisplayPath $sourceRegisterPath), $duplicate.Name, $duplicate.Count)
    }
    foreach ($duplicate in @($sourceRows | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Url) } | Group-Object Url | Where-Object { $_.Count -gt 1 })) {
        Add-Failure ("{0}: duplicate source URL '{1}' used by {2}" -f (Get-DisplayPath $sourceRegisterPath), $duplicate.Name, (@($duplicate.Group | ForEach-Object { $_.Id }) -join ', '))
    }

    $registeredSources = @{}
    foreach ($row in $sourceRows) {
        $registeredSources[$row.Id] = $true
    }
    $usedSources = @{}
    $guideUsedSources = @{}
    $referenceAppendixSources = @{}
    $guidePrefix = [System.IO.Path]::GetFullPath($script:GuideRoot).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $referenceAppendixPath = [System.IO.Path]::GetFullPath((Join-Path (Join-Path $script:GuideRoot 'appendices') 'e-references.md'))
    foreach ($document in $documents) {
        if ($document.FilePath -eq [System.IO.Path]::GetFullPath($sourceRegisterPath)) {
            continue
        }
        foreach ($line in $document.Outside) {
            foreach ($match in [regex]::Matches($line.Text, '\bS-\d{3}\b')) {
                $sourceId = $match.Value.ToUpperInvariant()
                $usedSources[$sourceId] = $true
                if ($document.FilePath.StartsWith($guidePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                    $guideUsedSources[$sourceId] = $true
                }
                if ($document.FilePath -eq $referenceAppendixPath) {
                    $referenceAppendixSources[$sourceId] = $true
                }
                if (-not $registeredSources.ContainsKey($sourceId)) {
                    Add-Failure ("{0}:{1}: source reference {2} is not defined in source-register.md" -f (Get-DisplayPath $document.FilePath), $line.Number, $sourceId)
                }
            }
        }
    }
    foreach ($sourceId in @($registeredSources.Keys | Sort-Object)) {
        if (-not $guideUsedSources.ContainsKey($sourceId)) {
            Add-Failure ("source coverage: {0} is registered but never referenced in docs/dify-technical-guide" -f $sourceId)
        }
        if (-not $referenceAppendixSources.ContainsKey($sourceId)) {
            Add-Failure ("reference coverage: {0} is missing from appendices/e-references.md" -f $sourceId)
        }
    }

    $claimIds = @(Get-DefinitionIds -FilePath (Join-Path $script:WorkingRoot 'claim-evidence-matrix.md') -Prefix 'C')
    $gapIds = @(Get-DefinitionIds -FilePath (Join-Path $script:WorkingRoot 'assumptions-and-gaps.md') -Prefix 'G')
    $decisionIds = @(Get-DefinitionIds -FilePath (Join-Path $script:WorkingRoot 'decision-log.md') -Prefix 'D')
    $validationIds = @(Get-DefinitionIds -FilePath (Join-Path $script:WorkingRoot 'validation-log.md') -Prefix 'V')

    $guideFiles = @(Get-ChildItem -LiteralPath $script:GuideRoot -Recurse -File -Filter '*.md' | Sort-Object FullName)
    $chapterCount = Test-ChapterContract -GuideFiles $guideFiles

    $controlIds = New-Object System.Collections.ArrayList
    foreach ($file in $guideFiles) {
        $document = Read-MarkdownDocument $file.FullName
        foreach ($line in $document.Outside) {
            $match = [regex]::Match($line.Text, '^\|\s*(?<id>CFG-[A-Z0-9]+-\d{3})\s*\|')
            if ($match.Success) {
                [void]$controlIds.Add($match.Groups['id'].Value.ToUpperInvariant())
            }
        }
    }
    foreach ($duplicate in @($controlIds | Group-Object | Where-Object { $_.Count -gt 1 })) {
        Add-Failure ("duplicate control definition {0} ({1} rows)" -f $duplicate.Name, $duplicate.Count)
    }
    if ($controlIds.Count -eq 0) {
        Add-Failure 'no CFG control definitions found'
    }

    $governanceDefinitions = @{}
    foreach ($definedId in @($claimIds + $gapIds + $decisionIds + $validationIds + @($controlIds.ToArray()))) {
        $governanceDefinitions[[string]$definedId] = $true
    }
    Test-GovernanceReferences -Documents $documents -Definitions $governanceDefinitions

    $guideDocuments = @($guideFiles | ForEach-Object { Read-MarkdownDocument $_.FullName })
    $guideMermaid = Test-MermaidBlocks -Documents $guideDocuments -ExpectedCount 29 -ScopeName 'guide source tree'
    $assembledResult = Test-AssembledFinal -FinalPath $Path

    $mermaidTypeSummary = @(
        $guideMermaid.Types.Keys |
            Sort-Object |
            ForEach-Object { '{0}={1}' -f $_, $guideMermaid.Types[$_] }
    ) -join ', '

    Write-Output ("Markdown QA summary")
    Write-Output ("  files={0}; register_tables={1}; relative_links={2}" -f $markdownFiles.Count, $script:TableCount, $script:RelativeLinkCount)
    $coveredSourceCount = @($registeredSources.Keys | Where-Object { $guideUsedSources.ContainsKey($_) }).Count
    $indexedSourceCount = @($registeredSources.Keys | Where-Object { $referenceAppendixSources.ContainsKey($_) }).Count
    Write-Output ("  sources={0}; guide_covered={1}; reference_indexed={2}" -f $sourceRows.Count, $coveredSourceCount, $indexedSourceCount)
    Write-Output ("  claims={0}; gaps={1}; decisions={2}; validations={3}" -f $claimIds.Count, $gapIds.Count, $decisionIds.Count, $validationIds.Count)
    Write-Output ("  chapters={0}; controls={1}" -f $chapterCount, $controlIds.Count)
    Write-Output ("  mermaid={0} ({1})" -f $guideMermaid.Count, $mermaidTypeSummary)
    if ($null -ne $assembledResult) {
        Write-Output ("  assembled={0}; anchors={1}; mermaid={2}" -f (Get-DisplayPath $assembledResult.FilePath), $assembledResult.AnchorCount, $assembledResult.Mermaid.Count)
    }

    if ($script:Failures.Count -gt 0) {
        Write-Output ("FAILED: {0} validation error(s)" -f $script:Failures.Count)
        foreach ($failure in $script:Failures) {
            Write-Output ("  - {0}" -f $failure)
        }
        exit 1
    }

    Write-Output 'PASS: Markdown static QA completed without errors.'
    exit 0
}
catch {
    Write-Output ("FAILED: validator crashed: {0}" -f $_.Exception.Message)
    Write-Output ("  at {0}" -f $_.ScriptStackTrace)
    exit 2
}
