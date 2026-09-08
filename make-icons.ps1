# 產生 PWA icon：石墨底 + X 橙紅倒角方塊 + 深色 X
# 用法： powershell -ExecutionPolicy Bypass -File make-icons.ps1
Add-Type -AssemblyName System.Drawing

$out = Join-Path $PSScriptRoot 'pwa'
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out | Out-Null }

$ground = [System.Drawing.ColorTranslator]::FromHtml('#14161a')
$accent = [System.Drawing.ColorTranslator]::FromHtml('#ff4d2e')

function New-Icon {
    param([int]$size, [string]$file, [double]$inset)

    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear($ground)

    # 倒角方塊：右下角切走，同 header 個 mark 一樣
    $m = [int]($size * $inset)
    $s = $size - 2 * $m
    $cut = [int]($s * 0.24)
    $pts = @(
        (New-Object System.Drawing.Point($m, $m)),
        (New-Object System.Drawing.Point(($m + $s), $m)),
        (New-Object System.Drawing.Point(($m + $s), ($m + $s - $cut))),
        (New-Object System.Drawing.Point(($m + $s - $cut), ($m + $s))),
        (New-Object System.Drawing.Point($m, ($m + $s)))
    )
    $brush = New-Object System.Drawing.SolidBrush($accent)
    $g.FillPolygon($brush, $pts)

    # X：兩條粗斜槓，唔靠字型，粗幼跟住尺寸縮放
    $pad = $s * 0.26
    $x0 = $m + $pad
    $x1 = $m + $s - $pad
    $y0 = $m + $pad
    $y1 = $m + $s - $pad
    $pen = New-Object System.Drawing.Pen($ground, [single]($s * 0.155))
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Square
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Square
    $g.DrawLine($pen, [single]$x0, [single]$y0, [single]$x1, [single]$y1)
    $g.DrawLine($pen, [single]$x1, [single]$y0, [single]$x0, [single]$y1)

    $path = Join-Path $out $file
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

    $g.Dispose(); $bmp.Dispose(); $brush.Dispose(); $pen.Dispose()
    Write-Output "$file  $size x $size"
}

New-Icon -size 512 -file 'icon-512.png'        -inset 0.20
New-Icon -size 192 -file 'icon-192.png'        -inset 0.20
New-Icon -size 180 -file 'apple-touch-icon.png' -inset 0.10
New-Icon -size 32  -file 'favicon-32.png'       -inset 0.06
