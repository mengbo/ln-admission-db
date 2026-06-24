WITH
-- 一次性选出“目标学校”的代码
target_insts AS (
    SELECT DISTINCT inst_code
    FROM (
        SELECT inst_code, inst FROM plan_2025
        UNION
        SELECT inst_code, inst FROM plan_2024
    )
    WHERE inst LIKE '%上海交通大学%'
        -- OR inst LIKE '%浙江大学%'
),

-- 使用 inst_code 来筛选 2025 年计划
filtered_2025 AS (
    SELECT *
    FROM plan_2025
    WHERE batch LIKE '%本科批%'
      AND first LIKE '%物%'
      AND inst_code IN (SELECT inst_code FROM target_insts)
),

-- 使用 inst_code 来筛选 2024 年计划
filtered_2024 AS (
    SELECT *
    FROM plan_2024
    WHERE batch LIKE '%本科批%'
      AND first LIKE '%物%'
      AND inst_code IN (SELECT inst_code FROM target_insts)
)

-- 查询主体：模拟 FULL OUTER JOIN
SELECT
    p25.inst_code, p25.inst, p25.major_code, p25.major,
    p25.plan_num AS plan_num_25,
    p24.plan_num AS plan_num_24,
    s.min_score, r.rank
FROM filtered_2025 AS p25
LEFT JOIN filtered_2024 AS p24
    ON p25.inst_code = p24.inst_code AND p25.major_code = p24.major_code
LEFT JOIN score_phy2024 AS s
    ON p25.inst_code = s.inst_code AND p25.major_code = s.major_code
LEFT JOIN rank_phy2024 AS r
    ON s.min_score = r.score

UNION

SELECT
    p24.inst_code, p24.inst, p24.major_code, p24.major,
    NULL AS plan_num_25,
    p24.plan_num AS plan_num_24,
    s.min_score, r.rank
FROM filtered_2024 AS p24
LEFT JOIN filtered_2025 AS p25
    ON p24.inst_code = p25.inst_code AND p24.major_code = p25.major_code
LEFT JOIN score_phy2024 AS s
    ON p24.inst_code = s.inst_code AND p24.major_code = s.major_code
LEFT JOIN rank_phy2024 AS r
    ON s.min_score = r.score
WHERE p25.inst_code IS NULL

ORDER BY s.min_score DESC;
