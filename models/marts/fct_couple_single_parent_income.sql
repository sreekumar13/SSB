WITH all_rank AS (SELECT
type_of_household,
income.income AS income,
year,
RANK() OVER(PARTITION BY year ORDER BY income.income DESC) AS inc_rnk,
FROM {{ ref('dim_hh_type') }}
WHERE income.income_type LIKE '%After-tax income, median in constant prices (NOK)%'),

rank_filtered AS (

SELECT 
  CASE WHEN type_of_household LIKE '%Couple with children%' 
       THEN 'Couple Household'
       ELSE 'Single Parent Household' 
       END AS household_type,
  CASE WHEN SPLIT(type_of_household,',') [SAFE_OFFSET(1)] LIKE '%youngest child 0-5 years%'
       THEN '1. 0-5 Years Old'
       WHEN SPLIT(type_of_household,',') [SAFE_OFFSET(1)] LIKE '%youngest child 6-17 years%'
       THEN '2. 6-17 Years Old'
       WHEN SPLIT(type_of_household,',') [SAFE_OFFSET(1)] LIKE '%youngest child 18 years and older%'
       THEN '3. 18 Years and Older'
       ELSE NULL
       END AS age_category_youngest_child,
  income,
  year,
  inc_rnk
  FROM all_rank
  WHERE type_of_household LIKE '%Mother/father with children%'  OR type_of_household LIKE 'Couple with children%'
  ORDER BY year
),

final AS (SELECT * FROM 

(
 SELECT 
  household_type,
  age_category_youngest_child,
  income,
  year,
  inc_rnk

  FROM rank_filtered )

  PIVOT
  (
    MAX(income) AS income,
    MAX(inc_rnk) AS inc_rnk
    FOR household_type IN('Couple Household' AS couple, 'Single Parent Household' AS single_parent)
  )
  ORDER BY year)

  SELECT 
  age_category_youngest_child,
  income_couple AS couple_household_income,
  income_single_parent AS single_parent_household_income,
  inc_rnk_couple AS total_rank_couple_household,
  inc_rnk_single_parent AS total_rank_single_parent_household,
  year,
  FROM final
  ORDER BY year,age_category_youngest_child