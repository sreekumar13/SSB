WITH hh_type AS (
                SELECT ROW_NUMBER() OVER () AS hh_key,
                type_of_household
                FROM {{ ref('stg_ssb_household_raw_edited') }}
                GROUP BY type_of_household
                )

SELECT * FROM hh_type