 

--- FULL PROJECT ON COVID19, DATA GOTTEN FROM OURWORDINDATA AND ANALYSED BY ALEX THE ANALYST
--- YOUTUBE TITLE: Data Analyst Portfolio Project | SQL Data Exploration | Project 1/4


--Viewing data from CovidDeaths
select *
from CovidProjects..CovidDeaths
order by 3,4

--Viewing data from CovidVaccinations
select *
from CovidProjects..CovidVaccinations
order by 3,4

--Select Columns 
select location, date, total_cases, new_cases, total_deaths, population
from CovidProjects..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Total Deaths
-- Convert total_deaths and total_cases to float in order to perform numeric operations

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 
DeathPercentage
From CovidProjects..CovidDeaths
where continent is not null
order by 1,2
----------------------------------------------- Or ------------------------------------------
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / (CONVERT(float, total_cases))*100) as 
DeathPercentage
From CovidProjects..CovidDeaths
where continent is not null
order by 1,2

-- Filter by location containing geria in it
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / (CONVERT(float, total_cases))*100) as 
DeathPercentage
From CovidProjects..CovidDeaths
where location like '%geria%'
and continent is not null

-- Filter by location containing states in it
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / (CONVERT(float, total_cases))*100) as 
DeathPercentage
From CovidProjects..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Total Cases by Population
Select Location, date, population, total_cases,  (CONVERT(float, total_cases) / (CONVERT(float, population))*100) as 
PopulationPercentage
From CovidProjects..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2 

-- Countries with Highest Infection Rate
Select Location, population, max(total_cases) 'HighesCase', max(CONVERT(float, total_cases) / CONVERT(float, population))*100 
PercentPopulationInfected
From CovidProjects..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by population, location
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select Location, max(cast(total_deaths as int)) TotalDeathCount
from CovidProjects..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc 

-- In the above, continents showed as Locations and need to be omitted. This is to be added to all syntax. ie:
Select Location, max(cast(total_deaths as int)) TotalDeathCount
from CovidProjects..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENTS
Select continent, max(cast(total_deaths as int)) TotalDeathCount
from CovidProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- The summation of total_deaths above does not seem right,hence another syntax is initiated
Select Location, max(cast(total_deaths as int)) TotalDeathCount
from CovidProjects..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Showing Continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) TotalDeathCount
from CovidProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, sum(new_cases) Cases, sum(new_deaths) Deaths, sum(new_deaths)/NULLIF(sum(new_cases),0)*100 as DeathPercentage
From CovidProjects..CovidDeaths
where continent is not null
group by date
order by 1,2
-- In the above, NULLIF function is to be applied to all expressions that use / operator, not into only some of them.
-- This is a syntax to call null if the divisor is, reason for having ,0) before *100. ie (NULLIF(expression),0)expression

-- SHOWS GLOBAL FIGURE
Select sum(new_cases) Cases, sum(new_deaths) Deaths, sum(new_deaths)/NULLIF(sum(new_cases),0)*100 as DeathPercentage
From CovidProjects..CovidDeaths
where continent is not null
--group by date
--order by 1,2

------------------------------- COVID VACCINATIONS --------------------------------------

select*
from CovidProjects..CovidVaccinations

-- JOINING BOTH TABLES ON LOCATION AND DATE

select*
from CovidProjects..CovidDeaths dea
join CovidProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- LOOKING AT TOTAL POPULATION VS VACCINATION

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidProjects..CovidDeaths dea
join CovidProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Ruling count of the new_vaccinations column i.e suming up the sum continously per location

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location)
-- or , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location)
from CovidProjects..CovidDeaths dea
join CovidProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Ruling count of the new_vaccinations column i.e suming up the sum continously per row

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
-- or , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location)
from CovidProjects..CovidDeaths dea
join CovidProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE TO CREATE A TABLE FOR THE VARIABLE RollingPeopleVaccinated

with PopVsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
-- or , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location)
from CovidProjects..CovidDeaths dea
join CovidProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from PopVsVac
-- NB: The number of columns must be equal in the cte and the existing table, also the order by is omitted


-- ALTERNATIVE WAY FOR TEMP TABLE

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
-- or , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location)
from CovidProjects..CovidDeaths dea
join CovidProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- TO EDIT ANYTHING IN THE EXISTING TABLE, ADD 'DROP TABLE IF EXISTS' TO THE ABOVE SYNTAX,
-- SAY IF TRYING TO COMMENT OUT: where dea.continent is not null. ie:

DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
-- or , sum(cast(vac.new_vaccinations as float)) over (partition by dea.location)
from CovidProjects..CovidDeaths dea
join CovidProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- It is relevant to add DROP table if exists when planning to make alterations in a table.


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from CovidProjects..CovidDeaths dea
join CovidProjects..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
-- to view, goto Databases- database name ie CovidProjects- Views - refresh the view - select top 1000 row

-- or

select*
from PercentPopulationVaccinated
