SELECT * 
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM [Portfolio Project]..CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPerc
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%india%' AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases Vs Population
-- Shows what percentage of population got Covid
SELECT location,date,population,total_cases,(total_cases/population)*100 AS InfectedPopPerc
FROM [Portfolio Project]..CovidDeaths
WHERE location LIKE '%india%' AND continent IS NOT NULL
ORDER BY 1,2

-- Country with Highest Infection Rate compared to Population
SELECT location,population, MAX(total_cases)AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopPerc
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%india%'
GROUP BY location,population
ORDER BY InfectedPopPerc DESC

-- Countries with highest Death Count per Population
SELECT location,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with highest Death Count per Population
SELECT continent,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
SELECT date,SUM(new_cases)AS TOTAL_CASES, SUM(CAST(new_deaths AS int)) AS TOTAL_DEATHS,(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPerc
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%india%' AND 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases)AS TOTAL_CASES, SUM(CAST(new_deaths AS int)) AS TOTAL_DEATHS,(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPerc
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%india%' AND 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Total Population Vs Vaccinations

SELECT dea.continent , dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE 
WITH PopvsVac ( continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) 
AS(
SELECT dea.continent , dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 FROM PopvsVac

-- Creating view to store data for later visualziations
DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent , dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated

