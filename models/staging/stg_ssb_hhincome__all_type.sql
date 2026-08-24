WITH income_type AS (
                SELECT ROW_NUMBER() OVER () AS key,contents
                FROM {{ source('ssb_pipeline', 'ssb_household_income_raw') }}
                GROUP BY contents)

SELECT * FROM income_type