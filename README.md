# ln-admission-db
辽宁省高考招生信息数据库

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

## 通过 MCP 协议使用（可选）

本项目也支持通过 [SQLite MCP Server](./docs/MCP.md) 供 AI 助手查询，详见 [docs/MCP.md](./docs/MCP.md)。