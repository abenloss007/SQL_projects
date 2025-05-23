

/*
Covid 19 Data Exploration
Tools Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types */
select * 
from PortfolioProject2..CovidDeaths
order by 3,4

select * 
from PortfolioProject2..CovidVaccinations
where continent is not null
order by 3,4


--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject2..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Likelihood of dying if you contract covid in a country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject2..CovidDeaths
where location like '%states%'
and continent is not null 
order by 1,2


--Looking at the total cases vs population
--Percentage of population infected with Covid
select location, date, population,total_cases, (total_cases/population)*100 as CovidPreecentage
from PortfolioProject2..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject2..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per populatuion 

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject2..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Breaking down by Continent

-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject2..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject2..CovidDeaths
where continent is not null
order by 1,2


--Loooking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform Calculation on Partition By in pervious query


with PopvsVac(continent,location,date,population,new_vaccinatiions, RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
from PortfolioProject2..CovidDeaths dea
join PortfolioProject2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (RollingPeopleVaccinated/population)*100
from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in Previous

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select * ,(ROllingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject2..CovidDeaths dea
Join PortfolioProject2..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * 
from PercentPopulationVaccinated