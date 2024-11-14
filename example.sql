SELECT
s.min_score, p.plan_num, p.inst, p.major, p.inst_code, p.major_code
FROM plan_2024 AS p JOIN score_phy2024 AS s
ON p.inst_code = s.inst_code AND p.major_code = s.major_code
WHERE
s.min_score BETWEEN 670 AND 720
AND p.FIRST LIKE '%物%'
AND (
	p.second LIKE '%化%'
	OR p.second LIKE '%生%'
	OR p.second LIKE '%不限%'
)
AND (
	p.inst LIKE '%上海交通大学%'
	OR p.inst LIKE '%浙江大学%'
	OR p.inst LIKE '%南京大学%'
	OR p.inst LIKE '%华中科技大学%'
	-- OR p.inst LIKE '%东北大学%'
)
/*
AND (
	p.major LIKE '%计算机%'
	OR p.major LIKE '%信息%'
	OR p.major LIKE 自动化%'
)
*/
ORDER BY s.min_score DESC;
