-- ProjectCoronavirus

/*
PART - A

-- Creating Database
DROP DATABASE IF EXISTS ProjectCoronavirus;
Create database ProjectCoronavirus;

-- Creating Table
Use ProjectCoronavirus;
CREATE TABLE CovidDeaths (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    population BIGINT,
    total_cases BIGINT,
    new_cases BIGINT,
    new_cases_smoothed BIGINT,
    total_deaths BIGINT,
    new_deaths BIGINT,
    new_deaths_smoothed BIGINT,
    total_cases_per_million DECIMAL(10, 10),
    new_cases_per_million DECIMAL(10, 10),
    new_cases_smoothed_per_million DECIMAL(10, 10),
    total_deaths_per_million DECIMAL(10, 10),
    new_deaths_per_million DECIMAL(10, 10),
    new_deaths_smoothed_per_million DECIMAL(10, 10),
    reproduction_rate DECIMAL(10, 10),
    icu_patients BIGINT,
    icu_patients_per_million DECIMAL(10, 10),
    hosp_patients BIGINT,
    hosp_patients_per_million DECIMAL(10, 10),
    weekly_icu_admissions BIGINT,
    weekly_icu_admissions_per_million DECIMAL(10, 10),
    weekly_hosp_admissions BIGINT,
    weekly_hosp_admissions_per_million DECIMAL(10, 10)
);

INSERT INTO CovidDeaths (
    iso_code, continent, location, date, population, total_cases, new_cases, new_cases_smoothed, 
    total_deaths, new_deaths, new_deaths_smoothed, total_cases_per_million, new_cases_per_million, 
    new_cases_smoothed_per_million, total_deaths_per_million, new_deaths_per_million, 
    new_deaths_smoothed_per_million, reproduction_rate, icu_patients, icu_patients_per_million, 
    hosp_patients, hosp_patients_per_million, weekly_icu_admissions, weekly_icu_admissions_per_million, 
    weekly_hosp_admissions, weekly_hosp_admissions_per_million
) VALUES 
(
    'AFG', 'Asia', 'Afghanistan', '2020-02-24', 38928341, 1, 1, NULL, 
    NULL, NULL, NULL, 0.026, 0.026, 
    NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL, 
    NULL, NULL
),
(
    'AFG', 'Asia', 'Afghanistan', '2020-02-25', 38928341, 1, 0, NULL, 
    NULL, NULL, NULL, 0.026, 0, 
    NULL, NULL, NULL, 
    NULL, NULL, NULL, NULL, 
    NULL, NULL, NULL, 
    NULL, NULL
);


--- ALTER TABLE ---
USE ProjectCoronavirus;

-- Add a new column to temporarily store converted values
ALTER TABLE CovidDeaths
ADD new_deaths_new INT;

-- Update the new column with converted values
UPDATE CovidDeaths
SET new_deaths_new = TRY_CAST(new_deaths AS INT);

-- Drop the old varchar column
ALTER TABLE CovidDeaths
DROP COLUMN new_deaths;

-- Rename the new column to match the original column name
EXEC sp_rename 'CovidDeaths.new_deaths_new', 'new_deaths', 'COLUMN';


Explanation of the steps:
Add a New Column: We first add a new column new_deaths_new of type INT to store the converted values temporarily.

Update Values: I used UPDATE with TRY_CAST to convert the existing new_deaths values from VARCHAR to INT and store them in the new column. 

TRY_CAST attempts to convert the values; if it fails (due to non-numeric values, for example), it returns NULL.

Drop the Old Column: After updating the values, we drop the original new_deaths column.

Rename the New Column: Finally, we rename new_deaths_new to new_deaths to restore the original column name.

This approach ensured that data integrity is maintained and that the conversion is handled smoothly, taking into account any potential issues
with the existing data in the new_deaths column. Adjusting the column and table names (CovidDeaths, new_deaths) to match my actual database 
schema and column names as needed.

*/


-- Show databases;
SELECT name, database_id, create_date  
FROM sys.databases;  
GO

--- PART B ---

--- EXPLORATORY DATA ANALYSIS ---
-- a) How many lines does the dataset have?
SELECT COUNT(*) as DeathsRows
From ProjectCoronavirus..CovidDeaths$;

SELECT COUNT(*) as VaccRows
FROM ProjectCoronavirus..CovidVaccinations$;


-- b) Basic queries - Selecting everything from a table
select *
from ProjectCoronavirus..CovidDeaths$
Where continent is not null 
order by 3, 4

select *
from ProjectCoronavirus..CovidVaccinations$
Where continent is not null 
order by 3, 4


-- c) Selecting Data that we will be using ( 6 columns and all rows)
select location, date, total_cases, new_cases, total_deaths, population
from ProjectCoronavirus..CovidDeaths$
Where continent is not null 
order by 1, 2


-- d) Checking for duplicate values
SELECT date, continent, location, 
       COUNT(*) AS Checking_Dup
FROM ProjectCoronavirus..CovidDeaths$
GROUP BY date, continent, location
HAVING COUNT(*) > 1;

SELECT date, continent, location, 
       COUNT(*) AS Checking_Dup
FROM ProjectCoronavirus..CovidVaccinations$
GROUP BY date, continent, location
HAVING COUNT(*) > 1;


-- e) Checking the number of continents and countries.
-- Continents
SELECT COALESCE(continent, 'Total') AS Continent,
       COUNT(continent) AS Count
FROM (
    SELECT DISTINCT continent
    FROM ProjectCoronavirus..CovidDeaths$
) AS Subquery
GROUP BY continent WITH ROLLUP
ORDER BY Continent;

-- Countries
SELECT COUNT(location) as No_Of_Countries
FROM(SELECT DISTINCT location
FROM ProjectCoronavirus..CovidDeaths$
Where continent is not null
) as Subquery


--- PART C ---

-- f) Top 10 location, the continents and the percent of population affected on average.
SELECT TOP 10 continent, 
       location,
       ROUND(AVG((CAST(total_cases AS float) / CAST(population AS float)) * 100), 2) AS Percentage_Population
FROM ProjectCoronavirus..CovidDeaths$
GROUP BY continent, location
ORDER BY Percentage_Population DESC;


-- g) Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in one's country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ProjectCoronavirus..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

 
-- h) Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From ProjectCoronavirus..CovidDeaths$
-- Where location like '%states%'
order by 1,2


-- i) Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectCoronavirus..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- j) Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectCoronavirus..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- k) Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From ProjectCoronavirus..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

SELECT location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM ProjectCoronavirus..CovidDeaths$
WHERE continent IS NULL
  AND location NOT LIKE 'European Union%'
  AND location NOT LIKE 'International%'
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- l) GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectCoronavirus..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- VACCINATION ANALYSIS
-- VACCINATION PROGRESS
-- m) Total Population vs Vaccinations
-- m)1) What is the percentage of the population that has been vaccinated in different countries?
-- Shows Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectCoronavirus..CovidDeaths$ dea
Join ProjectCoronavirus..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE (Common Table Expressions) to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectCoronavirus..CovidDeaths$ dea
Join ProjectCoronavirus..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectCoronavirus..CovidDeaths$ dea
Join ProjectCoronavirus..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- n) Creating View to store data for later visualizations
GO
Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectCoronavirus..CovidDeaths$ dea
Join ProjectCoronavirus..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
GO

-- Showing our View
SELECT * FROM PercentPopulationVaccinated1;


-- o) TREND ANALYSIS -- 
-- o)1) How have total cases and total deaths trended over time globally?
-- location
SELECT Location, date, total_cases,total_deaths
From ProjectCoronavirus..CovidDeaths$
where continent is not null
order by 1,2


-- o)2) What are the trends in new cases and new deaths over time globally?
SELECT dea.date, SUM(cast(dea.new_cases as int)) AS TotalNewCases,SUM(cast(dea.new_deaths as int)) AS TotalNewDeaths
FROM ProjectCoronavirus..CovidDeaths$ dea
GROUP BY dea.date
ORDER BY dea.date;


-- p) PER CAPITA ANALYSIS
-- p)1) Which countries have the highest total cases per million by date?
SELECT dea.location AS Country, dea.date, MAX(dea.total_cases_per_million) AS MaxTotalCasesPerMillion
FROM ProjectCoronavirus..CovidDeaths$ dea
WHERE dea.total_cases_per_million IS NOT NULL
GROUP BY dea.location, dea.date
ORDER BY MaxTotalCasesPerMillion DESC;

-- p)2) How do new cases per million vary across different continents?
SELECT dea.continent, dea.date, AVG(dea.new_cases_per_million) AS AverageNewCasesPerMillion
FROM ProjectCoronavirus..CovidDeaths$ dea
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.date
ORDER BY dea.date, dea.continent;


-- q) CASE SEVERITY
-- q)1) What is the reproduction rate over time in different regions?
SELECT dea.location, dea.date, AVG(CAST(dea.reproduction_rate as float)) AS AverageReproductionRate
FROM ProjectCoronavirus..CovidDeaths$ dea
WHERE dea.continent IS NOT NULL
GROUP BY dea.location, dea.date
ORDER BY dea.location, dea.date;

-- q)2) How has the number of ICU patients and hospital patients changed over time?
SELECT dea.location, dea.date, dea.population, dea.total_cases, dea.new_cases, dea.icu_patients AS ICUPatients, icu_patients_per_million,
    dea.hosp_patients AS HospitalPatients, hosp_patients_per_million
FROM ProjectCoronavirus..CovidDeaths$ dea
WHERE dea.icu_patients IS NOT NULL 
    AND dea.hosp_patients IS NOT NULL
    AND dea.continent IS NOT NULL
GROUP BY dea.location, dea.date, dea.population, dea.total_cases, dea.new_cases, dea.icu_patients, icu_patients_per_million, dea.hosp_patients,
    hosp_patients_per_million
ORDER BY dea.location, dea.date;


-- r)TESTING ANALYSIS
-- r)1) TESTING TRENDS - How has the number of new tests, new cases, total tests, total cases changed over time?
SELECT dea.location, dea.date, vac.new_tests, dea.new_cases, vac.total_tests, dea.total_cases
FROM ProjectCoronavirus..CovidDeaths$ dea
JOIN ProjectCoronavirus..CovidVaccinations$ vac ON dea.date = vac.date AND dea.location = vac.location
ORDER BY dea.location, dea.date;

-- r)2) TEST EFFECTIVENESS - How does the number of tests per case vary across different countries?
SELECT dea.location, dea.date, vac.total_tests, dea.total_cases,
       CASE
           WHEN total_cases > 0 THEN total_tests / total_cases
           ELSE 0 -- To handle cases where total_cases might be zero to avoid division by zero error
       END AS tests_per_case
FROM ProjectCoronavirus..CovidDeaths$ dea
JOIN ProjectCoronavirus..CovidVaccinations$ vac ON dea.date = vac.date AND dea.location = vac.location
WHERE total_cases > 0 -- Filtering out rows where total_cases are zero to avoid division by zero error
ORDER BY dea.location, dea.date; 


-- S) DEMOGRAPHIC AND SOCIOECONOMIC ANALYSIS
-- POPULATION AND DENSITY
-- s)1) How do total cases and deaths relate to population density in different countries?
SELECT dea.location, vac.population_density, SUM(CAST(dea.total_cases as float)) AS total_cases, SUM(CAST(dea.total_deaths as float)) AS total_deaths
FROM ProjectCoronavirus..CovidDeaths$ dea
JOIN ProjectCoronavirus..CovidVaccinations$ vac ON dea.date = vac.date AND dea.location = vac.location
GROUP BY dea.location, vac.population_density
ORDER BY vac.population_density DESC;

-- s)2) What is the impact of median age on the number of cases and deaths?
SELECT dea.location,
       vac.median_age,
       SUM(CAST(dea.total_cases as float)) AS total_cases,
       SUM(CAST(dea.total_deaths as float)) AS total_deaths
FROM ProjectCoronavirus..CovidDeaths$ dea
JOIN ProjectCoronavirus..CovidVaccinations$ vac ON dea.date = vac.date AND dea.location = vac.location
GROUP BY dea.location, vac.median_age
ORDER BY vac.median_age DESC;

-- ECONOMIC IMPACT
-- s)3) Is there a relationship between GDP per capita and the number of COVID-19 cases or deaths?
SELECT dea.location,
       vac.gdp_per_capita,
       SUM(CAST(dea.total_cases as float)) AS total_cases,
       SUM(CAST(dea.total_deaths as float)) AS total_deaths
FROM ProjectCoronavirus..CovidDeaths$ dea
JOIN ProjectCoronavirus..CovidVaccinations$ vac ON dea.date = vac.date AND dea.location = vac.location
GROUP BY dea.location, vac.gdp_per_capita
ORDER BY vac.gdp_per_capita DESC;

-- s)4) How does extreme poverty influence the spread and mortality of COVID-19?
SELECT dea.location,
       CAST(vac.extreme_poverty as float),
       SUM(CAST(dea.total_cases as float)) AS total_cases,
       SUM(CAST(dea.total_deaths as float)) AS total_deaths
FROM ProjectCoronavirus..CovidDeaths$ dea
JOIN ProjectCoronavirus..CovidVaccinations$ vac ON dea.date = vac.date AND dea.location = vac.location
GROUP BY dea.location, vac.extreme_poverty
ORDER BY CAST(vac.extreme_poverty as float) DESC, dea.location;

-- T) Using Except and Intersect
-- t)1) EXCEPT - Which countries have reported COVID-19 deaths but have not yet administered any vaccinations?
 SELECT dea.location
 FROM ProjectCoronavirus..CovidDeaths$ dea
EXCEPT
 SELECT vac.location
 FROM ProjectCoronavirus..CovidVaccinations$ vac;

 -- t)2) INTERSECT - Which countries have reported both COVID-19 deaths and vaccinations in "North America"?
SELECT DISTINCT dea.location
FROM ProjectCoronavirus..CovidDeaths$ dea
WHERE dea.location IN (
    SELECT dea.location
    FROM ProjectCoronavirus..CovidDeaths$ dea
    WHERE dea.continent = 'North America'
INTERSECT
	SELECT vac.location
	FROM ProjectCoronavirus..CovidVaccinations$ vac
	WHERE vac.continent = 'North America');



--- U) FINAL IMPACT 
-- u)1) Countries with more vaccinations per million than deaths per million on 30 Apr, 2021
WITH vaccinations_per_million AS (
    SELECT vac.location, 
           CAST(vac.people_fully_vaccinated_per_hundred AS float) * 10000 AS vacc_per_million,
		   vac.date, vac.continent
    FROM ProjectCoronavirus..CovidVaccinations$ vac
),
deaths_per_million AS (
    SELECT dea.location,
           CAST(dea.total_deaths_per_million AS float) AS TDPM,
		   dea.date, dea.continent
    FROM ProjectCoronavirus..CovidDeaths$ dea
)
SELECT DISTINCT d.location
FROM deaths_per_million d
JOIN vaccinations_per_million v ON d.location = v.location
WHERE v.vacc_per_million > d.TDPM 
AND d.date = '2021-04-30'
AND d.continent is not null 
ORDER BY d.location;

-- u)2) How does the percentage of the population vaccinated affect the reproduction rate?
WITH VaccinationStats AS (
    SELECT vac.location, vac.date, vac.people_vaccinated, dea.population,
        (people_vaccinated / population) * 100 AS pct_population_vaccinated
    FROM
        ProjectCoronavirus..CovidVaccinations$ vac
	JOIN ProjectCoronavirus..CovidDeaths$ dea ON dea.date = vac.date AND dea.location = vac.location
),
ReproductionRate AS (
    SELECT location,
        date,
        reproduction_rate
    FROM ProjectCoronavirus..CovidDeaths$ dea
)
SELECT
    v.location,
    v.date,
    v.pct_population_vaccinated,
    r.reproduction_rate
FROM
    VaccinationStats v
JOIN
    ReproductionRate r ON v.location = r.location AND v.date = r.date
WHERE v.pct_population_vaccinated IS NOT NULL AND r.reproduction_rate IS NOT NULL;


--- V) VACCINATION IMPACT
-- v)1) Is there a correlation between the number of people vaccinated and the number of new cases or new deaths?
-- Calculate means (average values) for people_vaccinated and new_cases
SELECT AVG(CAST(people_vaccinated AS bigint)) AS avg_people_vaccinated, AVG(CAST(new_cases AS bigint)) AS avg_new_cases
INTO #averages --(Temporary Table)
FROM ProjectCoronavirus..CovidVaccinations$ vac
JOIN ProjectCoronavirus..CovidDeaths$ dea ON vac.location = dea.location AND vac.date = dea.date;

-- View temp table
-- SELECT * FROM #averages;


-- Calculate Pearson correlation coefficient
SELECT SUM((vac.people_vaccinated - a.avg_people_vaccinated) * (dea.new_cases - b.avg_new_cases)) 
        / (SQRT(SUM(POWER(vac.people_vaccinated - a.avg_people_vaccinated, 2))) 
        * SQRT(SUM(POWER(dea.new_cases - b.avg_new_cases, 2)))) AS pearson_correlation_coefficient
FROM ProjectCoronavirus..CovidVaccinations$ vac
JOIN ProjectCoronavirus..CovidDeaths$ dea ON vac.location = dea.location AND vac.date = dea.date
CROSS JOIN 
    #averages a
CROSS JOIN 
    #averages b
WHERE 
    vac.location = 'United States' -- location
    AND vac.date >= '2021-01-01' -- desired start date
    AND vac.date <= '2021-04-30'; -- desired end date

-- Drop temporary table
DROP TABLE IF EXISTS #averages;


-- v)2) Calculate covariance and standard deviations
-- Calculate means (average values) for people_vaccinated and new_cases
SELECT AVG(CAST(vac.people_vaccinated AS BIGINT)) AS avg_people_vaccinated, AVG(CAST(dea.new_cases AS BIGINT)) AS avg_new_cases
INTO #averages1 -- Temporary Table
FROM ProjectCoronavirus..CovidVaccinations$ vac
JOIN ProjectCoronavirus..CovidDeaths$ dea ON vac.location = dea.location AND vac.date = dea.date;

-- View temp table
SELECT * FROM #averages1;

-- Calculate covariance
SELECT SUM((CAST(vac.people_vaccinated AS BIGINT) - a1.avg_people_vaccinated) * (CAST(dea.new_cases AS BIGINT) - b1.avg_new_cases)) 
        / COUNT(*) AS covariance
FROM ProjectCoronavirus..CovidVaccinations$ vac
JOIN ProjectCoronavirus..CovidDeaths$ dea ON vac.location = dea.location AND vac.date = dea.date
CROSS JOIN 
    #averages1 a1
CROSS JOIN 
    #averages1 b1
WHERE 
    vac.location = 'United States' -- location
    AND vac.date >= '2021-01-01' -- desired start date
    AND vac.date <= '2021-04-30'; -- desired end date

-- Drop temporary table
DROP TABLE IF EXISTS #averages1;

-- Calculate standard deviation for people_vaccinated and new_cases
SELECT STDEV(CAST(vac.people_vaccinated AS BIGINT)) AS stddev_people_vaccinated, STDEV(CAST(dea.new_cases AS BIGINT)) AS stddev_new_cases
FROM ProjectCoronavirus..CovidVaccinations$ vac
JOIN ProjectCoronavirus..CovidDeaths$ dea ON vac.location = dea.location AND vac.date = dea.date
WHERE 
    vac.location = 'United States' -- location
    AND vac.date >= '2021-01-01' -- desired start date
    AND vac.date <= '2021-04-30'; -- desired end date;

	   	  

--- W) Using different types of Joins
--- w)1) Self Join : Find the change in total COVID-19 deaths over a week for each location on the same continent.
SELECT a.location, a.continent, a.date as 'current_date', b.date AS previous_date, CAST(a.total_deaths AS bigint) AS current_total_deaths,
	CAST(b.total_deaths AS bigint) AS previous_total_deaths, (CAST(a.total_deaths AS bigint) - CAST(b.total_deaths AS bigint)) AS deaths_change
FROM ProjectCoronavirus..CovidDeaths$ a
JOIN ProjectCoronavirus..CovidDeaths$ b
ON a.location = b.location
AND a.continent = b.continent
AND a.date = DATEADD(DAY, 7, b.date)
WHERE CAST(a.total_deaths AS bigint) IS NOT NULL
AND CAST(b.total_deaths AS bigint) IS NOT NULL
ORDER BY a.location, a.date;


--- w)2) Inner Join : How many total cases and total vaccinations were reported for each country on a specific date?
SELECT dea.iso_code, dea.continent, dea.location, dea.date, dea.total_cases, vac.total_vaccinations
FROM ProjectCoronavirus..CovidDeaths$ dea
INNER JOIN ProjectCoronavirus..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.date = '2021-04-30' -- Example date
AND dea.continent is not null
ORDER BY dea.iso_code;


--- w)3) Left Join : How many new COVID-19 cases and deaths occurred on the same day as new COVID-19 vaccinations in each country?
SELECT dea.iso_code, dea.location, dea.date, dea.new_cases, dea.new_deaths, vac.new_vaccinations
FROM ProjectCoronavirus..CovidDeaths$ dea
LEFT JOIN ProjectCoronavirus..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE vac.new_vaccinations IS NOT NULL
AND dea.continent is not null
ORDER BY dea.iso_code;


--- w)4) Right Join : Find the total number of COVID deaths and the total number of COVID vaccinations for each location?
SELECT dea.location, SUM(CAST(dea.total_deaths AS bigint)) AS total_deaths, SUM(CAST(vac.total_vaccinations AS bigint)) AS total_vaccinations
FROM ProjectCoronavirus..CovidDeaths$ dea
RIGHT JOIN ProjectCoronavirus..CovidVaccinations$ vac 
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.location
ORDER BY dea.location;


--- w)5) Full Outer Join : Find the total deaths and total vaccinations for each location where data is available, showing locations even if one dataset has data and the 
--- other doesn't.
SELECT 
    COALESCE(dea.iso_code, vac.iso_code) AS iso_code,
    COALESCE(dea.continent, vac.continent) AS continent,
    COALESCE(dea.location, vac.location) AS location,
    COALESCE(dea.date, vac.date) AS date,
    COALESCE(dea.total_deaths, 0) AS total_deaths,
    COALESCE(vac.total_vaccinations, 0) AS total_vaccinations
FROM ProjectCoronavirus..CovidDeaths$ dea
FULL JOIN ProjectCoronavirus..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date;



/*

SAMPLE - Delete one record from one table. Use select statements to demonstrate the table contents before and after the DELETE statement. 
MakING sure to ROLLBACK afterwards so that the data will not be physically removed.

COMMIT;
SELECT * FROM ProjectCoronavirus..CovidDeaths$;
DELETE FROM ProjectCoronavirus..CovidDeaths$ WHERE location = 'Afghanistan';
SELECT * FROM ProjectCoronavirus..CovidDeaths$;
ROLLBACK;

*/

---------------------------------------------------

/*
-- SAMPLE - UPDATE RECORD. 
Use select statements to demonstrate the table contents before and after the UPDATE statement. 
Making sure I ROLLBACK afterwards so that the data will not be physically removed.

START TRANSACTION;
UPDATE ProjectCoronavirus..CovidDeaths$
SET location = 'U.S.A'
WHERE location = 'United States';

-- SELECT to verify changes
SELECT * FROM ProjectCoronavirus..CovidDeaths$ WHERE location = 'U.S.A';
SELECT * FROM ProjectCoronavirus..CovidDeaths$;

-- Next, we COMMIT the changes if everything is alright
COMMIT;

-- If there's an issue and you want to discard changes, we can ROLLBACK
ROLLBACK;

*/

---------------------------------------------------

/*

SAMPLE - INDEX

-- Create an index on covid_deaths table
CREATE INDEX idx_dea_location ON ProjectCoronavirus..CovidDeaths$ (location);

-- Create an index on covid_Vaccinations table
CREATE INDEX idx_vac_location ON ProjectCoronavirus..CovidVaccinations$ (location);

*/

---------------------------------------------------

/* TRIGGERS */
--- Creating a sample Covid Deaths Log table
DROP TABLE IF EXISTS covid_deaths_log;
USE ProjectCoronavirus;
CREATE TABLE covid_deaths_log (
    log_id INT,
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    population BIGINT,
    total_cases INT,
    new_cases INT,
    total_deaths INT,
    new_deaths INT,
    created_by VARCHAR(50),
    date_created DATETIME,
    modified_by VARCHAR(50),
    modified_date DATETIME
);
GO

--- 1) Creating the "trg_covid_deaths_log_id" trigger
--DROP TRIGGER IF EXISTS trg_covid_deaths_log_id;
--GO
CREATE TRIGGER trg_covid_deaths_log_id 
ON covid_deaths_log
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO covid_deaths_log (log_id, iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths, created_by, date_created, modified_by, modified_date)
    SELECT 
        ISNULL((SELECT MAX(log_id) FROM covid_deaths_log), 0) + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS log_id,
        iso_code,
        continent,
        location,
        date,
        population,
        total_cases,
        new_cases,
        total_deaths,
        new_deaths,
        COALESCE(created_by, SUSER_SNAME()),
        COALESCE(date_created, GETDATE()),
        SUSER_SNAME(),
        GETDATE()
    FROM inserted;
END;
GO

--- 2) Creating the "trg_covid_deaths_insert" trigger
DROP TRIGGER IF EXISTS trg_covid_deaths_insert;
GO

CREATE TRIGGER trg_covid_deaths_insert
ON ProjectCoronavirus..CovidDeaths$
AFTER INSERT
AS
BEGIN
    INSERT INTO ProjectCoronavirus..covid_deaths_log (iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths)
    SELECT iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths
    FROM inserted;
END;
GO

-- Example: Inserting a new record into CovidDeaths$
INSERT INTO ProjectCoronavirus..CovidDeaths$ (iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths)
VALUES ('USA', 'North America', 'United States', '2024-07-01', 331002651, 33000000, 1000, 600000, 10),
 ('USA', 'North America', 'United States', '2024-07-02', 331002651, 34000000, 2000, 700000, 12);

-- Deleting the records that just entered
DELETE FROM ProjectCoronavirus..CovidDeaths$
WHERE iso_code = 'USA' AND continent = 'North America' AND location = 'United States' AND date = '2024-07-01' AND total_cases = 33000000;

DELETE FROM ProjectCoronavirus..CovidDeaths$
WHERE iso_code = 'USA' AND continent = 'North America' AND location = 'United States' AND date = '2024-07-02' AND total_cases = 34000000;

-- Select all records from covid_deaths_log to verify the trigger
SELECT *
FROM ProjectCoronavirus..covid_deaths_log;

---------------------------------------------------

/* STORED PROCEDURE */
--- "Which country has the highest total number of COVID-19 deaths in a given continent, and what is the total number of deaths?"

USE ProjectCoronavirus;
GO
-- Stored procedure
DROP PROCEDURE IF EXISTS sp_GetCountryWithHighestDeaths;
GO

CREATE PROCEDURE sp_GetCountryWithHighestDeaths
    @Continent NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	        SELECT TOP 1
        location AS Country,
        CAST(total_deaths as int) AS TotalDeaths
    FROM ProjectCoronavirus..CovidDeaths$
    WHERE continent = @Continent
    ORDER BY CAST(total_deaths AS int) DESC;
END;
GO

--- Testing the Stored Procedure by calling it with a specific continent, example "North America".
EXEC sp_GetCountryWithHighestDeaths @Continent = 'North America';

---------------------------------------------------

/* STORED FUNCTION */
--- What is the average number of new COVID-19 cases per million for a given country?
USE ProjectCoronavirus;
GO

-- Stored function
DROP FUNCTION IF EXISTS fn_AvgNewCasesPerMillion;
GO

CREATE FUNCTION fn_AvgNewCasesPerMillion
    (@Country NVARCHAR(100))
RETURNS FLOAT
AS
BEGIN
    DECLARE @AvgNewCasesPerMillion FLOAT;
	    -- Calculate the average number of new cases per million for the given country
    SELECT @AvgNewCasesPerMillion = AVG(new_cases_per_million)
    FROM ProjectCoronavirus..CovidDeaths$
    WHERE location = @Country;

    RETURN @AvgNewCasesPerMillion;
END;
GO


--- Testing the stored function by calling it with a specific country, such as "United States".
SELECT dbo.fn_AvgNewCasesPerMillion('United States') AS AvgNewCasesPerMillion;