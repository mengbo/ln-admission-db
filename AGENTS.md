# 辽宁省高考招生信息数据库 AGENTS.md

## 参考文件

整个项目的描述见 [README.md](./README.md)。
数据库结构见 [docs/db_schema.md](./docs/db_schema.md)。
MCP 协议方案（已不推荐）见 [docs/MCP.md](./docs/MCP.md)。

## 构建/设置命令
- `./scripts/createdb.sh` - 创建 SQLite 数据库并导入所有 CSV 数据
- `./scripts/exp_phy2024.sh` - 运行 2024 年物理类数据示例查询
- `sqlite3 data.sqlite3` - 直接打开数据库进行查询
- `sqlite3 -cmd ".mode csv" -cmd ".headers on" data.sqlite3 < queries/query.sql` - 运行 SQL 文件并以 CSV 格式输出

## 查询方式约定

**本项目直接使用 `sqlite3` 命令行工具进行数据查询，不使用 MCP sqlite 工具。**

理由：
- `sqlite3` 命令行与现有 shell 脚本（如 `scripts/exp_phy2024.sh`）风格一致
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
- **优先使用 `sqlite3` 命令行进行数据查询，不使用 MCP sqlite 工具**（如需 MCP 方案请参考 [docs/MCP.md](./docs/MCP.md)）
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

## 📅 年份约定（通用术语）

为了让报告与具体年份解耦，本项目所有分析都使用相对概念：

- **今年** = 考生参加高考的年份（AI 从考生信息中获取）
- **去年** = 今年 − 1
- **前年** = 今年 − 2

SQL 查询时按"今年"的具体年份替换 `YYYY`：

| 今年 | 数据表使用 |
|---|---|
| 2026 | `rank_phy2026`（今年）+ `rank_phy2025`（去年）+ `rank_phy2024`（前年） |
| 2027 | `rank_phy2027`（今年）+ `rank_phy2026`（去年）+ `rank_phy2025`（前年） |
| 2028 | `rank_phy2028`（今年）+ `rank_phy2027`（去年）+ `rank_phy2026`（前年） |

**项目维护**：每年补充新一年的 CSV 数据后，所有模板和 SQL 都不需要改框架，只需要把"今年"重新指向新一年即可。

---

## 🤖 AI Agent 辅助报考工作流

### 推荐工具

- **[OpenCode](https://opencode.ai)** / **Claude Code**：本地 shell 即可调 `sqlite3`，零额外配置，响应快。
- 不推荐：Cline / Cherry Studio 通过 MCP 协议接入，仅作历史参考，详见 [docs/MCP.md](./docs/MCP.md)。

> 推荐理由：Agent 拥有 shell 执行权，可以直接运行 `sqlite3` 命令；省去 MCP 协议握手、SQL 写入与回读的开销，更稳定。

### Agent 调 sqlite3 的最佳实践

1. **可读输出**：用 `-header -column` 让 Agent 更易解析。
   ```bash
   sqlite3 -header -column data.sqlite3 "SELECT ..."
   ```
2. **多行 SQL 用 heredoc**：避免 shell 转义地狱。
   ```bash
   sqlite3 -header -column data.sqlite3 <<'EOF'
   SELECT ...
   WHERE ...
   EOF
   ```
3. **大结果集分页**：`LIMIT 50 OFFSET 100` 配合 `COUNT(*)` 估计总量。
4. **编码**：CSV 默认 UTF-8，shell 终端需支持中文（建议 `LANG=zh_CN.UTF-8`）。
5. **结果落盘**：复杂结果重定向到 `/tmp/result.csv` 便于 Agent 反复读取。

### 常见坑

- `plan_YYYY.first` 的值是"物理" / "历史"，用 `LIKE '%物%'` 匹配物理类。
- `plan_YYYY.second` 表述多样（"化学""化学或生物""不限"），用 `LIKE '%化%'` `LIKE '%生%'` `LIKE '%不限%'` 组合匹配。
- `score_phyYYYY` 与 `plan_YYYY` 用 `inst_code` + `major_code` 关联，**`inst` + `major` 文本不一致**时一定要用编码。
- `rank_phyYYYY.score` 类型是 TEXT，比较时用 `CAST(score AS INTEGER)` 避免字典序问题。
- 同一专业在不同年份可能换编码，跨年比较时要校验。
- `score_his2022` 不存在，分析历史类时仅能从 2023 起。

## 💬 提示词模板

完整使用流程与单点提问模板见 [README.md#-单点提问可选](./README.md#-单点提问可选)。

主工作流是 `templates/question.md` → `templates/report.md` 一次完成，单点提问模板只用于"只想问一个具体问题"的场景。

## 📁 报告存档约定

AI 输出的报告应保存到本地 `reports/` 目录，**该目录已被 `.gitignore` 忽略，不会提交到仓库**。

### 文件命名

**用时间戳，不用考生姓名**——AI 通常不知道考生姓名，且时间戳排序更可靠。

格式：

```
reports/YYYYMMDD-HHMMSS.md
```

| 字段 | 说明 |
|---|---|
| `YYYYMMDD` | 生成日期，8 位数字 |
| `HHMMSS` | 生成时间，6 位数字（24 小时制） |

**示例**：

- `reports/20260626-143022.md` — 2026-06-26 14:30:22 生成的报告
- `reports/20260626-143022-v2.md` — 同日再次追问后的更新版
- `reports/20260628-091530.md` — 后续追问生成的新版本（独立文件）

**命名规则**：

- 同一天同一会话多次生成：后缀加 `-v2` / `-v3`
- 不同日期生成：独立文件（不覆盖前一次的）
- 不用考生姓名（隐私 + AI 通常不知道）
- 不用空格 / 中文 / 特殊字符（保证文件系统兼容）

### 目录结构

```
reports/
├── 20260626-143022.md      # 第 1 份报告
├── 20260626-143022-v2.md   # 同日追问更新版
├── 20260628-091530.md      # 第 2 份报告（不同考生或不同次生成）
└── README.md               # 本说明（虽然被 .gitignore 忽略，作为本地参考）
```

**注意**：`reports/README.md` 是本地参考文件，虽然 `reports/` 被忽略，但 README 不应被删除——它记录命名规则。

---

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

### 6. 位次驱动的等效分换算（核心基石）

> **重要**：这是整个报考分析的基石。**等效分错了，下游一切结论都错**——冲稳保划线、风险判断、最终志愿表全部依赖准确的等效分换算。

#### 6.1 三步流程（必须严格按顺序执行）

| 步骤 | 输入 | 输出 | 数据来源 |
|---|---|---|---|
| 1. 今年分数 → 今年位次 | 考生原始分（如 500） | 考生位次（如 50000） | `rank_phy今年` 或 `rank_his今年` |
| 2. 今年位次 → 去年等效分 | 考生位次（50000） | 去年等效分（如 490） | `rank_phy去年` 或 `rank_his去年` |
| 3. 今年位次 → 前年等效分 | 考生位次（50000） | 前年等效分（如 510） | `rank_phy前年` 或 `rank_his前年` |

**关键点**：步骤 2、3 用的是同一个位次（考生今年的位次），不是去年的分数。位次就是沟通今年与去年的"坐标轴"。

#### 6.2 反查去年/前年的精确写法

去年、前年的 rank 表通常不会刚好命中"考生位次"这个整数（因为考生位次是今年分数对应的，不是去年某个精确分数对应的）。用"不大于考生位次的最大位次"近似：

```sql
SELECT score, rank FROM rank_phy去年
WHERE CAST(rank AS INTEGER) <= 考生位次
ORDER BY CAST(rank AS INTEGER) DESC LIMIT 1;
```

#### 6.3 CAST 的强制要求

- `rank_phyYYYY.score` 和 `rank` 都是 TEXT 类型
- 所有比较必须 `CAST(... AS INTEGER)`
- 正确：`WHERE CAST(score AS INTEGER) = 500`、`WHERE CAST(rank AS INTEGER) <= 50000`
- 错误：`WHERE score = 500`、`WHERE score >= 421`（TEXT 下 `5 > 421`）

#### 6.4 出报告前必做的校验

- [ ] 考生位次是否在 0 ~ 该年一分一段表最大值之间（异常值说明第 1 步有误）
- [ ] 反查去年、前年是否都返回了恰好 1 行（0 行或多行都是异常）
- [ ] 去年等效分、前年等效分与今年分的差值是否在 ±30 分以内（差值过大说明位次突变或题目难度异常）
- [ ] 历史类考生如要反查 2022：先确认 `score_his2022` 不存在，跳过前年、只到去年

#### 6.5 反例：为什么不能用直接分数对比

❌ "今年 500 分 = 去年 500 分，所以今年 500 分能上去年 500 分的学校"
- 题目难度不同、报考人数不同、招生计划数不同
- 同一个 500 分在不同年份对应的位次差异可能 1-2 万名

✅ 唯一正确的对比方式：用**今年位次**反查**去年分数**。位次是稳定的，分数是不可比的。

#### 6.6 完整参考 SQL（2026 年物理类 500 分考生示例）

```sql
-- 第 1 步：今年分数 → 今年位次
SELECT score, rank FROM rank_phy2026 WHERE CAST(score AS INTEGER) = 500;
-- 假设返回 rank = 50000

-- 第 2 步：用 50000 反查去年 rank 表（去年等效分）
SELECT score, rank FROM rank_phy2025
WHERE CAST(rank AS INTEGER) <= 50000
ORDER BY CAST(rank AS INTEGER) DESC LIMIT 1;
-- 假设返回 score = 490（去年等效分）

-- 第 3 步：用 50000 反查前年 rank 表（前年等效分）
SELECT score, rank FROM rank_phy2024
WHERE CAST(rank AS INTEGER) <= 50000
ORDER BY CAST(rank AS INTEGER) DESC LIMIT 1;
-- 假设返回 score = 510（前年等效分）
```

#### 6.7 失败处理

- **去年 rank 表缺失**：只展示今年 + 前年两行，标注"去年数据缺失"
- **反查返回 0 行**：位次异常，重新核对第 1 步结果
- **反查返回多行**：SQL 错误（`LIMIT 1` 之外不应有结果），检查 WHERE 条件
- **去年/前年与今年分差 > 30**：异常，标红提示人工复核（可能是疫情年、政策年等特殊情况）

#### 6.8 冲稳保综合决策方法

**核心原则**：不能用"（去年等效分 + 前年等效分）/ 2"作为划线基准——平均后的分数在历史上从未存在过，对应的"录取格局"也无从查证。

**正确做法**：分别用两年实际录取数据独立分析，再综合取保守档位。

1. **去年角度**：把去年等效分 ±15 作为分界线，看每个候选志愿的去年实际录取分落点 → 得到"去年档位"
2. **前年角度**：把前年等效分 ±15 作为分界线，看每个候选志愿的前年实际录取分落点 → 得到"前年档位"
3. **综合判定**：冲 > 稳 > 保，**取两年中更偏"保"的档位**

| 去年档位 | 前年档位 | 综合档位 |
|---|---|---|
| 冲 | 冲 | 冲 |
| 冲 | 稳 | 稳 |
| 稳 | 冲 | 稳 |
| 冲 / 稳 / 保 | 保 | 保 |
| 保 | 冲 / 稳 / 保 | 保 |
| 稳 | 稳 | 稳 |

**为什么取保守**：避免高估录取难度导致漏掉合理档位，确保志愿表的安全垫。

**报告呈现**：冲稳保分析必须分三步展示（去年角度 / 前年角度 / 两年综合），每步独立成表，便于家长复核决策过程。详见 [templates/report.md 第 2 节](./templates/report.md#2-冲稳保志愿清单)。
