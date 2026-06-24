# 通过 MCP 协议使用 SQLite（可选方案）

> **本项目主路径**：使用 `sqlite3` 命令行直接查询，详见 [AGENTS.md](./AGENTS.md)。
> **本页内容**：介绍一种**可选的辅助方案**——通过 [MCP 协议](https://modelcontextprotocol.io/introduction) 让 AI 助手直接查询数据库。

---

[SQLite MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/sqlite) 是 [MCP 协议](https://modelcontextprotocol.io/introduction) 服务器实现，提供 SQLite 数据库交互等功能。该服务器可运行 SQL 查询、分析业务数据。[Cline](https://github.com/cline/cline) 是 VSCode 的人工智能助手，配合 Deepseek 使用，性价比和易用性非常好，并且 Cline 是目前比较好的 MCP 协议客户端。

在 Cline 中使用类似如下 MCP 配置就可以使用 [SQLite MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/sqlite) （注意：要修改项目目录）：

```json
{
  "mcpServers": {
    "ln-admission-db": {
      "command": "uvx",
      "args": [
        "--directory",
        "/Users/mengbo/Developer/github/ln-admission-db",
        "mcp-server-sqlite",
        "--db-path",
        "./data.sqlite3"
      ]
    }
  }
}
```

通过类似如下的提示词，就可以使用人工智能来分析数据：

> 使用中文。@/docs/db_schema.md 是 mcp server 连接的数据库的描述。从数据库中总结一下2023年和2024年南京大学物理类的录取情况。首先获取各个专业招生人数，然后获取各个专业录取最低分，最后找到这个最低分的省内排名。

![AI Screenshot](https://github.com/mengbo/ln-admission-db/blob/main/assets/screenshot_ai.png?raw=true)

[Cherry Studio](https://cherry-ai.com/) 作为支持 MCP 的客户端软件，界面更加友好，建议使用。

![Cherry Studio](https://github.com/mengbo/ln-admission-db/blob/main/assets/screenshot_cs.png?raw=true)
