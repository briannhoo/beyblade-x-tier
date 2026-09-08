#!/usr/bin/env bash
# 由 beyblade-x-tier.html（Artifact 版，單檔無 head）產生 docs/index.html（GitHub Pages 版）。
# 兩邊共用同一份 app 程式碼，改完 source 行一次呢個就同步。
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$DIR/beyblade-x-tier.html"
OUT="$DIR/docs/index.html"

[ -f "$SRC" ] || { echo "搵唔到 $SRC"; exit 1; }

# 用 </style> 做分界：之前嘅入 <head>，之後嘅入 <body>
LINE="$(grep -n '^</style>$' "$SRC" | head -1 | cut -d: -f1)"
[ -n "$LINE" ] || { echo "source 入面搵唔到單獨一行嘅 </style>"; exit 1; }

{
  cat <<'HEAD'
<!doctype html>
<html lang="zh-HK">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#14161a">
<meta name="description" content="個人 Beyblade X 天梯表：上蓋／固鎖／軸心／輔助戰刃分級、擁有紀錄同備註。">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="X 天梯">
<link rel="manifest" href="manifest.webmanifest">
<link rel="apple-touch-icon" href="apple-touch-icon.png">
<link rel="icon" href="favicon-32.png" sizes="32x32" type="image/png">
HEAD

  sed -n "1,${LINE}p" "$SRC"

  echo '</head>'
  echo '<body>'

  sed -n "$((LINE + 1)),\$p" "$SRC"

  echo '</body>'
  echo '</html>'
} > "$OUT"

echo "已產生 $OUT  ($(wc -c < "$OUT") bytes)"
echo "提醒：改完 app 記得升 docs/sw.js 入面嘅 VERSION，唔係手機會食舊 cache。"
