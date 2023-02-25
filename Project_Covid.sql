--select*
--From Demo_1..covid_death$
--order by 3,4
----select*
--From Demo_1..covid_vaccination$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population_density
From Demo_1..covid_death$
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpersentage
From Demo_1..covid_death$
where location like '%China%'
order by 1,2


-- looking at total cases vs total death
-- shows what percentage of death by covid

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpersentage
From Demo_1..covid_death$
where location like '%states%'
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid

Select location, date, total_cases, population_density, (total_deaths/population_density)*100 as Deathpersentage
From Demo_1..covid_death$
where location like '%states%'
order by 1,2


-- looking at countries with Highest infection Rate compared to population

Select location, population_density, MAX(total_cases) as HighestInfection, MAX(total_cases/population_density)*100 as PercentagePopulationInfactor
From Demo_1..covid_death$
--where location like '%states%'
group by location, population_density
order by PercentagePopulationInfactor desc


-- looking at countries with Highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Demo_1..covid_death$
where continent is not null
group by location
order by TotalDeathCount desc


-- looking at continent with Highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Demo_1..covid_death$
where continent is null
group by location
order by TotalDeathCount desc


--looking at the global total cases and death

select date, SUM(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeath,(Sum(cast(new_deaths as int))/SUM(new_cases))*100 as GlobalChange
From Demo_1..covid_death$
where continent is not null
group by date
order by 1,2


--looking at the total vaccination vs population

select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, SUM(Convert(float ,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from Demo_1..covid_death$ dea
join Demo_1..covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

with VacVsPop (continent, location, date, population, new_vac, RollingPeople)
as(
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, SUM(Convert(float ,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from Demo_1..covid_death$ dea
join Demo_1..covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeople/population)*100
From VacVsPop


--Create a new table to save what we got
Drop table if exists #PercentPeopleVaccinated
Create Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
Rollingpeoplevaccinated numeric,
)

--Insert

Insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, SUM(Convert(float ,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from Demo_1..covid_death$ dea
join Demo_1..covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
From #PercentPeopleVaccinated

--Create a view 

Create view vs_1 as
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, SUM(Convert(float ,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from Demo_1..covid_death$ dea
join Demo_1..covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

