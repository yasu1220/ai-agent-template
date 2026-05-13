# 運用マニュアル

## 日次の流れ

### 朝（5分）
1. Cowork を開いて「今日の状況」と聞く  
   → `morning-standup` が `daily/YYYY-MM-DD.md` を生成・更新
2. 今日のTop3を確認・修正
3. P0タスクから着手

### 日中（随時）
- 思いついたことは `obsidian-vault/00_inbox/YYYY-MM-DD.md` にメモ
- AIに依頼するときは Cowork で **オーケストレーター** に話す（tech-lead, content-director等）
- 専門エージェントへの直接指示は避ける

### 夜（5分）
- `daily/YYYY-MM-DD.md` の「完了報告」「気分」を埋める
- 翌日に持ち越すタスクは `task-board/main-board.md` に整理

## 週次の流れ

### 月曜朝（5分）
- `obsidian-vault/03_decisions/weekly-brief-YYYY-WXX.md` を読む（自動生成済み）
- 今週の方針を確認・修正

### 金曜夜（30分）— 最重要
- `logs/` の今週分をざっと眺める
- `agents/*/desk/log-*.md` で各エージェントの判断ミスを拾う
- 該当エージェントの `skills.md` を更新
- これが「組織が静かに壊れる」のを防ぐ唯一の方法

## エージェントへの依頼例

```
（Coworkで）
「tech-lead として、ログイン画面のバグを調べて修正して」
「content-director として、SaaS経理の動画台本を書いて」
「task-dispatch として、inbox を整理して」
```

## トラブルシューティング

### AIが期待と違う動きをする
→ 該当エージェントの `agents/*/skills.md` を見直す  
→ `obsidian-vault/01_context/` のコンテキストが薄すぎないか確認

### タスクが詰まる
→ `task-board/main-board.md` の `🛑 BLOCKED` を確認  
→ 5日以上 BLOCKED が続いていれば、タスクを諦めるか分割する

### コストが膨らむ
→ Opus を多用していないか `agents/*/brain.yaml` を確認  
→ 不要なエージェントは `agents/*/brain.yaml` を空にして無効化

### safety-guardian が頻繁に発動
→ `philosophy-values.md` の「バグサイン」が厳しすぎないか確認  
→ 仕事のペースを見直すサインかも

## 拡張のタイミング

| 状況 | 次のアクション |
|---|---|
| トークン不足 | Claude MAX に格上げ |
| 単純作業が多い | local-support を Ollama に換装 |
| エージェントが多すぎる | 使ってないものを `99_archive/` に退避 |
| 自作ツールが欲しい | task-board をバイブコードで自作アプリ化 |

## 重要な原則

1. **エージェント同士は会話させない** — 必ずファイル経由
2. **オーケストレーターを通す** — 専門家に直接指示しない
3. **書き物で残す** — 重要な判断は `03_decisions/` に
4. **金曜の30分を死守** — メンテナンスを怠らない
5. **safety-guardian を信頼する** — 暴走の前に止めてくれる
