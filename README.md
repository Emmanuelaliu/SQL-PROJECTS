# 🚀 Exploratory Data Analysis of Global Tech Startups (SQLite)

> Which tech startups stayed strong between 2023 and 2026, and which shrank, ran low on cash, or got acquired? An SQL-only exploratory analysis of 25,000 startups to support funding, hiring and investment decisions.

![SQLite](https://img.shields.io/badge/SQLite-Database-003B57?logo=sqlite&logoColor=white)
![DBeaver](https://img.shields.io/badge/Tool-DBeaver-brown)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## 📌 Table of Contents
1. [Project Overview](#-project-overview)
2. [Business Problem](#-business-problem)
3. [Dataset](#-dataset)
4. [Tools Used](#-tools-used)
5. [Analysis Workflow](#-analysis-workflow)
6. [Key Insights](#-key-insights)
7. [Investor Shortlisting Framework](#-investor-shortlisting-framework)
8. [Sample Queries](#-sample-queries)
9. [Recommendations](#-recommendations)
10. [Limitations & Next Steps](#-limitations--next-steps)
11. [Repository Structure](#-repository-structure)
12. [About the Author](#-about-the-author)

---

## 📖 Project Overview
This project uses SQL to explore a synthetic but realistic dataset tracking the global technology ecosystem from 2023 to 2026. It covers data quality checks, dimension and measure exploration, KPI calculation, and a multi-criteria shortlist of the most resilient startups.

**Skills demonstrated:** data profiling · duplicate detection · aggregation · `CASE` bucketing · CTEs · window functions (`RANK`, `COUNT() OVER`, `SUM() OVER (PARTITION BY)`) · KPI design · translating query output into business insight.

## 🎯 Business Problem
Between 2023 and 2026, tech startups faced tighter funding, falling valuations, widespread layoffs and pressure to adopt AI. Investors, founders and acquirers still lack a clear view of which startups are truly resilient and which are just running out of time.

**Goal:** find what separates startups that stayed strong from those that shrank, ran low on cash, or were acquired, so stakeholders can make better funding, hiring and investment decisions.

### Questions answered
- Which countries and cities host the most startups?
- How do funding, ARR and valuation change from Seed to Post-IPO?
- Do top-tier investors back higher-valued companies?
- How many companies fall into each runway band (under 6, 6–12, 12–24, 24+ months)?
- Which domains and countries are strongest on average?
- Do companies with deeper AI adoption lay off fewer staff?
- Which companies are the best investment candidates, and which are the top performers per domain?

## 🗂 Dataset
**Source:** synthetic dataset of global tech startups, `global_tech_startups` table, **25,000 rows**, 10 domains, 10 countries, 29 city locations.

| Column | Description |
|---|---|
| `Company_ID` | Unique identifier |
| `Domain` | Sector (10 domains) |
| `Founding_Year` | Year the company started |
| `Country` / `City` | Headquarters location |
| `Funding_Stage` | Seed → Series A → Series B → Series C+ → Pre-IPO → Post-IPO |
| `Total_Funding_USD_Millions` | Cumulative money raised |
| `Valuation_USD_Millions` | Estimated company value |
| `Revenue_ARR_Millions` | Predictable yearly revenue |
| `Monthly_Burn_Rate_Millions` | Monthly spend beyond earnings |
| `Runway_Months_2024` | Months of cash left at the 2024 burn rate |
| `Peak_Headcount_2023` | Highest employee count in 2023 |
| `Layoffs_2024_2025` | Employees laid off across 2024 and 2025 |
| `Current_Headcount_2026` | Employees as of 2026 |
| `Investor_Tier` | Bootstrapped, Tier 1, Tier 2, Tier 3, Corporate VC |
| `AI_Adoption_Level` | Low / Medium / High |
| `Acquisition_Status` | Independent, acquired, IPO, or similar |

## 🛠 Tools Used
- **SQLite** (database), queried in DBeaver
- **Concepts:** CTEs, window functions, conditional aggregation, ranking

## 🔍 Analysis Workflow
1. **Data quality checks:** row count vs distinct `Company_ID`, duplicate detection, null checks.
2. **Dimension and measure exploration:** distinct domains, countries, cities, funding stages, investor tiers, AI levels, acquisition statuses; founding-year range.
3. **KPI exploration:** startups by location, financials by funding stage, investor tier, domain and country, runway bands, layoff rate by AI adoption.
4. **Resilience shortlisting:** multi-criteria filters built with nested CTEs.
5. **Ranking:** top companies per domain using window functions.

## 💡 Key Insights
| # | Finding |
|---|---|
| 1 | **Data quality:** one `Company_ID` (`7791E581`) appears twice with a different domain and country, so one record is assumed to be an entry error. No null `Company_ID`s were found. |
| 2 | **Geography:** the USA, China, India, the UK, Israel, Germany and Canada each host more than 1,000 startups. |
| 3 | **Funding stage:** Pre-IPO and Post-IPO companies have notably higher funding, ARR and valuation than early-stage startups. |
| 4 | **Investor tier:** Tier 1 backed startups have the highest funding and valuation. |
| 5 | **Country averages:** country-level averages are fairly close, so location alone is a weak separator. Japan stands out for highest valuation with relatively few startups. |
| 6 | **AI adoption:** high-AI startups lay off more people in absolute terms, but the layoff *rate* is close to other groups. |
| 7 | **Shortlist:** applying status and AI filters narrowed 25,000 startups to **11,133**; domain-level valuation and runway thresholds narrowed that to **1,969**. |

## 🎯 Investor Shortlisting Framework
**Criteria 1 (25,000 → 11,133):** `Acquisition_Status` is Independent or IPO, and `AI_Adoption_Level` is High or Medium.

**Criteria 2 (11,133 → 1,969):** valuation and runway at or above the domain average:

| Domain | Min valuation ($M) | Min runway (months) |
|---|---|---|
| Generative AI | 885 | 15 |
| SpaceTech | 747 | 14 |
| Web3/Crypto | 402 | 12 |
| Autonomous Vehicles | 376 | 11 |
| FinTech | 344 | 11 |
| HealthTech | 328 | 12 |
| Robotics | 323 | 11 |
| ClimateTech | 320 | 11 |
| EdTech | 298 | 11 |
| Cybersecurity | 292 | 11 |

## 🧾 Sample Queries

**Runway bands**
```sql
SELECT
  CASE
    WHEN Runway_Months_2024 < 6  THEN 'Under 6'
    WHEN Runway_Months_2024 < 12 THEN 'Between 6 and 12'
    WHEN Runway_Months_2024 < 24 THEN 'Between 12 and 24'
    ELSE '24+ months'
  END AS Category,
  COUNT(Company_ID) AS NrOfCompany
FROM global_tech_startups
GROUP BY Category;
```

**Layoff rate by AI adoption**
```sql
SELECT AI_Adoption_Level,
       COUNT(*) AS NrOfCompany,
       SUM(Layoffs_2024_2025) AS Nr_of_LayoffStaffs,
       SUM(Peak_Headcount_2023) AS Initial_nr_of_staffs,
       ROUND(CAST(SUM(Layoffs_2024_2025) AS REAL) / SUM(Peak_Headcount_2023) * 100, 2) || '%' AS layoff_rate
FROM global_tech_startups
GROUP BY AI_Adoption_Level;
```

**Top 3 shortlisted companies per domain**
```sql
WITH ranked AS (
  SELECT Company_ID, Domain, Funding_Stage, Valuation_USD_Millions, Runway_Months_2024,
         RANK() OVER (PARTITION BY Domain
                      ORDER BY Valuation_USD_Millions DESC, Runway_Months_2024 DESC) AS Company_rank
  FROM potential_company_2   -- the Criteria 2 shortlist
)
SELECT * FROM ranked WHERE Company_rank <= 3;
```
Full scripts are in [`/sql`](./sql).

## ✅ Recommendations
- **Investors:** prioritise independent or listed companies with at least medium AI adoption, and benchmark valuation and runway against the *domain* average, not the whole market.
- **Founders:** runway under 12 months is the main warning sign; investor tier and funding stage track strongly with scale.
- **Acquirers:** use the shortlist as a starting watchlist; look at domains where strong valuation and runway coincide.
- **Hiring decisions:** AI adoption alone does not predict fewer layoffs, so look at the layoff rate, not totals.

## ⚠️ Limitations & Next Steps
- The dataset is synthetic, so findings illustrate method rather than real market behaviour.
- Averages are skewed by very large companies; medians would be more robust.
- Next steps: add a headcount retention metric (`Current_Headcount_2026 / Peak_Headcount_2023`), test AI adoption against retention, and build a Power BI dashboard on top of these findings.

## 📁 Repository Structure
```
global-tech-startups-sql-eda/
├── data/
│   └── global_tech_startups.csv
├── sql/
│   └── eda_queries.sql
├── report/
│   └── EDA_of_Global_Tech_Startups.docx
└── README.md
```

## 👤 About the Author
**Emmanuel Aliu**, aspiring data analyst (SQL · Power BI · Excel)
[LinkedIn](https://www.linkedin.com/in/aliu-godwin-emmanuel) · [Portfolio](datascienceportfol.io/aliuemmanuel31) · [Email](aliuemmanuel31@gmail.com)

⭐ If you found this useful, feel free to star the repo.
