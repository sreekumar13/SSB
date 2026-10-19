WITH all_key AS 
(
    SELECT 
        hh_key, 
        hht.type_of_household,
        allt.metric_key, 
        allt.observed_metric,
        year,
        value

        FROM {{ source('ssb_pipeline', 'ssb_household_income_raw') }} as raw

        LEFT JOIN `dbt_ssb.stg_ssb_hhincome__hh_type` as hht 
        USING (type_of_household)

        LEFT JOIN `dbt_ssb.stg_ssb_hhincome__all_type` AS allt
        ON allt.observed_metric = raw.contents

        WHERE hh_key <> 1 AND metric_key = 10
),

count_household_comp AS
(
    SELECT 
        (ak.hh_key||ak.metric_key||'_'||year) AS tot_count_key,
        ak.hh_key,
        CAST(value AS int64) AS household_count,
        CAST (year AS int64) as year,
        CASE WHEN SPLIT (type_of_household, ',') [OFFSET(0)] LIKE 'Living alone%'
             THEN 'One Person'
             WHEN SPLIT (type_of_household, ',') [OFFSET(0)] LIKE 'Couple without resident children%'
             THEN 'Couple'
             WHEN SPLIT (type_of_household, ',') [OFFSET(0)] LIKE 'Couple with children%'
             THEN 'Couple with children'
             WHEN SPLIT (type_of_household, ',') [OFFSET(0)] LIKE 'Mother/father with children%'
             THEN 'Single parent with children'
             WHEN type_of_household LIKE 'Two or more%'
             THEN 'More than one family'
             ELSE NULL
        END AS household_comp,

        CASE WHEN SPLIT (type_of_household, ',') [SAFE_OFFSET(1)] LIKE '%under 30%'
             THEN 'Less than 30 years old'
             WHEN SPLIT (type_of_household, ',') [SAFE_OFFSET(1)] LIKE '%30-44%'
             THEN '30-44 years old'
             WHEN SPLIT (type_of_household, ',') [SAFE_OFFSET(1)] LIKE '%45-66%'
             THEN '45-66 years old'
             WHEN SPLIT (type_of_household, ',') [SAFE_OFFSET(1)] LIKE '%67 years and over%'
             THEN 'More than 66 years old'
             ELSE 'N.A'
        END AS age_of_oldest_person,

        CASE WHEN SPLIT (type_of_household, ',') [SAFE_OFFSET(1)] LIKE '%0-5%'
             THEN '0-5 Years old'
             WHEN SPLIT (type_of_household, ',') [SAFE_OFFSET(1)] LIKE '%6-17%'
             THEN '6-17 Years old'
             WHEN SPLIT (type_of_household, ',') [SAFE_OFFSET(1)] LIKE '%18 years and older%'
             THEN 'More than 17 years old'
             ELSE 'N.A'
        END AS age_of_youngest_child,

        CASE WHEN SPLIT (type_of_household, ',') [OFFSET(0)] LIKE 'Mother/father with children%'
             THEN 1
             ELSE 0
        END AS single_parent_ind

        FROM all_key ak
)

SELECT 
*
FROM count_household_comp