# COVID-19 Data Analysis

## Data Collection

The COVID-19 World Data from 2021 to 2022 was downloaded from [Here](https://ourworldindata.org/covid-deaths).

NOTE: `/data/raw_data` has been excluded from the repository.

The Data was divided into two parts using Excel:

1. `covid_vaccination.csv`
2. `covid_death.csv`

## SQL Exploration

Data exploration was conducted using SQL with MySQL-Server and DBeaver. The [SQL script](./covid-analysis-sql-script.sql)

These are the export scripts taken from the `covid-analysis-sql-script.sql` script.

```sql
-- 1. tableau_table_1 export
SELECT SUM(new_cases)
AS total_cases, SUM(new_deaths)
AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100
AS death_percentage  
FROM covid_deaths cd 
WHERE continent != ""
ORDER BY 1,2

-- 2. tableau_table_2 export
SELECT continent, SUM(new_deaths)
AS total_deaths_count 
FROM covid_deaths cd
WHERE continent != ""
GROUP BY continent 
ORDER BY total_deaths_count DESC

-- 3. tableau_table_3 export
SELECT location, population, MAX(total_cases)
AS highest_infection_count, MAX(total_cases/population)*100
AS percentage_population_infected
FROM covid_deaths cd
GROUP BY location, population
ORDER BY percentage_population_infected DESC 

-- 4. tableau_table_4 export
SELECT location, population, `date`, MAX(total_cases)
AS highest_infection_count, MAX(total_cases/population)*100
AS percentage_population_infected  
FROM covid_deaths cd 
GROUP BY location , population , `date` 
ORDER BY percentage_population_infected DESC 
```

## Tableau Visualization

The visualization was made using Tableau Public, you can check it out by clicking the link below.

[COVID-19 Global Analysis](https://public.tableau.com/shared/DFJWR8C63?:display_count=n&:origin=viz_share_link)
