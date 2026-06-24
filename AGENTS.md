# 辽宁省高考招生信息数据库 AGENTS.md

## 参考文件

整个项目的描述件 [README.md](./README.md)。
数据库结构见文件 [db_schema.md](./db_schema.md)。
通过 MCP 协议使用 SQLite 的可选方案见 [MCP.md](./MCP.md)。

## 构建/设置命令
- `./createdb.sh` - 创建 SQLite 数据库并导入所有 CSV 数据
- `./exp_phy2024.sh` - 运行 2024 年物理类数据示例查询
- `sqlite3 data.sqlite3` - 直接打开数据库进行查询
- `sqlite3 -cmd ".mode csv" -cmd ".headers on" data.sqlite3 < query.sql` - 运行 SQL 文件并以 CSV 格式输出

## 查询方式约定

**本项目直接使用 `sqlite3` 命令行工具进行数据查询，不使用 MCP sqlite 工具。**

理由：
- `sqlite3` 命令行与现有 shell 脚本（如 `exp_phy2024.sh`）风格一致
- SQL 语句可保存为文件复用、便于版本管理
- 无 MCP 协议开销，响应更快
- 任何能执行 shell 的环境都能用

常用查询模板：

```bash
# 列出所有表
sqlite3 data.sqlite3 ".tables"

# 查看表结构
sqlite3 data.sqlite3 ".schema table_name"

# 表格对齐输出（带表头）
sqlite3 -header -column data.sqlite3 "SELECT * FROM table_name LIMIT 5;"

# CSV 格式输出
sqlite3 -header -csv data.sqlite3 "SELECT score, rank FROM rank_phy2026 WHERE CAST(score AS INTEGER) = 424;"

# 一行内联查询
sqlite3 data.sqlite3 "SELECT COUNT(*) FROM plan_2026;"

# 复杂查询保存为 SQL 文件
sqlite3 -header -column data.sqlite3 < query.sql
```

## 代码风格指南
- **重要：所有交互过程、注释和文档必须使用中文，本项目为中文项目**
- **优先使用 `sqlite3` 命令行进行数据查询，不使用 MCP sqlite 工具**（如需 MCP 方案请参考 [MCP.md](./MCP.md)）
- SQL 查询应使用正确的 JOIN 语法和表别名（如 `p`, `s`, `r`）
- 遵循现有表命名规范：`plan_YYYY`, `rank_hisYYYY`, `rank_phyYYYY`, `score_hisYYYY`, `score_phyYYYY`
- 使用描述性列名匹配模式：`inst_code`, `major_code`, `min_score`, `plan_num`
- Shell 脚本应可执行并使用正确的 shebang `#!/bin/bash`
- CSV 导入应保持一致的数据类型（数字用 INTEGER，字符串用 TEXT）
- 使用 SQLite 特定语法如 `||` 进行字符串连接，`LIKE` 进行模式匹配
- Shell 脚本中包含适当的错误处理，变量用引号包围
- Shell 脚本中的多行 SQL 查询使用 heredoc（`<<EOF`）
- SQL 格式化应使用适当的缩进和一致的列顺序
- 数值范围使用 `BETWEEN`，模式匹配使用 `LIKE` 与 `%`
- 复杂的 WHERE 子句和过滤逻辑应包含注释（`--`）

## 数据库分析经验

### 1. 数据库结构获取方法
- 使用 `sqlite3 data.sqlite3 ".tables"` 查看所有可用表
- 使用 `sqlite3 data.sqlite3 ".schema table_name"` 获取具体表结构
- 使用 `sqlite3 -header -column data.sqlite3 "SELECT * FROM table_name LIMIT 5;"` 查看表的前几行数据，了解数据格式

### 2. 分析流程经验
- **分步查询策略：** 先查招生计划，再查录取分数，最后查排名对应关系
- **数据验证步骤：** 通过 `COUNT(*)` 确认表有数据，通过 `LIMIT` 查看数据样本
- **模糊匹配技巧：** 使用 `LIKE '%关键词%'` 查找院校名称
- **多表关联方法：** 分别查询计划表、分数表、排名表，然后手动关联分析

### 3. 常用查询模式
```sql
-- 查看表结构和数据样本
SELECT * FROM table_name LIMIT 5;

-- 查找特定院校
SELECT DISTINCT inst FROM table_name WHERE inst LIKE '%南京%';

-- 查询招生计划（注意不同年份字段映射可能不同）
SELECT * FROM plan_YYYY WHERE inst = '南京大学' AND first = '物理';

-- 查询录取分数
SELECT * FROM score_phyYYYY WHERE inst = '南京大学';

-- 查询分数对应排名
SELECT score, rank FROM rank_phyYYYY WHERE score IN (分数列表);
```

### 4. 数据分析技巧
- **排序重要性：** 最终结果要按排名排序（排名数字从小到大）
- **对比分析：** 多年数据对比时要注意分数对应的排名变化
- **结果验证：** 通过多个角度验证数据合理性
- **异常检测：** 关注数据异常值和缺失值

### 5. 输出格式规范
- 表格形式展示，包含：专业、招生人数、最低录取分、省内排名
- 按排名排序，竞争激烈的专业排在前面
- 提供总结性分析，指出最难录取和相对容易的专业
- 对比多年数据变化趋势
