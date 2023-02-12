/* SQL DATA EXPLORATION */

/* Checking the data */
SELECT *
FROM covid_deaths cd
WHERE continent != ""
ORDER BY 3,4

/* Data selection */
SELECT location, `date`, total_cases, new_cases, total_deaths, population
FROM covid_deaths cd 
ORDER BY 1,2

/* Total cases vs Total deaths | likelihood of dying from COVID */
SELECT location, `date`, total_cases, total_deaths, (total_deaths /total_cases)*100 as death_percentage
FROM covid_deaths cd 
ORDER BY 1,2

/* Total cases vs Population | percentage of population that had COVID */
SELECT location, `date`, total_cases, population , (total_cases/population)*100 as infected_percentage
FROM covid_deaths cd 
ORDER BY 1,2

/* Highest infection rate compared to the Population */
SELECT continent,location, population, MAX(total_cases) as highest_infection_count , MAX((total_cases/population))*100 as infected_percentage
FROM covid_deaths cd 
GROUP BY continent, location, population
ORDER BY infected_percentage DESC

/* Countries with the highest death count */
SELECT location, MAX(total_deaths) as total_death_count
FROM covid_deaths cd 
WHERE continent != ""
GROUP BY location
ORDER BY total_death_count DESC

/* Continent with the highest death count */
SELECT continent, MAX(total_deaths) as total_death_count
FROM covid_deaths cd 
WHERE continent != ""
GROUP BY continent 
ORDER BY total_death_count DESC

/* Global numbers */
SELECT `date`, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage  
FROM covid_deaths cd 
WHERE continent != ""
GROUP BY `date` 
ORDER BY 1,2

/* Total Population vs Vaccinations */
SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (PARTITION by cd.location ORDER BY cd.location, cd.`date`) as people_vaccinated_daily_count
FROM covid_deaths cd JOIN covid_vaccinations cv ON cd.location = cv.location AND cd.`date` = cv.`date` 
WHERE cd.continent != "" 
ORDER BY 2,3

/* Common Table Expression (CTE) */
WITH pop_percentage_vaccinated
(
contient,
location,
`date`,
population,
new_vaccinations,
people_vaccinated_daily_count
)
AS
(
SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (PARTITION by cd.location ORDER BY cd.location, cd.`date`) as people_vaccinated_daily_count
FROM covid_deaths cd JOIN covid_vaccinations cv ON cd.location = cv.location AND cd.`date` = cv.`date` 
WHERE cd.continent != ""
)
SELECT *, (people_vaccinated_daily_count/population)*100 as pop_vaccination_percentage
FROM pop_percentage_vaccinated

/* Creating views */
CREATE VIEW pop_percentage_vaccinated as
SELECT cd.continent, cd.location, cd.`date`, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) OVER (PARTITION by cd.location ORDER BY cd.location, cd.`date`) as people_vaccinated_daily_count
FROM covid_deaths cd JOIN covid_vaccinations cv ON cd.location = cv.location AND cd.`date` = cv.`date` 
WHERE cd.continent != ""

/* Quering the created view */
SELECT *
FROM pop_percentage_vaccinated ppv


/* TABLEAU TABLE EXPORTS */

-- 1. tableau_table_1 export
/* Global numbers */
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage  
FROM covid_deaths cd 
WHERE continent != ""
ORDER BY 1,2

-- 2. tableau_table_2 export
SELECT continent, SUM(new_deaths) AS total_deaths_count 
FROM covid_deaths cd
WHERE continent != ""
GROUP BY continent 
ORDER BY total_deaths_count DESC

-- 3. tableau_table_3 export
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 as percentage_population_infected
FROM covid_deaths cd
GROUP BY location, population
ORDER BY percentage_population_infected DESC 

-- 4. tableau_table_4 export
SELECT location, population, `date`, MAX(total_cases) AS highest_infection_count, MAX(total_cases/population)*100 as percentage_population_infected  
FROM covid_deaths cd 
GROUP BY location , population , `date` 
ORDER BY percentage_population_infected DESC 