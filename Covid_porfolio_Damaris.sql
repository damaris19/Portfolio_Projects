SELECT *
FROM PortfolioProject..Covid_deaths
Order By 3,4

--SELECT *
--FROM PortfolioProject..Covid_vaccinations
--Order By 3,4


--Select Data that we are going to be using
   Select Location, date, total_cases,new_cases, total_deaths, population
   From PortfolioProject..Covid_deaths
   Order by 1,2

--Looking at Total cases vs Total Deaths
--Shows the likelyhood of dying if you contract Covid in your country
   Select Location, date, total_cases,new_cases, total_deaths,(total_deaths/total_cases)*100 as death_rate
   From PortfolioProject..Covid_deaths
   Where location LIKE '%Kenya%'
   Order by 1,2

   --Looking at the total cases vs Population
   --Shows what percentage of population got covid
 Select Location, total_cases, population ,(total_deaths/population)*100 as Percent_of_population_Infected
   From PortfolioProject..Covid_deaths
   Where location LIKE '%Kenya%'
   Order by 1,2

   --Looking at countries with highest infection rate compared to population 
   Select Location,population,  MAX(total_cases) as Highestinfectioncount,MAX((total_deaths/population)*100) as Percent_of_population_Infected
   From PortfolioProject..Covid_deaths
  -- Where location LIKE '%Kenya%'
   Group By population, location
   Order by Percent_of_population_Infected desc

    --Showing countries with highest death count per to population 
   Select Location,  MAX(Cast(total_deaths as int)) as TotalDeathCount
   From PortfolioProject..Covid_deaths
   --Where location LIKE '%Kenya%
   Where continent IS NOT NULL
   Group By location
   Order by TotalDeathCount desc

    --Showing CONTINENTS with highest death count per to population 
   Select continent,  MAX(Cast(total_deaths as int)) as TotalDeathCount
   From PortfolioProject..Covid_deaths
   --Where location LIKE '%Kenya%
   Where continent IS NOT NULL
   Group By continent
   Order by TotalDeathCount desc

   --Global Numbers

   Select sum(new_cases) as total_cases, SUM(CAST(new_deaths as int))as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
   From PortfolioProject..Covid_deaths
   --Where location LIKE '%Kenya%'
   Where continent is not null
   --Group By date
   Order by 1,2
   --Looking at Total population vs Vaccinations
   Select d.continent, d.location, d.date, d.population, v.new_vaccinations
   , SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location, d.date) AS RollingPeopleVaccinated
   --, (RollingPeopleVaccinated/population)*100
   From PortfolioProject..Covid_deaths d
   Join PortfolioProject..Covid_vaccinations v
     on d.location = v.location
    and  d.date = v.date
   where d.continent is not null
   Order By 2,3

   --1. Use CTE to get include Percentage of Population Vaccinated
   With PopvsVacc(Continent, Location, Date, Population, New_Vaccinattions, RollingPeopleVaccinated)
  as
  (
   Select d.continent, d.location, d.date, d.population, v.new_vaccinations
   , SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location, d.date) AS RollingPeopleVaccinated
   --, (RollingPeopleVaccinated/population)*100
   From PortfolioProject..Covid_deaths d
   Join PortfolioProject..Covid_vaccinations v
     on d.location = v.location
    and  d.date = v.date
   where d.continent is not null

   )
Select *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVacc

   --2. Use Temp Table to  include Percentage of Population Vaccinated
 
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
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location, d.date) AS RollingPeopleVaccinated
   --, (RollingPeopleVaccinated/population)*100
 From PortfolioProject..Covid_deaths d
   Join PortfolioProject..Covid_vaccinations v
     on d.location = v.location
    and  d.date = v.date
 --where d.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


--creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location, d.date) AS RollingPeopleVaccinated
   --, (RollingPeopleVaccinated/population)*100
 From PortfolioProject..Covid_deaths d
   Join PortfolioProject..Covid_vaccinations v
     on d.location = v.location
    and  d.date = v.date
 --where d.continent is not null

