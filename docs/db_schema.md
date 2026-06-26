# 数据库结构

由于高考招生是分省招生，本项目数据都是关于辽宁省的高考数据。

> **本文件是数据库结构的单一权威源。**
> 在执行任何 SQL 之前，先读完本文件。
> **不要**再用 `sqlite3 data.sqlite3 ".schema 表名"` 或 `PRAGMA table_info(...)` 去反推字段——既慢又容易漏掉 `LIKE '%物%'` 这种隐性约定。
> 如果发现文档与数据库实际结果不一致，以数据库为准并更新本文件。

---

## 📅 表命名规则（通用）

本数据库使用 `YYYY` 通配符表示任意 4 位年份。**每年补充新一年 CSV 数据后，按命名规则自动生成新表，本文件无需修改。**

| 表名前缀 | 含义 |
|---|---|
| `plan_YYYY` | YYYY 年招生计划（每个院校 × 专业一行） |
| `score_phyYYYY` | YYYY 年物理类（理科）各专业最低录取分 |
| `score_hisYYYY` | YYYY 年历史类（文科）各专业最低录取分 |
| `rank_phyYYYY` | YYYY 年物理类一分一段表（分数 → 位次） |
| `rank_hisYYYY` | YYYY 年历史类一分一段表（分数 → 位次） |

> "YYYY" 就是 4 位年份数字（2022 / 2023 / 2024 / …），下同。

---

## 📊 当前覆盖（参考快照）

> 不同数据类型发布时间不同：招生计划 5-6 月、录取分数 7-8 月、一分一段表 6 月底。
> 下表区分"已发布"和"待发布"——遇到 2026 录取分数表查询失败是预期状态。
> 实际表清单以 `sqlite3 data.sqlite3 ".tables"` 为准。

| 表系列 | 已发布（已导入） | 待发布（导入条件） |
|---|---|---|
| `plan_YYYY` | 2022, 2023, 2024, 2025 | 2026（6 月已发布，已导入） |
| `score_phyYYYY` | 2022, 2023, 2024, 2025 | 2026（待 7-8 月录取结束后导入） |
| `score_hisYYYY` | 2023, 2024, 2025 | 2026（待 7-8 月录取结束后导入） |
| `rank_phyYYYY` | 2022, 2023, 2024, 2025 | 2026（6 月已发布，已导入） |
| `rank_hisYYYY` | 2022, 2023, 2024, 2025 | 2026（6 月已发布，已导入） |

> **2026 考生场景**：6 月份出方案时，2026 的 score 表**还不存在**，分析只能基于 2025/2024 历史数据 + 2026 的一分一段位次。详见 [AGENTS.md 6.7 失败处理](../AGENTS.md#67-失败处理) 与 [templates/report.md 1 节降级策略](../templates/report.md#1-定位分析)。

---

## 🧩 数据行 = 辽宁志愿单位（重要约定）

> 本节是阅读下面字段定义的前提，请先读这一段。

辽宁采用"专业平行志愿"模式，**每个 (院校, 专业) 组合就是 1 个独立志愿槽**，
一共可填 **112 个**志愿。详细说明见 [AGENTS.md 辽宁志愿模式](../AGENTS.md#-辽宁志愿模式核心概念)。

因此本数据库的核心表 `plan_YYYY` / `score_phyYYYY` / `score_hisYYYY` 的
**每一行**就对应辽宁志愿表里的 1 个槽：

| 表 | 每行 = ? |
|---|---|
| `plan_YYYY` | 1 个 (院校, 专业) 组合的计划数 |
| `score_phyYYYY` / `score_hisYYYY` | 该 (院校, 专业) 组合的最低录取分 |
| `rank_phyYYYY` / `rank_hisYYYY` | 分数 → 全省累计位次（不是按志愿划分的） |

志愿筛选时，AI 输出的"志愿"颗粒度 = 1 行 = 1 个槽；
志愿推荐表（[report.md 2.3 节](../templates/report.md#23-志愿推荐表默认-200-条)）按 (院校, 专业) 全局去重即可。

---

## 🗂 三类表的字段定义

> 每年表的字段结构相同，**只看一次即可**。

### 1. 招生计划表（`plan_YYYY`）

在高考招生前，招生主管部门会发布各个院校的各个专业的招生计划。

| 字段 | 类型 | 含义 |
|---|---|---|
| `batch` | TEXT | 录取批次 |
| `first` | TEXT | 首选科目（"物理" / "历史"，区分理科 / 文科考生） |
| `inst_code` | TEXT | 院校编码（主管部门统一编码，一般不变化） |
| `inst` | TEXT | 院校名称 |
| `major_code` | TEXT | 专业编码（主管部门统一编码，偶有变化） |
| `major` | TEXT | 专业名称 |
| `second` | TEXT | 次选科目要求（"化学" / "化学或生物" / "不限" 等） |
| `plan_num` | TEXT | 该院校此专业在辽宁计划招生人数（CSV 数字默认推断为 TEXT，比较时 `CAST(plan_num AS INTEGER)`） |

### 2. 一分一段表（`rank_phyYYYY` / `rank_hisYYYY`）

在高考出成绩后，主管部门会发布考生考试成绩的一分一段表，通过此表可以知道分数所对应的省内排名。**由于高考是以成绩排名从高到低按照考生志愿进行录取的，考生排名才是决定录取的关键。**

例如：2024 年物理类 701 分省内排名为 52 名、700 分为 65 名；2023 年物理类 700 分为 49 名、699 分为 65 名；则 2024 年的 701 分大概相当于 2023 年的 699 分。

| 字段 | 类型 | 含义 |
|---|---|---|
| `score` | TEXT | 高考分数（**TEXT 类型，比较时要 `CAST(score AS INTEGER)`**） |
| `number` | TEXT | 该分数考生人数 |
| `rank` | TEXT | 累计人数（分数 ≥ score 的考生总数，**TEXT 类型，比较时要 CAST**） |

### 3. 录取分数表（`score_phyYYYY` / `score_hisYYYY`）

在高考录取后，主管部门会发布各个院校各个专业的录取情况，最主要的就是录取的最低分数。

| 字段 | 类型 | 含义 |
|---|---|---|
| `inst_code` | TEXT | 院校编码（与 `plan_YYYY.inst_code` 对应） |
| `inst` | TEXT | 院校名称 |
| `major_code` | TEXT | 专业编码（与 `plan_YYYY.major_code` 对应） |
| `major` | TEXT | 专业名称（详细描述） |
| `min_score` | TEXT | 该院校该专业最低录取分数 |

---

## 🔗 三类表之间的关联

- **`score_phyYYYY` ↔ `plan_YYYY`**：通过 `inst_code` + `major_code` 关联（**强烈推荐用编码**，inst + major 文本字段跨年时偶有不一致）
- **`score_phyYYYY` ↔ `rank_phyYYYY`**：通过 `min_score` ↔ `score` 关联，再从 rank 表反查对应位次
- **历史类同理**：`score_hisYYYY` ↔ `plan_YYYY` 用编码；`score_hisYYYY` ↔ `rank_hisYYYY` 用分数
- **`plan_YYYY.first`**：值为"物理" / "历史"，用 `LIKE '%物%'` 匹配物理类，`LIKE '%历%'` 匹配历史类
- **`plan_YYYY.second`**：表述多样（"化学" / "化学或生物" / "不限"），用 `LIKE '%化%'` / `LIKE '%生%'` / `LIKE '%不限%'` 组合匹配

---

## 📐 常见查询示例

下例把 "今年" 替换为 2026，"去年" 替换为 2025——按实际高考年份调整即可。

```sql
-- 查看某年某专业的招生计划（物理类 + 选科要求化学）
SELECT * FROM plan_2026 WHERE first LIKE '%物%' AND second LIKE '%化%';

-- 查 2026 物理类 600 分对应位次
SELECT score, rank FROM rank_phy2026 WHERE CAST(score AS INTEGER) = 600;

-- 用 2026 物理类 600 分的位次反查 2025 等效分
SELECT score, rank FROM rank_phy2025
WHERE CAST(rank AS INTEGER) <= (SELECT rank FROM rank_phy2026 WHERE CAST(score AS INTEGER) = 600)
ORDER BY CAST(rank AS INTEGER) DESC LIMIT 1;

-- 物理类某院校近两年录取分 + 位次（用编码关联）
SELECT s.major, s.min_score, r.rank
FROM score_phy2025 s
JOIN rank_phy2025 r ON s.min_score = r.score
JOIN plan_2025    p ON p.inst_code = s.inst_code AND p.major_code = s.major_code
WHERE p.inst_code = '某院校编码' AND p.first LIKE '%物%'
ORDER BY s.min_score DESC;
```

---

## ⚠️ 已知数据边界

- **`score_his2022` 不存在**：历史类录取分数表从 2023 年起，分析历史类时最早只能回溯到 2023
- **`score_phy2026` / `score_his2026` 不存在（2026 考生场景）**：2026 年录取分数 7-8 月发布，6 月份出方案时**只能用 2025/2024 历史 score 数据**——这是预期状态，不是数据错误
- **`plan_YYYY.second` 与 `plan_num` 偶有更新滞后**：以官方最新发布为准
- **`major_code` 偶有变化**：跨年比较同一专业时要校验编码是否仍一致
- **`plan_num` 类型为 TEXT**：由 `createdb.sh` 的 `.import --csv` 默认推断为 TEXT；比较/排序/求和时需 `CAST(plan_num AS INTEGER)`，否则字典序可能导致"10 < 2"