$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..")).Path

$CommonPackagesFile = Join-Path $RepoRoot "packages/common.txt"
$WindowsPackagesFile = Join-Path $RepoRoot "packages/windows.txt"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "[error] winget is required but was not found in PATH."
    exit 1
}

function Get-PackagesFromFile {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        Write-Warning "[warn] Package list not found: $Path"
        return @()
    }

    return Get-Content $Path |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith("#") }
}

$PackageMap = @{
    "ripgrep" = "BurntSushi.ripgrep"
    "fd"      = "sharkdp.fd"
    "fzf"     = "junegunn.fzf"
    "git"     = "Git.Git"
    "neovim"  = "Neovim.Neovim"
    "jq"      = "jqlang.jq"
    "gh"      = "GitHub.cli"
    "tmux"    = "Terminals.Tmux"
    "tree"    = "GnuWin32.Tree"
    "bat"     = "sharkdp.bat"
    "zoxide"  = "ajeetdsouza.zoxide"
    "python"  = "Python.Python.3.12"
    "node"    = "OpenJS.NodeJS.LTS"
    "curl"    = "cURL.cURL"
    "wget"    = "GnuWin32.Wget"
}

function Install-Package {
    param([string]$PackageName)

    $WingetId = if ($PackageMap.ContainsKey($PackageName)) { $PackageMap[$PackageName] } else { $PackageName }

    Write-Host "[install] $PackageName ($WingetId)"
    try {
        winget install --id $WingetId --exact --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[ok] $PackageName"
        } else {
            Write-Warning "[skip] Failed or unavailable: $PackageName ($WingetId)"
        }
    } catch {
        Write-Warning "[skip] Failed or unavailable: $PackageName ($WingetId)"
    }
}

$AllPackages = @()
$AllPackages += Get-PackagesFromFile -Path $CommonPackagesFile
$AllPackages += Get-PackagesFromFile -Path $WindowsPackagesFile

foreach ($Pkg in $AllPackages) {
    Install-Package -PackageName $Pkg
}

Write-Host "[done] bootstrap completed for windows"
