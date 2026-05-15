# AIエージェント会社設立

複数のAIエージェントを「会社」のように役割分担で運用する仕組み。  
1人で約20体のAI社員を回し、自分は判断と週次メンテだけに集中する状態を目指します。

> 設計思想：「どのAIが賢いか」ではなく「どう組織として回すか」で勝負する

---

## 全体構成

```
あなた (CEO・設計者)
    ↓
【調整層】Obsidian (文脈エンジン) + カンバンボード (タスク管理)
    ↓
┌─────────────┬─────────────┬─────────────┬─────────────┐
│エンジニアリング│  コンテンツ  │   ビジネス   │ インフラ運用 │
│ Claude Code  │   Cowork    │   Cowork    │ スケジューラ │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

詳細は [`docs/org-chart.md`](docs/org-chart.md) を参照。

---

## ディレクトリ構成

```
.
├── obsidian-vault/         📚 文脈エンジン（全AIが読む共通知識）
│   ├── 00_inbox/           ← 思いつきメモ
│   ├── 01_context/         ← 哲学・キャリア・ツール・デザイン
│   ├── 02_handoff/         ← AI同士の引き継ぎ
│   ├── 03_decisions/       ← 意思決定ログ (ADR)
│   ├── 04_projects/        ← 進行中プロジェクト
│   └── 99_archive/         ← 過去の残骸
│
├── task-board/             📋 カンバンボード
│   └── main-board.md       ← Obsidian Kanbanで開く
│
├── daily/                  📅 自分の日次TODO・振り返り
│   └── YYYY-MM-DD.md
│
├── agents/                 🤖 各AIエージェント定義
│   ├── 01_engineering/     14体（コード・実装）
│   ├── 02_content/          5体（原稿・SNS）
│   ├── 03_business/         4体（戦略・契約）
│   └── 04_infrastructure/   5体（基盤・安全弁）
│
├── claude/                 ⚙️ Claude Code 設定
├── scheduled/              ⏰ Windows タスクスケジューラ用
├── logs/                   📝 AI実行ログ（自動生成）
├── docs/                   📖 運用マニュアル等
├── README.md               (このファイル)
└── CLAUDE.md               (Claude Code/Cowork共通ルール)
```

---

## セットアップ手順

### 0. リポジトリを取得する

**初回（クローン）**
```bash
git clone https://github.com/yasu1220/ai-agent-template.git
cd ai-agent-template
```

**テンプレートの更新を取り込む（2回目以降）**
```bash
git pull origin main
```

> ⚠️ `obsidian-vault/01_context/` 配下は `.gitignore` で除外されているため、個人情報（哲学・キャリア・ツール設定）は `git pull` で上書きされません。

---

### 1. Obsidian をインストール
1. https://obsidian.md からダウンロード
2. 「Open vault」で `obsidian-vault/` フォルダを選択
3. プラグインインストール: Kanban / Dataview / Templater

### 2. 個人情報を埋める

各テンプレートをコピーして `.template.md` の部分を除いたファイル名で保存し、記入する。

**必須**
- `obsidian-vault/01_context/philosophy-values.md` ← あなたの哲学・価値観・聖域
- `obsidian-vault/01_context/professional-identity.md` ← キャリア・スキル・使える時間

**任意**（埋めなくても日次タスク生成は動く）
- `obsidian-vault/01_context/technical-setup.md` ← 使用ツール・環境

### 3. 今日の日次ファイルを生成して運用開始

Claude Code または Cowork に「今日のタスクを生成して」と依頼すると `daily/YYYY-MM-DD.md` が作られる。

```
毎朝の流れ

  Claude に「今日のタスクを生成して」と依頼
          ↓
  daily/YYYY-MM-DD.md が生成される（今日やることのTop3など）
          ↓
  ┌─────────────────────────────────┐
  │  どちらで操作しても両方に反映される  │
  │                                 │
  │  daily/YYYY-MM-DD.md           │
  │  → チェックを入れると完了扱い     │
  │                                 │
  │  task-board/main-board.md      │
  │  （カンバンビュー）               │
  │  → カードを DONE に移動で完了     │
  │  → 新しいタスクの追加もここから   │
  └─────────────────────────────────┘
```

---

## 必要なもの

**必須（追加コスト¥0）**
- Cowork（契約済み）
- Obsidian（無料）

**任意（後から追加可）**
- Claude MAX（$200/月、エンジニアリングをフル活用するなら）
- iCloud Drive（スマホ連携用、無料枠で十分）
- Ollama（ローカルAI、運用が安定してから）
- Windows タスクスケジューラ（定期自動化を使う場合）

---

## 参考

- 元動画: [シリコンバレー17年のプロが本気でAIエージェント使い込んだ結果全部見せます](https://www.youtube.com/watch?v=K1JBWvTIc2Y)
