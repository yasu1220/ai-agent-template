# 組織図

```
                          あなた (CEO・設計者)
                                │
                ┌───────────────┴───────────────┐
                │                               │
                ▼                               ▼
        【調整層】                       【緊急安全弁】
     Obsidian (文脈エンジン)            safety-guardian
     カンバンボード (タスク管理)
                │
    ┌───────────┼───────────┬──────────┐
    ▼           ▼           ▼          ▼
┌─────────┐┌─────────┐┌─────────┐┌──────────┐
│§01 Eng. ││§02 Cont.││§03 Biz. ││§04 Infra │
│         ││         ││         ││          │
│tech-lead││content- ││marketing││task-     │
│  (窓口) ││director ││director ││dispatch  │
│         ││  (窓口) ││         ││          │
│eng-     ││brand-   ││business-││morning-  │
│director ││voice    ││strategy ││standup   │
│         ││         ││         ││          │
│qa       ││root-    ││partner- ││knowledge-│
│frontend ││cause    ││ship-mng ││sync      │
│backend  ││         ││         ││          │
│security ││anti-ai- ││legal-   ││local-    │
│devops   ││slop     ││review   ││support   │
│architect││         ││         ││          │
│mobile   ││morning- ││         ││safety-   │
│data     ││brain-   ││         ││guardian  │
│reviewer ││storm    ││         ││          │
│tester   ││         ││         ││          │
│debugger ││         ││         ││          │
│docs     ││         ││         ││          │
└─────────┘└─────────┘└─────────┘└──────────┘
  14体        5体        4体        5体
```

## チーム別一覧

### § 01 エンジニアリング (14体)
| 名前 | モデル | 役割 |
|---|---|---|
| tech-lead | Sonnet | 窓口・タスク振り分け |
| eng-director | Opus | 戦略・設計判断 |
| qa | Haiku | 品質テスト |
| frontend | Haiku | UI実装 |
| backend | Haiku | API実装 |
| security | Sonnet | セキュリティ |
| devops | Sonnet | インフラ・CI/CD |
| architect | Opus | アーキテクチャ設計 |
| mobile | Haiku | モバイル開発 |
| data | Sonnet | データ処理 |
| reviewer | Sonnet | コードレビュー |
| tester | Haiku | テスト追加 |
| debugger | Sonnet | バグ調査 |
| docs | Haiku | ドキュメント作成 |

### § 02 コンテンツ (5体)
| 名前 | モデル | 役割 |
|---|---|---|
| content-director | Sonnet | 窓口・台本展開 |
| brand-voice | Sonnet | ブランド一致チェック |
| root-cause | Opus | 本質・賞味期限チェック |
| anti-ai-slop | Haiku | AIっぽさ除去 |
| morning-brainstorm | Sonnet | 朝のアイデア出し |

### § 03 ビジネス (4体)
| 名前 | モデル | 役割 |
|---|---|---|
| marketing-director | Sonnet | マーケ統括 |
| business-strategy | Opus | 中長期戦略 |
| partnership-manage | Sonnet | 案件フィルタリング |
| legal-review | Opus | 契約書一次チェック |

### § 04 インフラ運用 (5体)
| 名前 | モデル | 役割 |
|---|---|---|
| task-dispatch | Sonnet | inbox→タスク化 |
| morning-standup | Sonnet | 朝のサマリ生成 |
| knowledge-sync | Haiku | 整合性チェック |
| local-support | Haiku | 雑用・データ整理 |
| **safety-guardian** | **Opus** | **緊急停止・倫理チェック** |

**合計：28体のAIエージェント**
