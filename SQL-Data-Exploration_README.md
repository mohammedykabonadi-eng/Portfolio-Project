# COVID-19 SQL Data Exploration

## Overview

A comprehensive SQL-based exploration of global COVID-19 data, analyzing the pandemic's impact across countries and continents. This project covers infection rates, death percentages, vaccination rollouts, and population-level statistics using advanced SQL techniques.

## Tools & Technologies

- **MySQL 8.0**
- **DataGrip**
- Data Source: [Our World in Data – COVID-19 Dataset](https://ourworldindata.org/covid-deaths)

## Dataset

Two main tables were used:
- `CovidDeaths` — daily death and case counts by location
- `CovidVaccinations` — daily vaccination counts by location

> A custom fix was applied to convert Excel serial date numbers into proper SQL `DATE` format using `DATE_ADD('1899-12-30', INTERVAL date DAY)`.

## Key Analyses

### 1. Death Percentage
Calculates the likelihood of dying if infected with COVID-19 in a given country.
```sql
SELECT location, date, total_cases, total_deaths,
       (total_deaths / total_cases) * 100 AS DeathPercentage
FROM coviddeaths
ORDER BY 1, 2;
```

### 2. Infection Rate vs Population
Shows what percentage of each country's population contracted COVID-19.
```sql
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
       MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;
```

### 3. Countries with Highest Death Count
```sql
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;
```

### 4. Continental Breakdown
```sql
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;
```

### 5. Global Death Percentage Over Time
```sql
SELECT date,
       SUM(new_cases) AS total_cases,
       SUM(new_deaths) AS total_deaths,
       SUM(new_deaths) / SUM(new_cases) * 100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;
```

### 6. Population vs Vaccinations (Rolling Count)
Joins both tables and uses a **Window Function** to track cumulative vaccinations per country over time.
```sql
SELECT dea.continent, dea.location, dea.date, dea.population,
       vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
```

### 7. CTE — Vaccination Percentage
Uses a **Common Table Expression (CTE)** to calculate the vaccinated percentage of the population.

### 8. Temp Table
Creates a temporary table `PercentPopulationVaccinated` to store and query rolling vaccination data.

### 9. View for Visualization
Creates a SQL **View** (`PercentPopulationVaccinated_view`) to feed into Tableau dashboards.

## SQL Concepts Used

| Concept | Usage |
|---|---|
| Joins | Merging deaths and vaccinations tables |
| Aggregate Functions | SUM, MAX, COUNT |
| Window Functions | Rolling vaccination count with PARTITION BY |
| CTEs | Calculating vaccination percentage |
| Temp Tables | Intermediate data storage |
| Views | Preparing data for Tableau |
| Date Manipulation | Converting Excel serial dates |

## Related Project

This project feeds directly into the **[COVID-19 Tableau Dashboard](https://github.com/mohammedykabonadi-eng/Covid_Tableau_Project)** for visual reporting.

---

**Author:** Mohammed Abo Nadi  
**GitHub:** [mohammedykabonadi-eng](https://github.com/mohammedykabonadi-eng)  
**LinkedIn:** [mohammed-abonadi](https://www.linkedin.com/in/mohammed-abonadi-096b093b5/)
