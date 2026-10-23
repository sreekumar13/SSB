WITH income_type AS (
                SELECT ROW_NUMBER() OVER () AS key,contents
                FROM {{ ref('stg_ssb_household_raw_edited') }}
                GROUP BY contents)

SELECT
ROW_NUMBER() OVER () AS income_type_key,
key AS metric_key,
contents as type_of_income
FROM income_type
WHERE key IN (1,2,4,5)