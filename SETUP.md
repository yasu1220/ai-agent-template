# セットアップガイド

このリポジトリを clone した人が同じ環境を再現するための手順書です。  
対象：Windows / Mac ユーザー / Claude Code インストール済みの方

---

## 必要なもの

- **Git**（[git-scm.com](https://git-scm.com) からダウンロード）
- **Obsidian**（[obsidian.md](https://obsidian.md) からダウンロード）
- **Claude Code**（インストール済み前提）
- **PowerShell Core (pwsh)**（Macの場合のみ — Windowsは不要）
  - Mac: `brew install --cask powershell`

---

## 手順 1：リポジトリを clone する

```powershell
git clone <リポジトリURL> AIエージェント会社設立
cd AIエージェント会社設立
```

好きな場所に置いてください（例：`C:\Users\yourname\Documents\AIエージェント会社設立`）。

---

## 手順 2：Obsidian で保管庫を開く

1. Obsidian を起動
2. 「保管庫を開く」→「フォルダを開く」を選択
3. **clone したフォルダそのもの（`AIエージェント会社設立`）を選択**して開く

> ⚠️ 注意：clone 先フォルダの**一つ上**を開かないこと。  
> ダッシュボードのパスがずれて何も表示されなくなります。

---

## 手順 3：コミュニティプラグインをインストールする

Obsidian の設定から以下の3つをインストール・有効化してください。

1. 設定（⚙️）→「コミュニティプラグイン」→ セーフモードを **OFF**
2. 「参照」から以下を検索してインストール・有効化

| プラグイン名 | 用途 |
|---|---|
| **Kanban** | task-board/main-board.md をカンバンボードとして表示 |
| **Dataview** | task-board/dashboard.md でタスクを集計・表示 |
| **Templater** | daily ノートのテンプレート展開（任意） |

---

## 手順 4：テンプレートをコピーして自分の情報を書く

各 `.template.md` ファイルをコピーして `.md` にリネームし、内容を書き換えてください。  
`.md` ファイルは `.gitignore` 対象なので、`git pull` で上書きされることはありません。

**Mac / Linux（ターミナル）**

```bash
cp obsidian-vault/01_context/philosophy-values.template.md obsidian-vault/01_context/philosophy-values.md
cp obsidian-vault/01_context/professional-identity.template.md obsidian-vault/01_context/professional-identity.md
cp obsidian-vault/01_context/technical-setup.template.md obsidian-vault/01_context/technical-setup.md
cp task-board/dashboard.template.md task-board/dashboard.md
```

**Windows（PowerShell）**

```powershell
Copy-Item obsidian-vault/01_context/philosophy-values.template.md obsidian-vault/01_context/philosophy-values.md
Copy-Item obsidian-vault/01_context/professional-identity.template.md obsidian-vault/01_context/professional-identity.md
Copy-Item obsidian-vault/01_context/technical-setup.template.md obsidian-vault/01_context/technical-setup.md
Copy-Item task-board/dashboard.template.md task-board/dashboard.md
```

### 書き換えるファイル

| ファイル | 内容 | 優先度 |
|---|---|---|
| `obsidian-vault/01_context/philosophy-values.md` | 価値観・哲学・聖域・バグサイン | 必須 |
| `obsidian-vault/01_context/professional-identity.md` | 本業・副業・スキル・ロードマップ | 必須 |
| `obsidian-vault/01_context/technical-setup.md` | OS・エディタ・ツール・リポジトリ | 推奨 |
| `agents/02_content/brand-voice/desk/brand-voice.md` | SNS・コンテンツのトーン・文体ルール | 推奨 |

---

## 手順 5：スケジューラを設定する（自動化したい場合）

3つの定期タスクを自動実行できます。

| タスク名 | 実行タイミング | 役割 |
|---|---|---|
| `AIAgent_MorningStandup` | 毎日 09:00 | daily ファイル生成・タスク選定・git push |
| `AIAgent_SaturdayPush` | 毎週土曜 22:00 | progress-tracking の git push |
| `AIAgent_StrategyReview` | 毎週日曜 08:00 | 戦略レビュー（strategy-review-YYYY-MM-DD.md）を自動生成 |

### Windows（タスクスケジューラ）

PowerShell を**管理者として起動**し、リポジトリのルートに `cd` した後：

```powershell
& ".\scheduled\register-morning-standup.ps1"
```

### Mac（launchd）

ターミナルで実行：

```bash
pwsh ./scheduled/register-morning-standup.ps1
```

実行すると `~/Library/LaunchAgents/` に plist ファイルが3つ生成され自動実行されます。

> 💡 自動化しない場合は `scheduled/morning-standup.ps1` を手動実行してください。

---

## 手順 6：Claude Code でフォルダを開く

```powershell
cd AIエージェント会社設立
claude
```

または Claude Code の「フォルダを開く」から clone したフォルダを選択。

---

## 日常の使い方

### 毎日やること

1. `daily/YYYY-MM-DD.md` を作成（Claude Code に「今日の daily ノートを作って」と依頼すると自動生成）
2. Top3 に今日やる main-board のタスクを設定
3. 作業しながらチェックを入れる

### タスクを完了にするとき

Kanban ボードで DONE 列にドラッグ、または Claude Code に以下のように依頼：

```
T0004 を DONE に移動して
```

### AI にタスクを頼むとき

Claude Code のチャットで依頼するだけで OK です。例：

```
Instagram 投稿文を3案作って
```

---

## OS 別の注意事項

### Windows
`scheduled/` フォルダの `.ps1` スクリプトはそのまま `powershell.exe` で実行できます。  
パスはスクリプト自身の場所から自動解決されるため、どのディレクトリに置いても動作します。

タスクスケジューラへの登録（手順5）は PowerShell を **管理者として起動** して実行してください。

### Mac
PowerShell Core (`pwsh`) が必要です。未インストールの場合：

```bash
brew install --cask powershell
```

タスクの自動登録（手順5）は以下で実行します：

```bash
pwsh ./scheduled/register-morning-standup.ps1
```

実行すると `~/Library/LaunchAgents/` に launchd の plist ファイルが生成され、  
毎日 09:00 / 毎週土曜 22:00 / 毎週日曜 08:00 に自動実行されます。

登録を解除したい場合：

```bash
launchctl unload ~/Library/LaunchAgents/com.aiagent.morningstandup.plist
launchctl unload ~/Library/LaunchAgents/com.aiagent.saturdaypush.plist
launchctl unload ~/Library/LaunchAgents/com.aiagent.strategyreview.plist
```

---

## フォルダ構造（参考）

```
AIエージェント会社設立/
├── CLAUDE.md                   ← AI への共通ルール（触らなくてOK）
├── SETUP.md                    ← このファイル
├── obsidian-vault/             ← 文脈エンジン（自分の情報・哲学）
│   ├── 01_context/             ← 個人情報（gitignore・各自が書く）
│   ├── 05_strategy/            ← OKR・戦略ファイル
│   └── ...
├── task-board/                 ← カンバンボード・ダッシュボード
├── daily/                      ← 日次TODO（gitignore・個人データ）
├── agents/                     ← AIエージェント定義
├── scheduled/                  ← 自動実行スクリプト
│   ├── morning-standup.ps1         ← 毎朝9時に自動実行
│   ├── saturday-push.ps1           ← 毎週土曜22時に自動実行
│   ├── generate-strategy-review.ps1 ← 毎週日曜8時に戦略レビュー自動生成
│   └── register-morning-standup.ps1 ← スケジューラ登録（初回のみ）
└── logs/                       ← 実行ログ（gitignore）
```
