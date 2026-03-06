-- =========================================================
-- Exploratory Data Analysis (EDA)
-- =========================================================
-- In this section, we explore the cleaned dataset to identify
-- trends, patterns, and potential outliers in global layoffs.
--
-- EDA helps us understand the data better before building
-- visualizations or performing deeper analysis.
-- =========================================================



-- ---------------------------------------------------------
-- Inspect the Cleaned Dataset
-- ---------------------------------------------------------

SELECT * 
FROM world_layoffs.layoffs_staging2;



-- =========================================================
-- Basic Exploration Queries
-- =========================================================

-- Find the maximum number of layoffs recorded in a single entry

SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;



-- ---------------------------------------------------------
-- Analyze Layoff Percentages
-- ---------------------------------------------------------
-- This helps identify how severe the layoffs were for
-- different companies.

SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;



-- Identify companies where 100% of employees were laid off
-- (percentage_laid_off = 1 indicates the entire workforce)

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1;


-- Ordering these companies by the amount of funding raised
-- helps highlight companies that received significant
-- investment before shutting down.

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;



-- =========================================================
-- Aggregated Analysis Using GROUP BY
-- =========================================================

-- ---------------------------------------------------------
-- Companies with the Largest Single Layoff Event
-- ---------------------------------------------------------

SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;



-- ---------------------------------------------------------
-- Companies with the Highest Total Layoffs
-- ---------------------------------------------------------

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;



-- ---------------------------------------------------------
-- Total Layoffs by Location
-- ---------------------------------------------------------

SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;



-- ---------------------------------------------------------
-- Total Layoffs by Country
-- ---------------------------------------------------------

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;



-- ---------------------------------------------------------
-- Layoff Trends by Year
-- ---------------------------------------------------------

SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;



-- ---------------------------------------------------------
-- Layoffs by Industry
-- ---------------------------------------------------------

SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;



-- ---------------------------------------------------------
-- Layoffs by Company Stage
-- ---------------------------------------------------------

SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;



-- =========================================================
-- Advanced Analysis
-- =========================================================

-- ---------------------------------------------------------
-- Top Companies with the Most Layoffs Per Year
-- ---------------------------------------------------------
-- This analysis ranks companies based on the total layoffs
-- they made each year and identifies the top three companies
-- with the highest layoffs annually.

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)

, Company_Year_Rank AS (

  SELECT company, years, total_laid_off, 
  DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year

)

SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;



-- =========================================================
-- Time Series Analysis
-- =========================================================

-- ---------------------------------------------------------
-- Monthly Layoff Totals
-- ---------------------------------------------------------
-- Aggregates layoffs by month to analyze overall trends.

SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;



-- ---------------------------------------------------------
-- Rolling Total of Layoffs Over Time
-- ---------------------------------------------------------
-- Calculates the cumulative number of layoffs across months.

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)

SELECT dates, 
SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
