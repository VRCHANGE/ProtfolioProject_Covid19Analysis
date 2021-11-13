SELECT * FROM [Portfolio Project]..['Covid Death$']
where continent is not null
order by 3, 4


select * FROM [Portfolio Project]..['Covid Vaccination$']
order by 3, 4

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM [Portfolio Project]..['Covid Death$']
order by 1 ,2

--Looking at total cases vs total death
--Shows likelyhood of dying if you contract covid in your contry
SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..['Covid Death$']
where location like '%canada%'
order by 1 ,2

--Looking at Total Cases vs Population
SELECT location, date, total_cases,population,(total_cases/population)*100 as PercentagePopulationInfected
FROM [Portfolio Project]..['Covid Death$']
where location like '%canada%'
order by 1 ,2

--Looking at Country with Highest Infection Rate Compared to Population
SELECT location,population,MAX (total_cases) as HigestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..['Covid Death$']

Group by location, population
order by PercentPopulationInfected desc


--Countries with higest death count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..['Covid Death$']
where continent is not null
Group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

-- SHOWING THE CONTINENT WITH THE HIGHEST COUNT
 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..['Covid Death$']
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage-- total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..['Covid Death$']
--where location like '%canada%'
where continent is not null
--Group by date
order by 1 ,2

--Looking Total Population Vs Total Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['Covid Death$'] dea
Join [Portfolio Project]..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['Covid Death$'] dea
Join [Portfolio Project]..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['Covid Death$'] dea
Join [Portfolio Project]..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..['Covid Death$'] dea
Join [Portfolio Project]..['Covid Vaccination$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 