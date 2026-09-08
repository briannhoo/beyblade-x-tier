# X 天梯 · Beyblade X Tier

個人用嘅 Beyblade X 天梯表。上蓋 / 固鎖 / 軸心 / 輔助戰刃分級，可以自己改等級、標已擁有、寫備註。單檔、零依賴、離線用得。

**網址**：https://briannhoo.github.io/beyblade-x-tier/

iPhone Safari 開條 link → 分享 → 加入主畫面，就有全螢幕 app。

---

## 資料來源同限制

**天梯等級（386 件，X / S+ / S / A+ / A / B+ / B / C+ / C / D+ / D / E+ / E / 未分級）**

整份抄自[台灣天梯情報站](https://stan-yao.github.io/beyblade_x_tier/)，2026-09-08 擷取。等級、名稱、型號、屬性同相片都係佢哋嘅資料，唔係我自己評。呢個 app 淨係俾你喺佢個底稿上面改。

**相片**：外連自 `i.ibb.co`（原站用嘅圖床），冇下載重發。載唔到會顯示零件名。

**橙色角標＝大賽數據交叉標示**（36 件）。大賽入賞統計另外有一套評級，方法唔同、結論唔一定夾（例：騎士重盾喺原站係 D+，大賽數據係 A）。撳入去兩個都見到：

| 出處 | 樣本 | 日期 |
|---|---|---|
| BBXHub | 3,918 場賽事 / 39,726 組配置 | 04/09/2026 |
| BEYWATCH.GG | 3,282 場賽事 | 07/09/2026 |
| BeyX Hub | 頂級配置清單 | 17/06/2026 |
| 日本社群共識 | 軸心五強 LR / FB / H / UF / E | 07/2026 |

**未入嘅部分**：Namaste 阿土同白 Shiro 嘅天梯係喺 YouTube 影片入面講，抽唔到文字，所以佢哋嘅排名一件都冇入。要跟佢哋嘅版本要自己睇片改。

原站不時會改，呢度係 2026 年 9 月頭嘅快照。你改過嘅零件會一直保住你嘅版本，唔會被覆蓋。

---

## 檔案結構

```
beyblade-x-tier.html     # source（單檔，無 <head>，同時係 Claude Artifact 版本，386 件資料內嵌）
data.txt                 # 由原站擷取嘅 386 行原始資料，作紀錄／重新匯入用
build.sh                 # 由 source 產生 docs/index.html
make-icons.ps1           # 產生 PWA icon（PowerShell + System.Drawing）
docs/                    # GitHub Pages 服務嘅資料夾
  index.html             # build 出嚟，唔好直接改
  sw.js                  # service worker（離線）
  manifest.webmanifest
  *.png                  # icon
```

## 改嘢流程

1. 改 `beyblade-x-tier.html`（唯一一份 app 程式碼）
2. `bash build.sh`
3. 升 `docs/sw.js` 入面嘅 `VERSION`，唔係已裝咗嘅手機會繼續食舊 cache
4. commit + push，Pages 自動出返新版

改 icon 就行 `powershell -ExecutionPolicy Bypass -File make-icons.ps1`。
注意 `.ps1` 要存 UTF-8 **連 BOM**，Windows PowerShell 5.1 先讀得正中文註解。

## 資料存喺邊

改動存喺瀏覽器 `localStorage`，唔會上 repo。即係：

- 換機／清 Safari 資料 = 冇晒。想過機就用「⋯ → 匯出我的天梯」出 JSON，另一邊匯入。
- 呢個 repo 係 public，但入面淨係得 app 同種子資料，冇你嘅個人紀錄。

另有一個 Claude Artifact 版本，用雲端儲存做跨機同步，但冇離線同全螢幕。兩個版本嘅資料獨立，唔會互通。
