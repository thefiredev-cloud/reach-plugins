# Graph Report - reach-plugins  (2026-10-21)

## Corpus Check
- 4 files · ~1,610 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 5 file(s) not represented in the graph (top: .toml 3, (none) 2)

## Summary
- 27 nodes · 27 edges · 5 communities (3 shown, 2 thin omitted)
- Extraction: 85% EXTRACTED · 15% INFERRED · 0% AMBIGUOUS · INFERRED: 4 edges (avg confidence: 0.95)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- reach-plugins
- Hooks
- What it does
- Reach plugin API

## God Nodes (most connected - your core abstractions)
1. `reach-plugins` - 10 edges
2. `Hooks` - 5 edges
3. `What it does` - 4 edges
4. `Reach plugin API` - 3 edges
5. `on_session_connected()` - 2 edges
6. `on_session_disconnected()` - 2 edges
7. `on_sftp_upload_complete()` - 2 edges
8. `on_sftp_download_complete()` - 2 edges
9. `Install` - 2 edges
10. `session-notifier` - 1 edges

## Surprising Connections (you probably didn't know these)
- `Hooks` --references--> `on_session_connected()`  [INFERRED]
  README.md → plugins/session-notifier/main.lua
- `Hooks` --references--> `on_session_disconnected()`  [INFERRED]
  README.md → plugins/session-notifier/main.lua
- `Hooks` --references--> `on_sftp_upload_complete()`  [INFERRED]
  README.md → plugins/transfer-logger/main.lua
- `Hooks` --references--> `on_sftp_download_complete()`  [INFERRED]
  README.md → plugins/transfer-logger/main.lua

## Import Cycles
- None detected.

## Communities (5 total, 2 thin omitted)

### Community 0 - "reach-plugins"
Cohesion: 0.20
Nodes (9): Configuration, Development, Install, License, Permissions after an upgrade, Project layout, reach-plugins, Requirements (+1 more)

### Community 1 - "Hooks"
Cohesion: 0.28
Nodes (5): on_session_connected(), on_session_disconnected(), on_sftp_download_complete(), on_sftp_upload_complete(), Hooks

### Community 2 - "What it does"
Cohesion: 0.50
Nodes (4): fleet-summary, session-notifier, transfer-logger, What it does

## Knowledge Gaps
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `reach-plugins` connect `reach-plugins` to `What it does`, `Reach plugin API`?**
  _High betweenness centrality (0.658) - this node is a cross-community bridge._
- **Are the 4 inferred relationships involving `Hooks` (e.g. with `on_session_connected()` and `on_session_disconnected()`) actually correct?**
  _`Hooks` has 4 INFERRED edges - model-reasoned connections that need verification._
- **Why does `Reach plugin API` connect `Reach plugin API` to `reach-plugins`, `Hooks`?**
  _High betweenness centrality (0.458) - this node is a cross-community bridge._
- **Why does `Hooks` connect `Hooks` to `Reach plugin API`?**
  _High betweenness centrality (0.446) - this node is a cross-community bridge._