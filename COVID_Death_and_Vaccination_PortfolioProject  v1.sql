--General Inspection
SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

-- Looking at Total Population vs Total Vaccinations(percentage vaccinated globaly)
-- Join tables
select dea.continent , dea.location,dea.date,dea.population, vac.new_vaccinations,
	SUM(CAST (vac.new_vaccinations AS int)) OVER (partition by  dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
order by 2,3

-- We want to know :"is cummulative vaccinations have 
-- corelation to new cases and new deaths in specific loaction?"
-- can be plot into x-y plot 
select dea.continent,dea.location,dea.date, dea.population,dea.new_cases ,dea.new_deaths,vac.new_vaccinations
	,SUM(convert(float, vac.new_vaccinations))over (partition by dea.location 
	order by dea.location, dea.date) as cumm_vaccinations
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
	and dea.date=vac.date
where dea.location ='Indonesia' and
	dea.continent is not null
order by 2,3

-- Create a View For Deaths by continents #view 1
create view DeathGlobally as
select continent, MAX(cast(total_deaths as float))as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
--order by total_death_count desc


-- we want to make a temporary table or temp table to
	--use new colum that we make in select lists


--create TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_cases numeric,
new_deaths numeric,
new_vaccinations numeric,
cumm_vaccinations numeric
)

-- insert the data to the table above
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population,dea.new_cases ,dea.new_deaths,vac.new_vaccinations
	,SUM(convert(float, vac.new_vaccinations))over (partition by dea.location 
	order by dea.location, dea.date) as cumm_vaccinations
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--show the table and use cumm_vaccinations as percentage over the population (people vaccinated percentage)

select *, (cumm_vaccinations/population)*100 as vaccination_percentage
from PercentPopulationVaccinated

-- create a view for later visualization #view2
drop table if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population,dea.new_cases ,dea.new_deaths,vac.new_vaccinations
	,SUM(convert(float, vac.new_vaccinations))over (partition by dea.location 
	order by dea.location, dea.date) as cumm_vaccinations
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
