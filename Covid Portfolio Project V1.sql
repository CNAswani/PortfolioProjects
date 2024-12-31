SELECT *
FROM [First Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

/*SELECT *
FROM [First Portfolio Project].dbo.CovidVaccinations$
ORDER BY 3,4*/

-- SELECT THE DATA WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [First Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- Shows the likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, new_cases, total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
FROM [First Portfolio Project].dbo.CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

-- United States
SELECT location, date, total_cases, new_cases, total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
FROM [First Portfolio Project].dbo.CovidDeaths$
WHERE location LIKE '%states%' AND 
continent IS NOT NULL
ORDER BY 1,2

-- LOOKING AT THE TOTAL CASES VS POPULATION - USA
-- Shows the percentage of population got covid

SELECT location, date, population, total_cases,  
(total_cases/population)*100 AS PercentagePopulationInfected
FROM [First Portfolio Project].dbo.CovidDeaths$
WHERE location LIKE '%states%' AND
continent IS NOT NULL
ORDER BY 1,2

SELECT location, date, population, total_cases,  
(total_cases/population)*100 AS PercentagePopulationInfected
FROM [First Portfolio Project].dbo.CovidDeaths$
-- WHERE location LIKE '%states%'
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, 
MAX(total_cases) AS HighestInfectionCount,  
MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM [First Portfolio Project].dbo.CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected Desc


/*SELECT Location,  
MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount  
FROM [First Portfolio Project].dbo.CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount Desc*/


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULAITON

SELECT location,  
MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount  
FROM [First Portfolio Project].dbo.CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount Desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT Continent,  
MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount  
FROM [First Portfolio Project].dbo.CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount Desc

-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT BY POPULATION

SELECT Continent,  
MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount  
FROM [First Portfolio Project].dbo.CovidDeaths$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount Desc


-- GLOBAL NUMBERS

SELECT Date, 
SUM(new_cases) AS TotalCases, 
SUM(CAST(new_deaths AS int)) AS TotalDeaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [First Portfolio Project].dbo.CovidDeaths$
--WHERE location LIKE '%states%' AND 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Overall accross the world

SELECT
SUM(new_cases) AS TotalCases, 
SUM(CAST(new_deaths AS int)) AS TotalDeaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [First Portfolio Project].dbo.CovidDeaths$
--WHERE location LIKE '%states%' AND 
WHERE continent IS NOT NULL
ORDER BY 1,2


-- JOIN THE TWO TABLES DEATHS AND VACCINATIONS

SELECT *
FROM [First Portfolio Project].dbo.CovidDeaths$ dea
JOIN [First Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations
FROM [First Portfolio Project].dbo.CovidDeaths$ dea
JOIN [First Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- LOOKING AT THE CUMULATIVE TOTAL FOR EACH LOCATION

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM [First Portfolio Project].dbo.CovidDeaths$ dea
JOIN [First Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- TOTAL POPULATION VS TOTAL VACCINATED

SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM [First Portfolio Project].dbo.CovidDeaths$ dea
JOIN [First Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- How many people are vaccinated per location using CTE/Temp table

-- USING CTE
WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, CummulativePeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM [First Portfolio Project].dbo.CovidDeaths$ dea
JOIN [First Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *,(CummulativePeopleVaccinated/Population)*100
FROM PopvsVac

-- USING A TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CummulativePeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM [First Portfolio Project].dbo.CovidDeaths$ dea
JOIN [First Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *,(CummulativePeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATE FOR FUTURE VISUALIZATIONS

Create view PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
ORDER BY dea.location, dea.date) AS CummulativePeopleVaccinated
FROM [First Portfolio Project].dbo.CovidDeaths$ dea
JOIN [First Portfolio Project].dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3 


SELECT *
FROM PercentPopulationVaccinated