WITH hh_type AS (
                SELECT ROW_NUMBER() OVER () AS key,type_of_household
                FROM {{ source('ssb_pipeline', 'ssb_household_income_raw') }}
                GROUP BY type_of_household
                )

SELECT * FROM hh_type