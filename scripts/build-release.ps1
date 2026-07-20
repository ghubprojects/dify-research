[CmdletBinding()]
param(
    [string]$ManifestPath,
    [string]$OutputPath,
    [string]$DocumentVersion = '0.3.4-working-draft',
    [string]$BaselineVersion = '1.15.0',
    [string]$BaselineCommit = '3aa26fb6374bbd47e5469f7d7cc25f3e0075a60c',
    [string]$DocsSnapshot = '57a492d8063d1583c582b4c0444fb838c6dd3027',
    [string]$BaselineLockDate = '2026-07-16',
    [string]$VersionDriftCheckedAt = '2026-07-20',
    [string]$BuildDate = (Get-Date -Format 'yyyy-MM-dd'),
    [ValidateSet('working-draft', 'review-candidate', 'review-ready', 'final')]
    [string]$DocumentStatus = 'working-draft',
    [ValidateSet('core-guide', 'deployment-profile')]
    [string]$ReleaseClass = 'core-guide',
    [ValidateSet('not-validated', 'partially-validated', 'deployment-validated')]
    [string]$DeploymentValidationStatus = 'not-validated'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$AssemblerSchema = '3'
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$DocumentTitle = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String('SMaw4bubbmcgZOG6q24ga+G7uSB0aHXhuq10IERpZnkgQUkgc2VsZi1ob3N0ZWQ=')
)
$GeneratedNotice = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String('RmlsZSBuw6B5IMSRxrDhu6NjIGdow6lwIHThu7EgxJHhu5luZyB04burIG5ndeG7k24gdGhlbyBjaMawxqFuZzsga2jDtG5nIGNo4buJbmggc+G7rWEgdHLhu7FjIHRp4bq/cC4=')
)
$TocHeading = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String('TeG7pWMgbOG7pWM=')
)
$StartLabel = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String('QuG6r3QgxJHhuqd1')
)
$PartOneLabel = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String('UGjhuqduIEkg4oCUIEtp4bq/biB0aOG7qWMgbuG7gW4=')
)
$PartTwoLabel = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String('UGjhuqduIElJIOKAlCBQbGF5Ym9vayB0cmnhu4NuIGtoYWk=')
)
$PartThreeLabel = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String('UGjhuqduIElJSSDigJQgS2h1bmcgcmEgcXV54bq/dCDEkeG7i25o')
)
$AppendicesLabel = [System.Text.Encoding]::UTF8.GetString(
    [System.Convert]::FromBase64String('UGjhu6UgbOG7pWMgQeKAk0Y=')
)

foreach ($dateValue in @($BaselineLockDate, $VersionDriftCheckedAt, $BuildDate)) {
    if ($dateValue -notmatch '^\d{4}-\d{2}-\d{2}$') {
        throw "Date metadata must use YYYY-MM-DD: '$dateValue'."
    }
}
if ($BaselineCommit -notmatch '^[0-9a-fA-F]{40}$') {
    throw "BaselineCommit must be a full 40-character SHA: '$BaselineCommit'."
}
if ($DocsSnapshot -notmatch '^[0-9a-fA-F]{40}$') {
    throw "DocsSnapshot must be a full 40-character SHA: '$DocsSnapshot'."
}

$sourceTreeCommit = 'unknown'
$sourceTreeDirty = 'unknown'
$gitCommand = Get-Command 'git.exe' -ErrorAction SilentlyContinue
if ($null -ne $gitCommand) {
    $commitOutput = @(& $gitCommand.Source -C $RepoRoot rev-parse HEAD 2>$null)
    if ($LASTEXITCODE -eq 0 -and $commitOutput.Count -gt 0 -and $commitOutput[0] -match '^[0-9a-fA-F]{40}$') {
        $sourceTreeCommit = $commitOutput[0].ToLowerInvariant()
    }

    $statusOutput = @(& $gitCommand.Source -C $RepoRoot status --porcelain --untracked-files=all 2>$null)
    if ($LASTEXITCODE -eq 0) {
        $sourceTreeDirty = if ($statusOutput.Count -gt 0) { 'true' } else { 'false' }
    }
}

if ($DocumentStatus -eq 'final') {
    if ($sourceTreeCommit -eq 'unknown' -or $sourceTreeDirty -ne 'false') {
        throw 'A final build requires a clean Git worktree with a resolvable source commit.'
    }
    if ($DocumentVersion -match '(?i)(?:working|draft|candidate)') {
        throw "A final build cannot use a draft/candidate DocumentVersion: '$DocumentVersion'."
    }
}

if ([string]::IsNullOrWhiteSpace($ManifestPath)) {
    $ManifestPath = Join-Path $RepoRoot 'docs/releases/release-manifest.txt'
}
elseif (-not [System.IO.Path]::IsPathRooted($ManifestPath)) {
    $ManifestPath = Join-Path $RepoRoot $ManifestPath
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    throw 'OutputPath is required. Use a temp path for previews or docs/releases/dify-research-final.md only after the applicable release gates pass.'
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputPath)) {
    $OutputPath = Join-Path $RepoRoot $OutputPath
}

$ManifestPath = [System.IO.Path]::GetFullPath($ManifestPath)
$OutputPath = [System.IO.Path]::GetFullPath($OutputPath)

function Get-NormalizedFullPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    return [System.IO.Path]::GetFullPath($Path).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ).ToLowerInvariant()
}

function Get-RepositoryRelativePath {
    param([Parameter(Mandatory = $true)][string]$FullPath)

    $rootWithSeparator = $RepoRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $rootUri = New-Object System.Uri($rootWithSeparator)
    $fileUri = New-Object System.Uri([System.IO.Path]::GetFullPath($FullPath))
    $relative = [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($fileUri).ToString())
    return $relative.Replace('\', '/')
}

function Get-ChapterKey {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $leaf = [System.IO.Path]::GetFileName($RelativePath)
    if ($leaf -match '^(?<number>\d{2})-') {
        return 'ch' + $Matches['number']
    }
    if ($leaf -match '^(?<letter>[a-fA-F])-') {
        return 'app' + $Matches['letter'].ToLowerInvariant()
    }
    throw "Cannot derive a chapter key from manifest entry '$RelativePath'."
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

function Get-FenceStart {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Line)

    if ($Line -match '^\s*(?<marker>`{3,}|~{3,})(?<info>.*)$') {
        $marker = $Matches['marker']
        return [pscustomobject]@{
            Character = $marker.Substring(0, 1)
            MarkerLength = $marker.Length
            Info = $Matches['info'].Trim()
        }
    }
    return $null
}

function Test-FenceEnd {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Line,
        [Parameter(Mandatory = $true)]$Fence
    )

    $character = [System.Text.RegularExpressions.Regex]::Escape($Fence.Character)
    $pattern = '^\s*' + $character + '{' + $Fence.MarkerLength + ',}\s*$'
    return $Line -match $pattern
}

function Get-HeadingRecords {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string[]]$Lines,
        [Parameter(Mandatory = $true)][string]$ChapterKey,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    $records = @()
    $slugCounts = @{}
    $fence = $null

    for ($lineIndex = 0; $lineIndex -lt $Lines.Count; $lineIndex++) {
        $line = $Lines[$lineIndex]
        if ($null -ne $fence) {
            if (Test-FenceEnd -Line $line -Fence $fence) {
                $fence = $null
            }
            continue
        }

        $fenceStart = Get-FenceStart -Line $line
        if ($null -ne $fenceStart) {
            $fence = $fenceStart
            continue
        }

        if ($line -match '^\s{0,3}(?<marks>#{1,6})[ \t]+(?<text>.*?)[ \t]*#*[ \t]*$') {
            $level = $Matches['marks'].Length
            if ($level -ge 6) {
                throw "Cannot demote H$level at ${RelativePath}:$($lineIndex + 1); H7 is not valid Markdown."
            }

            $text = $Matches['text'].Trim()
            if ([string]::IsNullOrWhiteSpace($text)) {
                throw "Empty heading at ${RelativePath}:$($lineIndex + 1)."
            }

            $baseSlug = Get-AnchorSlug -Text $text
            if (-not $slugCounts.ContainsKey($baseSlug)) {
                $slugCounts[$baseSlug] = 0
            }
            else {
                $slugCounts[$baseSlug]++
            }

            $duplicateNumber = [int]$slugCounts[$baseSlug]
            $sourceSlug = $baseSlug
            if ($duplicateNumber -gt 0) {
                $sourceSlug = "$baseSlug-$duplicateNumber"
            }

            $records += [pscustomobject]@{
                LineIndex = $lineIndex
                OriginalLevel = $level
                Text = $text
                SourceSlug = $sourceSlug
                Anchor = "$ChapterKey-$sourceSlug"
            }
        }
    }

    if ($null -ne $fence) {
        throw "Unclosed fenced code block in '$RelativePath'."
    }
    return $records
}

function Resolve-FragmentAnchor {
    param(
        [Parameter(Mandatory = $true)]$TargetSource,
        [Parameter(Mandatory = $true)][string]$Fragment,
        [Parameter(Mandatory = $true)][string]$Context
    )

    try {
        $decoded = [System.Uri]::UnescapeDataString($Fragment).Trim()
    }
    catch {
        throw "Invalid percent-encoding in fragment '$Fragment' at $Context."
    }

    if ([string]::IsNullOrWhiteSpace($decoded)) {
        return $TargetSource.FirstAnchor
    }

    $candidateKeys = @($decoded.ToLowerInvariant(), (Get-AnchorSlug -Text $decoded).ToLowerInvariant())
    foreach ($candidateKey in $candidateKeys) {
        if ($TargetSource.FragmentMap.ContainsKey($candidateKey)) {
            return $TargetSource.FragmentMap[$candidateKey]
        }
    }
    throw "Unresolved heading fragment '#$Fragment' in '$($TargetSource.RelativePath)' at $Context."
}

function Rewrite-MarkdownLinks {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Line,
        [Parameter(Mandatory = $true)]$CurrentSource,
        [Parameter(Mandatory = $true)][hashtable]$SourceByFullPath,
        [Parameter(Mandatory = $true)][int]$LineNumber
    )

    if ($Line -match '^\s*\[[^\]]+\]:\s+') {
        throw "Reference-style links are not supported at $($CurrentSource.RelativePath):$LineNumber."
    }

    $pattern = '(?<image>!?)\[(?<label>[^\]\r\n]*)\]\((?<inside>[^)\r\n]+)\)'
    $context = "$($CurrentSource.RelativePath):$LineNumber"

    return [System.Text.RegularExpressions.Regex]::Replace($Line, $pattern, {
        param($match)

        $inside = $match.Groups['inside'].Value
        if ($inside -notmatch '^(?<leading>\s*)(?<destination><[^>]+>|\S+?)(?<title>\s+(?:"[^"]*"|''[^'']*''|\([^)]*\)))?(?<trailing>\s*)$') {
            throw "Unsupported Markdown link syntax at ${context}: $($match.Value)"
        }

        $destination = $Matches['destination']
        $leading = $Matches['leading']
        $title = $Matches['title']
        $trailing = $Matches['trailing']
        if ($destination.StartsWith('<') -and $destination.EndsWith('>')) {
            $destination = $destination.Substring(1, $destination.Length - 2)
        }

        if ($destination -match '^[A-Za-z][A-Za-z0-9+.-]*:' -or $destination.StartsWith('//')) {
            return $match.Value
        }

        if ($match.Groups['image'].Value -eq '!') {
            throw "Local image links cannot be embedded in the standalone release at ${context}: $destination"
        }

        $targetSource = $CurrentSource
        $fragment = $null

        if ($destination.StartsWith('#')) {
            $fragment = $destination.Substring(1)
        }
        else {
            $hashIndex = $destination.IndexOf('#')
            $pathPart = $destination
            if ($hashIndex -ge 0) {
                $pathPart = $destination.Substring(0, $hashIndex)
                $fragment = $destination.Substring($hashIndex + 1)
            }

            if ($pathPart.Contains('?')) {
                throw "Query strings on local links are unsupported at ${context}: $destination"
            }
            if ($pathPart -notmatch '(?i)\.md$') {
                throw "Unsupported relative link target at ${context}: $destination"
            }

            try {
                $decodedPath = [System.Uri]::UnescapeDataString($pathPart)
                $candidatePath = [System.IO.Path]::GetFullPath((Join-Path $CurrentSource.DirectoryPath $decodedPath))
            }
            catch {
                throw "Invalid local link path at ${context}: $destination"
            }

            $candidateKey = Get-NormalizedFullPath -Path $candidatePath
            if (-not $SourceByFullPath.ContainsKey($candidateKey)) {
                if ([System.IO.File]::Exists($candidatePath)) {
                    throw "Local Markdown link targets a file omitted from the release manifest at ${context}: $destination"
                }
                throw "Missing local Markdown link target at ${context}: $destination"
            }
            $targetSource = $SourceByFullPath[$candidateKey]
        }

        $anchor = $targetSource.FirstAnchor
        if ($null -ne $fragment -and -not [string]::IsNullOrWhiteSpace($fragment)) {
            $anchor = Resolve-FragmentAnchor -TargetSource $targetSource -Fragment $fragment -Context $context
        }

        return $match.Groups['image'].Value + '[' + $match.Groups['label'].Value + '](' +
            $leading + '#' + $anchor + $title + $trailing + ')'
    })
}

if (-not [System.IO.File]::Exists($ManifestPath)) {
    throw "Release manifest not found: $ManifestPath"
}

$manifestLines = [System.IO.File]::ReadAllLines($ManifestPath, $Utf8NoBom)
$manifestEntries = @(
    $manifestLines |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') }
)

$expectedKeys = @()
0..19 | ForEach-Object { $expectedKeys += ('ch{0:d2}' -f $_) }
@('a', 'b', 'c', 'd', 'e', 'f') | ForEach-Object { $expectedKeys += "app$_" }

if ($manifestEntries.Count -ne $expectedKeys.Count) {
    throw "Manifest must contain exactly $($expectedKeys.Count) sources (00-19 and A-F); found $($manifestEntries.Count)."
}

$sources = @()
$seenPaths = @{}
$seenKeys = @{}

for ($index = 0; $index -lt $manifestEntries.Count; $index++) {
    $entry = $manifestEntries[$index].Replace('\', '/')
    if ([System.IO.Path]::IsPathRooted($entry)) {
        throw "Manifest entries must be repository-relative: '$entry'."
    }

    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $entry))
    $normalizedPath = Get-NormalizedFullPath -Path $fullPath
    $normalizedRoot = Get-NormalizedFullPath -Path $RepoRoot
    if (-not ($normalizedPath + [System.IO.Path]::DirectorySeparatorChar).StartsWith(
        $normalizedRoot + [System.IO.Path]::DirectorySeparatorChar,
        [System.StringComparison]::OrdinalIgnoreCase
    )) {
        throw "Manifest entry escapes the repository: '$entry'."
    }
    if ($seenPaths.ContainsKey($normalizedPath)) {
        throw "Duplicate manifest entry: '$entry'."
    }
    if (-not [System.IO.File]::Exists($fullPath)) {
        throw "Manifest source is missing: '$entry'."
    }

    $chapterKey = Get-ChapterKey -RelativePath $entry
    if ($chapterKey -ne $expectedKeys[$index]) {
        throw "Unexpected source order at position $($index + 1): expected '$($expectedKeys[$index])', found '$chapterKey' in '$entry'."
    }
    if ($seenKeys.ContainsKey($chapterKey)) {
        throw "Duplicate chapter key '$chapterKey' in manifest."
    }

    $content = [System.IO.File]::ReadAllText($fullPath, $Utf8NoBom)
    $content = $content.Replace("`r`n", "`n").Replace("`r", "`n")
    $lines = $content -split "`n", -1
    $headings = @(Get-HeadingRecords -Lines $lines -ChapterKey $chapterKey -RelativePath $entry)
    if ($headings.Count -eq 0 -or $headings[0].OriginalLevel -ne 1) {
        throw "Source '$entry' must start its heading hierarchy with exactly one H1."
    }
    if (@($headings | Where-Object { $_.OriginalLevel -eq 1 }).Count -ne 1) {
        throw "Source '$entry' must contain exactly one H1."
    }

    $headingByLine = @{}
    $fragmentMap = @{}
    foreach ($heading in $headings) {
        $headingByLine[$heading.LineIndex] = $heading
        foreach ($alias in @($heading.SourceSlug, $heading.Anchor)) {
            $aliasKey = $alias.ToLowerInvariant()
            if ($fragmentMap.ContainsKey($aliasKey) -and $fragmentMap[$aliasKey] -ne $heading.Anchor) {
                throw "Ambiguous heading fragment '$alias' in '$entry'."
            }
            $fragmentMap[$aliasKey] = $heading.Anchor
        }
    }

    $source = [pscustomobject]@{
        ChapterKey = $chapterKey
        RelativePath = $entry
        FullPath = $fullPath
        DirectoryPath = [System.IO.Path]::GetDirectoryName($fullPath)
        Content = $content
        Lines = $lines
        Headings = $headings
        HeadingByLine = $headingByLine
        FragmentMap = $fragmentMap
        FirstAnchor = $headings[0].Anchor
        Title = $headings[0].Text
    }

    $sources += $source
    $seenPaths[$normalizedPath] = $true
    $seenKeys[$chapterKey] = $true
}

$normalizedOutput = Get-NormalizedFullPath -Path $OutputPath
if ($seenPaths.ContainsKey($normalizedOutput) -or $normalizedOutput -eq (Get-NormalizedFullPath -Path $ManifestPath)) {
    throw 'OutputPath must not overwrite a source file or the release manifest.'
}
if ([System.IO.File]::Exists($OutputPath) -or [System.IO.Directory]::Exists($OutputPath)) {
    throw "OutputPath already exists; refusing to overwrite it: $OutputPath"
}

$sourceByFullPath = @{}
foreach ($source in $sources) {
    $sourceByFullPath[(Get-NormalizedFullPath -Path $source.FullPath)] = $source
}

$fingerprintInput = New-Object System.Text.StringBuilder
[void]$fingerprintInput.Append("assembler-schema=$AssemblerSchema`n")
[void]$fingerprintInput.Append("document-version=$DocumentVersion`n")
[void]$fingerprintInput.Append("baseline-version=$BaselineVersion`n")
[void]$fingerprintInput.Append("baseline-commit=$BaselineCommit`n")
[void]$fingerprintInput.Append("docs-snapshot=$DocsSnapshot`n")
[void]$fingerprintInput.Append("baseline-lock-date=$BaselineLockDate`n")
[void]$fingerprintInput.Append("version-drift-checked-at=$VersionDriftCheckedAt`n")
[void]$fingerprintInput.Append("build-date=$BuildDate`n")
[void]$fingerprintInput.Append("document-status=$DocumentStatus`n")
[void]$fingerprintInput.Append("release-class=$ReleaseClass`n")
[void]$fingerprintInput.Append("deployment-validation-status=$DeploymentValidationStatus`n")
[void]$fingerprintInput.Append("source-tree-commit=$sourceTreeCommit`n")
[void]$fingerprintInput.Append("source-tree-dirty=$sourceTreeDirty`n")
foreach ($source in $sources) {
    [void]$fingerprintInput.Append("source=$($source.RelativePath)`n")
    [void]$fingerprintInput.Append($source.Content)
    [void]$fingerprintInput.Append("`n")
}

$sha256 = [System.Security.Cryptography.SHA256]::Create()
try {
    $fingerprintBytes = $Utf8NoBom.GetBytes($fingerprintInput.ToString())
    $hashBytes = $sha256.ComputeHash($fingerprintBytes)
}
finally {
    $sha256.Dispose()
}
$buildId = ([System.BitConverter]::ToString($hashBytes)).Replace('-', '').ToLowerInvariant()

$output = New-Object System.Text.StringBuilder
[void]$output.AppendLine('---')
[void]$output.AppendLine("title: `"$DocumentTitle`"")
[void]$output.AppendLine("document_version: `"$DocumentVersion`"")
[void]$output.AppendLine("document_status: `"$DocumentStatus`"")
[void]$output.AppendLine("release_class: `"$ReleaseClass`"")
[void]$output.AppendLine("deployment_validation_status: `"$DeploymentValidationStatus`"")
[void]$output.AppendLine("baseline_product: `"Dify $BaselineVersion`"")
[void]$output.AppendLine("baseline_commit: `"$BaselineCommit`"")
[void]$output.AppendLine("docs_snapshot: `"$DocsSnapshot`"")
[void]$output.AppendLine("baseline_lock_date: `"$BaselineLockDate`"")
[void]$output.AppendLine("version_drift_checked_at: `"$VersionDriftCheckedAt`"")
[void]$output.AppendLine("build_date: `"$BuildDate`"")
[void]$output.AppendLine("source_tree_commit: `"$sourceTreeCommit`"")
[void]$output.AppendLine("source_tree_dirty: $sourceTreeDirty")
[void]$output.AppendLine("build_schema: `"$AssemblerSchema`"")
[void]$output.AppendLine("build_id: `"sha256:$buildId`"")
[void]$output.AppendLine("build_manifest: `"$(Get-RepositoryRelativePath -FullPath $ManifestPath)`"")
[void]$output.AppendLine("source_count: $($sources.Count)")
[void]$output.AppendLine('---')
[void]$output.AppendLine()
[void]$output.AppendLine('<a id="front-title"></a>')
[void]$output.AppendLine("# $DocumentTitle")
[void]$output.AppendLine()
[void]$output.AppendLine($GeneratedNotice)
[void]$output.AppendLine()
[void]$output.AppendLine('<a id="front-toc"></a>')
[void]$output.AppendLine("## $TocHeading")
[void]$output.AppendLine()
[void]$output.AppendLine("**$StartLabel**")
[void]$output.AppendLine()
foreach ($source in @($sources | Where-Object { $_.ChapterKey -eq 'ch00' })) {
    [void]$output.AppendLine("- [$($source.Title)](#$($source.FirstAnchor))")
}

[void]$output.AppendLine()
[void]$output.AppendLine("**$PartOneLabel**")
[void]$output.AppendLine()
foreach ($source in @($sources | Where-Object { $_.ChapterKey -match '^ch(?:0[1-9]|10)$' })) {
    [void]$output.AppendLine("- [$($source.Title)](#$($source.FirstAnchor))")
}

[void]$output.AppendLine()
[void]$output.AppendLine("**$PartTwoLabel**")
[void]$output.AppendLine()
foreach ($source in @($sources | Where-Object { $_.ChapterKey -match '^ch1[1-6]$' })) {
    [void]$output.AppendLine("- [$($source.Title)](#$($source.FirstAnchor))")
}

[void]$output.AppendLine()
[void]$output.AppendLine("**$PartThreeLabel**")
[void]$output.AppendLine()
foreach ($source in @($sources | Where-Object { $_.ChapterKey -match '^ch1[7-9]$' })) {
    [void]$output.AppendLine("- [$($source.Title)](#$($source.FirstAnchor))")
}

[void]$output.AppendLine()
[void]$output.AppendLine("**$AppendicesLabel**")
[void]$output.AppendLine()
foreach ($source in @($sources | Where-Object { $_.ChapterKey.StartsWith('app') })) {
    [void]$output.AppendLine("- [$($source.Title)](#$($source.FirstAnchor))")
}

$inputMermaidCount = 0
foreach ($source in $sources) {
    [void]$output.AppendLine()
    [void]$output.AppendLine('---')
    [void]$output.AppendLine()

    $fence = $null
    for ($lineIndex = 0; $lineIndex -lt $source.Lines.Count; $lineIndex++) {
        $line = $source.Lines[$lineIndex]

        if ($null -ne $fence) {
            [void]$output.AppendLine($line)
            if (Test-FenceEnd -Line $line -Fence $fence) {
                $fence = $null
            }
            continue
        }

        $fenceStart = Get-FenceStart -Line $line
        if ($null -ne $fenceStart) {
            $fence = $fenceStart
            if ($fenceStart.Info -match '^(?i)mermaid(?:\s|$)') {
                $inputMermaidCount++
            }
            [void]$output.AppendLine($line)
            continue
        }

        if ($source.HeadingByLine.ContainsKey($lineIndex)) {
            $heading = $source.HeadingByLine[$lineIndex]
            [void]$output.AppendLine("<a id=`"$($heading.Anchor)`"></a>")
            [void]$output.AppendLine(('#' * ($heading.OriginalLevel + 1)) + ' ' + $heading.Text)
            continue
        }

        $rewritten = Rewrite-MarkdownLinks -Line $line -CurrentSource $source `
            -SourceByFullPath $sourceByFullPath -LineNumber ($lineIndex + 1)
        [void]$output.AppendLine($rewritten)
    }
}

$assembled = $output.ToString().Replace("`r`n", "`n").Replace("`r", "`n")
$assembledLines = $assembled -split "`n", -1
$structuralH1Count = 0
$outputMermaidCount = 0
$fence = $null
foreach ($line in $assembledLines) {
    if ($null -ne $fence) {
        if (Test-FenceEnd -Line $line -Fence $fence) {
            $fence = $null
        }
        continue
    }

    $fenceStart = Get-FenceStart -Line $line
    if ($null -ne $fenceStart) {
        $fence = $fenceStart
        if ($fenceStart.Info -match '^(?i)mermaid(?:\s|$)') {
            $outputMermaidCount++
        }
        continue
    }
    if ($line -match '^# [^#]') {
        $structuralH1Count++
    }
}

if ($structuralH1Count -ne 1) {
    throw "Assembly invariant failed: expected one structural H1, found $structuralH1Count."
}
if ($outputMermaidCount -ne $inputMermaidCount) {
    throw "Assembly invariant failed: Mermaid count changed from $inputMermaidCount to $outputMermaidCount."
}

$outputDirectory = [System.IO.Path]::GetDirectoryName($OutputPath)
if (-not [System.IO.Directory]::Exists($outputDirectory)) {
    [void][System.IO.Directory]::CreateDirectory($outputDirectory)
}
$outputLeaf = [System.IO.Path]::GetFileName($OutputPath)
$temporaryOutputPath = Join-Path $outputDirectory (
    '.{0}.{1}.tmp' -f $outputLeaf, [System.Guid]::NewGuid().ToString('N')
)
try {
    [System.IO.File]::WriteAllText($temporaryOutputPath, $assembled, $Utf8NoBom)

    # The two-argument Move is atomic on the same volume and refuses to replace
    # a target created after the earlier existence check.
    [System.IO.File]::Move($temporaryOutputPath, $OutputPath)
}
finally {
    if ([System.IO.File]::Exists($temporaryOutputPath)) {
        [System.IO.File]::Delete($temporaryOutputPath)
    }
}

Write-Output ([pscustomobject]@{
    OutputPath = $OutputPath
    BuildId = "sha256:$buildId"
    SourceCount = $sources.Count
    HeadingCount = @($sources | ForEach-Object { $_.Headings }).Count
    MermaidCount = $outputMermaidCount
    StructuralH1Count = $structuralH1Count
    DocumentStatus = $DocumentStatus
    ReleaseClass = $ReleaseClass
    DeploymentValidationStatus = $DeploymentValidationStatus
    BuildDate = $BuildDate
    SourceTreeCommit = $sourceTreeCommit
    SourceTreeDirty = $sourceTreeDirty
})
