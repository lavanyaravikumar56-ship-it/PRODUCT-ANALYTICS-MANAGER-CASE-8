# Customer Acquisition Marketing Mix Analysis

## 📌 Project Overview

This project analyses the company's customer acquisition and marketing performance to identify which marketing channels create the most valuable customers.

The company has a **₹25 crore marketing budget** and wants to understand where the money should be invested for better customer growth and long-term value.

The project uses **Excel, SQL, and Power BI** to clean the data, perform analysis, identify insights, and create business dashboards.

---

## 🎯 Problem Statement

The company spends money across different marketing channels but needs to know which channels actually generate valuable customers.

The main goal is to:

- Analyse marketing spend and performance
- Compare different acquisition channels
- Calculate ROAS and contribution
- Understand customer LTV and retention
- Analyse campaign performance
- Compare first-order and repeat-order economics
- Identify opportunities for better marketing investment
- Build a ₹25 crore budget allocation scenario
- Understand the importance of incremental customer acquisition

---

## 🎯 Objectives

1. Audit and clean campaign and customer data.
2. Calculate marketing metrics such as CAC, ROAS and contribution margin.
3. Analyse first-order and repeat-order economics.
4. Estimate customer lifetime value (LTV).
5. Analyse customer retention by acquisition channel.
6. Compare short-term marketing performance with long-term customer value.
7. Analyse campaigns using SQL.
8. Build Power BI dashboards for management reporting.
9. Create a ₹25 crore marketing budget allocation scenario.
10. Identify the need for incrementality testing before scaling marketing spend.

---

## 📂 Dataset

The project contains the following datasets:

| Dataset | Description |
|---|---|
| Customers | Customer details, segment, city and acquisition channel |
| Marketing Campaigns | Campaign information and target ROAS |
| Marketing Spend | Campaign spending, impressions, clicks and conversions |
| Sessions | Customer sessions and engagement |
| Orders | Customer orders, GMV, discounts and contribution |
| Retention | Customer retention and monthly activity |
| Promo Usage | Discounts and promotions used by customers |
| Channel Targets | Target performance for marketing channels |

---

## 🛠️ Tools & Technologies

- **Microsoft Excel** – Data cleaning, PivotTables and business analysis
- **SQL / MySQL** – Data extraction, joins, CTEs and window functions
- **Power BI** – Interactive dashboards and KPI reporting

---

# 📊 Excel Analysis

Excel was used for data cleaning and business analysis.

### Data Cleaning

The data was checked for:

- Duplicate records
- Missing values
- Invalid values
- Business-rule anomalies

### Key Analysis

The following metrics were analysed:

- Marketing Spend
- GMV
- ROAS
- Contribution Value
- Contribution Margin
- Customer LTV
- Customer Retention
- First-order economics
- Repeat-order economics
- Channel performance

### Important Data Quality Finding

The campaign mapping contains duplicate and unmatched campaign IDs.

Therefore, channel-level CAC and ROAS should be treated as **provisional until the campaign mapping is corrected**.

---

# 🗄️ SQL Analysis

SQL was used to analyse the customer acquisition journey and campaign performance.

### Key SQL Analysis

### 1. Customer Acquisition Funnel

Multiple tables were joined to understand:

**Customer → Session → Order → Promotion → Retention**

### 2. First vs Repeat Orders

CTEs and window functions were used to identify first-order and repeat-order economics.

### 3. Campaign Ranking

Campaigns were ranked based on conversion performance.

### 4. Cumulative Channel Performance

Window functions were used to calculate cumulative conversion performance by channel.

### 5. Attribution Analysis

A simplified attribution analysis was performed to compare customer touchpoints.

### 6. Spend vs Conversion Growth

Campaigns were identified where marketing spend increased faster than conversions.

---

# 📈 Power BI Dashboard

The Power BI report contains five main pages.

## 1. Executive Growth Scorecard

Provides an overall view of business and marketing performance.

### KPIs

- Total Marketing Spend
- Overall ROAS
- Contribution Value
- Total Customers
- Contribution Margin

---

## 2. Channel Economics

Compares the performance of different acquisition channels.

Channels include:

- Affiliate
- Display
- Organic
- Paid Search
- Referral
- Social

Metrics include:

- ROAS
- GMV
- Contribution
- AOV
- Contribution Share

---

## 3. Cohort Retention & LTV

Analyses:

- Customer LTV
- Customer retention
- Customer segments
- Orders
- Active customers
- Cohort performance

---

## 4. Campaign Performance

Analyses:

- Campaign budget
- Marketing spend
- Conversions
- Target ROAS
- Channel performance

---

## 5. ₹25 Crore Budget Simulator

A budget allocation scenario was created for the company's **₹25 crore marketing budget**.

The scenario includes investment across marketing channels along with **₹4 crore allocated toward incrementality and measurement**.

The purpose is to avoid scaling channels only because they have high reported volume or last-click performance.

---

# 📌 Key Business KPIs

| KPI | Value |
|---|---:|
| Total Marketing Spend | ₹1.13 Cr |
| Overall ROAS | 2.75x |
| Contribution Value | ₹1.55 Cr |
| Contribution Margin | 49.61% |
| Total Customers | 3,161 |
| Order Records | ~22K |

---

# 💡 Key Insights

- Overall marketing ROAS is approximately **2.75x**.
- Contribution margin is approximately **49.6%**.
- **Social** has the strongest historical customer-value proxy.
- **Referral** also shows strong historical customer value.
- **Paid Search** generates high order volume but has the lowest historical LTV proxy among the major channels.
- Last-click ROAS alone should not be used to decide the complete marketing budget.
- Campaign ID mapping needs to be corrected before publishing final channel CAC/ROAS.
- Incrementality testing is important to identify whether marketing actually creates additional customers.

---

# 💰 Budget Recommendation

The ₹25 crore scenario prioritises channels based on observed customer-value signals while reserving budget for measurement and incrementality testing.

| Area | Proposed Budget |
|---|---:|
| Social | ₹5.0 Cr |
| Referral | ₹4.5 Cr |
| Organic | ₹3.5 Cr |
| Affiliate | ₹3.0 Cr |
| Display | ₹2.5 Cr |
| Paid Search | ₹2.5 Cr |
| Incrementality & Measurement | ₹4.0 Cr |
| **Total** | **₹25.0 Cr** |

This is an **illustrative scenario**, not proof that these channels will generate the expected incremental return.

---

# ⚠️ Limitations

- Campaign IDs are not consistently mapped to a unique channel.
- Some marketing spend records cannot be matched to the campaign master.
- Orders do not contain a proper order date, so true chronological first-order analysis is limited.
- Session data does not contain a reliable timestamp for true first-touch/last-touch attribution.
- Retention data requires validation before building a standard M1/M3/M6 cohort curve.
- Marginal CAC should be calculated after reliable incrementality data is available.

---

# 🎯 Final Recommendation

Marketing investment should not be based only on last-click ROAS.

The company should:

1. Fix campaign ID mapping.
2. Build a trusted customer acquisition data model.
3. Measure CAC and contribution accurately.
4. Analyse customer retention and LTV.
5. Run geo or audience holdout experiments.
6. Measure incremental customers and incremental contribution.
7. Increase budget only for channels that prove incremental value.

---

## 📌 Conclusion

This project combines **Excel, SQL and Power BI** to provide a complete view of customer acquisition marketing performance.

The analysis helps management understand **where marketing money is being spent, which channels generate customer value, and how the ₹25 crore budget can be allocated more effectively**.

> **The key decision is not simply which channel gets the most sales, but which channel creates the most incremental and long-term customer value.**
