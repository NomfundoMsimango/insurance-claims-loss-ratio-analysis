USE claims_db;

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
FROM state_summary;