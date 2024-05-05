use db_covid_data

select * from dbo.tb_vaccinations
select * from dbo.tb_covid_deaths

select  cd.continent, cd.date, cd.hosp_patients
from db_covid_data..tb_covid_deaths cd
order by 1,2


-- Select data (fields) what we are going to be using

select cd1.continent,cd1.location, cd1.date,  cd1.total_cases, cd1.total_deaths, cd1.population
from db_covid_data..tb_covid_deaths cd1
order by 3


-- Show likelihood of dying if you contract covid in your country. (probabilidad de morir si se contrae COVID en tu país)

select tcd.continent, tcd.location, tcd.date, tcd.total_cases, tcd.total_deaths, tcd.population ,(tcd.total_cases/tcd.population)*100 as likelihood_of_dying
from db_covid_data..tb_covid_deaths tcd
where tcd.location = 'Peru'
order by tcd.date


/*
select cd2.continent, cd2.location, cd2.date, cd2.total_cases, cd2. total_deaths, (cd2.total_deaths/cd2.total_cases) * 100 as probably_death
 from dbo.tb_covid_deaths cd2
where cd2.location like '%Afganistan%'
order by 3 asc*/


-- change datatype to column total_cases,
alter table tb_covid_deaths 
--alter column total_cases float
--alter column total_cases real
alter column total_cases decimal(12,2)


-- change datatype to column total_deaths, 
alter table tb_covid_deaths 
alter column total_deaths decimal(10,2)

-- What percentage of population got covid

Select 
location, date, population, total_cases, (total_cases / population)*100 as percentage_pop
from tb_covid_deaths 
order by 1, 2 asc

/*--change  type date population
alter table tb_covid_deaths
alter column population float*/


-- cantidad de muertos en el perú en el 2022(acumulado)

select continent, location, total_deaths
from tb_covid_deaths 
where location = 'Peru' and date = '2022-12-31'
group by continent, location

-- change data type of "total_deaths" column
alter table tb_covid_deaths
alter column total_deaths float

--change data type of "date" column
alter table tb_covid_deaths
alter column date date

--########################################
-- Cantidad maxima de muertes por continente

select max(x.HighestDeathCount) 
from(
select 
continent, max(total_deaths) as HighestDeathCount
from dbo.tb_covid_deaths
where continent is not null
group by continent
--order by max(total_deaths) desc   -->> OJO: No funciona con las subconsultas
--ó
--order by HighestDeathCount desc	-->> OJO: No funciona con las subconsultas
)x

--Continente con la cantidad maxima de muertes  
select continent, total_deaths 
from tb_covid_deaths
where total_deaths 
IN( 
select max(total_deaths) 
from tb_covid_deaths
) 


-- Looking at countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionRate, max(total_cases/population)*100 PercentagePopulationInfected	
from tb_covid_deaths
--where location = 'Cayman Islands'
group by location, population
order by PercentagePopulationInfected desc



select location, max(total_cases)
from tb_covid_deaths 
where total_cases IN (
select max(total_cases)
from tb_covid_deaths
)
group by location

alter table tb_covid_deaths 
alter column total_cases float


-- Looking at global numbers

/*
		select tbcd.date, SUM(tbcd.), SUM(CAST(tb_covid_deaths.new_deaths as int))
		SUM(cast(new_Deaths as int))/sum(New_cases) *100 as DeathPercent
		from tb_covid tbcd
		where continent is not null
		group by date
		order by 1,2
		*/

		select 
		tbcd.date, 
		sum(tbcd.new_deaths) as nuevas_muertes_tot,
		sum(cast(tbcd.new_cases as int)) as nuevos_casos_tot,
		(sum(cast(tbcd.new_deaths as int))/sum(cast(tbcd.new_cases as int)))* 100 as DeathPercent
		from tb_covid_deaths tbcd
		group by tbcd.new_deaths, tbcd.date
		order by 1,2


		-- ¿total de casos y muertes por continentes?
		select continent, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 as PercentageDeaths
		from tb_covid_deaths
		where continent is not null
		group by continent
		order by total_deaths desc
		
		-- ¿total de casos y muertes a nivel global? (check)
		select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 as PercentageDeaths
		from tb_covid_deaths
		where continent is not null
		order by total_cases, total_deaths desc

		-- ¿Total de muertes registrados por país? (check)
		select
		tcd.location, SUM(cast(tcd.new_deaths as int)) as TotalDeathCount, MAX(tcd.date)
		from dbo.tb_covid_deaths tcd
		where tcd.continent is not null 
		and tcd.location not in ('European Union','World','International')
		group by tcd.location
		order by TotalDeathCount desc


		-- ¿continente con mayor cantidad de muertes?
		select continent, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 as PercentageDeaths
		from tb_covid_deaths
		where continent is not null
		group by continent
		order by total_deaths desc
		
		-- ¿Cantidad de casos en Perú?
		select location ,sum(cast(new_cases as int)) 
		from tb_covid_deaths
		where location= 'Peru'
		group by location


		-- población por año de diferentes paises
		select distinct location, population
		from tb_covid_deaths
		where YEAR(date) = '2024' and location = 'Ecuador'


		-- Total de Muertes por pais en la actualidad
		select 
		distinct continent, location, date, total_deaths 
		from tb_covid_deaths 
		where date = '2024-04-07' and continent = 'Europe'
		order by total_deaths asc



-- ########## USING TABLE VACCINATION ####################

/*		select *
		from tb_covid_deaths tcd
		left join tb_vaccinations tbv on */

		select * from tb_covid_deaths 
		select * from tb_vaccinations 

		--¿Cantidad de personas en el mundo que han sido vacunadas?

		select tcd.continent, tcd.location, tcd.date, tcd.population, tbv.total_vaccinations
		from tb_covid_deaths tcd
		left join tb_vaccinations tbv on 
			tbv.location = tcd.location
			and tbv.date = tcd.date
			where tcd.date = '2023-12-31' and tcd.continent = 'South America'
			order by 1,2

		-- Sumemos la cantidad de nuevas vacunaciones por pais.

		select tcd.continent, tcd.location, tcd.date, tcd.population, tbv.new_vaccinations, 
		sum(new_vaccinations) over (partition by tcd.location order by tcd.date, tcd.location) as tot_newVac
		from tb_covid_deaths tcd
		left join tb_vaccinations tbv on 
			tbv.location = tcd.location
			and tbv.date = tcd.date
			where tcd.continent is not null
			order by 2, 3

		-- Sumemos la cantidad de nuevas vacunaciones por continente
		select continent, sum(tbvv.new_vaccinations) as tot_newVac
		from tb_vaccinations tbvv
		where continent is not null
		group by continent
		order by tot_newVac desc
		

		alter table dbo.tb_vaccinations
		alter column new_vaccinations float

		
		alter table dbo.tb_vaccinations
		alter column date date

-- USO DE CTE "Expresión de tablas comunes" , me permite hacer legibles mis consultas, 
--> la voy a usar cuando quiera hacer referencia a funciones de SQL(como si fuera una tabla de la BD), desde mi consulta principal.

		with PopvsVac (continent, location, date, population, new_vaccinations, tot_newVac) as
		--with PopvsVac as
		(
		select tcd.continent, tcd.location, tcd.date, tcd.population, tbv.new_vaccinations, 
		sum(new_vaccinations) over (partition by tcd.location order by tcd.date, tcd.location) as tot_newVac
		from tb_covid_deaths tcd
		left join tb_vaccinations tbv on 
			tbv.location = tcd.location
			and tbv.date = tcd.date
			where tcd.continent is not null
			--order by 2, 3 -> no es valido para un CTE
		)
		
		-- CONSULTA PRINCIPAL DEL CTE
		select *, (tot_newVac/population)* 100 as Pop_Vaccinated
		from PopvsVac


		/* Reto: Crear tabla temporal #PercentPopulationVaccinated 
		donde insertar toda la sábana de la consulta anterior
		. Hacerlo bajo un storage procedure
		*/

		create table #PercentPopulationVaccinated(

			continent nvarchar(255),
			location_ nvarchar(255),
			date_ date,
			population_ float,
			new_Vaccination float,
			tot_newVac float
		)

		create or alter procedure sp_load_tb_PercentPopulationVaccinated
		as 
		begin
			truncate table #PercentPopulationVaccinated

			insert into #PercentPopulationVaccinated
			select tcd.continent, tcd.location, tcd.date, tcd.population, tbv.new_vaccinations, 
			sum(new_vaccinations) over (partition by tcd.location order by tcd.date, tcd.location) as tot_newVac	
			from tb_covid_deaths tcd
			left join tb_vaccinations tbv on 
			tbv.location = tcd.location
			and tbv.date = tcd.date
			where tcd.continent is not null
			--order by 2, 3 -> no es valido para un CTE

			select *, (tot_newVac/population_)*100 as Pop_Vaccinated
			from #PercentPopulationVaccinated

		end
		

		--exec
		exec dbo.sp_load_tb_PercentPopulationVaccinated

		select * from #PercentPopulationVaccinated

		-- Reto 2: Creacion de vista

		create or alter view vw_PopulationVaccinated as
		select tcd.continent, tcd.location, tcd.date, tcd.population, tbv.new_vaccinations, 
			sum(new_vaccinations) over (partition by tcd.location order by tcd.date, tcd.location) as tot_newVac	
			from tb_covid_deaths tcd
			left join tb_vaccinations tbv on 
			tbv.location = tcd.location
			and tbv.date = tcd.date
			where tcd.continent is not null

			select * from vw_PopulationVaccinated