# layoffs-data-cleaning-sql
SQL data cleaning project using MySQL to clean, standardize, deduplicate, and prepare a layoffs dataset for analysis.

# Layoffs Data Cleaning Using SQL

## Project Overview

This project demonstrates a practical SQL data-cleaning workflow using MySQL. The goal was to transform a raw layoffs dataset into a cleaner and more analysis-ready dataset.

The project focuses on identifying duplicate records, standardizing inconsistent values, converting date fields into the correct data type, handling missing values, and removing records that did not contain useful layoff information.

## Tools Used

* MySQL
* SQL
* Window Functions
* CTEs
* Self Joins
* Data Cleaning and Transformation

## Data Cleaning Process

### 1. Created a staging table

Created a copy of the original layoffs table so that the raw data remained unchanged.

```sql
CREATE TABLE staging_layoff
LIKE layoffs;

INSERT INTO staging_layoff
SELECT *
FROM layoffs;
```

### 2. Identified duplicate records

Used `ROW_NUMBER()` with `PARTITION BY` to identify duplicate records based on the relevant columns.

```sql
ROW_NUMBER() OVER (
    PARTITION BY company,
                 location,
                 industry,
                 country,
                 stage,
                 funds_raised_millions,
                 total_laid_off,
                 percentage_laid_off,
                 `date`
) AS row_num
```

Records with `row_num > 1` were treated as duplicates.

### 3. Removed duplicates

Created a cleaned staging table containing the generated row number and removed duplicate records.

```sql
DELETE
FROM staging_layoff2
WHERE row_num > 1;
```

### 4. Standardized text values

Removed unnecessary whitespace from company names using `TRIM()`.

Also standardized inconsistent industry values, such as different variations beginning with `Crypto`, into a single `Crypto` category.

Country values were also standardized by removing unnecessary trailing periods.

### 5. Converted date values

The original date column was stored as text.

Converted the values using `STR_TO_DATE()`:

```sql
UPDATE staging_layoff2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
```

Then changed the column to the appropriate `DATE` data type:

```sql
ALTER TABLE staging_layoff2
MODIFY COLUMN `date` DATE;
```

### 6. Handled missing values

Inspected records containing missing or blank industry values.

Blank industry values were converted to `NULL`:

```sql
UPDATE staging_layoff2
SET industry = NULL
WHERE industry = '';
```

A self-join was then used to populate missing industry values when another record for the same company and location contained the industry information.

```sql
UPDATE staging_layoff2 t1
JOIN staging_layoff2 t2
    ON t1.company = t2.company
   AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;
```

### 7. Removed unusable records

Removed records where both `total_laid_off` and `percentage_laid_off` were missing because they did not contain useful layoff information for analysis.

```sql
DELETE
FROM staging_layoff2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
```

### 8. Finalized the cleaned dataset

Removed the temporary `row_num` column after duplicate removal.

```sql
ALTER TABLE staging_layoff2
DROP COLUMN row_num;
```

## Key SQL Skills Demonstrated

* `CREATE TABLE ... LIKE`
* `INSERT ... SELECT`
* `SELECT`
* `WHERE`
* `GROUP BY`
* `LIKE`
* `DISTINCT`
* `UPDATE`
* `DELETE`
* `TRIM()`
* `STR_TO_DATE()`
* `ALTER TABLE`
* `ROW_NUMBER()`
* CTEs
* Self Joins
* NULL handling
* Data standardization
* Data-type conversion

## Outcome

The raw layoffs dataset was transformed into a cleaner, standardized, and analysis-ready table while preserving the original source table through the use of a staging workflow.

Dataset Source: World Layoffs 2022 — Kaggle

