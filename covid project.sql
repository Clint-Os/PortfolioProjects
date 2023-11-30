select location, date, total_cases, new_cases, total_deaths, population
from projectportfolio.coviddeaths
order by 1,2

-- looking at total cases vs total deaths
-- rough estimate of chances of dying on contracting covid in your country--

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from projectportfolio.coviddeaths
where location like '%Kenya%'
order by 1,2

-- looking at total cases vs population-- shows population that got covid--

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from projectportfolio.coviddeaths
where location like '%Kenya%'
order by 1,2

--looking at coountry with highest infection rate compared to population

select location, population, MAx(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from projectportfolio.coviddeaths
-- where location like '%Kenya%'
group by location, population
order by percentpopulationinfected desc

-- showing countries with highest death count per population

select location, MAX(total_deaths) as TotalDeathCount
from projectportfolio.coviddeaths
where continent is not null 
group by location
order by TotalDeathCount desc

-- show continents with highest death count--

select location, continent, MAX(total_deaths) as TotalDeathCount
from projectportfolio.coviddeaths
where continent is not null 
group by continent, location
order by TotalDeathCount desc

-- joining tables--
-- looking at total population vs vaccinations--
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location) 
from projectportfolio.coviddeaths dea
join projectportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from projectportfolio.coviddeaths dea
join projectportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

-- use CTE-- 

With PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from projectportfolio.coviddeaths dea
join projectportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac 

-- Temp table-- 

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from projectportfolio.coviddeaths dea
join projectportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

-- THIS CODE ABOVE DID NOT RUN--

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from projectportfolio.coviddeaths dea
join projectportfolio.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

