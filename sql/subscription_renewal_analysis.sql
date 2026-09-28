-- Subscription Renewal Monitoring | SQLite
-- Snapshot: 2026-03-01. Window: 2026-03-01 through 2026-03-30 inclusive.
-- Source: subscriptions.csv, one row per recorded subscription entry.
-- Run each SELECT statement separately in SQLPro for SQLite.

-- 1. Source overview. Expected: 81 records, 76 marked Active.
SELECT
    COUNT(*) AS source_rows,
    SUM(CASE WHEN status = 'Active' THEN 1 ELSE 0 END) AS active_rows
FROM subscriptions;

-- 2. Candidate ID collisions. Expected: SP-021 appears twice.
SELECT subscription_id, COUNT(*) AS records_with_id
FROM subscriptions
GROUP BY subscription_id
HAVING COUNT(*) > 1;

-- 3. Investigate the collision. Different tools share SP-021;
-- do not delete either record solely because the ID repeats.
SELECT subscription_id, vendor, tool_name, billing_type, amount, currency
FROM subscriptions
WHERE subscription_id = 'SP-021';

-- 4. Check whether annual_cost agrees with billing cadence.
-- Expected: zero mismatches, with a 0.01 tolerance.
WITH checked AS (
    SELECT subscription_id, tool_name, billing_type, amount, annual_cost,
           CASE billing_type
               WHEN 'Monthly' THEN amount * 12
               WHEN 'Quarterly' THEN amount * 4
               WHEN 'Annual' THEN amount
           END AS expected_annual_cost
    FROM subscriptions
)
SELECT *
FROM checked
WHERE expected_annual_cost IS NULL
   OR annual_cost IS NULL
   OR ABS(annual_cost - expected_annual_cost) > 0.01;

-- 5. Operational watchlist. Expected: 26 records.
-- Explicit dates keep the historical dashboard reproducible.
SELECT subscription_id, tool_name, cost_center, renewal_date,
       billing_type, annual_cost, currency
FROM subscriptions
WHERE status = 'Active'
  AND renewal_date >= '2026-03-01'
  AND renewal_date < '2026-03-31'
ORDER BY renewal_date, subscription_id;

-- 6. Dashboard chart: renewals by cost center. Expected: Product = 8;
-- the nine department counts sum to 26. COUNT(*) retains both SP-021 rows.
SELECT cost_center, COUNT(*) AS renewals_due
FROM subscriptions
WHERE status = 'Active'
  AND renewal_date >= '2026-03-01'
  AND renewal_date < '2026-03-31'
GROUP BY cost_center
ORDER BY renewals_due DESC, cost_center;

-- 7. Dashboard table: annualized costs in original currencies.
-- Expected: AED 1 / 144; EUR 13 / 4644; USD 12 / 2820.
-- Amounts in different currencies must not be added without FX conversion.
SELECT currency, COUNT(*) AS renewals_due,
       ROUND(SUM(annual_cost), 2) AS annualized_cost
FROM subscriptions
WHERE status = 'Active'
  AND renewal_date >= '2026-03-01'
  AND renewal_date < '2026-03-31'
GROUP BY currency
ORDER BY currency;

-- 8. Exception queue as of the snapshot: 8 Active entries have dates
-- before 2026-03-01. A past renewal date does not prove a missed payment;
-- investigate whether the record was renewed but not updated.
SELECT subscription_id, tool_name, renewal_date, status, payment_date
FROM subscriptions
WHERE status = 'Active'
  AND renewal_date < '2026-03-01'
ORDER BY renewal_date;
