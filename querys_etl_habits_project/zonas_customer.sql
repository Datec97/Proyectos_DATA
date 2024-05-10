/************ZONA LANDING******************/
--### EXTRACCIÓN: TB_CUSTOMER
--### METODO DE INSERCIÓN: TRUNCATE - INSERT
/*******************************************/

/*#### tabla - customer (destino) #######*/

--recibamos información de la tabla origen db_cbp.dbo.tb_customer
use db_cbp
select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'tb_customer'

-- creación de estructura la tabla customer destino
create table lnd.tb_customer(
	id_customer nvarchar(30),
	name_ nvarchar(30),
	age_ int,
	gender_ char(20)
);

--se añade campo load_date para determinar fecha/hora de última carga
alter table lnd.tb_customer
add load_date datetime

--se elimina el contenido de la tabla, mas no la estructura
truncate table lnd.tb_customer



/*****************ZONA STAGING*******************/
--### SE LIMPIA Y TRASNFORMA ALGUNAS CADENAS
--### METODO DE INSERCIÓN: TRUNCATE - INSERT
/*******************************************/

/*#### tabla - CUSTOMER (destino) #######*/

--recibamos información de la tabla origen db_cbp.dbo.tb_product

select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'tb_customer'

--creación de la estructura de la tabla
select x.* into stg.tb_customer
from (select * from lnd.tb_customer)x

truncate table stg.tb_customer
select * from stg.tb_customer

-- Procedimiento para almacenar data de lnd a stg
create or alter procedure stg.sp_tb_customer
as 
begin
	truncate table stg.tb_customer
	insert into stg.tb_customer
	select x.* from(
		select
			case
				when LEN(z.id_customer) = 1 then  concat('C00',z.id_customer)
				else CONCAT('C0',z.id_customer)
			end as cadenas,
			z.name_,
			z.age_,
			z.gender_,
			z.load_date
		from lnd.tb_customer z
	)x
end;
exec stg.sp_tb_customer

select * from stg.tb_customer


/*****************ZONA DATAMART*******************/
--### DATA APTA PARA ANALISIS
--### LIMPIEZA Y TRASNFORMACIÓN MÁS PROFUNDA
--### COPIA DIRECTA DEL STAGING
/*******************************************/

create table dtm.tb_customer(
	codigo_cliente nvarchar(30) Null,
	nombre nvarchar(30) Null,
	edad int,
	genero char(20),
	ultima_carga datetime
);
	
create or alter proc dtm.sp_tb_customer
as
begin
	truncate table dtm.tb_customer
	
		insert into dtm.tb_customer
		select 
			t.id_customer as codigo_cliente,
			t.name_ as nombre,
			t.age_ as edad,
			case
				when t.gender_ = 'Male' THEN REPLACE(T.gender_,'Male','Hombre') 
				else REPLACE(T.gender_,'Female','Mujer') 
			end as genero,
			t.load_date as fecha_carga
		from stg.tb_customer t
end;

exec dtm.sp_tb_customer

-- ejecución de carga en stg y dtm
create or alter proc etl.load_dwh_cbp
as
begin
	exec stg.sp_tb_customer
	exec dtm.sp_tb_customer
end

exec etl.load_dwh_cbp

--corroborar
select * from dtm.tb_customer