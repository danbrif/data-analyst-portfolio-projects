/*
COVID-19 DATA EXPLORATION 

SKILLS USED: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
TOOLS: SQL Server Management Studio (SSMS)
DATASET: https://drive.google.com/drive/folders/1_qR2RyHUW1eaMZ9TGVeq9tx4AGq1_X3P?usp=sharing (www.ourworldindata.org/covid-deaths)
*/


select *
from PortfolioProject..CovidDeath
where continent is not null
order by 3, 4


select Countries, count(total_cases) total_cases, count(total_deaths) total_deaths
from PortfolioProject..CovidDeath
where continent is not null
group by countries
having count(total_cases) > 0
order by total_deaths desc



-- Select Data that We are Going Use

SELECT countries, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
WHERE continent is not null
ORDER by 1,2



-- Looking at Total Case vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT countries, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) as death_percentage
FROM PortfolioProject..CovidDeath
where countries = 'indonesia' and continent is not null
ORDER by 5



-- Looking at Total Case vs Population
-- Shows what percentage of population got Covid

SELECT countries, date, population, total_cases, ROUND((total_cases/population)*100, 2) as infected_population_rate
FROM PortfolioProject..CovidDeath
where countries = 'indonesia' and continent is not null
ORDER by 5 desc



-- Looking at Countries with Highest Infection Rate compared to Population

SELECT countries, population, MAX(total_cases) as highest_infection_count, ROUND(MAX(total_cases/population)*100, 2) as highest_case_rate
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY countries, population
ORDER BY 4 desc



-- Showing Continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY 2 desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100, 2) as death_percentage
FROM PortfolioProject..CovidDeath
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2



-- TOTAL POPULATION VS VACCINATIONS
-- Percentage of Population that has Received at least One Covid Vaccine

-- Showing Daily Vaccination Given of Each Countries

SELECT dea.continent, dea.countries, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.countries ORDER BY dea.countries, dea.date) as daily_count_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVac vac
	ON dea.countries = vac.countries AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



-- (1) Using CTE to Perform Calculation on Partition By in Previous Query

WITH CTE_PopVac (continent, countries, date, population, new_vaccinations, daily_count_vaccinations)
as
(SELECT dea.continent, dea.countries, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.countries ORDER BY dea.countries, dea.date) as daily_count_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVac vac
	ON dea.countries = vac.countries AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, ROUND((daily_count_vaccinations/population)*100, 2) as percent_daily_vaccinated
FROM CTE_PopVac



-- (2) Using TEMP TABLE to Perform Calculation on Partition By in Previous Query

DROP TABLE if exists #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated (
continent varchar(100),
countries varchar(100),
date datetime,
population numeric,
new_vaccinations numeric,
daily_count_vaccinations numeric,
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.countries, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.countries ORDER BY dea.countries, dea.date) as daily_count_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVac vac
	ON dea.countries = vac.countries AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, ROUND((daily_count_vaccinations/population)*100, 2) as percent_daily_vaccinated
FROM #percent_population_vaccinated



-- Creating View to Store Data for Later Visualizations

CREATE VIEW percent_population_vaccinated as
SELECT dea.continent, dea.countries, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.countries ORDER BY dea.countries, dea.date) as daily_count_vaccinations
FROM PortfolioProject..CovidDeath dea
JOIN PortfolioProject..CovidVac vac
	ON dea.countries = vac.countries AND dea.date = vac.date
WHERE dea.continent is not null
