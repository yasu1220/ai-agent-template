# CLAUDE.md — Claude Code / Cowork 共通ルール

このファイルは Claude Code および Cowork のセッション開始時に自動で読み込まれます。  
すべてのAIエージェントが従うべき基本ルールを定義します。

---

## 必読ファイル（セッション開始時）

1. `obsidian-vault/01_context/philosophy-values.md` — 主君の哲学・価値観
2. `obsidian-vault/01_context/professional-identity.md` — 主君のキャリア・スキル
3. `obsidian-vault/01_context/technical-setup.md` — 環境・使用ツール
4. `obsidian-vault/03_decisions/` — 直近の重要意思決定
5. このファイルの「緊急停止ルール」セクション

---

## エージェント階層

```
あなた（人間・CEO）
    ↓
オーケストレーター（tech-lead / content-director など）
    ↓
専門エージェント（qa, frontend, brand-voice など）
```

**人間は基本的にオーケストレーターにのみ依頼する。** 専門エージェントへの直接指示は避ける。

---

## ルーティング早見表

| 依頼の種類 | 起動エージェント |
|---|---|
| コード・バグ修正・システム実装 | `agents/01_engineering/tech-lead` |
| 動画台本・SNS投稿・原稿 | `agents/02_content/content-director` |
| 戦略・マーケ・契約 | `agents/03_business/marketing-director` |
| タスク整理・優先順位 | `agents/04_infrastructure/task-dispatch` |
| 朝の状況確認 | `agents/04_infrastructure/morning-standup` |
| 緊急停止・倫理チェック | `agents/04_infrastructure/safety-guardian` |
| 複合依頼 | tech-lead に投げ、必要なら他のディレクターに振る |

---

## モデルの使い分け（コスト階層化）

| モデル | 用途 |
|---|---|
| **Opus** | 戦略判断・複雑な設計・倫理判断（safety-guardian, eng-director） |
| **Sonnet** | オーケストレーション・通常作業（tech-lead, content-director） |
| **Haiku** | 単純実行・大量処理（個別エージェント） |

各エージェントの `brain.yaml` でモデルが指定されている。

---

## 書き物文化（重要）

- **エージェント同士は会話せず、必ずファイル経由でやり取り**する
- タスクの状態は `task-board/main-board.md` に記録
- 重要な判断は `obsidian-vault/03_decisions/YYYY-MM-DD-decisions.md` に記録
- 各エージェントの作業ログは自分の `desk/log-YYYY-MM-DD.md` に残す

---

## 自動記録ルール

- 重要な意思決定が生じたら → `obsidian-vault/03_decisions/YYYY-MM-DD-decisions.md` に追記
- 「inboxに追加して」と言われたら → `obsidian-vault/00_inbox/YYYY-MM-DD.md` に即時記録
- セッション開始時、その日の `daily/YYYY-MM-DD.md` が未作成なら生成

---

## 🚨 緊急停止ルール（最優先）

以下のいずれかが検知された場合、すべてのエージェントは**即座に作業を停止**し、`safety-guardian` エージェントに引き渡すこと。

1. **人間のバグサイン検知**  
   `daily/` の記述から、燃え尽き・自己否定・過剰な義務感の兆候が見える

2. **聖域の侵害疑い**  
   `philosophy-values.md` の「触れてはいけないこと」に抵触する依頼や生成物

3. **法的・倫理的リスク**  
   違法・差別的・他者を害する内容、機密情報の漏洩リスク

`safety-guardian` の判断は他のすべてのエージェントの判断より優先される。  
人間（あなた）の確認なしには再開してはならない。

---

## 出力ルール

- 完成物は `obsidian-vault/04_projects/{プロジェクト名}/` に置く
- 作業中の下書きは各エージェントの `desk/` に置く
- 完成物に到達したら desk/ から projects/ に移動

---

## プロジェクト構造（参照用）

```
obsidian-vault/      ← 文脈エンジン
task-board/          ← カンバンボード
daily/               ← 自分の日次TODO
agents/              ← エージェント定義
scheduled/           ← 定期実行スクリプト
logs/                ← AI実行ログ
```
