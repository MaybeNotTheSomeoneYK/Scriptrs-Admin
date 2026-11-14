
$ErrorActionPreference = "Stop"

$projectDir = "C:\Users\acer\Documents\Scriptr's Admin\extraction"
$modelPath = "C:\Users\acer\Documents\Scriptr's Admin\Scriptrs_Admin.rbxm"
$watchDir = Split-Path $modelPath -Parent

Set-Location $projectDir

Write-Host "[Watcher] Watching for Scriptrs_Admin.rbxm saves..."
Write-Host "[Watcher] Press Ctrl+C to stop."

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchDir
$watcher.Filter = "Scriptrs_Admin.rbxm"
$watcher.NotifyFilter = [IO.NotifyFilters]::LastWrite -bor [IO.NotifyFilters]::Size -bor [IO.NotifyFilters]::FileName
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier ModelChanged | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier ModelCreated | Out-Null
Register-ObjectEvent -InputObject $watcher -EventName Renamed -SourceIdentifier ModelRenamed | Out-Null

function Sync-Model {
    Write-Host "`n[Watcher] Model save detected. Waiting for file to settle..."

    $stableCount = 0
    $previous = ""

    while ($stableCount -lt 3) {
        Start-Sleep -Seconds 1

        if (-not (Test-Path $modelPath)) {
            $stableCount = 0
            continue
        }

        $file = Get-Item $modelPath
        $current = "$($file.Length)|$($file.LastWriteTimeUtc.Ticks)"

        if ($current -eq $previous) {
            $stableCount++
        } else {
            $stableCount = 0
            $previous = $current
        }
    }

    Write-Host "[Watcher] Running Rojo syncback..."

    & rojo syncback .\default.project.json --input $modelPath --non-interactive
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Rojo syncback failed. Git was not touched." -ForegroundColor Red
        return
    }

    $changes = git status --porcelain
    if (-not $changes) {
        Write-Host "[Watcher] No source changes. Nothing to commit."
        return
    }

    Write-Host "[Watcher] Changes detected. Committing..."

    git add -A
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] git add failed." -ForegroundColor Red
        return
    }

    git commit -m "Sync source from Roblox Studio"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Git commit failed. Nothing was pushed." -ForegroundColor Red
        return
    }

    Write-Host "[Watcher] Pushing to GitHub..."

    git push origin main
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Git push failed. Your commit remains local." -ForegroundColor Red
        return
    }

    Write-Host "[Watcher] Sync and push completed!" -ForegroundColor Green
}

try {
    while ($true) {
        $notification = Wait-Event -Timeout 1

        if ($notification) {
            Get-Event |
                Where-Object { $_.SourceIdentifier -in @("ModelChanged", "ModelCreated", "ModelRenamed") } |
                Remove-Event

            Sync-Model
        }
    }
}
finally {
    Unregister-Event -SourceIdentifier ModelChanged -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier ModelCreated -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier ModelRenamed -ErrorAction SilentlyContinue
    $watcher.Dispose()
}
