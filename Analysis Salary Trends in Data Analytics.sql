SELECT * FROM ds_salaries;

-- 1. Ensure there's no NULL data?
SELECT
	COUNT(*) AS total_null
FROM
	ds_salaries
WHERE
	work_year IS NULL
	OR experience_level IS NULL
	OR employment_type IS NULL
	OR job_title IS NULL
	OR salary IS NULL
	OR salary_currency IS NULL
	OR salary_in_usd IS NULL
	OR employee_residence IS NULL
	OR remote_ratio IS NULL
	OR company_location IS NULL
	OR company_size IS NULL;

-- 2. Checking what job titles are available
SELECT
	DISTINCT job_title
FROM
	ds_salaries
ORDER BY
	job_title;

-- 3. Checking what job titles are related to data analyst
SELECT
	DISTINCT job_title
FROM
	ds_salaries
WHERE
	job_title LIKE '%data analyst%'
ORDER BY
	job_title;

-- 4. Average salary of data analyst in Rupiah
SELECT
	(AVG(salary_in_usd) * 15000) / 12 AS avg_sal_rp_monthly
FROM
	ds_salaries
WHERE
	job_title LIKE '%data analyst%';

-- 4.1 Average salary of data analyst based on experience level in Rupiah
SELECT
	experience_level,
	(AVG(salary_in_usd) * 15000) / 12 AS avg_sal_rp_monthly
FROM
	ds_salaries
WHERE
	job_title LIKE '%data analyst%'
GROUP BY
	experience_level;

-- 4.2 Average salary of data analyst based on experience level and type of employment in Rupiah
SELECT
	experience_level,
	employment_type,
	(AVG(salary_in_usd) * 15000) / 12 AS avg_sal_rp_monthly
FROM
	ds_salaries
WHERE
	job_title LIKE '%data analyst%'
GROUP BY
	experience_level,
	employment_type
ORDER BY
	experience_level,
	employment_type;

-- 5. Countries with attractive salaries for data analyst positions, full-time, with entry-level and mid-level work experience
SELECT
	company_location,
	AVG(salary_in_usd) avg_sal_in_usd
FROM
	ds_salaries
WHERE
	job_title LIKE '%data analyst%'
	AND employment_type = 'FT'
	AND experience_level IN ('MI', 'EN')
GROUP BY
	company_location
HAVING
	avg_sal_in_usd >= 20000;

-- 6. Year with the highest salary increase from mid to expert (for full-time data analyst related jobs)
WITH ds_1 AS (
	SELECT
		work_year,
		AVG(salary_in_usd) sal_in_usd_ex
	FROM
		ds_salaries
	WHERE
		employment_type = 'FT'
		AND experience_level = 'EX'
		AND job_title LIKE '%data analyst%'
	GROUP BY
		work_year
),
ds_2 AS (
	SELECT
		work_year,
		AVG(salary_in_usd) sal_in_usd_mi
	FROM
		ds_salaries
	WHERE
		employment_type = 'FT'
		AND experience_level = 'MI'
		AND job_title LIKE '%data analyst%'
	GROUP BY
		work_year
),
t_year AS (
	SELECT
		DISTINCT work_year
	FROM
		ds_salaries
)
SELECT
	t_year.work_year,
	ds_1.sal_in_usd_ex,
	ds_2.sal_in_usd_mi,
	ds_1.sal_in_usd_ex - ds_2.sal_in_usd_mi AS differences
FROM
	t_year
	LEFT JOIN ds_1 ON ds_1.work_year = t_year.work_year
	LEFT JOIN ds_2 ON ds_2.work_year = t_year.work_year;
