SELECT * FROM 
[protfolio sql]..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT DATA
SELECT location,date,total_cases, new_cases ,total_deaths,population
FROM [protfolio sql]..CovidDeaths
ORDER BY 1,2

--Total cases ve total deaths

SELECT location,date,total_cases,total_deaths, (total_deaths / total_cases) as Deathpercentage
FROM [protfolio sql]..CovidDeaths
--where location like '%states%'
ORDER BY 1,2
--death according to population
SELECT location,date,total_cases,population, (total_cases/ population)*100 as Deathpercentage
FROM [protfolio sql]..CovidDeaths
where location like '%china%'
ORDER BY 1,2
--countries with high infection compared to population
SELECT location,population, MAX(total_cases),MAX(total_cases/ population)*100 as populationinfected
FROM [protfolio sql]..CovidDeaths
--where location like '%china%'
group by location,population
ORDER BY populationinfected desc

--high death count per population
SELECT location, MAX(cast (total_deaths as int)) as totaldeath
FROM [protfolio sql]..CovidDeaths
--where location like '%china%'
where continent is not null
group by location
ORDER BY  totaldeath desc

--lets break by contients
SELECT location, MAX(cast (total_deaths as int)) as totaldeath
FROM [protfolio sql]..CovidDeaths
--where location like '%china%'
where continent is null
group by location
ORDER BY  totaldeath desc

--showing continents with high deaths

SELECT continent, MAX(cast (total_deaths as int)) as totaldeath
FROM [protfolio sql]..CovidDeaths
--where location like '%china%'
where continent is not null
group by continent
ORDER BY  totaldeath desc

--Global numbers
select sum(cast(new_cases as int)) as totalcases, sum(cast(new_deaths as int)) as totalcases , SUM(CAST( new_deaths as int)/sum(new_cases)) as deathpercent
FROM [protfolio sql]..CovidDeaths
--where location like '%china%'
where continent is not null
--group by continent
ORDER BY  1,2


--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations AS int)
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
 FROM [protfolio sql]..CovidDeaths dea
join [protfolio sql]..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use CTE
with PopvsVas (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations AS int)
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
 FROM [protfolio sql]..CovidDeaths dea
join [protfolio sql]..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*,(rollingpeoplevaccinated/population)*100
from PopvsVas

--temp table
create table #percentpopulationvaccinated
(
 Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations AS int)
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
 FROM [protfolio sql]..CovidDeaths dea
join [protfolio sql]..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select*,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--create view for visualization
Create view percentpopulationvaccinated AS
Select dea.continent,dea.location,dea.date,dea.population,(vac.new_vaccinations )
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
 FROM [protfolio sql]..CovidDeaths dea
join [protfolio sql]..Covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM percentpopulationvaccinated