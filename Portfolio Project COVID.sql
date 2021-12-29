


SELECT * 
	FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
	ORDER BY 3,4 DESC

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

--Continent with Highest Death Count  

SELECT continent,MAX(CAST(total_deaths AS int)) TotalDeathCount
	FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND continent NOT IN ('World')
	GROUP BY continent
	ORDER BY TotalDeathCount DESC
	
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

--Use CTE to perform calculation on Partitin By from the previous query

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

--TEMP TABLE to perform calculation on Partitin By from the previous query

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


