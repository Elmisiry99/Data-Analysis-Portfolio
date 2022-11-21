Select  *
From PortfolioProject..CovidDeaths$
Where continent is Null
--Where continent is not null



--Select  * 
--From PortfolioProject..CovidVaccinations$
--Order BY 3,4

-- Select Data that we are going to be using

Select  location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$

Order by 1,2

-- Looking at total cases vs total deaths
-- Calculating the mortality rate of the virus in my country
Select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location = 'Germany'
Order by 1,2


-- looking at total cases vs population
-- calculating the percentage of the population who were infected with the virus
Select  location, date, total_cases, new_cases, population, (total_cases/population)*100 as Infection_Percentage
From PortfolioProject..CovidDeaths$
Where location = 'Germany'
Order by 1,2

-- looking at countries with highest infection rate compared to population
Select  location, MAX(total_cases) as Highest_Infection_Count, population, (MAX(total_cases)/population)*100 as Infection_Percentage
From PortfolioProject..CovidDeaths$
--Where location = 'Germany'
Group by location,population
Order by Infection_Percentage desc

-- Showing the countries with highest death count per population

Select  location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths$
--Where location = 'Germany'
Where continent is not null
Group by location
Order by Total_Death_Count desc

-- Let us break things down by continent

--showing continents with the highest death per population

Select  location, MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths$
--Where location = 'Germany'
Where continent is null
Group by location
Order by Total_Death_Count desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as Death_Percentage
From PortfolioProject..CovidDeaths$
--Where location = 'Germany'
where continent is not null
--Group by date
Order by 1,2

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as Death_Percentage
From PortfolioProject..CovidDeaths$
--Where location = 'Germany'
where continent is not null
Group by date
Order by 1,2


select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
 Sum(CONVERT(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
 Sum(CONVERT(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac

--Temp table

Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
contintent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
 Sum(CONVERT(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated


-- creating view to store data for later visualizations
Drop View if exists PercentPopulationVaccinated
create View PercentPopulationVaccinated as
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations,
 Sum(CONVERT(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * 
from PercentPopulationVaccinated
