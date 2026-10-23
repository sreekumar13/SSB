WITH all_metrics AS (
                SELECT ROW_NUMBER() OVER () AS metric_key,
                contents as observed_metric
                FROM {{ ref('stg_ssb_household_raw_edited') }}
                GROUP BY contents)

SELECT * FROM all_metrics