[CmdletBinding()]
param(
    [string]$BrowserExecutable,
    [string]$NpmCache,
    [string]$MermaidCliVersion = '11.16.0',
    [switch]$AllowDownload,
    [switch]$DisableBrowserSandbox,
    [switch]$KeepArtifacts
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ExpectedDiagramCount = 29
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$BuildScript = Join-Path $PSScriptRoot 'build-release.ps1'

function Resolve-BrowserExecutable {
    param([AllowEmptyString()][string]$RequestedPath)

    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        $resolved = [System.IO.Path]::GetFullPath($RequestedPath)
        if (-not [System.IO.File]::Exists($resolved)) {
            throw "Browser executable not found: $resolved"
        }
        return $resolved
    }

    $candidates = @()
    $programFilesX86 = [System.Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
    $programFiles = [System.Environment]::GetEnvironmentVariable('ProgramFiles')
    $localAppData = [System.Environment]::GetEnvironmentVariable('LOCALAPPDATA')

    if (-not [string]::IsNullOrWhiteSpace($programFilesX86)) {
        $candidates += (Join-Path $programFilesX86 'Microsoft\Edge\Application\msedge.exe')
        $candidates += (Join-Path $programFilesX86 'Google\Chrome\Application\chrome.exe')
    }
    if (-not [string]::IsNullOrWhiteSpace($programFiles)) {
        $candidates += (Join-Path $programFiles 'Microsoft\Edge\Application\msedge.exe')
        $candidates += (Join-Path $programFiles 'Google\Chrome\Application\chrome.exe')
    }
    if (-not [string]::IsNullOrWhiteSpace($localAppData)) {
        $candidates += (Join-Path $localAppData 'Microsoft\Edge\Application\msedge.exe')
        $candidates += (Join-Path $localAppData 'Google\Chrome\Application\chrome.exe')
    }

    foreach ($commandName in @('msedge.exe', 'chrome.exe')) {
        $command = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($null -ne $command -and -not [string]::IsNullOrWhiteSpace($command.Source)) {
            $candidates += $command.Source
        }
    }

    foreach ($candidate in @($candidates | Select-Object -Unique)) {
        if ([System.IO.File]::Exists($candidate)) {
            return [System.IO.Path]::GetFullPath($candidate)
        }
    }

    throw 'Microsoft Edge or Google Chrome was not found. Pass -BrowserExecutable with an explicit executable path.'
}

function Resolve-NpmCachePath {
    param([AllowEmptyString()][string]$RequestedPath)

    if ([string]::IsNullOrWhiteSpace($RequestedPath)) {
        return [System.IO.Path]::GetFullPath(
            (Join-Path ([System.IO.Path]::GetTempPath()) 'dify-mermaid-npm-cache')
        )
    }
    return [System.IO.Path]::GetFullPath($RequestedPath)
}

function Test-PathIsWithin {
    param(
        [Parameter(Mandatory = $true)][string]$ChildPath,
        [Parameter(Mandatory = $true)][string]$ParentPath
    )

    $child = [System.IO.Path]::GetFullPath($ChildPath).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $parent = [System.IO.Path]::GetFullPath($ParentPath).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    return $child.StartsWith($parent, [System.StringComparison]::OrdinalIgnoreCase)
}

function ConvertTo-WindowsCommandLineArgument {
    param([Parameter(Mandatory = $true)][AllowEmptyString()][string]$Argument)

    if ($Argument.Length -eq 0) {
        return '""'
    }
    if ($Argument -notmatch '[\s"]') {
        return $Argument
    }

    # Start-Process joins ArgumentList with spaces on Windows PowerShell 5.1.
    # Quote each argument using the CommandLineToArgvW/C-runtime escaping rules.
    $builder = New-Object System.Text.StringBuilder
    [void]$builder.Append([char]0x0022)
    $backslashCount = 0
    foreach ($character in $Argument.ToCharArray()) {
        if ($character -eq [char]0x005c) {
            $backslashCount++
            continue
        }

        if ($character -eq [char]0x0022) {
            [void]$builder.Append([char]0x005c, (($backslashCount * 2) + 1))
            [void]$builder.Append([char]0x0022)
            $backslashCount = 0
            continue
        }

        if ($backslashCount -gt 0) {
            [void]$builder.Append([char]0x005c, $backslashCount)
            $backslashCount = 0
        }
        [void]$builder.Append($character)
    }

    if ($backslashCount -gt 0) {
        [void]$builder.Append([char]0x005c, ($backslashCount * 2))
    }
    [void]$builder.Append([char]0x0022)
    return $builder.ToString()
}

function Repair-DuplicateProcessEnvironmentKeys {
    # Windows PowerShell 5.1 Start-Process builds a case-insensitive environment
    # dictionary and crashes if its parent supplied both Path and PATH. Keep one
    # copy only when their values are identical; conflicting values are unsafe.
    $entries = @([System.Environment]::GetEnvironmentVariables('Process').GetEnumerator())
    $duplicateGroups = @(
        $entries |
            Group-Object { ([string]$_.Key).ToUpperInvariant() } |
            Where-Object { $_.Count -gt 1 }
    )

    foreach ($group in $duplicateGroups) {
        $values = @($group.Group | ForEach-Object { [string]$_.Value } | Select-Object -Unique)
        if ($values.Count -ne 1) {
            $keys = @($group.Group | ForEach-Object { [string]$_.Key }) -join ', '
            throw "Cannot start Mermaid CLI because process environment keys differ only by case and have conflicting values: $keys"
        }

        $keeper = @($group.Group | Select-Object -First 1)[0]
        foreach ($entry in $group.Group) {
            if ([string]$entry.Key -cne [string]$keeper.Key) {
                [System.Environment]::SetEnvironmentVariable([string]$entry.Key, $null, 'Process')
            }
        }
    }
}

if (-not [System.IO.File]::Exists($BuildScript)) {
    throw "Release assembly script not found: $BuildScript"
}
if ($MermaidCliVersion -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$') {
    throw "MermaidCliVersion must be an exact version, not a range: '$MermaidCliVersion'."
}

$browserPath = Resolve-BrowserExecutable -RequestedPath $BrowserExecutable
$npmCachePath = Resolve-NpmCachePath -RequestedPath $NpmCache
$npxCommand = Get-Command 'npx.cmd' -ErrorAction SilentlyContinue
if ($null -eq $npxCommand) {
    throw 'npx.cmd was not found. Install a supported Node.js/npm runtime before rendering Mermaid.'
}

if (-not [System.IO.Directory]::Exists($npmCachePath)) {
    if (-not $AllowDownload) {
        throw "Offline npm cache does not exist: $npmCachePath. Seed the cache first or rerun with -AllowDownload."
    }
    [void][System.IO.Directory]::CreateDirectory($npmCachePath)
}

$temporaryRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$workRoot = Join-Path $temporaryRoot ('dify-mermaid-' + [System.Guid]::NewGuid().ToString('N'))
if (-not (Test-PathIsWithin -ChildPath $workRoot -ParentPath $temporaryRoot)) {
    throw "Refusing to use a work directory outside the system temp directory: $workRoot"
}

[void][System.IO.Directory]::CreateDirectory($workRoot)
$assembledPath = Join-Path $workRoot 'assembled.md'
$renderedMarkdownPath = Join-Path $workRoot 'rendered.md'
$artefactsPath = Join-Path $workRoot 'artefacts'
$puppeteerConfigPath = Join-Path $workRoot 'puppeteer-config.json'
$npxStdoutPath = Join-Path $workRoot 'npx-stdout.log'
$npxStderrPath = Join-Path $workRoot 'npx-stderr.log'
[void][System.IO.Directory]::CreateDirectory($artefactsPath)

$previousEnvironment = @{
    PUPPETEER_SKIP_DOWNLOAD = [System.Environment]::GetEnvironmentVariable('PUPPETEER_SKIP_DOWNLOAD', 'Process')
    npm_config_audit = [System.Environment]::GetEnvironmentVariable('npm_config_audit', 'Process')
    npm_config_fund = [System.Environment]::GetEnvironmentVariable('npm_config_fund', 'Process')
    npm_config_update_notifier = [System.Environment]::GetEnvironmentVariable('npm_config_update_notifier', 'Process')
}

try {
    $buildResult = & $BuildScript -OutputPath $assembledPath
    if ($null -eq $buildResult) {
        throw 'Release assembly did not return validation metadata.'
    }
    if ([int]$buildResult.MermaidCount -ne $ExpectedDiagramCount) {
        throw "Release assembly contains $($buildResult.MermaidCount) Mermaid diagrams; expected $ExpectedDiagramCount."
    }
    if (-not [System.IO.File]::Exists($assembledPath)) {
        throw "Release assembly did not create the expected temporary Markdown file: $assembledPath"
    }

    $browserArguments = @('--disable-gpu')
    if ($DisableBrowserSandbox) {
        $browserArguments += @('--no-sandbox', '--disable-setuid-sandbox')
    }

    $puppeteerConfig = [ordered]@{
        executablePath = $browserPath
        headless = $true
        args = $browserArguments
    } | ConvertTo-Json -Depth 4
    [System.IO.File]::WriteAllText($puppeteerConfigPath, $puppeteerConfig, $Utf8NoBom)

    [System.Environment]::SetEnvironmentVariable('PUPPETEER_SKIP_DOWNLOAD', 'true', 'Process')
    [System.Environment]::SetEnvironmentVariable('npm_config_audit', 'false', 'Process')
    [System.Environment]::SetEnvironmentVariable('npm_config_fund', 'false', 'Process')
    [System.Environment]::SetEnvironmentVariable('npm_config_update_notifier', 'false', 'Process')

    $npxArguments = @(
        '--yes',
        '--cache', $npmCachePath
    )
    if (-not $AllowDownload) {
        $npxArguments += '--offline'
    }
    $npxArguments += @(
        '--package', "@mermaid-js/mermaid-cli@$MermaidCliVersion",
        'mmdc',
        '--input', $assembledPath,
        '--output', $renderedMarkdownPath,
        '--artefacts', $artefactsPath,
        '--outputFormat', 'svg',
        '--puppeteerConfigFile', $puppeteerConfigPath,
        '--quiet'
    )

    Repair-DuplicateProcessEnvironmentKeys
    $quotedNpxArguments = @($npxArguments | ForEach-Object {
        ConvertTo-WindowsCommandLineArgument -Argument ([string]$_)
    })
    $cliProcess = Start-Process -FilePath $npxCommand.Source `
        -ArgumentList $quotedNpxArguments `
        -WorkingDirectory $RepoRoot `
        -NoNewWindow `
        -Wait `
        -PassThru `
        -RedirectStandardOutput $npxStdoutPath `
        -RedirectStandardError $npxStderrPath
    $cliExitCode = [int]$cliProcess.ExitCode
    $cliStdout = if ([System.IO.File]::Exists($npxStdoutPath)) {
        [System.IO.File]::ReadAllText($npxStdoutPath, $Utf8NoBom)
    }
    else { '' }
    $cliStderr = if ([System.IO.File]::Exists($npxStderrPath)) {
        [System.IO.File]::ReadAllText($npxStderrPath, $Utf8NoBom)
    }
    else { '' }
    if ($cliExitCode -ne 0) {
        $combinedOutput = @($cliStdout.TrimEnd(), $cliStderr.TrimEnd()) | Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        }
        $combinedOutput = $combinedOutput -join "`n"
        $details = (@($combinedOutput -split "`r?`n") | Select-Object -Last 20 | Out-String).Trim()
        if (-not $AllowDownload) {
            throw "Offline Mermaid render failed with exit code $cliExitCode. Ensure @mermaid-js/mermaid-cli@$MermaidCliVersion is present in '$npmCachePath', or explicitly rerun with -AllowDownload. $details"
        }
        throw "Mermaid render failed with exit code $cliExitCode. $details"
    }

    if (-not [System.IO.File]::Exists($renderedMarkdownPath)) {
        throw "Mermaid CLI exited successfully but did not create rendered Markdown: $renderedMarkdownPath"
    }

    $svgFiles = @(Get-ChildItem -LiteralPath $artefactsPath -Filter '*.svg' -File -Recurse)
    if ($svgFiles.Count -ne $ExpectedDiagramCount) {
        throw "Mermaid CLI produced $($svgFiles.Count) SVG files; expected $ExpectedDiagramCount."
    }

    foreach ($svgFile in $svgFiles) {
        if ($svgFile.Length -le 0) {
            throw "Mermaid CLI produced an empty SVG: $($svgFile.FullName)"
        }
        $svgText = [System.IO.File]::ReadAllText($svgFile.FullName, $Utf8NoBom)
        if ($svgText -notmatch '<svg(?:\s|>)') {
            throw "Rendered artefact is not an SVG document: $($svgFile.FullName)"
        }
    }

    $renderedMarkdown = [System.IO.File]::ReadAllText($renderedMarkdownPath, $Utf8NoBom)
    $svgReferenceCount = [System.Text.RegularExpressions.Regex]::Matches(
        $renderedMarkdown,
        '(?i)!\[[^\]]*\]\([^\)\r\n]+\.svg\)'
    ).Count
    $remainingMermaidCount = [System.Text.RegularExpressions.Regex]::Matches(
        $renderedMarkdown,
        '(?m)^\s*`{3,}mermaid\s*$'
    ).Count

    if ($svgReferenceCount -ne $ExpectedDiagramCount) {
        throw "Rendered Markdown contains $svgReferenceCount SVG references; expected $ExpectedDiagramCount."
    }
    if ($remainingMermaidCount -ne 0) {
        throw "Rendered Markdown still contains $remainingMermaidCount Mermaid code fences."
    }

    Write-Output ([pscustomobject]@{
        MermaidCliVersion = $MermaidCliVersion
        BrowserExecutable = $browserPath
        NpmCache = $npmCachePath
        Offline = -not [bool]$AllowDownload
        BrowserSandboxDisabled = [bool]$DisableBrowserSandbox
        DiagramCount = $ExpectedDiagramCount
        SvgCount = $svgFiles.Count
        SvgReferenceCount = $svgReferenceCount
        ExitCode = $cliExitCode
        BuildId = $buildResult.BuildId
        ArtifactsPath = if ($KeepArtifacts) { $workRoot } else { $null }
    })
}
finally {
    foreach ($environmentName in $previousEnvironment.Keys) {
        [System.Environment]::SetEnvironmentVariable(
            $environmentName,
            $previousEnvironment[$environmentName],
            'Process'
        )
    }

    if (-not $KeepArtifacts -and [System.IO.Directory]::Exists($workRoot)) {
        if (-not (Test-PathIsWithin -ChildPath $workRoot -ParentPath $temporaryRoot)) {
            throw "Refusing to clean a work directory outside the system temp directory: $workRoot"
        }
        [System.IO.Directory]::Delete($workRoot, $true)
    }
}
