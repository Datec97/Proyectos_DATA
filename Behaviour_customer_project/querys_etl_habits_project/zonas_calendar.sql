
/************ZONA LANDING******************/
--### EXTRACCIÓN: TB_CALENDAR
--### METODO DE INSERCIÓN: TRUNCATE - INSERT
/*******************************************/

-- Comprobamos fecha máxima y minima
select min(date), max(date) from db_cbp.dbo.tb_fact_purch


-- creación de estructura de tabla
create table lnd.tb_calendar(
date_ date,
date_int int,
year_ int,
month_ int,
day_ int,
month_name varchar(50),
week_ int,
last_update datetime
)
select * from  lnd.tb_calendar

/*****************ZONA STAGING*******************/
--### SE LIMPIA Y TRASNFORMA ALGUNAS CADENAS
--### METODO DE INSERCIÓN: TRUNCATE - INSERT
/*******************************************/

/*#### tabla - CALENDAR(destino) #######*/

--creación de la estructura de la tabla 
create table stg.tb_calendar(
fecha date,
fecha_int int,
anio int,
mes int,
dia int,
nom_mes varchar(50),
semana int,
ultima_carga datetime
)

-- Procedimiento para almacenar data de lnd a stg
create or alter procedure stg.sp_tb_calendar
as 
begin
	truncate table stg.tb_calendar

	insert into stg.tb_calendar
	select * from lnd.tb_calendar
	
end;
exec stg.sp_tb_calendar

select * from stg.tb_calendar

/*****************ZONA DATAMART*******************/
--### DATA APTA PARA ANALISIS
--### LIMPIEZA Y TRASNFORMACIÓN MÁS PROFUNDA
--### COPIA DIRECTA DEL STAGING
/*******************************************/

select x.* into dtm.tb_calendar
from (select * from stg.tb_calendar) x

create or alter proc dtm.sp_tb_calendar
as
begin
	truncate table dtm.tb_calendar
	
		insert into dtm.tb_calendar
		select * from stg.tb_calendar
		
end;

exec dtm.sp_tb_calendar

-- ejecución de carga en stg y dtm
create or alter proc etl.load_dwh_cbp_cal
as
begin
	exec stg.sp_tb_calendar
	exec dtm.sp_tb_calendar
end

exec etl.load_dwh_cbp_cal

--corroborar
select * from dtm.tb_calendar