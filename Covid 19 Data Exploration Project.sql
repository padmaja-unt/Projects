/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null


--Selecting the data that is going to be used

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


--Outcome of cases: Death rate in India 

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,3) as deathPercentage
From PortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null
Order by 1,2


--Percentage of population in India that is effected by Covid

Select location, date, population, total_cases, (total_cases/population)*100 as percentage_of_population_affected
From PortfolioProject..CovidDeaths
Where location like '%India%'
and continent is not null
Order by 1,2


--Countries having highest percentage of their population affected with Covid 19

Select location, population, max(total_cases) as highest_infected_count, max((total_cases/population)*100) as percentage_of_population_affected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by percentage_of_population_affected desc


--Countries having highest death count per population due to Covid 19

Select location, population, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by total_death_count desc


--Breaking things down by continent

--Continents having highest death count per population due to Covid 19

Select continent, max(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by total_death_count desc


--Global Numbers

--New deaths vs New cases everyday globally

Select date, sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by date


--Number of vaccinations vs Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location and 
   dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Using CTE to find the percentage of population that is vaccinated 

With pop_vaccinated(continent, location, date, population, new_vaccinations, rolling_people_vaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location and 
dea.date = vac.date
Where dea.continent is not null
)
Select *, (rolling_people_vaccinated/population)*100 as percentage_pf_population_vaccinated
From pop_vaccinated
Order by 2,3


--Using Temp Table to find the percentage of population that is vaccinated 

Drop table if exists #percent_pop_vaccinated
Create table #percent_pop_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #percent_pop_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
From PortfolioProject..CovidDeaths dea JOIN PortfolioProject..CovidVaccinations vac
On dea.location = vac.location and 
   dea.date = vac.date

Select *, (rolling_people_vaccinated/population)*100 as percentage_of_population_vaccinated
From #percent_pop_vaccinated












