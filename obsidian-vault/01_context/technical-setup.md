# Technical Setup — 寺田 雄人

> 使用環境・ツール・連携サービスの一覧。  
> AIが「自分が動いている環境」を理解するための情報。

---

## OS / 基本環境

- **OS**: macOS
- **シェル**: zsh（macOS標準）
- **エディタ**: Visual Studio Code

---

## AI関連

- **Claude Code**: 本格運用時にClaude MAX移行を検討
- **その他**: 必要に応じて Gemini / Perplexity を使い分け

---

## 知識管理

- **Obsidian**: Vault は `obsidian-vault/`
- **必須プラグイン**:
  - Kanban (タスクボード)
  - Dataview (集計ビュー)
  - Templater (テンプレ展開)

---

## タスク管理

- **メイン**: `task-board/main-board.md` (Obsidian Kanban)
- **日次TODO**: `daily/YYYY-MM-DD.md`
- **inbox**: `obsidian-vault/00_inbox/`

---

## 自動化

- **定期実行**: launchd（macOS標準）
- **スクリプト**: `scheduled/*.ps1`（PowerShell Core / pwsh で実行）
- **登録方法**: `pwsh ./scheduled/register-morning-standup.ps1`

---

## 開発・コード関連

<!-- 使用言語・フレームワーク・リポジトリ等 -->

---

## 連携サービス（任意）

- iCloud Drive: スマホ⇄Mac同期用（オプション）
- GitHub: バージョン管理

---

## 環境変数・設定ファイルの場所

<!-- 個人の環境固有の設定ファイルパス。共有時は除外 -->

- ……
