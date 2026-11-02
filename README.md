[SQL claims queries.sql](https://github.com/user-attachments/files/34259385/SQL.claims.queries.sql)
# Auto Insurance Claims: Loss Ratio Analysis

## Business question
Which customer and incident segments cost the insurer the most relative to the premiums they pay, and where should it focus?

## Tools
Excel (cleaning, pivot tables) | MySQL 8.0 (analysis) | Power BI Desktop (dashboard)

## Data
Kaggle "Auto Insurance Claims Data" (insurance_claims.csv), 1,000 policies. No duplicates found. `?` values appear in some categorical columns and were not used in the analysis.

## Method
1. **Excel:** checked for duplicates, added loss ratio, age band and claim size columns, built pivot tables.
2. **MySQL:** wrote 5 queries (aggregation, CASE WHEN, HAVING with a subquery, CTE, RANK window function). See `sql/SQL USE claims_db;

-- Q1: Overall portfolio: policies, premium, claims, loss ratio
SELECT
    COUNT(*) AS policies,
    ROUND(SUM(policy_annual_premium), 0) AS total_premium,
    ROUND(SUM(total_claim_amount), 0) AS total_claims,
    ROUND(SUM(total_claim_amount) / SUM(policy_annual_premium), 2) AS loss_ratio
FROM insurance_claims;

-- Q2: Loss ratio by incident severity (should match Excel pivot)
SELECT
    incident_severity,
    COUNT(*) AS policies,
 ROUND(SUM(total_claim_amount) / SUM(policy_annual_premium), 2) AS loss_ratio
FROM insurance_claims
GROUP BY incident_severity
ORDER BY loss_ratio DESC;

-- Q3: Loss ratio by age band (CASE WHEN)
SELECT
    CASE
        WHEN CAST(age AS SIGNED) < 30 THEN '18-29'
        WHEN CAST(age AS SIGNED) < 40 THEN '30-39'
        WHEN CAST(age AS SIGNED) < 50 THEN '40-49'
        ELSE '50+'
    END AS age_band,
    COUNT(*) AS policies,
    ROUND(SUM(total_claim_amount) / SUM(policy_annual_premium), 2) AS loss_ratio
FROM insurance_claims
GROUP BY age_band
ORDER BY age_band;

-- Q4: Fraud flag vs loss ratio, only groups worse than the portfolio average (HAVING)
SELECT
    fraud_reported,
    COUNT(*) AS policies,
    ROUND(SUM(total_claim_amount) / SUM(policy_annual_premium), 2) AS loss_ratio
FROM insurance_claims
GROUP BY fraud_reported
HAVING SUM(total_claim_amount) / SUM(policy_annual_premium) >
       (SELECT SUM(total_claim_amount) / SUM(policy_annual_premium) FROM insurance_claims);

-- Q5: CTE + window function: rank states by loss ratio
WITH state_summary AS (
    SELECT
        incident_state,
        COUNT(*) AS policies,
        SUM(total_claim_amount) / SUM(policy_annual_premium) AS loss_ratio
    FROM insurance_claims
    GROUP BY incident_state
)
SELECT
    incident_state,
    policies,
    ROUND(loss_ratio, 2) AS loss_ratio,
    RANK() OVER (ORDER BY loss_ratio DESC) AS risk_rank
FROM state_summary;claims queries.sql`
3. **Validation:** SQL results were checked against Excel pivots and the Power BI dashboard. All matched.
4. **Power BI:** one-page dashboard with KPI cards, three charts and state slicers. Loss ratio is a measure (total claims / total premium), not an average of row-level ratios.  `screenshots/`<img width="1317" height="731" alt="dashboard image" src="https://github.com/user-attachments/assets/9db20a31-e65a-4f3e-8fdd-fa93f2ee49dd" />


## Key findings
- **Severity:** Major Damage (5,110%) and Total Loss (4,920%) are about 12x Trivial Damage (431%).
- **Age:** 50+ has the highest loss ratio (4,812%), about 19% above 30-39 (4,054%).
- **Fraud:** Flagged claims run at 4,823% vs 3,996% for non-flagged, about 21% higher.

## Recommendation
Review underwriting and pricing for the 50+ segment, and prioritise fraud screening on high-severity claims.

## Limitations
- Synthetic dataset in which every policy has a claim, so absolute loss ratios are heavily overstated. Compare segments with each other, not with real-world benchmarks.
- One year of data and 1,000 policies; some differences (e.g. between age bands) are modest and not tested for statistical significance.
- Loss ratio uses total claim amount / annual premium, with no adjustment for exposure period or reinsurance.

## Files
- `data/` original CSV
- `excel/` cleaned workbook with Data Notes sheet
- `sql/SQL claims queries.sql` queries
- `powerbi/claims_dashboard.pbix` dashboard
- `screenshots/` dashboard image
