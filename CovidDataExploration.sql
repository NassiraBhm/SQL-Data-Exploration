/*
Covid 19 Data Exploration 
*/

SELECT *
FROM [First project].dbo.CovidDs
ORDER BY 3,4


SELECT *
FROM [First project].dbo.CovidVs
ORDER BY 3,4

-- Select Data that we are going to work with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [First project].dbo.CovidDs
WHERE continent is not null
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathsPercentage
FROM [First project].dbo.CovidDs
WHERE Location = 'Morocco'
ORDER BY 1,2

-- Total Cases vs Population

SELECT Location, date, population, total_cases,  (total_cases/population)*100 AS CasesPercentage
FROM [First project]..CovidDs
WHERE Location = 'Morocco'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS MaxCases,  MAX((total_cases/population)*100) AS MaxCasesPercentage
FROM [First project]..CovidDs
WHERE continent is not null
GROUP BY location, population
ORDER BY MaxCasesPercentage DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int )) as MaxDeaths
FROM [First project]..CovidDs
WHERE continent is not null
GROUP BY location
ORDER BY MaxDeaths desc

-- Max deaths by continent

SELECT continent, MAX(cast(total_deaths as int )) as MaxDeaths
FROM [First project]..CovidDs
WHERE continent is not null
GROUP BY continent
ORDER BY MaxDeaths desc

SELECT location, MAX(cast(total_deaths as int )) as MaxDeaths
FROM [First project]..CovidDs
WHERE continent is null
GROUP BY location
ORDER BY MaxDeaths desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as SumNewCases, SUM(cast(new_deaths as int)) as SumNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [First project].dbo.CovidDs
where continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as SumNewCases, SUM(cast(new_deaths as int)) as SumNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [First project].dbo.CovidDs
where continent is not null
ORDER BY 1,2

-- Total Population vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(Vac.new_vaccinations as int)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingVaccinations
FROM [First project]..CovidDs Dea
JOIN [First project]..CovidVs Vac
  ON Dea.location = Vac.location
  and Dea.date = Vac.date
WHERE Dea.continent is not null 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [First project]..CovidDs dea
Join [First project]..CovidVs vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 AS VacPercent
From PopvsVac

--Alternative methode: temporary tables

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [First project]..CovidDs dea
Join [First project]..CovidVs vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 AS VacPercent
From #PercentPopulationVaccinated

-- Creating View 

Create View VaccinatedPopulation as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [First project]..CovidDs dea
Join [First project]..CovidVs vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT * FROM VaccinatedPopulation
