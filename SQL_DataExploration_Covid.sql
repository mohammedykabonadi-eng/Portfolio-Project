#Fixing the table date from serial number to real date i know how to fix it in excel but i try with sql and it work perfect
-- Step 1: Add a new proper DATE column
ALTER TABLE CovidDeaths ADD COLUMN date_fixed DATE;

-- Step 2: Convert the Excel serial numbers to real dates
UPDATE CovidDeaths
SET date_fixed = DATE_ADD('1899-12-30', INTERVAL date DAY);

-- Step 3: Drop the old broken column
ALTER TABLE CovidDeaths DROP COLUMN date;

-- Step 4: Rename the fixed column to 'date'
ALTER TABLE CovidDeaths RENAME COLUMN date_fixed TO `date`;

-- Step 1: Add a new proper DATE column
ALTER TABLE covidvaccinations ADD COLUMN date_fixed DATE;

-- Step 2: Convert the Excel serial numbers to real dates
UPDATE covidvaccinations
SET date_fixed = DATE_ADD('1899-12-30', INTERVAL date DAY);

-- Step 3: Drop the old broken column
ALTER TABLE covidvaccinations DROP COLUMN date;

-- Step 4: Rename the fixed column to 'date'
ALTER TABLE covidvaccinations RENAME COLUMN date_fixed TO `date`;

select *
from coviddeaths;

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1, 2;

-- Looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPrercentage
from coviddeaths
order by 1, 2;

-- Looking at total cases vs total deaths in the US
select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPrercentage
from coviddeaths
where location like '%states%'
order by 1, 2;

-- Looking at Total Cases vs Population
-- show what percentage of population got covid
select location, date, total_cases, population, (total_cases / population) * 100 as PrercentPopulationInfected
from coviddeaths
order by 1, 2;

-- Looking at countries with highest infection reate compared to population
select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as PrercentPopulationInfected
from coviddeaths
group by location,population
order by PrercentPopulationInfected desc ;

-- Showing Countries with Highest Death Count per Population
select location,max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc ;

-- LEts Break This Down By Continent
-- Showing the continent with the highest death count per population
select continent, max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is  not null
group by continent
order by TotalDeathCount desc;

-- Global Numbers
select date,sum(new_cases) as totalCases,sum(new_deaths) as totalDeaths,sum(new_deaths)/sum(new_cases) * 100 as deathPercentage
from coviddeaths
where continent is not null
group by date
order by 1,2;


select sum(new_cases)as total_cases,
       sum(new_deaths)as total_deaths,
       sum(new_deaths ) / sum(new_cases) * 100 as deathpercentage
from coviddeaths
where continent is not null
order by 1, 2;

#Exploraing CovidVaccinations and joining the tow table
-- looking at Total Population vs Vaccinations
select dea.continent,
       dea.location,
       dea.date,
       dea.population,
       vac.new_vaccinations,
       sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
         join covidvaccinations vac
              on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3;

-- Use CTE
with popvsvac (continent, location, date, population, new_vaccinations ,rollingpeoplevaccinated) as (
    select dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
    from coviddeaths dea
             join covidvaccinations vac
                  on dea.location = vac.location and dea.date = vac.date
    where dea.continent is not null
    order by 2, 3
)
select *,(rollingpeoplevaccinated/population) * 100 vaccinatedpercentage
from popvsvac;

-- Temp Table

drop table if exists percentpopulationvaccinated;

create table percentpopulationvaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    rollingpeoplevaccinated numeric
);

insert into percentpopulationvaccinated
    select dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
    from coviddeaths dea
             join covidvaccinations vac
                  on dea.location = vac.location and dea.date = vac.date
    where dea.continent is not null;

select *, (rollingpeoplevaccinated / population) * 100 as vaccinatedpercentage
from percentpopulationvaccinated
# order by 2, 3
;

-- Creating View to Store Data for later visualizations

create view PercentPopulationVaccinated_view as
select dea.continent,
           dea.location,
           dea.date,
           dea.population,
           vac.new_vaccinations,
           sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
    from coviddeaths dea
             join covidvaccinations vac
                  on dea.location = vac.location and dea.date = vac.date
    where dea.continent is not null;


select *
from PercentPopulationVaccinated_view;
