# ln-admission-db
辽宁省高考招生信息数据库

## 项目简介

ln-admission-db 是辽宁省高考招生本地化数据库，将招生计划、一分一段表、历年录取分数灌入 SQLite 文件（`data.sqlite3`），覆盖 2022–2026 年，通过 SQL 即可完成分数↔位次↔院校的交叉查询，便于志愿填报分析。

## 项目结构

```
ln-admission-db/
├── data/                   # CSV 数据源（数据库导入输入）
├── docs/                   # 详细文档（数据库结构、MCP 协议）
├── queries/                # SQL 查询脚本
├── scripts/                # 构建/查询脚本（Shell）
├── references/             # 原始 XLSX 归档
├── assets/                 # 截图等静态资源
├── data.sqlite3            # SQLite 数据库（运行 createdb.sh 后生成）
├── README.md
├── AGENTS.md
└── .gitignore
```

## 快速开始

数据库结构见 [docs/db_schema.md](./docs/db_schema.md)。

执行 `./scripts/createdb.sh` 脚本，可以建立名为 `data.sqlite3` 的 sqlite3 数据库文件，并将 `data/` 目录下所有 CSV 数据导入该数据库。

![DB Screenshot](https://github.com/mengbo/ln-admission-db/blob/main/assets/screenshot_db.png?raw=true)

## 报考助力示例

借助 [opencode](https://opencode.ai) 等 AI 助手配合 SQLite，可用 SQL 快速完成"分数→位次→历年等效分→冲稳保院校清单"的志愿分析。

以 2026 物理类 620 分考生为例：

1. 查 `rank_phy2026` 得 2026 位次 **8813**；
2. 用该位次回查 `rank_phy2025` 和 `rank_phy2024`，得到等效分 **616** 和 **622**；
3. 用 `plan_2026` JOIN `score_phy2024/2025`，按等效分 ±15 划出冲、稳、保三档。

结果显示：吉林大学、东华大学、河海大学的计算机/电子信息类可作"稳"，北邮中外合作、西南财大金融科技等可冲，大连医科口腔医学、东北财大会计学等可保。

![OpenCode Demo](https://github.com/mengbo/ln-admission-db/blob/main/assets/screenshot_oc.png?raw=true)

## 通过 MCP 协议使用（可选）

本项目也支持通过 [SQLite MCP Server](./docs/MCP.md) 供 AI 助手查询，详见 [docs/MCP.md](./docs/MCP.md)。