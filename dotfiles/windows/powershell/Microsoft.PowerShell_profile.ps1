Set-Alias vim nvim

function ll {
    Get-ChildItem -Force
}

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    zoxide init powershell | Out-String | Invoke-Expression
}
