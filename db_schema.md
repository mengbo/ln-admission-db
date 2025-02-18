# 数据库结构


由于高考招生是分省招生，本项目数据都是关于辽宁省的高考数据。

## 招生计划表

在高考招生前，招生主管部门会发布各个院校的各个专业的招生计划。

plan_2022 为2022年招生计划表；
plan_2023 为2023年招生计划表；
plan_2024 为2024年招生计划表。

表结构如下：

batch 为批次字段，表示录取批次；
first 为首选科目字段，决定考生为历史类还是物理类；
inst_code 为院校编码字段，为主管部门统一编码，一般不变化；
inst 为院校字段，即院校名称；
major_code 为专业编码字段，为主管部门统一编码，偶有变化；
major 为专业字段，即招生专业名称；
second 为次选科目字段，为招生院校对考生次选科目要求；
plan_num 为招生计划数字段，即改院校此专业招生人数。

## 一分一段表

在高考出成绩后，主管部门会发布考生考试成绩的一分一段表，通过此表可以知道考生分数所对应的省内排名，由于高考是按照成绩排名从高到底按照考生志愿进行录取的，所以考生排名才是决定考试录取的关键。

rank_his2022 为2022年历史类一分一段表；
rank_his2023 为2023年历史类一分一段表；
rank_his2024 为2024年历史类一分一段表；
rank_phy2022 为2022年物理类一分一段表；
rank_phy2023 为2023年物理类一分一段表；
rank_phy2024 为2024年物理类一分一段表。

表结构如下：

score 为高考分数字段；
number 为该分数人数字段，即有几位考生高考分数为该分数；
rank 为累计人数字段，即有多少为考生分数大于等于该分数。

## 录取分数表

在高考录取后，主管部门会发布各个院校各个专业的录取情况，最主要的就是录取的最低分数，即多少分才能被这个专业录取。

score_his2023 为2023年历史类专业分数表；
score_his2024 为2024年历史类专业分数表；
score_phy2022 为2022年物理类专业分数表；
score_phy2023 为2023年物理类专业分数表；
score_phy2024 为2024年物理类专业分数表。

表结构如下：

inst_code 为院校编码字段，为主管部门统一编码，一般不变化；
inst 为院校字段，即院校名称；
major_code 为专业编码字段，为主管部门统一编码，偶有变化；
major 为专业字段，即招生专业名称；
min_score 为最低录取分数字段，即该院校该专业最低录取分数为多少分。

