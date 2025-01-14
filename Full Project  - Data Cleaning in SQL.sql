-- DATA CLEANING FOR LAYOFFS DATASET
-- create a new table to do not use the original dataset
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- FIND DUPLICATES
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off,`date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, 
industry, total_laid_off, percentage_laid_off,`date`,stage,
country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

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

-- STANDARDIZING DATA
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

-- CHANGE THE DATE FROM STRING TO DATE FORMAT
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- CHANGE THE FORMAT IN THE TABLE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- DEALING WITH NULLS IN INDUSTRY COLUMN
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

-- DEALING WITH NULLS IN TOTAL_LAID_OFF AND PERCENTAGE LAID OFF COLUMNS
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- REMOVE ROW_NUM COLUMN
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2
;









