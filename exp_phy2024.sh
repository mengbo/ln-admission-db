#!/bin/bash

year=2024

sqlite3 -cmd ".mode csv" -cmd ".head on" data.sqlite3 << EOF
SELECT
s.min_score, r.rank, p.plan_num, s.inst_code, s.major_code,
s.inst || ' ' || s.major AS inst_major
FROM plan_${year} AS p JOIN score_phy${year} AS s JOIN rank_phy${year} AS r
ON p.inst_code = s.inst_code AND p.major_code = s.major_code
AND s.min_score = r.score
WHERE
p.first LIKE '%物%'
AND (
	p.second LIKE '%化%'
	OR p.second LIKE '%生%'
	OR p.second LIKE '%不限%'
)
ORDER BY s.min_score DESC;
EOF

