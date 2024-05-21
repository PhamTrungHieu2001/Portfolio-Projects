select * 
from PortfolioProject.dbo.CovidDeaths 
where continent is null
order by location, date

select * 
from PortfolioProject.dbo.CovidVaccinations 
order by location, date

select location, date, new_cases, total_cases, total_deaths 
from PortfolioProject.dbo.CovidDeaths 
order by location, date


-- final deaths vs cases
select location, max(total_deaths) final_deaths, max(total_cases) final_cases,  max(total_deaths)/max(total_cases)*100 final_death_rate
from CovidDeaths 
group by location
order by location

-- total cases vs total deaths in a country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_rate
from CovidDeaths
where location = 'Vietnam'
order by date


-- Looking at a country's daily infection rate (total cases / population)
select location, date, total_cases, population, (total_cases/population)*100 infection_percentage
from CovidDeaths
where location = 'Vietnam'
order by date


-- Looking at countries with the highest infection rate compared to population (total cases / population)
select location, population, MAX(total_cases) final_cases, MAX(total_cases)/population * 100 infection_rate
from CovidDeaths
group by location, population
order by infection_rate desc, location


-- Looking at countries with highest deaths per population
select location, population, MAX(cast(total_deaths as int)) final_deaths, MAX(total_deaths)/population * 100 death_rate
from CovidDeaths
where continent is not null
group by location, population
order by final_deaths desc, death_rate desc


-- Looking at continents with highest deaths
select continent, MAX(cast(total_deaths as int)) final_deaths
from CovidDeaths
where continent is not null
group by continent
order by final_deaths desc


-- Looking at the global numbers
select sum(new_cases) global_cases, sum(cast(new_deaths as int)) global_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 global_death_rate
from CovidDeaths
where continent is not null


-- Vaccination rate around the world day by day
with VaccinationPopulation
as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(CONVERT(int, new_vaccinations)) over (partition by d.location order by d.date) total_vaccinations
from PortfolioProject.dbo.CovidDeaths d
join PortfolioProject.dbo.CovidVaccinations v 
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)

select *, total_vaccinations/population * 100 vaccination_rate
from VaccinationPopulation
order by location, date

-- Create Views for visualization
create view VaccinationPopulation
as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations
, sum(CONVERT(int, new_vaccinations)) over (partition by d.location order by d.location, d.date) total_vaccinations
from PortfolioProject.dbo.CovidDeaths d
join PortfolioProject.dbo.CovidVaccinations v 
	on d.location = v.location
	and d.date = v.date
where d.continent is not null 




-- Queries for visualization -> save the result on Excel to upload on Tableau

-- 1. Total cases, total deaths and death rate in the world
select sum(new_cases) global_cases, sum(cast(new_deaths as int)) global_deaths,  
sum(cast(new_deaths as int)) / sum(new_cases) * 100 global_death_rate
from PortfolioProject.dbo.CovidDeaths
where continent is not null

-- 2. Total deaths of each continent
select continent, sum(cast(new_deaths as int)) total_deaths
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by total_deaths desc

-- 3. The percentage of people being infected in each country
select location, population, MAX(total_cases) final_cases, MAX(total_cases)/population * 100 infection_rate
from PortfolioProject.dbo.CovidDeaths
group by location, population
order by infection_rate desc

-- 4. The number of cases and infection rate on a daily basis
select location, population, date, total_cases, total_cases/population * 100 infection_rate
from PortfolioProject.dbo.CovidDeaths
order by infection_rate desc

