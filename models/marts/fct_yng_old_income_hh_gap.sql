WITH young_person AS 

(
SELECT 
type_of_household, 
year,
income.income as yng_prsn_inc,
number_of_households as yng_prsn_hh_cnt
FROM `dbt_ssb.dim_hh_type`
WHERE income.income_type LIKE '%After-tax income, median in constant prices (NOK)%'
AND type_of_household LIKE '%Living alone, person 30-44 years%'),

old_person AS (SELECT 
type_of_household, 
year,
income.income as old_prsn_inc,
number_of_households as old_prsn_hh_cnt
FROM `dbt_ssb.dim_hh_type`
WHERE income.income_type LIKE '%After-tax income, median in constant prices (NOK)%'
AND type_of_household LIKE '%Living alone, person 67 years and over%'),

gap_calc AS (

SELECT
yp.type_of_household AS young_person_household,
op.type_of_household AS old_person_household,
yp.yng_prsn_inc AS young_person_household_income,
op.old_prsn_inc AS old_person_household_income,
yp.yng_prsn_hh_cnt AS young_person_household_count,
op.old_prsn_hh_cnt AS old_person_household_count,
(yp.yng_prsn_inc - op.old_prsn_inc) AS income_gap,
(yp.yng_prsn_hh_cnt - op.old_prsn_hh_cnt) AS household_count_gap,
yp.year

FROM young_person yp
INNER JOIN old_person op
ON yp.year = op.year

)

/*yoy_diff AS (

SELECT
young_person_household,
old_person_household,
young_person_household_income,
old_person_household_income,
young_person_household_count,
old_person_household_count,
LAG(inc_diff) OVER(ORDER BY year) AS prev_diff_inc,
inc_diff AS income_gap,
LAG(hh_cnt_diff) OVER(ORDER BY year) as prev_diff_hh,
hh_cnt_diff AS household_gap,
ROUND(((SAFE_DIVIDE(inc_diff,LAG(inc_diff) OVER(ORDER BY year))-1)*100),2) AS inc_pnct_diff,
ROUND(((SAFE_DIVIDE(hh_cnt_diff,LAG(hh_cnt_diff) OVER(ORDER BY year)) - 1) *100),2) AS hh_pnct_diff,
ROUND(((SAFE_DIVIDE(young_person_household_count,LAG(young_person_household_count) OVER(ORDER BY year))-1)*100),2) AS young_person_hh_pcnt,
ROUND(((SAFE_DIVIDE(old_person_household_count,LAG(old_person_household_count) OVER(ORDER BY year)) - 1) *100),2) AS old_person_hh_pcnt,
ROUND(((SAFE_DIVIDE(young_person_household_income,LAG(young_person_household_income) OVER(ORDER BY year))-1)*100),2) AS young_person_inc_pcnt,
ROUND(((SAFE_DIVIDE(old_person_household_count,LAG(old_person_household_count) OVER(ORDER BY year)) - 1) *100),2) AS old_person_inc_pcnt,
year

FROM income_gap
)*/

SELECT * FROM gap_calc 
/*WHERE prev_diff_inc IS NOT NULL AND prev_diff_hh IS NOT NULL*/
ORDER BY year 