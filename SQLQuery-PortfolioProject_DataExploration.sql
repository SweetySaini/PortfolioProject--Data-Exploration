
SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs. total deaths

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
order by 1,2

--looking at total cases vs. Population

SELECT location, date, Population, total_cases, (CAST(total_cases AS FLOAT)/Population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
order by 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS FLOAT)/Population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
group by location, Population
order by 4 DESC


--Showing countries with Highest Death Count per Population

SELECT location, Population, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount, MAX((CAST(total_deaths AS FLOAT)/Population)*100) AS PercentPopulationDied
FROM PortfolioProject..CovidDeaths
group by location, Population
order by 4 DESC

--Showing countries with Highest Death Count

SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
group by location
order by 2 DESC

--Looking at Death Count by Continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
group by continent
order by HighestDeathCount DESC

--Global Numbers wrt date

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)*100/NULLIF(SUM(new_cases),0)) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
group by date
order by 1,2

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)*100/NULLIF(SUM(new_cases),0)) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2

--Looking at Total Vaccinations vs Population
--Using CTE

WITH PopvsVac (continent, location, population, date, new_vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
		SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM PopvsVac

--Using Temporary Table

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
population numeric,
date datetime,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
		SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
SELECT *, (RollingPeopleVaccinated/population)*100 AS PeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated


--Creating a View for later Visulisations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
		SUM(CONVERT(BIGINT, vac.new_vaccinations)) 
		OVER (Partition by dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PercentPopulationVaccinated