SELECT
	Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM coviddeaths
ORDER BY 1,2;

-- looking at total cases vs total deaths
SELECT
	Location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases*100) AS death_rate_pct
FROM coviddeaths
WHERE location REGEXP 'states'
ORDER BY 1,2;

-- Looking in the total case vs population
SELECT
	Location,
    date,
    total_cases,
    population,
    (total_cases/population*100) AS infected_rate_pct
FROM coviddeaths
ORDER BY 1,2;

-- Looking for country have highest infected_rate_pct
SELECT
	Location,
	population,
    MAX(total_cases) AS max_total_case,
	MAX(Total_cases/population*100) AS max_infected_rate_pct
FROM coviddeaths
GROUP BY Location;

-- Looking for countries with max death count
UPDATE coviddeaths
SET total_deaths = null
WHERE total_deaths = '';

ALTER TABLE coviddeaths
MODIFY total_deaths INTEGER;

USE pfl_project;
SELECT 
	Location, 
    MAX(Total_deaths) AS max_Totaldeath_count
FROM coviddeaths
WHERE continent != ''
GROUP BY Location
ORDER BY max_Totaldeath_count DESC;


-- Looking for continent with max death count
SELECT 
	continent, 
    MAX(Total_deaths) AS max_Totaldeath_count
FROM coviddeaths
WHERE continent != ''
GROUP BY continent
ORDER BY max_Totaldeath_count DESC;


-- Global Number by date
SELECT date, 
		SUM(new_cases) AS total_cases, 
        SUM(new_deaths) AS total_deaths,
		SUM(new_deaths)/SUM(new_cases)*100 AS death_rate_pct
FROM coviddeaths
WHERE continent <> ''
GROUP BY date
ORDER BY date; 

-- Global number total
SELECT  
		SUM(new_cases) AS total_cases, 
        SUM(new_deaths) AS total_deaths,
		SUM(new_deaths)/SUM(new_cases)*100 AS death_rate_pct
FROM coviddeaths
WHERE continent <> '' ;


-- Vaccination
-- total population vs vaccination
UPDATE covidvaccinations
SET new_vaccinations = null
WHERE new_vaccinations = '';

ALTER TABLE covidvaccinations
MODIFY new_vaccinations INTEGER;


-- CTP common table expression
WITH PopvsVac (continent, location, date, population, new_vac, RollingPeoVac)
AS(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(V.new_vaccinations) OVER 
        (PARTITION BY d.location ORDER BY d.date) AS RollingPeoVac
        -- (RollingPeoVac/d.population)*100
FROM coviddeaths d JOIN covidvaccinations v
	USING(location, date)
WHERE d.continent <> ''
ORDER BY 2,3

) 
SELECT * ,(RollingPeoVac/population)*100 FROM PopvsVac;

-- Temp table
CREATE TABLE temptable AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(V.new_vaccinations) OVER 
        (PARTITION BY d.location ORDER BY d.date) AS RollingPeoVac
        -- (RollingPeoVac/d.population)*100
FROM coviddeaths d JOIN covidvaccinations v
	USING(location, date)
WHERE d.continent <> ''
ORDER BY 2,3);
SELECT *, (RollingPeoVac/population)*100 FROM temptable;

-- Creating view to store data for later visualization
CREATE VIEW viewdata  AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(V.new_vaccinations) OVER 
        (PARTITION BY d.location ORDER BY d.date) AS RollingPeoVac
        -- (RollingPeoVac/d.population)*100
FROM coviddeaths d JOIN covidvaccinations v
	USING(location, date)
WHERE d.continent <> ''
ORDER BY 2,3);



