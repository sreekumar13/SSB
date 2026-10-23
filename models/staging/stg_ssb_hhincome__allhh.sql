WITH all_hh AS 
(
    SELECT 
        hh_key, 
        allt.metric_key AS data_key, 
        allt.observed_metric,
        year,
        value

    FROM {{ ref('stg_ssb_household_raw_edited') }} as raw

    LEFT JOIN {{ ref('stg_ssb_hhincome__hh_type') }} as hht 
    USING (type_of_household)

    LEFT JOIN {{ ref('stg_ssb_hhincome__all_type') }} AS allt
    ON allt.observed_metric = raw.contents

    WHERE hh_key = 1 AND metric_key <> 10
),

all_hh_index_income AS
(
  SELECT 
    hh_key,
    data_key,
    observed_metric AS income_data ,
    CAST (value AS float64) as value,
    CAST (year AS int64) as year,
    CASE WHEN observed_metric LIKE '%index%' 
         THEN 1
         ELSE 0
    END AS index_ind,
    CASE WHEN observed_metric NOT LIKE '%index%' 
         THEN 1
         ELSE 0
    END AS income_ind,    
    CASE WHEN observed_metric LIKE 'Total income%'
         THEN 'BT'
         ELSE 'AT'
    END AS tax_ind,
    CASE WHEN observed_metric LIKE '%nominal%'
         THEN 0
         ELSE 1
    END AS inf_adj_ind
    FROM all_hh
)

SELECT

    data_key AS income_data_key,
    year,
    income_data,
    CASE WHEN income_ind = 1
         THEN value 
         ELSE NULL
    END AS income,
    CASE WHEN index_ind = 1
         THEN value
         ELSE null
    END AS index_const_price,
    income_ind,
    index_ind,
    tax_ind,
    inf_adj_ind,
    hh_key

    FROM all_hh_index_income