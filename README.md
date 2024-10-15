# Layoffs-data-cleaning

## Table of Contents
  - [Project Overview](#project-overview)
  - [Data Source](#data-source)
  - [Tools](#tools)
  - [Data Cleaning](#data-cleaning)
  - [Key Achievements](#key-achievements)

### Project Overview

This project aims to develop the necessary steps for data cleaning in the Layoffs by Industry dataset, such as finding, removing duplicates, and standardizing the data.

### Data Source

Layoffs by industry dataset (https://rb.gy/6we5n5)

### Tools

- MySQL - Data Cleaning

### Data Cleaning

[Data Cleaning - Layoffs by Industry - SQL code](https://github.com/galaes/layoffs-data-cleaning/blob/f14a7af736afc0bb9586013d708fc5df1bc429f4/Full%20Project%20%20-%20Data%20Cleaning%20in%20SQL.sql)

- Find and remove duplicates

```sql
-- find duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off,`date`) AS row_num
FROM layoffs_staging;

-- create another table to add the column row_num
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

-- remove duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1;
```

- Remove blank spaces and standardizing industry and country names
```sql
-- remove blank spaces
UPDATE layoffs_staging2
SET company = TRIM(company);

-- standardizing industry and country names
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



