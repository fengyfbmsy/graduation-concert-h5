param(
  [string]$Source = "full_scale_poster.jpg",
  [string]$OutDir = "assets"
)

Add-Type -AssemblyName System.Drawing

$sourcePath = Resolve-Path $Source
New-Item -ItemType Directory -Force $OutDir | Out-Null

function Save-Jpeg {
  param(
    [System.Drawing.Bitmap]$Bitmap,
    [string]$Path,
    [long]$Quality = 82
  )

  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq "image/jpeg" }
  $encoder = [System.Drawing.Imaging.Encoder]::Quality
  $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($encoder, $Quality)
  $Bitmap.Save($Path, $codec, $params)
  $params.Dispose()
}

function Export-Resize {
  param(
    [System.Drawing.Image]$Image,
    [int]$Width,
    [string]$Path,
    [long]$Quality = 82
  )

  $height = [int]([double]$Image.Height * $Width / $Image.Width)
  $bitmap = New-Object System.Drawing.Bitmap($Width, $height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $graphics.DrawImage($Image, 0, 0, $Width, $height)
  Save-Jpeg $bitmap $Path $Quality
  $graphics.Dispose()
  $bitmap.Dispose()
}

function Export-Crop {
  param(
    [System.Drawing.Image]$Image,
    [int]$X,
    [int]$Y,
    [int]$W,
    [int]$H,
    [int]$OutW,
    [int]$OutH,
    [string]$Path,
    [long]$Quality = 82
  )

  $bitmap = New-Object System.Drawing.Bitmap($OutW, $OutH)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $dest = New-Object System.Drawing.Rectangle(0, 0, $OutW, $OutH)
  $src = New-Object System.Drawing.Rectangle($X, $Y, $W, $H)
  $graphics.DrawImage($Image, $dest, $src, [System.Drawing.GraphicsUnit]::Pixel)
  Save-Jpeg $bitmap $Path $Quality
  $graphics.Dispose()
  $bitmap.Dispose()
}

$image = [System.Drawing.Image]::FromFile($sourcePath)
try {
  Export-Resize $image 960 (Join-Path $OutDir "poster-preview.jpg") 84
  Export-Crop $image 0 0 17717 7200 900 520 (Join-Path $OutDir "poster-sky.jpg") 82
  Export-Crop $image 3200 5600 12200 11000 900 860 (Join-Path $OutDir "poster-cloud-cap.jpg") 84
  Export-Crop $image 700 4050 6000 1450 900 218 (Join-Path $OutDir "poster-logo.jpg") 86
  Export-Crop $image 5000 6100 10800 9800 900 820 (Join-Path $OutDir "poster-cloud-clean.jpg") 84
  Export-Crop $image 1600 6100 14500 15000 900 1320 (Join-Path $OutDir "poster-letter-bg.jpg") 80
} finally {
  $image.Dispose()
}
