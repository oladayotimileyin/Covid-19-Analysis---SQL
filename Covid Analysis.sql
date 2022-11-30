select *
from [Covid portfolio project]..CovidDeaths
where continent is not null
order by 3,4;


---picking out some important data

select Location, date, population, total_cases, new_cases, total_deaths
from CovidDeaths
where continent is not null
order by Location, date;

--- Total cases against Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
from CovidDeaths
where continent is not null
order by Location, date;

--- Death percentage in Nigeria

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
from CovidDeaths
where Location like '%Nigeria%' and continent is not null
order by Location, date;

--- Death percentage in United Kingdom

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
from CovidDeaths
where Location like '%United Kingdom%'
order by Location, date;

--- Total Covid Cases against Population

select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentageCases
from CovidDeaths
where continent is not null
order by Location, date;

--- percentage cases for Nigeria

select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentageCases
from CovidDeaths
where Location like '%Nigeria%'
order by Location, date;

---Countries with highest infection rate to population

select Location, Population, MAX(total_cases) as HighestInfectionCases, MAX((total_cases/Population))*100 as HighestPercentageCases
from CovidDeaths
where continent is not null
group by Location, Population
order by HighestPercentageCases desc;

--infection/day

select Location, Population, date, MAX(total_cases) as HighestInfectionCases, MAX((total_cases/Population))*100 as PercentagePopulationInfected
from CovidDeaths
where continent is not null
group by Location, Population, date
order by PercentagePopulationInfected desc;

---Countries with highest death count per population

select Location, Population, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by Location, Population
order by TotalDeaths desc;

---- Continents with highest death count per population

select Location, Population, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is null and
location not in ('World', 'High income', 'Upper middle income', 'Lower middle income', 'European Union', 'Low income', 'International')
group by Location, Population
order by TotalDeaths desc;

select continent, Population, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by continent, Population
order by TotalDeaths desc;

---Global daily cases and deaths

select date, sum(new_cases) as DailyCases, sum(cast(new_deaths as int)) as DailyDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentageDeath
from CovidDeaths
where continent is not null
group by date
order by date;

---Total cases and death till date

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentageDeath
from CovidDeaths
where continent is not null;

---Join the death and vaccination tables

select *
from CovidDeaths cod
join CovidVacinations cov
	on cod.location = cov.location
	and cod.date = cov.date

--- Total Vacination to Total Population

select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations
from CovidDeaths cod
join CovidVacinations cov
	on cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null
order by continent, location, date;

--- getting rolling count of vacination by date

select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
sum(convert(int, cov.new_vaccinations)) over (Partition by cod.location Order by cod.location, cod.date)
as CummulativeVaccinationCount
from CovidDeaths cod
join CovidVacinations cov
	on cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null
order by location, date;

--- creating a ommon table expression, or CTE and add percentage vaccination

with populationvsvaccination (Continent, Location, Date, Population, New_Vaccination, CummulativeVaccinationCount)
as
(
select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
sum(convert(int, cov.new_vaccinations)) over (Partition by cod.location Order by cod.location, cod.date)
as CummulativeVaccinationCount
from CovidDeaths cod
join CovidVacinations cov
	on cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null
)

select * , (CummulativeVaccinationCount / Population) * 100 as PercentageVaccinated
from populationvsvaccination

--- replicating the above using temp table

drop table if exists #percentagepopulationvacinated

create table #percentagepopulationvacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CummulativeVaccinationCount numeric,
)

insert into #percentagepopulationvacinated
select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
sum(convert(int, cov.new_vaccinations)) over (Partition by cod.location Order by cod.location, cod.date)
as CummulativeVaccinationCount
from CovidDeaths cod
join CovidVacinations cov
	on cod.location = cov.location
	and cod.date = cov.date
--where cod.continent is not null 

select * , (CummulativeVaccinationCount / Population) * 100
from #percentagepopulationvacinated

---lets create a view to store some data
---percentage death table

create view percentagedeath as

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
from CovidDeaths
where continent is not null

---percentagepopulationcases
create view percentagepopulationcases as

select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentageCases
from CovidDeaths
where continent is not null;

--- highestInfectionrate
create view highestinfectionrate as

select Location, Population, MAX(total_cases) as HighestInfectionCases, MAX((total_cases/Population))*100 as HighestPercentageCases
from CovidDeaths
where continent is not null
group by Location, Population;

---highestdeathcountcountry
create view highestdeathcountcountry as

select Location, Population, MAX(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths
where continent is not null
group by Location, Population;

--globaldailycasesanddeath
create view globaldailycasesanddeath as

select date, sum(new_cases) as DailyCases, sum(cast(new_deaths as int)) as DailyDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentageDeath
from CovidDeaths
where continent is not null
group by date;

--globaldeathtilldate
create view globaldeathtilldate as

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentageDeath
from CovidDeaths
where continent is not null;

---totalvacinationtopopulation
create view totalvacinationtopopulation as

select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations
from CovidDeaths cod
join CovidVacinations cov
	on cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null;

---percentagepopulationvacinated
create view percentagepopulationvacinated as

select cod.continent, cod.location, cod.date, cod.population, cov.new_vaccinations,
sum(convert(int, cov.new_vaccinations)) over (Partition by cod.location Order by cod.location, cod.date)
as CummulativeVaccinationCount
from CovidDeaths cod
join CovidVacinations cov
	on cod.location = cov.location
	and cod.date = cov.date
where cod.continent is not null 
