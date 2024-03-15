/*

SQL Queries Used for Tableau Visualization Project
Raw Dataset: https://ourworldindata.org/covid-deaths
Clean Dataset: https://drive.google.com/drive/folders/1_qR2RyHUW1eaMZ9TGVeq9tx4AGq1_X3P?usp=sharing 

*/


-- 1a. 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
FROM PortfolioProject..CovidDeath
WHERE continent is not null 
ORDER BY 1,2


-- 1b.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- 2. 
-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT countries, SUM(cast(new_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeath
WHERE continent is null 
AND countries not in ('World', 'European Union', 'International')
GROUP BY countries
ORDER BY total_death_count desc



-- 3a.
SELECT Countries, Population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
FROM PortfolioProject..CovidDeath
WHERE countries not in ('Africa', 'Asia', 'Europe', 'European Union', 'International', 'North America', 'Oceania', 'South America', 'World')
GROUP BY countries, Population
ORDER BY Percent_Population_Infected DESC



-- 3b.
SELECT Countries, Population, Date, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
FROM PortfolioProject..CovidDeath
WHERE countries not in ('Africa', 'Asia', 'Europe', 'European Union', 'International', 'North America', 'Oceania', 'South America', 'World')
GROUP BY Countries, Population, Date
ORDER BY Percent_Population_Infected DESC



-- 4.
SELECT dea.continent, dea.countries, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.countries ORDER BY dea.countries, dea.date) as daily_count_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVac vac
	ON dea.countries = vac.countries
	AND dea.date = vac.date
WHERE dea.continent is not null
--AND countries not in ('Africa', 'Asia', 'Europe', 'European Union', 'International', 'North America', 'Oceania', 'South America', 'World')
ORDER BY 1, 2, 3


