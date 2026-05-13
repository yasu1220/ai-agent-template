# コスト戦略

## モデル使い分けの原則

```
Opus    ← 戦略判断・難判断・倫理判断のみ（高い・滅多に使わない）
Sonnet  ← オーケストレーション・通常作業（バランス）
Haiku   ← 単純実行・大量処理（安い・速い）
```

## 各エージェントのモデル割り当て

| 用途 | モデル | エージェント数 |
|---|---|---|
| 戦略・倫理 (Opus) | claude-opus-4-6 | 5体 |
| オーケストレーション (Sonnet) | claude-sonnet-4-6 | 13体 |
| 単純実行 (Haiku) | claude-haiku-4-5 | 10体 |

詳細は各 `agents/*/brain.yaml` を参照。

## コストを抑えるテクニック

### 1. オーケストレーター方式の徹底
- 人間 → tech-lead (Sonnet) → frontend (Haiku) の流れで、最も安いモデルが実作業を担う
- Opus は eng-director や architect が「セカンドオピニオン」として時々呼ばれるだけ

### 2. 文脈の最小化
- 各エージェントは自分に必要な `01_context/` のファイルだけを読む
- 全文脈を毎回渡さない

### 3. desk による文脈分離
- エージェントごとに `desk/` を分けることで、他のエージェントの作業内容が混ざらない
- 結果としてトークン消費が減る

### 4. ローカルAIへの段階的移行
- 単純作業（local-support, anti-ai-slop, knowledge-sync など）は将来 Ollama に換装可能
- `brain.yaml` を書き換えるだけで切り替え可能

## 想定コスト

### 最小構成（Cowork のみ）
- Cowork サブスク代 のみ
- AI追加コスト: ¥0

### 通常運用（Cowork + Claude Code 軽め）
- Cowork サブスク代
- Claude Code: 必要時のみ Pro ($20/月)

### 本格運用（動画と同等）
- Claude MAX: ~$200/月
- すべてのエージェントをClaude統一で運用

### コスト最適化後
- Claude MAX: $200/月
- + Ollama (ローカルAI) 雑用エージェントを移行
- → 重要タスクのみ Claude を使用、トークン消費を50%以上削減可能
