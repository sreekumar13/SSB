WITH all_metrics AS (
                SELECT ROW_NUMBER() OVER () AS metric_key,
                contents as observed_metric
                FROM {{ source('ssb_pipeline', 'ssb_household_income_raw') }}
                GROUP BY contents)

SELECT * FROM all_metrics