--Data that is going to be used from covid_deths table

SELECT [location],[date],total_cases,new_cases,total_deaths,population_density
FROM PortfoLioProject.dbo.covid_deaths
WHERE continent IS NOT NULL
ORDER by 3,4

--- Looking at total cases vs total deaths
--- Shows the likelihood of dying if you contract COVID19 in Norway

SELECT [location],[date],total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentDeath
FROM PortfoLioProject.dbo.covid_deaths
WHERE [location] like '%%way'
ORDER by 1,2

--- Looking at total cases vs population
--- Shows the percentage of population that will get COVID19 in Norway 

SELECT [location],[date],total_cases, population_density, (total_cases/population_density)*100 as PercentDeath
FROM PortfoLioProject.dbo.covid_deaths
WHERE [location] like '%%way'
ORDER by 1,2

--- Looking at countries with highest infection rate compared to population density

SELECT [location], population_density, MAX(total_cases) as HighestInfectionRate, MAX(total_cases/population_density)*100 as PopulationInfectionRate
FROM PortfoLioProject.dbo.covid_deaths
GROUP BY [location],population_density
ORDER by PopulationInfectionRate DESC

--- Showing countries with highest death count per population density

SELECT [location], MAX(total_deaths) as TotalDeathperDay
FROM PortfoLioProject.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY [location]
ORDER by TotalDeathperDay DESC

--- Show by continent

SELECT continent, MAX(total_deaths) as TotalDeathperDay
FROM PortfoLioProject.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER by TotalDeathperDay DESC


--- Show continents by the highest death counts

SELECT continent, MAX(total_deaths) as TotalDeathperDay
FROM PortfoLioProject.dbo.covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER by TotalDeathperDay DESC

--- Showing global numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage 
FROM PortfoLioProject.dbo.covid_deaths
---WHERE [location] like '%%way'
WHERE continent IS NOT NULL
--GROUP BY [date]
ORDER by 1,2

---------------------------------------------------------------------
-----Use the COVID vaccination table
SELECT *
FROM PortfoLioProject.dbo.covid_vaccinations

------------------------------------------------------------
--- Looking at total population density versus vaccinations

-- I converted the location column data type from nvarchar(max) to varchar(50) to avoid a LDO error
-- ALTER TABLE PortfoLioProject.dbo.covid_deaths
-- ALTER COLUMN [location]  VARCHAR(50) NULL;

SELECT cd.continent,cd.[location],cd.[date],cd.population_density,cv.new_vaccinations,
SUM(cv.new_vaccinations) 
OVER (PARTITION BY cd.location Order BY cd.location,cd.date) as DailyPeopleVaccinated
FROM PortfoLioProject.dbo.covid_deaths cd 
JOIN PortfoLioProject.dbo.covid_vaccinations cv 
ON cd.[location] = cv.[location]
AND cd.[date] = cv.[date]
WHERE cd.continent IS NOT NULL
ORDER by 2,3

-- Use CTE

WITH PopulationVersesVaccination(continent, location,date,Population_Density,New_Vaccinations, DailyPeopleVaccinated)
AS 
(
SELECT cd.continent,cd.[location],cd.[date],cd.population_density,cv.new_vaccinations,
SUM(cv.new_vaccinations) 
OVER (PARTITION BY cd.location Order BY cd.location,cd.date) as DailyPeopleVaccinated
FROM PortfoLioProject.dbo.covid_deaths cd 
JOIN PortfoLioProject.dbo.covid_vaccinations cv 
ON cd.[location] = cv.[location]
AND cd.[date] = cv.[date]
WHERE cd.continent IS NOT NULL
--ORDER by 2,3
)
SELECT *, (DailyPeopleVaccinated/Population_Density)*100 as DailyVacinnatedPopDensity
FROM PopulationVersesVaccination


-- Use Temp Table 

DROP TABLE IF EXISTS #DailyVacinnatedPopDensityPercent
CREATE TABLE #DailyVacinnatedPopDensityPercent
(

    Continent NVARCHAR(255),
    LOCATION NVARCHAR(255),
    Date DATETIME,
    Population_Density NUMERIC,
    New_Vaccinations NUMERIC,
    DailyPeopleVaccinated NUMERIC

)
INSERT INTO #DailyVacinnatedPopDensityPercent
SELECT cd.continent,cd.[location],cd.[date],cd.population_density,cv.new_vaccinations,
SUM(cv.new_vaccinations) 
OVER (PARTITION BY cd.location Order BY cd.location,cd.date) as DailyPeopleVaccinated
FROM PortfoLioProject.dbo.covid_deaths cd 
JOIN PortfoLioProject.dbo.covid_vaccinations cv 
ON cd.[location] = cv.[location]
AND cd.[date] = cv.[date]
WHERE cd.continent IS NOT NULL
--ORDER by 2,3

SELECT *, (DailyPeopleVaccinated/Population_Density)*100 as DailyVacinnatedPopDensity
FROM #DailyVacinnatedPopDensityPercent




---- Creating Views to store data for later visualizations 

CREATE VIEW PopulationVersesVaccination AS 
SELECT cd.continent,cd.[location],cd.[date],cd.population_density,cv.new_vaccinations,
SUM(cv.new_vaccinations) 
OVER (PARTITION BY cd.location Order BY cd.location,cd.date) as DailyPeopleVaccinated
FROM PortfoLioProject.dbo.covid_deaths cd 
JOIN PortfoLioProject.dbo.covid_vaccinations cv 
ON cd.[location] = cv.[location]
AND cd.[date] = cv.[date]
WHERE cd.continent IS NOT NULL

CREATE VIEW PoulationVaccination AS
SELECT cd.continent,cd.[location],cd.[date],cd.population_density,cv.new_vaccinations,
SUM(cv.new_vaccinations) 
OVER (PARTITION BY cd.location Order BY cd.location,cd.date) as DailyPeopleVaccinated
FROM PortfoLioProject.dbo.covid_deaths cd 
JOIN PortfoLioProject.dbo.covid_vaccinations cv 
ON cd.[location] = cv.[location]
AND cd.[date] = cv.[date]
WHERE cd.continent IS NOT NULL
