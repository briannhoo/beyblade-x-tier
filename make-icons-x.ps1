# 產生暖色版 PWA icon：分裂式 X（左人字 + 右上／右下兩條斜槓）
# 深底 + 米白人字 + 橙色斜槓，同 app 內嘅 logo 一致
# 用法： powershell -ExecutionPolicy Bypass -File make-icons-x.ps1
Add-Type -AssemblyName System.Drawing

$out = Join-Path $PSScriptRoot 'docs/warm'
if (-not (Test-Path $out)) { New-Item -ItemType Directory -Path $out -Force | Out-Null }

$bg     = [System.Drawing.ColorTranslator]::FromHtml('#17130f')
$ink    = [System.Drawing.ColorTranslator]::FromHtml('#f2ede8')
$bright = [System.Drawing.ColorTranslator]::FromHtml('#f2921e')
$soft   = [System.Drawing.ColorTranslator]::FromHtml('#fac68a')

# logo 喺 120x120 座標系內嘅幾何，同 app 入面個 SVG 一樣
function New-Icon {
    param([int]$size, [string]$file, [double]$safe)

    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear($bg)

    # safe = logo 佔畫布幾多（maskable 要留邊）
    $span = $size * $safe
    $off  = ($size - $span) / 2.0
    $s = { param($v) $off + ($v / 120.0) * $span }

    $penW = [single](($span / 120.0) * 18)

    $penInk = New-Object System.Drawing.Pen($ink, $penW)
    $penInk.StartCap = [System.Drawing.Drawing2D.LineCap]::Flat
    $penInk.EndCap   = [System.Drawing.Drawing2D.LineCap]::Flat
    $penInk.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Miter
    $pts = @(
        (New-Object System.Drawing.PointF([single](& $s 22), [single](& $s 18))),
        (New-Object System.Drawing.PointF([single](& $s 58), [single](& $s 60))),
        (New-Object System.Drawing.PointF([single](& $s 22), [single](& $s 102)))
    )
    $g.DrawLines($penInk, $pts)

    $penSoft = New-Object System.Drawing.Pen($soft, $penW)
    $penSoft.StartCap = [System.Drawing.Drawing2D.LineCap]::Flat
    $penSoft.EndCap   = [System.Drawing.Drawing2D.LineCap]::Flat
    $g.DrawLine($penSoft, [single](& $s 78), [single](& $s 48), [single](& $s 106), [single](& $s 16))

    $penBright = New-Object System.Drawing.Pen($bright, $penW)
    $penBright.StartCap = [System.Drawing.Drawing2D.LineCap]::Flat
    $penBright.EndCap   = [System.Drawing.Drawing2D.LineCap]::Flat
    $g.DrawLine($penBright, [single](& $s 78), [single](& $s 72), [single](& $s 106), [single](& $s 104))

    $bmp.Save((Join-Path $out $file), [System.Drawing.Imaging.ImageFormat]::Png)

    $g.Dispose(); $bmp.Dispose()
    $penInk.Dispose(); $penSoft.Dispose(); $penBright.Dispose()
    Write-Output "$file  $size x $size"
}

# maskable 要收細，any 同 apple-touch 可以大啲
New-Icon -size 512 -file 'icon-512.png'         -safe 0.72
New-Icon -size 512 -file 'icon-512-maskable.png' -safe 0.56
New-Icon -size 192 -file 'icon-192.png'         -safe 0.72
New-Icon -size 180 -file 'apple-touch-icon.png' -safe 0.76
New-Icon -size 32  -file 'favicon-32.png'       -safe 0.86
