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
