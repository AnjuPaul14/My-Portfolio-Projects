-----------------------------------------------------------
COVID-19 WORLD DATA - EXPLORATORY DATA ANALYSIS
-----------------------------------------------------------


select * 
from PortfolioProjects..CovidDeaths
order by 3,4

--select * 
--from PortfolioProjects..CovidVaccinations
--order by 3,4

--select Data that we are going to be using
select location, date, total_cases, new_cases,total_deaths,population
from PortfolioProjects..CovidDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths 
-- shows the likelihood of dying if you contract covid at your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases) *100 as Deathpercentage
from PortfolioProjects..CovidDeaths
where location like '%kingdom%'
order by 1, 2

-- Looking at Total Cases Vs Population
-- Shows what percentage of population got covid
select location, date,population, total_cases, (total_cases/population) *100 as AffectedPercentage
from PortfolioProjects..CovidDeaths
where location like '%kingdom%'
order by 1, 2

--Looking at countries with Highest Infection Rate Compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population) *100) 
as PercentagePopulationInfected
from PortfolioProjects..CovidDeaths
Group by Location, Population
order by PercentagePopulationInfected Desc


--Showing Countries with Highest Death Counts per Population


Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount Desc


-- LET's BREAK THINGS BY CONTINENT


-- Showing the continents with the Highest Death Counts


Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is  not null
Group by continent
order by TotalDeathCount Desc

--GLOBAL NUMBERS



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
where continent is not null 
-- Group By date
order by 1,2


select *
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- Group By date
order by 2,3


Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.Location order by 
dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- Group By date
order by 2,3


--USE CTE

With PopvsVac(continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.Location order by 
dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac


--TEMP TABLE

DROP Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.Location order by 
dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.Location order by 
dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated

