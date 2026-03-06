-- =========================================================
-- SQL Data Cleaning Project
-- Dataset: Global Tech Layoffs
-- Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- =========================================================


-- ---------------------------------------------------------
-- 1. Inspect the Raw Dataset
-- ---------------------------------------------------------

SELECT * 
FROM world_layoffs.layoffs;



-- ---------------------------------------------------------
-- 2. Create a Staging Table
-- ---------------------------------------------------------
-- A staging table is created to perform all cleaning and
-- transformation operations. This ensures the original
-- dataset remains unchanged and can be used as a backup
-- if any issues occur during the cleaning process.

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;



-- ---------------------------------------------------------
-- Data Cleaning Workflow
-- ---------------------------------------------------------
-- The data cleaning process will follow these steps:
--
-- 1. Identify and remove duplicate records
-- 2. Standardize data formats and correct inconsistencies
-- 3. Review and handle NULL or missing values
-- 4. Remove unnecessary columns or records



-- =========================================================
-- STEP 1: Remove Duplicate Records
-- =========================================================

-- First, review the dataset

SELECT * 
FROM world_layoffs.layoffs;


-- Identify duplicate rows using ROW_NUMBER()

SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1;


-- To remove duplicates, we will create a new table and
-- include a row number column that identifies duplicates.
-- Rows with row_num greater than 1 will be considered duplicates.


ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;


SELECT *
FROM world_layoffs.layoffs_staging
;


CREATE TABLE `world_layoffs`.`layoffs_staging2` (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);


INSERT INTO `world_layoffs`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging;


-- Delete duplicate rows (row_num >= 2)

DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;



-- =========================================================
-- STEP 2: Standardize Data
-- =========================================================

SELECT * 
FROM world_layoffs.layoffs_staging2;



-- ---------------------------------------------------------
-- Standardizing Industry Values
-- ---------------------------------------------------------

-- Identify distinct industry values

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;


-- Identify rows with NULL or empty industry values

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;


-- Investigate specific companies to understand missing values

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company LIKE 'airbnb%';


-- Convert empty strings into NULL values for easier handling

UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';


-- Verify NULL industry values

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;


-- Populate missing industry values using other rows
-- with the same company name

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;


-- Verify remaining NULL industry values

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;



-- ---------------------------------------------------------
-- Standardizing Industry Categories
-- ---------------------------------------------------------

-- Identify inconsistent industry labels

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;


-- Standardize all crypto-related labels

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');


-- Verify changes

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;



-- ---------------------------------------------------------
-- Standardizing Country Names
-- ---------------------------------------------------------

SELECT *
FROM world_layoffs.layoffs_staging2;


-- Identify inconsistent country names

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;


-- Remove trailing periods from country names

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);


-- Verify results

SELECT DISTINCT country
FROM world_layoffs.layoffs_staging2
ORDER BY country;



-- ---------------------------------------------------------
-- Converting Date Column to Proper Date Format
-- ---------------------------------------------------------

SELECT *
FROM world_layoffs.layoffs_staging2;


-- Convert text date format to SQL date format

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- Modify column data type to DATE

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


SELECT *
FROM world_layoffs.layoffs_staging2;



-- =========================================================
-- STEP 3: Review NULL Values
-- =========================================================

-- The NULL values in the following columns appear valid:
-- total_laid_off
-- percentage_laid_off
-- funds_raised_millions
--
-- These NULL values will be kept as they may represent
-- unavailable data and can still be useful during the
-- Exploratory Data Analysis (EDA) phase.



-- =========================================================
-- STEP 4: Remove Unnecessary Records and Columns
-- =========================================================

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Delete rows where both layoff metrics are missing

DELETE FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT * 
FROM world_layoffs.layoffs_staging2;


-- Remove the helper column used for duplicate detection

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT * 
FROM world_layoffs.layoffs_staging2;
