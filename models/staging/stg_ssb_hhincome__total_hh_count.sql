WITH all_hh AS 
(
    SELECT
        allt.metric_key AS data_key, 
        allt.observed_metric,
        year,
        value,
        hh_key

    FROM {{ source('ssb_pipeline', 'ssb_household_income_raw') }} as raw

    LEFT JOIN `dbt_ssb.stg_ssb_hhincome__all_type` AS allt
    ON allt.observed_metric = raw.contents
    LEFT JOIN `dbt_ssb.stg_ssb_hhincome__hh_type` as hht 
    USING (type_of_household)


    WHERE metric_key = 10 AND hh_key = 1
)

SELECT

    data_key,
    hh_key,
    CAST(year AS INT64) as year,
    CAST(value AS int64) as household_count

    FROM all_hh