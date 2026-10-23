WITH raw_ssb AS (

SELECT 

CASE WHEN type_of_household = 'Two or more-familiy households'
                     THEN 'Two or more-family households'
                     ELSE type_of_household
                     END as type_of_household,
contents,
year,
value

FROM {{ source('ssb_pipeline', 'ssb_household_income_raw') }}
)

SELECT * FROM raw_ssb