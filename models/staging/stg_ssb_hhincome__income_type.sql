WITH income_type AS (
                SELECT ROW_NUMBER() OVER () AS key,contents
                FROM {{ source('ssb_pipeline', 'ssb_household_income_raw') }}
                GROUP BY contents)

SELECT
ROW_NUMBER() OVER () AS income_key, 
contents as type_of_income
FROM income_type
WHERE key IN (1,2,4,5)