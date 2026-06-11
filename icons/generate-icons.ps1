# Generates GymApp PWA PNG icons using System.Drawing (GDI+).
# Design: #0a0a0a square, centered white dumbbell glyph with purple accents.
# Glyph stays within the central ~60% (maskable safe zone).

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

function New-RoundedRectPath {
    param([float]$x, [float]$y, [float]$w, [float]$h, [float]$r)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $maxR = [Math]::Min($w, $h) / 2
    if ($r -gt $maxR) { $r = $maxR }
    if ($r -le 0) {
        $path.AddRectangle((New-Object System.Drawing.RectangleF($x, $y, $w, $h)))
        return $path
    }
    $d = 2 * $r
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function New-GymIcon {
    param([int]$size, [string]$outPath)

    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    $bg     = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 10, 10))
    $white  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
    $purple = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 168, 85, 247))

    # Background: fill the full square.
    $g.FillRectangle($bg, 0, 0, $size, $size)

    $S  = [float]$size
    $cy = $S / 2

    # --- Bar (thin rounded rect across the middle, under the plates) ---
    $barH = 0.075 * $S
    $barX = 0.30 * $S
    $barW = 0.40 * $S
    $bar = New-RoundedRectPath $barX ($cy - $barH / 2) $barW $barH ($barH / 2)
    $g.FillPath($white, $bar)
    $bar.Dispose()

    # --- End caps (small rounded rects at the extremes) ---
    $capW = 0.045 * $S; $capH = 0.17 * $S; $capR = 0.018 * $S
    $capXL = 0.20 * $S
    $capXR = $S - $capXL - $capW
    foreach ($capX in @($capXL, $capXR)) {
        $cap = New-RoundedRectPath $capX ($cy - $capH / 2) $capW $capH $capR
        $g.FillPath($white, $cap)
        $cap.Dispose()
    }

    # --- Plates (larger white rounded rects near each end) ---
    $plateW = 0.085 * $S; $plateH = 0.40 * $S; $plateR = 0.026 * $S
    $plateXL = 0.26 * $S
    $plateXR = $S - 0.26 * $S - $plateW
    foreach ($plateX in @($plateXL, $plateXR)) {
        $plate = New-RoundedRectPath $plateX ($cy - $plateH / 2) $plateW $plateH $plateR
        $g.FillPath($white, $plate)
        $plate.Dispose()
    }

    # --- Purple accents (thin inner plate edges) ---
    $accW = 0.03 * $S; $accH = 0.27 * $S; $accR = $accW / 2
    $accXL = $plateXL + $plateW + 0.015 * $S
    $accXR = $S - $accXL - $accW
    foreach ($accX in @($accXL, $accXR)) {
        $acc = New-RoundedRectPath $accX ($cy - $accH / 2) $accW $accH $accR
        $g.FillPath($purple, $acc)
        $acc.Dispose()
    }

    $g.Dispose()
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $bg.Dispose(); $white.Dispose(); $purple.Dispose()
    Write-Output ("Wrote {0} ({1} bytes)" -f $outPath, (Get-Item $outPath).Length)
}

$iconsDir = "C:\Users\Lucas Alexandre\Documents\AppGym\icons"
New-GymIcon -size 192 -outPath (Join-Path $iconsDir "icon-192.png")
New-GymIcon -size 512 -outPath (Join-Path $iconsDir "icon-512.png")
New-GymIcon -size 180 -outPath (Join-Path $iconsDir "apple-touch-icon.png")
