SELECT *
FROM PortfolioProject..CovidDeaths
ORDER by 3,4

--Select * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
order by 1,2

--Looking at Countries with Highest Infection Cases compared to Population
SELECT Location, Population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY Location, Population
order by PercentagePopulationInfected DESC

--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY Location
order by TotalDeathCount DESC

--Lets Break Things Down By Continent 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
order by 1,2

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Coviddeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Coviddeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
LOCATION nvarchar(255),
DATE datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Coviddeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations 
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..Coviddeaths dea
JOIN PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated