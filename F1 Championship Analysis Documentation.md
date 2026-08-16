### **Project Wrap-Up: F1 Championship Analytics**



**Overview**

An end-to-end data analytics project using 74 years of Formula 1 championship data (1950–2024): a relational SQL Server database built from raw Kaggle CSVs, 14 business-question SQL queries spanning basic aggregation through window functions and CTEs, and a 2-page interactive Power BI dashboard.



**What Was Built**

* *Database:* 6 core tables + pitstops, loaded via a staging-table pipeline that safely handles the source data's missing-value convention and column mismatches between raw CSVs and the target schema.



* *SQL Analysis:* 14 business questions across two tiers — foundational (JOINs, GROUP BY, aggregates) and advanced (CASE WHEN, CTEs, window functions, multi-column joins, self-referential logic).



* *Views:* 4 SQL views pre-shaping data specifically for BI consumption, keeping transformation logic in the database rather than the reporting tool.



* *Dashboard:* a 2-page Power BI report with 8 visuals, a custom F1-branded color theme (including real constructor livery colors), and synced slicers.



**Key Findings**

DNF is F1's single most common race outcome (\~41% of all results) — more than gaining places, losing places, or holding position combined for any individual category.

Pit stop speed meaningfully predicts race outcome — drivers with sub-20-second average pit stops finished \~3 positions better, on average, than those with 30+ second stops.

Red Bull's performance at the Korean International Circuit is the strongest constructor/circuit pattern in F1 history — a 1.6 average finishing position across 5 races.



**Technical Decisions Worth Noting**

* *Staging tables over direct loads:* every CSV load goes through a wide, loosely-typed staging table before being cleaned and cast into the final schema — avoiding column-count mismatches and safely handling the dataset's \\N null placeholder.



* *Views over Power BI transformations:* data shaping logic (joins, aggregation, window functions) lives in SQL views, not Power Query — keeping the transformation logic version-controlled, testable, and reusable outside of Power BI.



* *A deliberate data-model limitation:* the dashboard's Year/Constructor slicers do not cross-filter every visual, because doing so would have required a many-to-many relationship between views — a relationship type Power BI itself warns against due to the risk of inflated/duplicated totals. Data accuracy was prioritized over full cross-page interactivity.



**What's Next**

The next phase of this project introduces a small machine learning component — predicting whether a driver will finish a race (DNF or not) based on features like grid position, constructor, and circuit. This builds directly on the SQL work already done, since the DNF definition and data cleaning logic are already established.



Repository:

**https://github.com/risacarvalho14/f1-championship-analytics**





