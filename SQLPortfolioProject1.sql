select * 
from PortfolioProject..CovidDeath
where continent is not null
order by 3, 4

select * 
from PortfolioProject..CovidVaccination
order by 3, 4

-- Data needed for analysis

select location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeath
order by 1, 2

-- a look at the total cases v total deaths
--it shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeath
where continent is not null
order by 1, 2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeath
where location like '%states%'
and continent is not null
order by 1, 2


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
from PortfolioProject..CovidDeath
where location like '%kingdom%'
and continent is not null
order by 1, 2

-- Looking at the total cases v population
--Shows the population percent of those that caught covid

select location, date, population,total_cases, (total_cases/population)*100 as PopulationInfectedPercent
from PortfolioProject..CovidDeath
where location like '%kingdom%'
and continent is not null
order by 1, 2

--Looking at countries with the highest infection rate compared to Population


select location, population,MAX(total_cases)as HighestInfectionCount, MAX(total_cases/population)*100 as PopulationInfectedPercent
from PortfolioProject..CovidDeath
where continent is not null
group by location, population
order by PopulationInfectedPercent desc

-- showing the countries with highest death count per location

select location,MAX(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by location
order by TotalDeathCount desc

-- Show the highest death count by continent 
-- Showing the continents with the Highest Death Count per population

select continent ,MAX(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

select location ,MAX(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is null
group by location
order by TotalDeathCount desc

--Global Numbers

select date, SUM( new_cases) as total_cases,
            sum (cast(new_deaths as int)) as total_deaths,
			 sum (cast(new_deaths as int))/ SUM( new_cases) as total_deaths_percentage
from PortfolioProject..CovidDeath
where continent is not null
group by date 
order by 1, 2 desc

select  SUM( new_cases) as total_cases,
            sum (cast(new_deaths as int)) as total_deaths,
			 sum (cast(new_deaths as int))/ SUM( new_cases) as total_deaths_percentage
from PortfolioProject..CovidDeath
where continent is not null
order by 1, 2 desc


-- Total amount of people that have been vaccinated

select * 
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location
and dea.date = vac.date

--Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date
order by 2, 3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(convert(int, vac.new_vaccinations)) over ( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date
order by 2, 3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
 , (RollingPeopleVaccinated/population)* 100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date
order by 2, 3

--Creating a CTE/Temp Table
--Using CTE


With PopsvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date
)
select *, (RollingPeopleVaccinated/population)*100
from PopsvsVac


--Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


Drop table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creatig view to store data for later visualisation

Create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 Sum(cast(vac.new_vaccinations as int)) over ( partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccination vac
  ON dea.location = vac.location
where dea.continent is not null
and dea.date = vac.date

select * from PercentPopulationVaccinated