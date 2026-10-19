WITH last_yr_inc_nom AS (
  
SELECT 
(year - 1) AS previous_year,
year AS current_year,
type_of_household,
income.income_type AS income_type,
LAG(income.income) OVER (PARTITION BY type_of_household,income.income_type ORDER BY year) AS prev_year_nom_inc,
income.income AS curr_year_nom_income

FROM {{ ref('dim_hh_type') }}
WHERE income.income_type LIKE '%After-tax income, median in nominal NOK%'),

last_yr_inc_adj AS (
  
SELECT 
(year - 1) AS previous_year,
year AS current_year,
type_of_household,
income.income_type AS income_type,
LAG(income.income) OVER (PARTITION BY type_of_household,income.income_type ORDER BY year) AS prev_year_adj_inc,
income.income AS curr_year_adj_income

FROM {{ ref('dim_hh_type') }}
WHERE income.income_type LIKE '%After-tax income, median in constant prices (NOK)%'),

yoy as (

SELECT  
nom.previous_year,
nom.current_year,
nom.type_of_household,
nom.income_type,
COALESCE(nom.curr_year_nom_income/prev_year_nom_inc,0) AS nom_YOY,
COALESCE(adj.curr_year_adj_income/prev_year_adj_inc,0) AS adj_YOY

FROM last_yr_inc_nom nom

INNER JOIN last_yr_inc_adj adj
ON nom.type_of_household = adj.type_of_household
AND nom.current_year = adj.current_year
AND nom.previous_year = adj.previous_year
),

final AS (

SELECT 
previous_year,
current_year,
type_of_household,
income_type,
(nom_YOY - adj_YOY) AS yoy_diff

FROM yoy
)

SELECT * FROM final ORDER BY yoy_diff desc