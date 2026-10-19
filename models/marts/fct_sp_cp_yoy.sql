WITH single_parent AS (

SELECT DISTINCT
dim.type_of_household,
dim.income.income_type,
dim.income.income,
dim.year,
stg2.age_of_youngest_child


FROM {{ ref('dim_hh_type') }} dim
INNER JOIN {{ ref('stg_ssb_hhincome__hh_type') }} stg1
USING (type_of_household)
INNER JOIN {{ ref('stg_ssb_hhincome__income') }} stg2
USING (hh_key,year)
WHERE dim.type_of_household LIKE '%Mother/father%' 
AND dim.income.income_type LIKE '%After-tax income, median in constant prices (NOK)%'),

couple AS (
SELECT DISTINCT
dim.type_of_household,
dim.income.income_type,
dim.income.income,
dim.year,
stg2.age_of_youngest_child


FROM {{ ref('dim_hh_type') }} dim
INNER JOIN {{ ref('stg_ssb_hhincome__hh_type') }} stg1
USING (type_of_household)
INNER JOIN {{ ref('stg_ssb_hhincome__income') }} stg2
USING (hh_key,year)
WHERE dim.type_of_household LIKE '%Couple with children%' 
AND dim.income.income_type LIKE '%After-tax income, median in constant prices (NOK)%'),

income_diff AS (

  SELECT 

  sp.type_of_household,
  sp.income_type,
  sp.income AS single_parent_income,
  cp.income AS couple_income,
  sp.year,
  sp.age_of_youngest_child as single_parent_household_child_age,
  cp.age_of_youngest_child as couple_household_child_age,
  ((cp.income-sp.income)/cp.income)*100 AS income_diff_pct

  FROM single_parent sp
  INNER JOIN couple cp
  ON sp.year = cp.year
  AND sp.age_of_youngest_child = cp.age_of_youngest_child
),

final AS (SELECT 
  type_of_household,
  income_type,
  year,
  single_parent_household_child_age AS age_of_youngest_child,
  income_diff_pct
  
  FROM income_diff)

  SELECT * FROM final 
  ORDER BY age_of_youngest_child ASC, year ASC