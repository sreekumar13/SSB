WITH all_rank AS (

SELECT
type_of_household,
income.income AS income,
year,
RANK() OVER(PARTITION BY year ORDER BY income.income DESC) AS inc_rnk,
FROM {{ ref('dim_hh_type') }}
WHERE income.income_type LIKE '%After-tax income, median in constant prices (NOK)%'),

rank_filtered AS (

SELECT 
  type_of_household,
  income,
  year,
  inc_rnk AS total_rank
  FROM all_rank
  WHERE type_of_household LIKE '%Mother/father with children%'  OR type_of_household LIKE 'Couple%'
)
SELECT * FROM rank_filtered ORDER BY year