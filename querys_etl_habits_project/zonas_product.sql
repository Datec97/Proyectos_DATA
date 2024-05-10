/************ZONA LANDING******************/
--### EXTRACCIÓN: TB_PRODUCT
--### METODO DE INSERCIÓN: TRUNCATE - INSERT
/*******************************************/

--recibamos información de la tabla origen db_cbp.dbo.tb_product
use db_cbp
select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'tb_product'

-- 2da forma de creación de estructura la tabla 

select z.* into lnd.tb_product
from(select * from db_cbp.dbo.tb_product)z

--se elimina el contenido de la tabla, mas no la estructura
truncate table lnd.tb_product

--se añade campo load_date para determinar fecha/hora de última carga
alter table lnd.tb_product
add load_date datetime


/*****************ZONA STAGING*******************/
--### SE LIMPIA Y TRASNFORMA ALGUNAS CADENAS
--### METODO DE INSERCIÓN: TRUNCATE - INSERT
/*******************************************/

/*#### tabla - PRODUCT (destino) #######*/

--recibamos información de la tabla origen db_cbp.dbo.tb_product

select * from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'tb_product'

--creación de la estructura de la tabla y vaciado
select x.* into stg.tb_product
from (select * from lnd.tb_product)x
truncate table stg.tb_product

-- cambio de data type
alter table stg.tb_product
alter column cod_item nvarchar(30)

-- Procedimiento para almacenar data de lnd a stg
create or alter procedure stg.sp_tb_product
as 
begin
	truncate table stg.tb_product
	insert into stg.tb_product
	select x.* from(
		select
			z.[Item Purchased],
			case
				when LEN(z.cod_item) = 1 then  concat('P00',z.cod_item)
				else CONCAT('P0',z.cod_item)
			end as cadenas,
			z.Category,
			z.[Purchase_price(USD)],
			z.load_date
		from lnd.tb_product z
	)x
end;
exec stg.sp_tb_product

select * from stg.tb_product

/*****************ZONA DATAMART*******************/
--### DATA APTA PARA ANALISIS
--### LIMPIEZA Y TRASNFORMACIÓN MÁS PROFUNDA
--### COPIA DIRECTA DEL STAGING
/*******************************************/

create table dtm.tb_product(
	articulo nvarchar(50) Null,
	cod_articulo nvarchar(30) Null,
	categoria nvarchar(50) Null,
	precio_compra float null,
	ultima_carga datetime null
);
	
create or alter proc dtm.sp_tb_product
as
begin
	truncate table dtm.tb_product
	
		insert into dtm.tb_product
		select 
			f.[Item Purchased],
			f.cod_item,
			case
				when f.Category = 'Clothing' THEN REPLACE(f.Category,'Clothing','Ropa')
				when f.Category = 'Footwear' THEN REPLACE(f.Category,'Footwear','Calzado')
				when f.Category = 'Accesories' THEN REPLACE(f.Category,'Accesories','Accesorios') 
				else REPLACE(f.Category,'Outerwear','Ropa de calle')
			end as Categoria,
			f.[Purchase_price(USD)],
			f.load_date as fecha_carga
		from stg.tb_product f
		
end;

exec dtm.sp_tb_product

-- ejecución de carga en stg y dtm
create or alter proc etl.load_dwh_cbp_prd
as
begin
	exec stg.sp_tb_product
	exec dtm.sp_tb_product
end

exec etl.load_dwh_cbp_prd

--corroborar
select * from dtm.tb_product
