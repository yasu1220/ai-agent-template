# セットアップガイド

このフォルダを受け取った人が同じ環境を再現するための手順書です。  
対象：Mac / Windows ユーザー / Claude Code インストール済みの方

---

## 必要なもの

- **Obsidian**（未インストールの場合は [obsidian.md](https://obsidian.md) からダウンロード）
- **Claude Code**（インストール済み前提）

---

## 手順 1：フォルダを展開する

zip を展開すると `AIエージェント会社設立` というフォルダが出てきます。  
好きな場所に置いてください（例：`~/Documents/AIエージェント会社設立`）。

---

## 手順 2：Obsidian で保管庫を開く

1. Obsidian を起動
2. 「保管庫を開く」→「フォルダを開く」を選択
3. **`AIエージェント会社設立` フォルダそのものを選択**して開く

> ⚠️ 注意：`AIエージェント会社設立` の**一つ上**のフォルダを開かないこと。  
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

## 手順 5：Claude Code でフォルダを開く

```bash
cd ~/Documents/AIエージェント会社設立
claude
```

または Claude Code の「フォルダを開く」から `AIエージェント会社設立` を選択。

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
Ice Bath Japan の Instagram 投稿文を3案作って
```

---

## OS 別の注意事項

### Windows
`scheduled/` フォルダの `.ps1` スクリプトはそのまま実行できます。  
パスはスクリプト自身の場所から自動解決されるため、どのディレクトリに置いても動作します。

### Mac / Linux
`scheduled/` フォルダに PowerShell スクリプト（`.ps1`）が入っていますが、  
**これらは現時点では Mac / Linux での自動実行を想定していません。**  
手動で Claude Code に依頼するか、必要になったタイミングで bash スクリプトへの書き直しを検討してください。

---

## フォルダ構造（参考）

```
AIエージェント会社設立/
├── CLAUDE.md              ← AI への共通ルール（触らなくてOK）
├── SETUP.md               ← このファイル
├── obsidian-vault/        ← 文脈エンジン（自分の情報・哲学）
├── task-board/            ← カンバンボード・ダッシュボード
├── daily/                 ← 日次TODO
├── agents/                ← AIエージェント定義
└── scheduled/             ← 自動実行スクリプト（Mac では未対応）
```
