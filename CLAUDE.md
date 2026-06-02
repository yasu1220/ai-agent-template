# CLAUDE.md — Claude Code / Cowork 共通ルール

このファイルは Claude Code および Cowork のセッション開始時に自動で読み込まれます。  
すべてのAIエージェントが従うべき基本ルールを定義します。

---

## 🚀 FIRST ACTION（このファイルを読んだら最初に必ず実行）

以下を順番に実行し、最後に報告すること。ユーザーからの最初のメッセージより前に完了すること。

1. Read `obsidian-vault/01_context/philosophy-values.md`
2. Read `obsidian-vault/01_context/professional-identity.md`
3. Read `obsidian-vault/01_context/technical-setup.md`（存在する場合のみ）
4. Read `task-board/main-board.md`
5. `obsidian-vault/03_decisions/` 内の最新ファイルを1件読む（存在する場合のみ）
6. `obsidian-vault/00_inbox/strategy-review-*.md` を探す。ファイルが存在し、かつ**今日が日曜日**であれば、文脈読み込み完了報告の直後に「日曜戦略セッション」を開始する（詳細は「日曜戦略セッションプロトコル」セクション参照）
7. 今日の `daily/YYYY-MM-DD.md` が存在しなければ、Top3選択ルールに従って生成する

完了後、以下の形式で報告する：

```
✅ 文脈読み込み完了
- 主君: [名前] / [役割]
- IN PROGRESS: X件 / NEW: X件 / BLOCKED: X件
- 今日のdaily: あり or 生成しました（YYYY-MM-DD.md）
- 戦略セッション: 日曜・strategy-reviewあり → セッション開始します or 通常モード
```

---

## 必読ファイル（セッション開始時）

1. `obsidian-vault/01_context/philosophy-values.md` — 主君の哲学・価値観
2. `obsidian-vault/01_context/professional-identity.md` — 主君のキャリア・スキル
3. `obsidian-vault/01_context/technical-setup.md` — 環境・使用ツール
4. `obsidian-vault/03_decisions/` — 直近の重要意思決定
5. このファイルの「緊急停止ルール」セクション

> ファイルが存在しない場合は、対応する `.template.md`（同ディレクトリに存在）を参照して内容を推測し、
> 不足している文脈は適宜補完しながら作業を継続すること。
> セッション開始時に「〇〇が未記入です。SETUP.md 手順4を参考に記入することを推奨します」と一言伝えるだけでよい。

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
| ファイル整理・名称統一・アーカイブ | `agents/04_infrastructure/local-support` |
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

## タスク記入ルール（厳守）

### フォーマット

```
- [ ] **TXXXX** タスク名 #P{優先度} #{担当} #{カテゴリ} ^tXXXX
```

完了時：

```
- [x] **TXXXX** タスク名 ✅YYYY-MM-DD #{担当} #{カテゴリ} ^tXXXX
```

### タスクIDの採番

新しいタスクを追加する際は **必ず** `scheduled/next-task-id.ps1` を実行して次のIDを取得すること。

```powershell
$id = & ".\scheduled\next-task-id.ps1"   # 例: T0007
```

IDは4桁ゼロ埋め（T0001〜）。アンカー `^tXXXX` はIDの小文字版（例: T0007 → `^t0007`）。

### 優先度タグ

| タグ | 意味 |
|---|---|
| `#P0` | 緊急（今すぐ対応） |
| `#P1` | 高（今日中） |
| `#P2` | 中（今週中） |
| `#P3` | 低（いつか） |

### 担当タグ

| タグ | 意味 |
|---|---|
| `#human` | 人間のみ |
| `#cowork` | 人間とAIの協働 |
| `#claude-code` | Claude Codeが単独実行（コード生成・ファイル操作） |

### カンバン列

```
## 📥 NEW / UNASSIGNED   ← 新規・未割当
## 🔄 IN PROGRESS        ← 作業中
## 🛑 BLOCKED            ← ブロック中
## ✅ DONE               ← 完了
```

---

## daily と main-board の関係

**タスクは必ず `task-board/main-board.md` に先に登録する。**

`daily/YYYY-MM-DD.md` は main-board からタスクをトランスクルード（参照）するだけで、
daily に書いたものが自動で main-board に反映される仕組みは**ない**。

```
daily/ の ![[task-board/main-board#^t0001]]  ←  main-board を参照（一方向）
```

新しいタスクを作る手順：
1. `scheduled/next-task-id.ps1` でIDを取得
2. `task-board/main-board.md` の `## 📥 NEW / UNASSIGNED` セクションに追記
3. 必要なら daily の「今日のTop3」に `![[task-board/main-board#^tXXXX]]` を追記

---

## 自動記録ルール

- 重要な意思決定が生じたら → `obsidian-vault/03_decisions/YYYY-MM-DD-decisions.md` に追記
- 「inboxに追加して」と言われたら → `obsidian-vault/00_inbox/YYYY-MM-DD.md` に即時記録
- セッション開始時、その日の `daily/YYYY-MM-DD.md` が未作成なら生成

**daily 生成時のタスク選定ルール**  
`task-board/main-board.md` から以下の優先順で今日取り組むタスクを選び、
`![[task-board/main-board#^tXXXX]]` 形式で列挙する。**最大3件**（優先度順で上位3件のみ）。

優先順：
1. `## 🔄 IN PROGRESS` 列の `#P0` タスク
2. `## 🔄 IN PROGRESS` 列の `#P1` タスク
3. `## 📥 NEW / UNASSIGNED` 列の `#P0` タスク
4. `## 📥 NEW / UNASSIGNED` 列の `#P1` タスク

**最大3件**（優先度順で上位3件のみ選定）。
該当タスクがゼロの場合はセクションに「今日は予定なし」と記載する。

**初回セットアップ検出ルール**  
セッション開始時に以下を確認し、存在しない場合は自動生成すること：

- `task-board/dashboard.md` がなければ `task-board/dashboard.template.md` をコピーして生成
- `daily/YYYY-MM-DD.md` がなければ `daily/_template.md` からTop3ルールに従って生成

**daily と main-board.md の同期は自動ではない。** daily でチェックを入れてもmain-board.mdは変わらない。タスクの状態変更は「T000X をDONEに移動して」のように明示的に依頼すること。

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

---

## 🗓️ 日曜戦略セッションプロトコル

### 起動条件
FIRST ACTION ステップ6で、**今日が日曜日** かつ `obsidian-vault/00_inbox/strategy-review-*.md` が存在する場合に起動する。

### セッションの流れ

「日曜戦略セッションを開始して」と言われたら STEP 1 から順番に実行する。

---

**STEP 1: 素材を読む**

以下をすべて読む：
- `obsidian-vault/00_inbox/strategy-review-*.md`（最新1件）
- `obsidian-vault/05_strategy/okr-2026.md`
- `obsidian-vault/05_strategy/progress-tracking-YYYY-MM.md`（当月）
- `task-board/main-board.md`

---

**STEP 2: strategy-review の内容をチャットで提示する**

strategy-review ファイルの内容を以下の形式で整理してそのまま提示する（自分で分析を加えない）：

```
## 📊 今週の戦略レビュー（YYYY-MM-DD）

### 先週の振り返り
（strategy-review の「今週の振り返り」セクションをそのまま提示）

### 戦略修正案
（strategy-review の「戦略修正案」セクションをそのまま提示。修正不要の場合はその旨）

### 来週の定量目標
（strategy-review の「来週の定量目標」テーブルをそのまま提示）
```

→ ユーザーと往復して調整する（「この数字は違う」「この点を重視して」など）
→ **「OK」「いいよ」「承認」** などが出たら STEP 3 へ

---

**STEP 3: OKRを更新する（変更ある場合のみ・承認後に実行）**

- 修正案がある場合：`okr-2026.md` を更新 → 「✅ OKR を更新しました」と報告
- 修正不要の場合：このステップを自動スキップして「OKR変更なし。タスク生成に進みます」と一言添えて STEP 4 へ

---

**STEP 4: task-proposals ファイルを生成してチャットで提示する**

STEP 2 で承認された来週の定量目標と okr-2026.md をもとに、週間タスク＋具体タスクを生成する。

1. `obsidian-vault/00_inbox/task-proposals-YYYY-MM-DD.md` を作成する
2. 以下の形式で書き出す：

```markdown
# タスク提案 YYYY-MM-DD

## 今週の週間タスク（MM/DD〜MM/DD）

| # | テーマ | 目標値 | 関連KR |
|---|---|---|---|
| ① | 体験イベント会場を決める | 3件調査・1件仮押さえ | 個人案件KR |
| ② | 法人案件の初回アプローチ | 1社に連絡 | 法人案件KR |

## 具体タスク（main-board追加候補）

### ①体験イベント会場を決める
- [ ] スタジオAに電話して料金・設備を確認する #P1 #human #event
- [ ] スタジオBのWebサイトで条件確認 #P2 #human #event

### ②法人案件の初回アプローチ
- [ ] 見込み候補1社をリストアップする #P1 #human #biz
- [ ] 初回コンタクト（メール or DM）を送る #P1 #human #biz
```

3. ファイルの内容をチャットでも提示する
4. ユーザーと往復して調整する（「③は外して」「これも追加して」など修正があればファイルも随時更新）
5. **「OK」** が出たら STEP 5 へ

---

**STEP 5: main-boardに追加する（承認後のみ実行）**

1. `scheduled/next-task-id.ps1` を実行して次のIDを取得する
2. 承認されたタスクを `task-board/main-board.md` の `## 📥 NEW / UNASSIGNED` に追記する
3. `task-proposals-YYYY-MM-DD.md` を `obsidian-vault/05_strategy/reviews/` に移動する（元ファイルは削除）
4. `strategy-review-*.md` も `obsidian-vault/05_strategy/reviews/` に移動する（元ファイルは削除）
5. 「✅ X件のタスクを main-board に追加しました」と報告する

---

### 注意事項
- **STEP 3（OKR更新）は承認前に実行しない**
- **STEP 5（main-board追加）は承認前に実行しない**
- 各STEPは必ず承認を得てから次に進む
- 副業時間制約（平日 朝30分・昼30分・夜1時間）を考慮してタスク量を調整する

---

## 🔗 途中修正時の連動確認ルール

タスクの追加・変更・削除の依頼があった場合、以下を**必ず**確認・更新すること。

### 確認対象

| 変更の種類 | 確認・更新するもの |
|---|---|
| タスクの追加 | main-board（IDの重複チェック・NEWに追記） |
| タスクの変更 | main-board + 今日の daily（タスクが今日に含まれているか） |
| タスクの削除 | main-board + 今日の daily（参照が残っていないか） |
| 優先度の変更 | main-board + 今日の daily（選定ロジックに影響するか） |

### 手順

1. 依頼を受けたら、まず「〇〇と△△を確認します」と影響範囲を宣言する
2. 確認後、不整合があれば「〇〇も変えますか？」と聞いてから変更する
3. すべての変更が終わったら「✅ 変更完了：main-board + daily を更新しました」と報告する
