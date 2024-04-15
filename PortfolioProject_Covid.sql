Select *
From PortfolioProjectCovid..CovidDeaths
order by 3,4

Select*
From PortfolioProjectCovid..CovidVaccinations
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovid..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
Select location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as death_rate
From PortfolioProjectCovid..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Likelihood of dying if you were infected in the Canada 
Select location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as death_rate_Canada
From PortfolioProjectCovid..CovidDeaths
Where location like 'Canada'
order by 1,2

--Total Cases vs Population (Worldwide)
Select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as infectionRate
From PortfolioProjectCovid..CovidDeaths
order by 1,2

--Total Cases vs Population 
--Infecction rate in Canada
Select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 as infection_rate_Canada
From PortfolioProjectCovid..CovidDeaths
Where location like 'Canada'
order by 1,2

--Looking at countries with the highest infection rate with respect to population
Select location, population,  Max(cast(Total_cases as int)) as HighestInfectionCount, Max((total_cases/population))* 100 as HighestInfectionRate
From PortfolioProjectCovid..CovidDeaths
Group by location, population
order by HighestInfectionRate Desc


--Canada at highest infection count and rate per population 
Select location, population, Max(cast(total_cases as int)) as Highest_infection, Max((cast(total_cases as bigint)/population))* 100 as HighestInfectionRate_Canada
From PortfolioProjectCovid..CovidDeaths
Where location like 'Canada'
Group by location, population


--Showing total Death count in different countries 
Select location, Max(cast(Total_deaths as int)) as HighestDeathCounts
From PortfolioProjectCovid..CovidDeaths
Group by location
order by HighestDeathCounts desc
OFFSET 9 row

--Showing the country with the highest infection rate per population 
Select location, Max(cast(Total_cases as int)) as TDC
From PortfolioProjectCovid..CovidDeaths
Group by location
having location like 'Cyprus'
order by TDC desc

-- Infection and death rate of the world  
Select location, population, Max(cast(total_cases as int)) as Highest_infection_Count, Max((cast(total_cases as bigint)/population))* 100 as HighestInfectionRate_world
From PortfolioProjectCovid..CovidDeaths
Where location like 'World'
Group by location, population;

Select location, population, Sum(cast(total_deaths as int)) as Highest_Death_Count, (Sum(cast(total_deaths as int))/Sum(new_cases)) * 100 as HighestDeathRate_world
From PortfolioProjectCovid..CovidDeaths
Where location like 'World'
Group by location, population

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(cast(new_cases as int)) * 100
From PortfolioProjectCovid..CovidDeaths as DeathPercentage
Where continent is not null 
Group by date
Order by 1,2

--Continent Stat highest infection and death rate
Select continent, Max(cast(total_cases as int)) as Highest_infection_Count, Max((cast(total_cases as bigint)/population))* 100 as HighestinfectionRate_Continent
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by continent
Order by Highest_infection_Count desc;

Select continent, Max(cast(total_deaths as int)) as Highest_Death_Count, Max(cast(total_cases as int)) as Highest_Infection_Count,
SUM(cast(new_deaths as int))/SUM(nullif(new_cases,0))*100
From PortfolioProjectCovid..CovidDeaths
Where continent is not null
Group by continent
Order by Highest_Death_Count desc 

-- Global numbers 

----SELECT Date, Sum(cast(new_cases as bigint)) as NewCases, Sum(cast(new_deaths as bigint)) as NewDeaths, 
----Sum(cast(new_deaths as bigint))/Sum(nullif(new_cases, 0))*100 as GlobalDeathPercentage
----From PortfolioProjectCovid..CovidDeaths
----Where continent is not null
----Group by date
----order by 1,2;

SELECT * From 
(

SELECT
Date, Sum(cast(new_cases as bigint)) as NewCases, Sum(cast(new_deaths as bigint)) as NewDeaths, 
Sum(cast(new_deaths as bigint))/Sum(nullif(new_cases, 0))*100 as GlobalDeathPercentage
From PortfolioProjectCovid..CovidDeaths
Group by date

) as innerTable 
Where GlobalDeathPercentage is not null
order by 1

-- looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location)
From PortfolioProjectCovid..CovidDeaths dea 
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccuminatedVaccinatedCount
From PortfolioProjectCovid..CovidDeaths dea 
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Vaccination rate (with CTE)

With VacPop (Continent, location, date, population, new_vaccinations,  AccuminatedVaccinatedCount) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccuminatedVaccinatedCount
From PortfolioProjectCovid..CovidDeaths dea 
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select*, (AccuminatedVaccinatedCount/Population)*100 as VaccinatiedRate
From VacPop
order by 2,3

--TEMP TABLE
Drop table if exists #PopultaionVaccinated
Create Table #PopultaionVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
AccuminatedVaccinatedCount numeric
)

Insert into #PopultaionVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as AccuminatedVaccinatedCount
From PortfolioProjectCovid..CovidDeaths dea 
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select*, (AccuminatedVaccinatedCount/Population)*100 as VaccinatiedRate
From #PopultaionVaccinated
order by 2,3

--Creating View for visualizations 

Create View