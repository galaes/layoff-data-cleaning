# Data Cleaning for Layoffs Dataset

## Table of Contents
  - [Objective](#objective)
  - [Dataset](#dataset)
  - [Tools](#tools)
  - [Methodology](#methodology)
  - [Key Achievements](#key-achievements)

### Objective

This project aims to develop the necessary steps for data cleaning in the Layoffs by Industry dataset, such as finding, removing duplicates, and standardizing the data.

### Dataset

The dataset of layoffs from March 2020 to March 2023 (https://rb.gy/6we5n5) contains the following key features:

- Company: Name of the company
- Location: Location of the company
- Industry: Industry of the company
- Total Laid off: Total of employees laid off
- Percentage Laid off: Percentage of laid off respects to the total of employees
- Date: date of the laid-off
- Stage: Business phase or funding stage the company is in
- Country: Country of the company
- Funds Raised Millions: Amount of capital the company has raised from investors in millions of dollars

### Tools

- MySQL for Data Cleaning

### Methodology

#### Data Cleaning

[Data Cleaning - SQL code](https://github.com/galaes/layoffs-data-cleaning/blob/f14a7af736afc0bb9586013d708fc5df1bc429f4/Full%20Project%20%20-%20Data%20Cleaning%20in%20SQL.sql)

- Find and remove duplicates

```sql
-- Find duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off,`date`) AS row_num
FROM layoffs_staging;

-- Create another table to add the column row_num
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `layoffs_staging2`
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off,`date`,stage,
country, funds_raised_millions) AS row_num
FROM layoffs_staging;
```
<img src="images/row_column.png" width="90%" alt="images">

```sql
-- Remove duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;
```

- Remove blank spaces and standardizing industry and country names

```sql
-- remove blank spaces
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardizing industry and country names
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE location LIKE 'Malm%';

UPDATE layoffs_staging2
SET location = 'Florianopolis'
WHERE location LIKE 'Floria%';

UPDATE layoffs_staging2
SET location = 'Dusseldorf'
WHERE location LIKE '%sseldorf';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';
```
<img src="images/location_names.png" width="15%" alt="images">
<img src="images/industry_names.png" width="12%" alt="images">

- Change the date from string to date format

```sql
-- CHANGE THE DATE FROM STRING TO DATE FORMAT
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- CHANGE THE FORMAT IN THE TABLE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```

<img src="images/date.png" width="10%" alt="images">

- Dealing with nulls and blank spaces in Industry column

```sql
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- FILL EMPTY SPACES WITH NULL IN INDUSTRY COLUMN
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- FILL THE EMPTY SPACES
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
```

- Remove the rows where there are nulls in total_laid_off and percentage_laid_off columns

```sql
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;
```

- Remove the row_num column

```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
```

<img src="images/final_table.png" width="80%" alt="images">

### Key Achievements

- Managed Missing Values: Actively identified and supplemented missing values in columns such as industry and total laid off, ensuring the completeness of the dataset.
- Improved Data Consistency: Standardized industry, location, and country names using MySQL, significantly enhancing data consistency and readability.
- Optimized Data Structure: Changed format type in some columns and removed unused columns, increasing the ease of analysis.
