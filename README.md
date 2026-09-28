# Subscription Renewal Monitoring

## Business question

Which subscriptions are due for renewal in the next 30 days, which teams own
them, and what is their annualized cost in each original currency?

## Data and approach

- Demonstration dataset: `subscriptions.csv` (81 recorded entries; 76 Active).
- Historical snapshot date: **1 March 2026**. The selected window runs from
  1 March through 30 March 2026, inclusive. The static date makes the analysis
  reproducible rather than changing with today's date.
- SQLite queries in `subscription_renewal_analysis.sql` check ID uniqueness
  and annualized costs, then create the renewal watchlist and summaries.
- Tableau workbook: `Subscription_Renewal_Monitoring.twbx` (add after exporting
  the completed packaged workbook). It charts renewal counts by cost center
  and shows annualized costs by currency.

## Findings

| Measure | Result |
| --- | ---: |
| Active entries renewing in the window | 26 |
| Product renewals | 8 |
| EUR renewals / annualized cost | 13 / 4,644 EUR |
| USD renewals / annualized cost | 12 / 2,820 USD |
| AED renewals / annualized cost | 1 / 144 AED |

One identifier, `SP-021`, is attached to two different services (Notion and
Airtable). It is an ID collision, not grounds to delete a record. The
annualized-cost validation found no mismatches using the stated billing
cadences. Eight entries marked Active have renewal dates before the snapshot;
their status or next renewal date requires review.

## Recommendation and limitations

Prioritize the eight Product renewals for review, then investigate the eight
older Active records and the duplicate ID. Confirm renewals and update records
before treating past dates as missed payments. Costs are annualized estimates,
not cash due during the 30-day window. EUR, USD, and AED totals stay separate
because no exchange rates were supplied. The source is a single snapshot: it
does not show payment transactions, confirmations, or changes after 1 March
2026. The `renewal_soon` source flag is not used as the date filter.

## How to reproduce

1. Open `subscriptions_portfolio.sqlite` in a SQLite client. The table is
   `subscriptions`. Alternatively, import `subscriptions.csv` into SQLite and
   ensure `amount` and `annual_cost` are numeric.
2. Run the statements in `subscription_renewal_analysis.sql` one at a time.
3. Open the Tableau packaged workbook and compare Product = 8 and the three
   currency totals to the SQL results.

This is a portfolio demonstration based on subscription operations. State the
source and its publication rights accurately before sharing the dataset or
workbook publicly.
