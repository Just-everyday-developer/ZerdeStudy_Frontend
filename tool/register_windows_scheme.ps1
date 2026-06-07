# Registers the `zerdestudy://` URL scheme on Windows (current user, no admin)
# so the OAuth redirect bridge can hand the authorization code back to the app
# via app_links.
#
# Run AFTER building the Windows app at least once:
#   flutter build windows --debug   (or run it once from the IDE)
# Then:
#   powershell -ExecutionPolicy Bypass -File tool\register_windows_scheme.ps1
#
# Pass -ExePath to point at a specific build (e.g. a Release exe).

param(
    [string]$ExePath = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ExePath)) {
    $candidates = @(
        "build\windows\x64\runner\Debug\frontend_flutter.exe",
        "build\windows\x64\runner\Release\frontend_flutter.exe",
        "build\windows\runner\Debug\frontend_flutter.exe",
        "build\windows\runner\Release\frontend_flutter.exe"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { $ExePath = (Resolve-Path $c).Path; break }
    }
}

if ([string]::IsNullOrWhiteSpace($ExePath) -or -not (Test-Path $ExePath)) {
    Write-Error "Could not find the built exe. Build the Windows app first (flutter build windows --debug) or pass -ExePath."
}

$scheme = "zerdestudy"
$root = "HKCU:\Software\Classes\$scheme"

New-Item -Path $root -Force | Out-Null
Set-ItemProperty -Path $root -Name "(Default)" -Value "URL:$scheme Protocol"
Set-ItemProperty -Path $root -Name "URL Protocol" -Value ""

New-Item -Path "$root\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "$root\shell\open\command" -Name "(Default)" -Value ("`"$ExePath`" `"%1`"")

Write-Host "Registered $scheme:// -> $ExePath" -ForegroundColor Green
Write-Host "Test it: start zerdestudy://auth/google/callback?code=test"
