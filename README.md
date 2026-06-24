# ln-admission-db
辽宁省高考招生信息数据库

数据库结构见文件 [db_schema.md](./db_schema.md)。

执行 `createdb.sh` 脚本，可以建立名为 `data.sqlite3` 的 sqlite3 数据库文件，并将所有 CSV 格式数据导入该数据库。

![DB Screenshot](https://github.com/mengbo/ln-admission-db/blob/main/screenshot_db.png?raw=true)


## 通过 MCP 协议使用（可选）

本项目也支持通过 [SQLite MCP Server](./MCP.md) 供 AI 助手查询，详见 [MCP.md](./MCP.md)。
