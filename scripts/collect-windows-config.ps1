$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$targetRoot = Join-Path $repoRoot "windows-reference"

function Ensure-Dir($Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Copy-IfExists($Source, $Destination) {
    if (Test-Path -LiteralPath $Source) {
        $destinationFullPath = [System.IO.Path]::GetFullPath($Destination)
        $targetRootFullPath = [System.IO.Path]::GetFullPath($targetRoot)
        if (-not $destinationFullPath.StartsWith($targetRootFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to write outside windows-reference: $Destination"
        }

        if (Test-Path -LiteralPath $Destination) {
            Remove-Item -LiteralPath $Destination -Recurse -Force
        }

        Ensure-Dir (Split-Path -Parent $Destination)
        Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
        Write-Host "Copied $Source -> $Destination"
    } else {
        Write-Host "Skipped missing path: $Source"
    }
}

Ensure-Dir $targetRoot

Write-Host "Collecting Windows reference config into $targetRoot"
Write-Host "Review files before committing. Do not commit secrets, tokens, SSH keys, VPN configs, or company certificates."

$scoopList = Join-Path $targetRoot "scoop-list.txt"
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    scoop export | Out-File -Encoding UTF8 $scoopList
    Write-Host "Wrote $scoopList"
} else {
    "scoop is not installed or not on PATH." | Out-File -Encoding UTF8 $scoopList
    Write-Host "Scoop not found; wrote placeholder."
}

Copy-IfExists "$env:LOCALAPPDATA\nvim" (Join-Path $targetRoot "nvim")
$nuTarget = Join-Path $targetRoot "nushell"
Copy-IfExists "$env:APPDATA\nushell\config.nu" (Join-Path $nuTarget "config.nu")
Copy-IfExists "$env:APPDATA\nushell\env.nu" (Join-Path $nuTarget "env.nu")

$pwshTarget = Join-Path $targetRoot "powershell"
Ensure-Dir $pwshTarget
if ($PROFILE) {
    Copy-IfExists $PROFILE (Join-Path $pwshTarget "Microsoft.PowerShell_profile.ps1")
}
Copy-IfExists "$HOME\Documents\PowerShell\powershell.config.json" (Join-Path $pwshTarget "powershell.config.json")

$terminalSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Copy-IfExists $terminalSettings (Join-Path $targetRoot "windows-terminal\settings.json")

$cursorUser = "$env:APPDATA\Cursor\User"
Copy-IfExists "$cursorUser\settings.json" (Join-Path $targetRoot "cursor\settings.json")
Copy-IfExists "$cursorUser\keybindings.json" (Join-Path $targetRoot "cursor\keybindings.json")
if (Get-Command cursor -ErrorAction SilentlyContinue) {
    $extensionsPath = Join-Path $targetRoot "cursor\extensions.txt"
    cursor --list-extensions | Out-File -Encoding UTF8 $extensionsPath

    $extensionCount = (Get-Content -LiteralPath $extensionsPath | Where-Object { $_.Trim() }).Count
    if ($extensionCount -eq 0) {
        $cursorExtensionsDir = Join-Path $HOME ".cursor\extensions"
        if (Test-Path -LiteralPath $cursorExtensionsDir) {
            Get-ChildItem -LiteralPath $cursorExtensionsDir -Directory -ErrorAction SilentlyContinue |
                ForEach-Object {
                    $packageJson = Join-Path $_.FullName "package.json"
                    if (Test-Path -LiteralPath $packageJson) {
                        try {
                            $package = Get-Content -Raw -LiteralPath $packageJson | ConvertFrom-Json
                            if ($package.publisher -and $package.name) {
                                "$($package.publisher).$($package.name)"
                            }
                        } catch {
                            Write-Host "Skipped unreadable extension metadata: $packageJson"
                        }
                    }
                } |
                Sort-Object -Unique |
                Out-File -Encoding UTF8 $extensionsPath
        }
    }
}

$ahkTarget = Join-Path $targetRoot "ahk"
Ensure-Dir $ahkTarget
Get-ChildItem -Path $HOME -Filter "*.ahk" -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FullName -notmatch "\\AppData\\Local\\Temp\\" -and
        -not $_.FullName.StartsWith($repoRoot.Path, [System.StringComparison]::OrdinalIgnoreCase)
    } |
    ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $ahkTarget $_.Name) -Force
        Write-Host "Copied AHK script: $($_.FullName)"
    }

Write-Host "Done. Next: inspect git diff before commit."
