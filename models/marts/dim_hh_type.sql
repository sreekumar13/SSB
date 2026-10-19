SELECT 

type_of_household,
inc.year,
struct(income_type,income) AS income,
household_count AS number_of_households

FROM {{ ref('stg_ssb_hhincome__income') }} inc

INNER JOIN {{ ref('stg_ssb_hhincome__hh_type') }}
USING(hh_key)

INNER JOIN {{ ref('stg_ssb_hhincome__income_type') }}
USING(income_type_key)

INNER JOIN {{ ref('stg_ssb_hhincome__hh_count') }}
USING (hh_key,year)