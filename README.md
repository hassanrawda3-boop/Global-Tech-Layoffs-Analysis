# 📊 Global Tech Layoffs: Data Cleaning & EDA (SQL Portfolio)

This project focuses on the end-to-end data pipeline of cleaning and analyzing a dataset regarding global tech layoffs. It transforms a raw, inconsistent CSV-sourced dataset into a structured format ready for business intelligence and trend analysis.

---

## 🛠️ Tech Stack & Skills

* **Language:** MySQL.
* **Key Techniques:** * **Data Cleaning:** Staging tables, CTEs, Window Functions (`ROW_NUMBER`), String Manipulation (`TRIM`, `TRAILING`), and Data Type Casting (`STR_TO_DATE`).
* **EDA:** Advanced Aggregations, Time Series Analysis, and Ranking (`DENSE_RANK`).



---

## 🏗️ Project Workflow

### 1. Data Cleaning

The primary goal was to ensure data integrity and remove noise before analysis. Key steps included:

* **Staging:** Created a `layoffs_staging` table to preserve the original raw data.
* **Duplicate Removal:** Identified and deleted duplicate records using `ROW_NUMBER()` partitioned across all columns.
* **Standardization:** * Standardized inconsistent industry names (e.g., merging "Crypto Currency" and "CryptoCurrency" into "Crypto").
* Cleaned geographical data by trimming trailing periods from country names.
* Converted the `date` column from a text string to a proper `DATE` format.


* **Handling Nulls:** Populated missing `industry` values by joining the table with itself to find matching company records.
* **Filtering:** Removed rows where both `total_laid_off` and `percentage_laid_off` were null, as they lacked actionable metrics.

### 2. Exploratory Data Analysis (EDA)

With a clean dataset, the analysis focused on identifying high-impact trends:

* **Company Impact:** Identified companies with the highest total layoffs and those that shut down completely (100% layoffs).
* **Geographic & Industry Trends:** Aggregated layoffs by country, location, and industry to find the most affected sectors.
* **Time Series Analysis:** * Calculated monthly layoff totals to identify spikes in the tech industry.
* Used a **CTE** to generate a **Rolling Total** of layoffs over time.


* **Yearly Rankings:** Applied `DENSE_RANK()` to determine the top 3 companies with the most layoffs for each year.

---

## 📈 Key Insights from the Code

* **Total Layoff Volume:** The analysis allows for identifying the single largest layoff events and the cumulative impact per company.
* **Funding vs. Failure:** By ordering 100% layoffs by `funds_raised_millions`, we can see highly-funded startups that ultimately failed.
* **Temporal Growth:** The rolling total provides a clear view of how layoffs accelerated across the 2020-2023 period.

---

## 📂 Repository Structure

* `Portfolio Project - Data Cleaning.sql`: All scripts for data transformation and quality assurance.
* `Portfolio Project - EDA.sql`: Scripts for uncovering patterns and business insights.
