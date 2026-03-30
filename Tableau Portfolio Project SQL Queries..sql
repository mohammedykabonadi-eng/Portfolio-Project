-- Queries used for Tableau Project
-- 1.
SELECT
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
FROM coviddeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2;

-- 2.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
select location, sum(cast(new_deaths as signed)) as totaldeathcount
from coviddeaths
where continent is null
and location not in ('World', 'European Union', 'International')
group by location
order by totaldeathcount desc;

-- 3
select location, population,
    max(total_cases) as highestinfectioncount,
    max((total_cases/population))*100 as percentpopulationinfected
from coviddeaths
group by location, population
order by percentpopulationinfected desc;

-- 4
select location, population, date,
    max(total_cases) as highestinfectioncount,
    max((total_cases/population))*100 as percentpopulationinfected
from coviddeaths
group by location, population, date
order by percentpopulationinfected desc;
