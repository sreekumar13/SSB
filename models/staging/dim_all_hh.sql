WITH all_household AS (

SELECT 
type_of_household,
income_data AS income_type,
income,
household_count AS total_number_of_households,
year

FROM `ssb-pipeline1.dbt_ssb.stg_ssb_hhincome__allhh`

INNER JOIN `ssb-pipeline1.dbt_ssb.stg_ssb_hhincome__hh_type`
USING (hh_key)

INNER JOIN `ssb-pipeline1.dbt_ssb.stg_ssb_hhincome__total_hh_count`
USING (year)

WHERE income_ind = 1
)

SELECT * FROM all_household