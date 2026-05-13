# タスクダッシュボード

> Dataviewプラグインで動的に集計されるビュー。
> セットアップ時に `dashboard.md` としてコピーしてください。

---

## あなた (human) の未完了タスク

### 🔥 P0

```dataview
TASK
FROM "task-board"
WHERE !completed AND contains(tags, "#human") AND contains(tags, "#P0")
```

### ⚠️ P1

```dataview
TASK
FROM "task-board"
WHERE !completed AND contains(tags, "#human") AND contains(tags, "#P1")
```

### 📌 P2 / P3

```dataview
TASK
FROM "task-board"
WHERE !completed AND contains(tags, "#human") AND !contains(tags, "#P0") AND !contains(tags, "#P1")
```

---

## チーム別の稼働状況

### ⚙️ Engineering

```dataview
TASK
FROM "task-board"
WHERE !completed AND (contains(tags, "#engineering") OR contains(tags, "#tech-lead") OR contains(tags, "#frontend") OR contains(tags, "#backend"))
```

### ✍️ Content

```dataview
TASK
FROM "task-board"
WHERE !completed AND (contains(tags, "#content") OR contains(tags, "#brand-voice") OR contains(tags, "#anti-ai-slop"))
```

### 💼 Business

```dataview
TASK
FROM "task-board"
WHERE !completed AND (contains(tags, "#business") OR contains(tags, "#marketing") OR contains(tags, "#legal-review"))
```

### 🛠️ Infrastructure

```dataview
TASK
FROM "task-board"
WHERE !completed AND (contains(tags, "#infra") OR contains(tags, "#task-dispatch") OR contains(tags, "#safety-guardian") OR contains(tags, "#cowork") OR contains(tags, "#setup"))
```

---

## ✅ 直近完了タスク

```dataview
TASK
FROM "task-board"
WHERE completed
SORT file.mtime DESC
LIMIT 10
```
