SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4 DESC

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4 DESC

--Playing around with CTE and PARTITION BY 
--WITH CTE_Covid AS 
--(SELECT Location,population,date,total_cases,COUNT(total_cases) OVER (PARTITION BY total_cases) TotalCasesCount,total_deaths,(total_deaths / total_cases) *100 DeathPercentage
--FROM PortfolioProject..CovidDeaths
--WHERE Location = 'United States'
--)
--SELECT *
--FROM CTE_Covid
--ORDER BY 3 DESC,4 DESC 

-----------------------------


--353948 WHERE date = '2020-12-31' 807952 WHERE date = '2021-12-20'

--SELECT total_deaths 
--FROM PortfolioProject..CovidDeaths
--WHERE date = '2020-12-31' AND location = 'United States'


--SELECT total_deaths 
--FROM PortfolioProject..CovidDeaths
--WHERE date = '2021-12-20' AND location = 'United States'

--SELECT DIFFERENCE(353948,807952)

-------------------------------


--Data that is going to be used

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 

--Total Cases vs. Total Deaths

SELECT location,date,total_cases,total_deaths,(total_deaths / total_cases) *100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY 2 DESC

--Shows the percentage of the population that contracted Covid

SELECT location,date,total_cases,population,(total_cases / population) *100 InfectedPercentagePopulation
FROM PortfolioProject..CovidDeaths
WHERE Location = 'United States' AND continent IS NOT NULL
ORDER BY 2 DESC

--Country with Highest Infection Count compared to Population

SELECT location,population, MAX(total_cases) HighestInfectionCount, MAX(total_cases / population) *100 InfectedPercentagePopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC

--Country with Highest Death Count

SELECT location,MAX(CAST(total_deaths AS int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Start using CONTINENT

--Continent with Highest Deat Count  

SELECT continent,MAX(CAST(total_deaths AS int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND continent NOT IN ('World')
GROUP BY continent
ORDER BY TotalDeathCount DESC

--SELECT location,MAX(CAST(total_deaths AS int)) TotalDeathCount
--FROM PortfolioProject..CovidDeaths
--WHERE continent IS NULL AND location NOT IN ('World')
--GROUP BY location
--ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date,SUM(new_cases) total_cases,SUM(CAST(new_deaths AS int)) total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 DeathPercentage --,total_cases,total_deaths,(total_deaths / total_cases) * 100 DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL --AND continent = 'North America'
GROUP BY date
ORDER BY 1 DESC,2

SELECT SUM(new_cases) total_cases,SUM(CAST(new_deaths AS int)) total_deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 DeathPercentage --,total_cases,total_deaths,(total_deaths / total_cases) * 100 DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingVaccinatedPeople,(RollingVaccinatedPeople / population) * 100 TotalVaccinatedPeople
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--USE CTE 



WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingVaccinatedPeople) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingVaccinatedPeople
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccinatedPeople / population) * 100 TotalVaccinatedPeople
FROM PopvsVac
--WHERE location = 'United States'
--ORDER BY 3 DESC

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinatedPeople numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingVaccinatedPeople
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingVaccinatedPeople / population) * 100 TotalVaccinatedPeople
FROM #PercentPopulationVaccinated
--WHERE location = 'United States'
--ORDER BY 3 DESC

-- Creating Views in order to import into Tableau

CREATE VIEW VaccinatedPopulationPercent AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) RollingVaccinatedPeople
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM VaccinatedPopulationPercent


