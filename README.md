# ln-admission-db
辽宁省高考招生信息数据库

数据库结构见文件 [db_schema.md](./db_schema.md)。

执行 `createdb.sh` 脚本，可以建立名为 `data.sqlite3` 的 sqlite3 数据库文件，并将所有 CSV 格式数据导入该数据库，最后执行 `example.sql` 中的查询例子。

![DB Screenshot](https://github.com/mengbo/ln-admission-db/blob/main/screenshot_db.png?raw=true)


[SQLite MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/sqlite) 是 [MCP 协议](https://modelcontextprotocol.io/introduction) 服务器实现，提供 SQLite 数据库交互等功能。该服务器可运行 SQL 查询、分析业务数据。

[Cline](https://github.com/cline/cline) 是 VSCode 的人工智能助手，配合 Deepseek 使用，性价比和易用性非常好，并且 Cline 是目前比较好的 MCP 协议客户端。

在 Cline 中使用如下 MCP 配置就可以使用 [SQLite MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/sqlite) ：

```json
{
  "mcpServers": {
    "sqlite": {
      "command": "uvx",
      "args": [
        "--directory",
        "/Users/mengbo/github/ln-admission-db",
        "mcp-server-sqlite",
        "--db-path",
        "./data.sqlite3"
      ]
    }
  }
}
```
通过类似如下的提示词，就可以使用人工智能来分析数据：

> 使用中文。@/db_schema.md 是 mcp server 连接的数据库的描述。从数据库中总结一下2023年和2024年南京大学物理类的录取情况。首先获取各个专业招生人数，然后获取各个专业录取最低分，最后找到这个最低分的省内排名。

![AI Screenshot](https://github.com/mengbo/ln-admission-db/blob/main/screenshot_ai.png?raw=true)