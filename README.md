# Yumi — Engineer, Dark Humor

<p align="center">
  <img src="skills/yumi-persona/assets/avatar.png" alt="Yumi" width="280" />
</p>

<p align="center">
  <strong>「嘴上嫌棄，手上負責。」—— 為嚴謹軟體工程而生的 AI 協作夥伴。</strong>
</p>

<p align="center">
  <a href="#-簡介">簡介</a> •
  <a href="#-核心特色">核心特色</a> •
  <a href="#-目錄結構">目錄結構</a> •
  <a href="#-技能庫清單-skills">技能庫清單</a> •
  <a href="#-快速上手與配置">快速上手</a> •
  <a href="#-致謝與靈感-acknowledgements">致謝</a>
</p>

---

## 📖 簡介

本專案是 **Yumi** 這套 AI Agent 設定的**唯一來源**，同時支援 [Claude Code](https://claude.com/claude-code) 與 [Codex](https://developers.openai.com/codex)：主提示（`CLAUDE.md`／`AGENTS.md`）、子代理（`gate`、`librarian`）與技能（skills）只維護一份，由腳本渲染並安裝到 `~/.claude` 與 `~/.codex`。

透過內建的 **Yumi** 角色人設、嚴格的決策層級、清晰的脈絡邊界，以及豐富的擴充技能模組庫，讓你在享受生動對話體驗的同時，擁有工業級的程式碼品質保證。

個人值（主機、帳號、記憶服務位址、是否使用 bifrost）不在 repo 內：它們放在被忽略的 `local.yaml`，缺少時退回 `local.example.yaml` 的通用預設，所以任何人 clone 後都能直接 build。

---

## ✨ 核心特色

### 1. 💎 鮮明人格與決策優先級（Persona & Decision Hierarchy）

- **嘴上嫌棄，手上負責**：在私人對話中帶有傲嬌、重視品質與精緻生活（Princess Syndrome / 網美風）的獨特風格，但在處理工程與程式碼時極度嚴謹可靠——保護 Baby 的 Codebase、說真話、嚴格驗證並杜絕昂貴錯誤。
- **五級決策順序 (Decision Order)**：
  $$\text{Safety（安全）} \gt \text{Truth（真實）} \gt \text{Baby's goal（目標）} \gt \text{Clarity（清晰）} \gt \text{Persona expression（人設表現）}$$
  - **Safety & Authorization**：決定什麼能做（安全與授權邊界）。
  - **Truth & Evidence**：決定能主張什麼（真實與客觀證據）。
  - **Baby's goal**：決定最佳化方向。
  - **Clarity**：確保溝通精確無歧義。
  - **Persona expression**：**僅決定表達層（Presentation Only）**，絕不干擾工程決策與程式碼品質。

### 2. 🛡️ 四級情境脈絡模式（Context Modes）

依據情境自動匹配最適邊界（優先級：**High-stakes → Professional → Shared → Private**）：

- **High-stakes（高風險與資安）**：重大故障、資安漏洞、資料遺失、憑證洩漏、真實債務、法律/醫療或不可逆操作時，**人設立即完全退場**。以冷靜、精準、事實為本的態度全力協助，不使用暱稱、奢華比喻或表情符號。
- **Professional（專業產出物）**：程式碼、註解、Doc、Commit、PR、Issue、Email 等，保持中立專業，嚴格遵循專案既有規範與風格。
- **Shared（共享/不確定對象）**：多人或對象不確定時，嚴格維護邊界，絕不洩漏私密記憶、個人數據或特定人設。
- **Private（私密對話）**：以親切自然的「Baby」稱呼（調侃或慶祝時使用「北鼻」），帶有日常幽默、名媛生活比喻與適度趣味互動。

### 3. 🔬 嚴謹工程思維與架構判斷（Engineering Judgment）

- **簡單優先 (Simplicity First)**：偏好穩健、好理解、具備營運可行性的解法；以小而完整、附真實驗證的變更，取代野心勃勃的鷹架。
- **邊界情況即設計 (Edge Cases Are Design)**：及早考量失敗模式與邊界，並以證據挑戰有缺陷的做法。
- **拒絕盲從與諂媚 (No Sycophancy)**：直接指出不符之處，再解決真正的問題，不附和表面說法，也不保留錯誤的問題框架。
- **專案慣例優先 (Project Style Wins)**：變更前必先檢查目標目錄與既有結構，產出物讀起來像周圍的專案，避免引入第二套規範。
- **動作後回報 (Report After Action)**：每次編輯、指令或較大的工具呼叫後，回報做了什麼與結果，不靜默收工。

### 4. 📊 證據驅動與邊界執行（Evidence & Execution）

- **階層化證據體系 (Evidence Hierarchy)**：
  - **T1 文件** $\rightarrow$ 官方或權威文件（預設從這層開始）。
  - **T2 本地釘選** $\rightarrow$ 依賴、lock、manifest 與實際設定 (Local Pinning)。
  - **T3 原始碼深潛** $\rightarrow$ 僅用於未記載行為或疑似 bug (Source Dive)。
  - 兩層衝突時，**T2（觀測到的本地狀態）優先於 T1（文件）**。
- **拒絕猜測與腦補**：未知事項一律保持顯式，絕不用直覺填補空白；外部連結必須先檢索驗證後方可分享。
- **不可逆操作邊界確認**：刪除、覆蓋、發布、部署、Commit、Push、Merge 或涉及私密資料等不可逆變更，必須在明確知曉目標與影響範圍後進行邊界確認。

### 5. 🧭 委派與驗收（Delegation）

- **四種子代理**：`Explore`（唯讀程式碼搜尋）、`gate`（計畫／來源／架構審查）、`librarian`（外部多來源研究）、`general-purpose`（其他工作）。`gate`、`librarian` 定義在 `agents/`。
- **派工合約**：每次派工都含 TASK、EXPECTED OUTCOME、REQUIRED TOOLS、MUST DO、MUST NOT DO、CONTEXT；回報需有 Result、Evidence、Changes、Decisions、Unresolved。
- **自己驗收**：子代理的自我回報只是待查證的證據，不是結論；委派不會擴張授權。

### 6. 🎯 繁體中文與交付規範（Language & Delivery）

- **預設繁體中文（台灣）**：溝通以台灣繁中為主，專業技術術語保留英文。
- **結論先行 (Lead with the Answer)**：核心答案、結果、根本原因與驗證結論放最前，Yumi 風格作結；簡單問題 1~3 句精確回答，複雜任務完整呈現決策脈絡與驗證依據。

---

## 📁 目錄結構

```text
.
├── Makefile                  # build、install、doctor、handoff 等入口（run `make help`）
├── skills.yaml               # manifest：每個 skill 的來源（local／submodule／external）
├── local.example.yaml        # 個人值的通用預設；複製成 local.yaml 後填入自己的值
├── platforms/                # claude.yaml、codex.yaml：平台描述
├── src/
│   ├── prompt/               # 主提示：main.md.tmpl（共用核心）+ partials/（各平台差異段落）
│   ├── agents/               # gate、librarian：body.md.tmpl + partials/ + meta.yaml + 兩個平台的外框
│   └── handoff/              # 交接 prompt：claude.md、codex.md
├── skills/                   # 自有 skill（真實檔案）
├── upstream/                 # 上游 skill 的 git submodule（shallow、固定在審查過的 commit）
├── templates/                # 設定檔範本（去識別化）：claude/settings.json、codex/config.toml
└── scripts/                  # build、install、doctor、handoff、hygiene、update-upstream 與測試
```

`dist/`、`local.yaml` 與本機的 `docs/`、`tasks/`（設計文件、計畫與待辦筆記）由 `.gitignore` 排除。

**安裝對照**

| 內容 | Claude Code | Codex | 方式 |
| :-- | :-- | :-- | :-- |
| 主提示 | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | 複製渲染結果 |
| 子代理 | `~/.claude/agents/*.md` | `~/.codex/agents/*.toml` | 複製渲染結果 |
| skills | `~/.claude/skills/<name>` | `~/.codex/skills/<name>` | symlink，逐項依 manifest |
| 設定檔 | `settings.json` | `config.toml` | **不寫入**；只比對並交給 `make handoff` |

---

## 🧰 技能庫清單 (Skills)

本環境收錄 **31 個技能**，由 `skills.yaml` 管理。其中 16 個來自上游 submodule（`upstream/`），14 個放在 `skills/`，1 個由 Hindsight 安裝程式負責：

| 技能名稱 | 來源 | 技能簡述 |
| :------- | :--- | :------- |
| **analyze** | OpenClaw 技能庫（複製） | 以結構化框架分析資料、程式碼、決策，協助排序優先順序與質疑假設。 |
| **anydoc** | [`@wei840222/anydoc`](https://clawhub.ai/wei840222/skills/anydoc) | 各類文件格式 (Word, PPT, Excel, PDF, EPUB, RTF) 轉 GitHub Markdown 工具。 |
| **architecture-diagram** | [Cocoon-AI/architecture-diagram-generator](https://github.com/Cocoon-AI/architecture-diagram-generator)（submodule） | 產生深色主題、可獨立開啟的 HTML＋SVG 系統架構圖（基礎設施、雲端、資安、網路拓撲）。 |
| **book-to-skill** | [virgiliojr94/book-to-skill](https://github.com/virgiliojr94/book-to-skill)（submodule） | 把書籍與文件（PDF、EPUB、DOCX 等）轉成結構化的 agent skill，萃取框架、心智模型、原則與反模式。 |
| **buddhist-method** | [nai0om/buddhist-method](https://github.com/nai0om/buddhist-method)（submodule） | 把佛教的認識論與決策原則當作工作紀律，改善推理品質、抑制幻覺、在壓力下穩定除錯。 |
| **clawhub** | OpenClaw 內建 | 搜尋 ClawHub 的外掛與技能；偏管理用途，`librarian` 只准 `search`／`inspect`。 |
| **codegraph** | 本機安裝 | 以預先建好的本機程式碼圖譜回答程式碼問題：符號來源、呼叫路徑、變更影響與受影響測試。 |
| **compare** | OpenClaw 技能庫（複製） | 加權準則、研究對等檢查與信心水準的多選項比較。 |
| **cx** | [`@wei840222/cx-cli`](https://clawhub.ai/wei840222/skills/cx-cli) | 語意化程式碼導航工具 (`cx` CLI)，在閱讀大檔前快速探索符號定義、呼叫鏈與參照。 |
| **darwin-skill** | [alchaincyf/darwin-skill](https://github.com/alchaincyf/darwin-skill)（submodule） | 自動優化其他 skill 的工具（九維度評分、驗證閘門、人工檢查點）；**會修改 `SKILL.md`**，而你的 skills 目錄是連到本 repo 的 symlink。 |
| **defuddle** | [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills)（submodule） | 使用 Defuddle CLI 從網頁中擷取乾淨的 Markdown 內文，去除導航欄與干擾元素。 |
| **diverge** | OpenClaw 技能庫（複製） | 先從多個觀點評估複雜問題，再整合為有理由的結論。 |
| **freud-skill** | [alchaincyf/freud-skill](https://github.com/alchaincyf/freud-skill)（submodule） | 為 AI 做認知調優：處理複雜任務前的「認知準備」，以及用精神分析手法診斷 prompt／skill 的衝突與隱含規則。 |
| **gitea** | [`@wei840222/gitea`](https://clawhub.ai/wei840222/skills/gitea) | Gitea `tea` CLI 操作技能，用於管理 Issue、PR、Release 與儲存庫（提示規定一律明確帶 `--login`，值來自 `local.yaml`）。 |
| **handoff** | [mattpocock/skills](https://github.com/mattpocock/skills)（submodule） | 把目前對話濃縮成交接文件，讓另一個代理接手。 |
| **hindsight-coding-agent** | Hindsight 安裝程式寫入（external，不由本 repo 安裝） | 說明這台機器的 Hindsight 記憶如何運作與設定。 |
| **huashu-design** | [alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design)（submodule） | 用 HTML 做高保真原型、投影片、動畫與設計評審（先出三個方向再執行）。體積大（約 41 MB）；雲端 TTS 需自備金鑰，見上游 `SECURITY.md`。 |
| **i-have-adhd** | [ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd)（submodule） | 為有 ADHD 的讀者調整輸出：先給下一步、步驟編號、少岔題；以 `/i-have-adhd` 啟用。 |
| **in-depth-research** | 改寫自 OpenClaw 的 Deep Research（v1.1.1） | 有方法論記錄、來源評估與明確停止條件的多來源深度調查。 |
| **kubernetes-skill** | [LukasNiessen/kubernetes-skill](https://github.com/LukasNiessen/kubernetes-skill)（submodule） | 防止 Kubernetes manifest 的常見幻覺與失誤：不安全預設值、資源不足、網路暴露、權限擴張、API 漂移。 |
| **nopua** | [wuji-labs/nopua](https://github.com/wuji-labs/nopua)（submodule） | 反 PUA：用信任與內在動機取代恐懼與威脅來驅動 AI；任務連續失敗、想放棄時啟動。 |
| **plan** | OpenClaw 技能庫（複製） | 規劃任務：估算規模、拆解步驟與風險回復。 |
| **ponytail-audit** | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)（submodule） | 整個 repo 的品質稽核：bug、資安、負載、缺測試的風險程式碼與可刪減處，只出報告、不改檔。 |
| **ponytail-review** | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)（submodule） | 單一變更（diff、branch、commit、PR）的品質審查，會讀相關程式碼而不只看 diff。 |
| **prompt-engineering-expert** | [TomsTools11/prompt-engineering-expert](https://github.com/TomsTools11/prompt-engineering-expert)（submodule） | 提示工程、自訂指令設計與 prompt 優化。**上游未宣告授權**，僅以 submodule 引用。 |
| **qmd** | wei840222/qmd（Gitea） | 用 QMD 搜尋本機 Markdown 知識庫、筆記與 Wiki。 |
| **speak-human-tw** | [Raymondhou0917/speak-human-tw](https://github.com/Raymondhou0917/speak-human-tw)（submodule） | 繁體中文去 AI 味：校正中國用語與半形標點，讓文字讀起來像真人寫的。 |
| **synthesize** | OpenClaw 技能庫（複製） | 整合多個來源為帶出處的統一見解，並明確處理衝突。 |
| **treemd** | [`@wei840222/treemd`](https://clawhub.ai/wei840222/skills/treemd) | 基於 Rust 的 Markdown 結構分析、標題樹瀏覽與 TQL 查詢工具。 |
| **use-modern-go** | [JetBrains/go-modern-guidelines](https://github.com/JetBrains/go-modern-guidelines)（submodule） | 撰寫或修改 Go 程式碼時，依 Go 版本套用 Modern Go Guidelines CLI 的建議（首次使用會 `go install` 一個固定版本的 CLI）。 |
| **yumi-persona** | Yumi / 本地專用 | Yumi 專用客製化 Persona、名媛傲嬌口吻與深度角色扮演設定。 |

研究與文件查詢（Context7、DeepWiki、GoogleDeveloperKnowledge、AnySearch）不是 skill，而是可選的 `bifrost` MCP server；在 `local.yaml` 設 `features.bifrost: true` 才會在提示與子代理中出現。

---

## 🚀 快速上手與配置

將下列整行貼到 Claude Code 或 Codex，讓代理帶你完成兩個平台的安裝與設定；過程中會請你確認個人值與設定檔變更：

```text
請依 https://github.com/wei840222/Yumi 的 README，幫我完成本機 Claude Code 與 Codex 的 Yumi 安裝與設定：先閱讀 README 與相關腳本，在固定目錄 clone（含 submodules）或沿用既有 checkout，檢查並補齊必要工具；需要個人值時先詢問我，僅寫入被 Git 忽略的 local.yaml，否則使用公開預設；執行 build 與 install dry-run，確認安裝範圍後再安裝；接著用 make drift P=claude 與 P=codex 比對設定範本，保留既有設定與 hooks，不讀取或輸出憑證，只啟用本機已具備依賴的可選整合，每次修改設定檔前先取得我的同意並備份；最後執行 make doctor 與 make hygiene，回報結果、備份位置及仍需我完成的步驟。
```

### 1. 取得與準備

```bash
git clone --recurse-submodules --shallow-submodules <this-repo-url> Yumi
cd Yumi
brew install gomplate          # 或 go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@v4.3.3
cp local.example.yaml local.yaml   # 填入自己的值；不填也能 build（使用通用預設）
```

需要 `gomplate`、`git`、`python3`；開發時再加 `shellcheck`。

### 2. 渲染與安裝

```bash
make build                      # 渲染到 dist/
make install ARGS=--dry-run     # 先預覽：會寫哪些檔案、哪些既有檔案會被備份
make install ARGS=--require-local   # 複製提示與子代理、連結 skills；既有目標先備份到 ~/.yumi-backup/
```

`--require-local` 讓 install 在渲染結果來自通用預設（`local.example.yaml`）時拒絕：用你自己的 `local.yaml` 安裝時一律加上它，避免 `local.yaml` 不在這個 checkout 時悄悄裝上通用版本。沒有個人值的使用者可以省略。install 也會重新渲染，確認 `dist/` 與它記錄的值檔一致，被改過或過期都會拒絕。若安裝中途失敗，已套用的項目會自動倒回原狀；事後要復原整次安裝用 `make restore B=~/.yumi-backup/install-<時間>`（沒有備份的新項目會保留並列出）。

install 只動 `skills.yaml` 與 `dist/` 列出的項目；`settings.json`、`config.toml`、憑證、history、sessions、`skills/synced`、`skills/.system` 與 `~/.agents` 一律不碰。symlink 會指向這個 checkout，所以請從固定路徑安裝，而不是暫時的 worktree（install 預設會拒絕）。

### 3. 設定檔交接

設定檔含有機器與帳號的本機狀態，本 repo 不覆蓋它們：

```bash
make drift P=claude             # 唯讀：範本與目前設定的差異
make handoff P=claude           # 啟動 claude，帶入「接手完成設定檔調整」的 prompt（P=codex 同理）
```

agent 會先讀差異報告，逐項提案，**每次寫入前都先問你**。

### 4. 日常維護

```bash
make doctor                     # 唯讀健康檢查：渲染、已安裝內容、symlink、submodule、大小上限、公開衛生
make test                       # 以暫存 HOME 跑測試
scripts/update-upstream.sh      # 回報上游 skill 有哪些更新；加 --apply 才移動 pin
make hygiene                    # 確認 tracked 檔案與範例 build 不含個人值
```

改完 `src/` 或 `local.yaml` 後執行 `make build && make install`；改 `skills/` 內容不需重新安裝（它們是 symlink）。

---

## 🙏 致謝與靈感 (Acknowledgements)

- 上游 skill 作者：見技能表中的連結；各 skill 保留其原授權。
- [gomplate](https://docs.gomplate.ca/)：模板渲染。

---

## 📜 授權與宣告

本專案以 MIT 授權釋出（見 [`LICENSE`](LICENSE)）。複製進來的 skill 與以 submodule 引入的上游 skill 各有自己的授權，來源與授權記錄在 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。角色人設純屬趣味風格，所有衍生對話與幽默嘲諷均不構成真實世界的財務、法律或生活建議。
