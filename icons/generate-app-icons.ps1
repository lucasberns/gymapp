# Gera todos os tamanhos de icone do GymApp a partir das duas imagens-fonte.
# Salve as imagens 1024x1024 nesta pasta (icons/) com estes nomes:
#   source-dark.png   -> halter branco em fundo escuro/roxo  (tema escuro)
#   source-light.png  -> halter escuro em fundo claro/roxo   (tema claro)
# Depois rode:  powershell -ExecutionPolicy Bypass -File .\generate-app-icons.ps1

Add-Type -AssemblyName System.Drawing

$here  = $PSScriptRoot
$dark  = Join-Path $here "source-dark.png"
$light = Join-Path $here "source-light.png"

foreach ($p in @($dark, $light)) {
  if (-not (Test-Path $p)) {
    Write-Error "Arquivo nao encontrado: $p`nSalve as duas imagens nesta pasta como source-dark.png e source-light.png."
    exit 1
  }
}

function New-Icon($srcPath, $outName, $size) {
  $out = Join-Path $here $outName
  $src = [System.Drawing.Image]::FromFile($srcPath)
  try {
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g   = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($src, 0, 0, $size, $size)
    $g.Dispose()
    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $kb = [math]::Round((Get-Item $out).Length / 1KB, 1)
    Write-Host ("  OK  {0,-28} {1}x{1}  ({2} KB)" -f $outName, $size, $kb)
  } finally {
    $src.Dispose()
  }
}

Write-Host "Gerando icones (tema escuro = padrao do app instalado):"
# Tema escuro -> icones principais (manifest / Android / iOS home screen)
New-Icon $dark  "icon-192.png"               192
New-Icon $dark  "icon-512.png"               512
New-Icon $dark  "apple-touch-icon.png"       180
New-Icon $dark  "favicon-dark.png"           96

Write-Host "Gerando variantes do tema claro:"
# Tema claro -> usado na troca por prefers-color-scheme (aba do navegador e Safari 16.4+)
New-Icon $light "apple-touch-icon-light.png" 180
New-Icon $light "favicon-light.png"          96

Write-Host "`nConcluido. Icones gerados em $here"
