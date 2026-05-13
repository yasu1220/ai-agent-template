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

### 1. Obsidian をインストール
1. https://obsidian.md からダウンロード
2. 「Open vault」で `obsidian-vault/` フォルダを選択
3. プラグインインストール: Kanban / Dataview / Templater

### 2. 個人情報を埋める
- `obsidian-vault/01_context/philosophy-values.md` ← あなたの哲学
- `obsidian-vault/01_context/professional-identity.md` ← キャリア
- `obsidian-vault/01_context/technical-setup.md` ← 使用ツール

### 3. エージェントを必要に応じてカスタマイズ
- `agents/*/skills.md` に各エージェントの指示書がある
- 自分の業務に合わせて修正

### 4. 定期実行を登録
- `scheduled/README.md` を見て、タスクスケジューラに登録

### 5. 運用開始
- 毎朝 Cowork で「今日の状況」と聞く → `daily/` に今日のTODOが書かれる
- 思いついたことは `obsidian-vault/00_inbox/` に投げ込む
- 詳細は `docs/operation-handbook.md`

---

## 必要なもの

**必須（追加コスト¥0）**
- Cowork（契約済み）
- Obsidian（無料）
- Windows タスクスケジューラ（OS標準）

**任意（後から追加可）**
- Claude MAX（$200/月、エンジニアリングをフル活用するなら）
- iCloud Drive（スマホ連携用、無料枠で十分）
- Ollama（ローカルAI、運用が安定してから）

---

## 参考

- 元動画: [シリコンバレー17年のプロが本気でAIエージェント使い込んだ結果全部見せます](https://www.youtube.com/watch?v=K1JBWvTIc2Y)
