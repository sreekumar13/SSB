WITH hh_cnt_first_last_yr AS(

SELECT
type_of_household,
MIN(year) AS first_year,
MAX(year) AS last_year

FROM {{ ref('dim_hh_type') }}
GROUP BY type_of_household

),

after_tax_const_inc AS (

  SELECT 
  type_of_household,
  income.income AS af_tax_const_inc,
  year
  FROM {{ ref('dim_hh_type') }}
  WHERE income.income_type LIKE '%After-tax income, median in constant prices (NOK)%'
),

first_yr AS (SELECT DISTINCT
type_of_household,
number_of_households AS hh_cnt_first_year,
af_tax_const_inc AS income_first_year,
dim.year as first_year

 FROM {{ ref('dim_hh_type') }} dim
 INNER JOIN hh_cnt_first_last_yr
 USING (type_of_household)
 INNER JOIN after_tax_const_inc
 USING(type_of_household,year)
 WHERE dim.year = first_year
 ),

latest_yr AS (SELECT DISTINCT
type_of_household,
number_of_households AS hh_cnt_last_year,
af_tax_const_inc AS income_last_year,
dim.year as last_year

 FROM {{ ref('dim_hh_type') }} dim
 INNER JOIN hh_cnt_first_last_yr
 USING (type_of_household)
 INNER JOIN after_tax_const_inc
 USING(type_of_household,year)
 WHERE dim.year = last_year
 ),

gwth_rate AS (SELECT 

type_of_household,
hh_cnt_first_year,
hh_cnt_last_year,
income_first_year,
income_last_year,
first_year,
last_year,
ROUND((((hh_cnt_last_year - hh_cnt_first_year)/hh_cnt_first_year)*100),2) AS hh_cnt_gwth_rate,
ROUND((((income_last_year - income_first_year)/income_first_year)*100),2) AS inc_gwth_rate
FROM first_yr
INNER JOIN latest_yr
USING (type_of_household)
),

hh_inc_rnk AS (SELECT
type_of_household,
hh_cnt_first_year,
hh_cnt_last_year,
income_first_year,
income_last_year,
first_year,
last_year,
hh_cnt_gwth_rate,
inc_gwth_rate,
RANK() OVER (ORDER BY hh_cnt_gwth_rate DESC) AS hh_rnk,
RANK() OVER (ORDER BY inc_gwth_rate DESC) AS inc_rnk
FROM gwth_rate
),

final AS (SELECT 
type_of_household,
hh_cnt_first_year AS starting_number_of_households,
hh_cnt_last_year AS final_number_of_households,
income_first_year AS starting_after_tax_income,
income_last_year AS final_after_tax_income,
hh_cnt_gwth_rate AS household_growth_rate,
inc_gwth_rate AS income_growth_rate,
hh_rnk AS household_growth_rank,
inc_rnk AS income_growth_rank,
(hh_rnk-inc_rnk) AS household_income_rank_gap
FROM hh_inc_rnk
)

SELECT * FROM final ORDER BY household_income_rank_gap DESC