select *
from staging_layoff;

create table staging_layoff
like layoffs;

insert staging_layoff
select *
from layoffs;

with duplicate_cte as (select *,
row_number()over(partition by company,location,industry,country,stage,funds_raised_millions, total_laid_off,percentage_laid_off,`date`) as row_num
from staging_layoff)

select *
from duplicate_cte
where row_num>1;

CREATE TABLE `staging_layoff2` (
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

INSERT INTO staging_layoff2
select *,
row_number()over(partition by company,location,industry,country,stage,funds_raised_millions, total_laid_off,percentage_laid_off,`date`) as row_num
from staging_layoff;

SET SQL_SAFE_UPDATES = 0;

DELETE
FROM staging_layoff2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM staging_layoff2
WHERE row_num>1;

select count(*) from staging_layoff2 where row_num > 1;


-- Standardizing

SELECT company,TRIM(company) as Updated
FROM staging_layoff2;

SET SQL_SAFE_UPDATES = 0;

UPDATE staging_layoff2
SET company=TRIM(company);

SELECT *
FROM staging_layoff2
WHERE industry like 'Crypto%';

UPDATE staging_layoff2
SET industry='Crypto'
WHERE industry like 'Crypto%';


SELECT DISTINCT country,trim(trailing '.' from country)
FROM staging_layoff2
order by 1; 

UPDATE staging_layoff2
SET country=trim(trailing '.' from country)
WHERE country like 'United States%';


-- Date formatting
select `date`,
str_to_date(`date`,'%m/%d/%Y' )
from staging_layoff2;

UPDATE staging_layoff2
SET `date`=str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE staging_layoff2
MODIFY COLUMN `date` DATE;

-- NULL /BLANK VALUES

SELECT *
FROM staging_layoff2
where total_laid_off is null and percentage_laid_off is null; 

SELECT *
FROM staging_layoff2
where industry is null or  industry='';

SELECT *
FROM staging_layoff2
where company like 'Bally%';

SELECT t1.industry,t2.industry
FROM staging_layoff2 t1
join staging_layoff2 t2
on t1.company=t2.company and t1.location=t2.location
where (t1.industry is null or t1.industry='') and t2.industry is not null;

update staging_layoff2
SET industry =null
where industry ='';

update staging_layoff2 t1
join staging_layoff2 t2
on t1.company=t2.company and t1.location=t2.location
SET t1.industry=t2.industry
where (t1.industry is null) and t2.industry is not null;

select *
from staging_layoff2
where total_laid_off is null and percentage_laid_off is null;

DELETE 
from staging_layoff2
where total_laid_off is null and percentage_laid_off is null;

SELECT *
FROM staging_layoff2;

ALTER TABLE staging_layoff2
DROP COLUMN row_num;