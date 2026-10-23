WITH all_key AS 
(
    SELECT 
        hh_key, 
        hht.type_of_household,
        allt.metric_key,
        allt.observed_metric,
        income_type_key,
        it.type_of_income,
        contents,
        year,
        value

        FROM {{ ref('stg_ssb_household_raw_edited') }} as raw

        LEFT JOIN {{ ref('stg_ssb_hhincome__hh_type') }} as hht 
        USING (type_of_household)

        LEFT JOIN {{ ref('stg_ssb_hhincome__all_type') }} AS allt
        ON allt.observed_metric = raw.contents

        LEFT JOIN {{ ref('stg_ssb_hhincome__income_type') }} AS it
        ON it.type_of_income = raw.contents
),

income_household_comp AS
(
    SELECT 
        (ak.hh_key||ak.income_type_key||'_'||year) AS income_key,
        ak.hh_key,
        ak.income_type_key,
        type_of_household as household_composition_person_state,
        ak.observed_metric as income_type,
        CASE WHEN ak.observed_metric LIKE 'Total income%'
             THEN 'BT'
             ELSE 'AT'
        END AS tax_ind,
        CASE WHEN ak.observed_metric LIKE '%nominal%'
             THEN 0
             ELSE 1
        END AS inf_adj_ind,
        CAST(value AS float64) AS income,
        CAST (year AS int64) as year

        FROM all_key ak
        INNER JOIN {{ ref('stg_ssb_hhincome__income_type') }}
        USING (income_type_key)
        WHERE hh_key <> 1
)

    SELECT

        income_key,
        hh_key,
        income_type_key,
        CASE WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [OFFSET(0)] LIKE 'Living alone%'
             THEN 'One Person'
             WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [OFFSET(0)] LIKE 'Couple without resident children%'
             THEN 'Couple'
             WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [OFFSET(0)] LIKE 'Couple with children%'
             THEN 'Couple with children'
             WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [OFFSET(0)] LIKE 'Mother/father with children%'
             THEN 'Single parent with children'
             WHEN income_household_comp.household_composition_person_state LIKE 'Two or more%'
             THEN 'More than one family'
             ELSE NULL
        END AS household_comp,

        CASE WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [SAFE_OFFSET(1)] LIKE '%under 30%'
             THEN 'Less than 30 years old'
             WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [SAFE_OFFSET(1)] LIKE '%30-44%'
             THEN '30-44 years old'
             WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [SAFE_OFFSET(1)] LIKE '%45-66%'
             THEN '45-66 years old'
             WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [SAFE_OFFSET(1)] LIKE '%67 years and over%'
             THEN 'More than 66 years old'
             ELSE 'N.A'
        END AS age_of_oldest_person,

        CASE WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [SAFE_OFFSET(1)] LIKE '%0-5%'
             THEN '0-5 Years old'
             WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [SAFE_OFFSET(1)] LIKE '%6-17%'
             THEN '6-17 Years old'
             WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [SAFE_OFFSET(1)] LIKE '%18 years and older%'
             THEN 'More than 17 years old'
             ELSE 'N.A'
        END AS age_of_youngest_child,

        CASE WHEN SPLIT (income_household_comp.household_composition_person_state, ',') [OFFSET(0)] LIKE 'Mother/father with children%'
             THEN 1
             ELSE 0
        END AS single_parent_ind,

        income_type,
        income,
        year,
        tax_ind,
        inf_adj_ind

        FROM income_household_comp