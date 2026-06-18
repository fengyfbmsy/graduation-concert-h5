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

function Export-CloudPng {
  param(
    [System.Drawing.Image]$Image,
    [int]$X,
    [int]$Y,
    [int]$W,
    [int]$H,
    [int]$OutW,
    [int]$OutH,
    [string]$Path
  )

  $bitmap = New-Object System.Drawing.Bitmap($OutW, $OutH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $dest = New-Object System.Drawing.Rectangle(0, 0, $OutW, $OutH)
  $src = New-Object System.Drawing.Rectangle($X, $Y, $W, $H)
  $graphics.DrawImage($Image, $dest, $src, [System.Drawing.GraphicsUnit]::Pixel)
  $graphics.Dispose()

  for ($yy = 0; $yy -lt $bitmap.Height; $yy++) {
    for ($xx = 0; $xx -lt $bitmap.Width; $xx++) {
      $pixel = $bitmap.GetPixel($xx, $yy)
      $hue = $pixel.GetHue()
      $sat = $pixel.GetSaturation()
      $bri = $pixel.GetBrightness()
      $r = [int]$pixel.R
      $g = [int]$pixel.G
      $b = [int]$pixel.B

      $skyLike = (($hue -ge 175 -and $hue -le 215 -and $sat -gt 0.13 -and $bri -lt 0.82) -or
        ($b -gt 112 -and $g -gt 95 -and $r -lt 170 -and ($b - $r) -gt 22 -and ($g - $r) -gt 12))
      $cloudCore = (($r -gt 205 -and $g -gt 210 -and $b -gt 210) -or
        ($bri -gt 0.72 -and $sat -lt 0.2) -or
        ($r -gt 168 -and $g -gt 178 -and $b -gt 178 -and $sat -lt 0.22))

      $alpha = 255
      if ($skyLike -and -not $cloudCore) {
        $alpha = 0
      } elseif ($skyLike) {
        $alpha = 108
      } elseif ($bri -lt 0.32) {
        $alpha = 0
      } elseif (-not $cloudCore -and $sat -gt 0.3) {
        $alpha = 90
      }

      $edge = [Math]::Min([Math]::Min($xx, $bitmap.Width - 1 - $xx), [Math]::Min($yy, $bitmap.Height - 1 - $yy))
      if ($edge -lt 18) {
        $alpha = [int]($alpha * ($edge / 18.0))
      }

      $bitmap.SetPixel($xx, $yy, [System.Drawing.Color]::FromArgb($alpha, $r, $g, $b))
    }
  }

  $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
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
  Export-CloudPng $image 0 11300 5200 4700 500 452 (Join-Path $OutDir "cloud-far-left.png")
  Export-CloudPng $image 13100 9300 4300 3600 420 353 (Join-Path $OutDir "cloud-far-right.png")
  Export-CloudPng $image 1800 8200 12900 6800 680 359 (Join-Path $OutDir "cloud-mid-main.png")
  Export-CloudPng $image 0 17000 17717 4800 720 195 (Join-Path $OutDir "cloud-front-bottom.png")
  Export-CloudPng $image 12800 13600 4300 3000 400 279 (Join-Path $OutDir "cloud-small-right.png")
} finally {
  $image.Dispose()
}
