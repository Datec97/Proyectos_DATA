/************ZONA LANDING******************/
--### EXTRACCIÓN: TB_FACT_CBP
/*******************************************/

-- Extracción de la tabla fact, 
/*Para esto debe haber una extractor condicional de tiempo
ya que al ser de una densidad mayor, no es conveniente extraer todo de forma directa,
puede ocasionar ineficiencias en el ordenador*/

-- creación de estructura la tabla customer destino
select x.* into lnd.tb_fact_purch from
(select * from db_cbp.dbo.tb_fact_purch)x

--vaciamos la tabla
truncate table lnd.tb_fact_purch
select * from lnd.tb_fact_purch

--añadimos campo de fecha_carga
alter table lnd.tb_fact_purch
add load_date datetime

--sentencia a configurar en el origen de SSIS para la extracción.
select * from db_cbp.dbo.tb_fact_purch tfp
where tfp.date between '2020/01/01' and '2020/06/30'

/*****************ZONA STAGING*******************/
--### SE LIMPIA Y TRASNFORMA ALGUNAS CADENAS
--### METODO DE INSERCIÓN: TRUNCATE - INSERT
/*******************************************/
--creación de estructura tabla
create table stg.tb_fact_purch(
	cod_compra int null,
	fecha_compra date null,
	fecha_int int null,
	id_cliente nvarchar(255) null,
	estado nvarchar(255) null,
	id_producto nvarchar(255) null,
	unidades int null,
	precio_compra float null,
	Importe_USD float null,
	tamanio char(20) null,
	color char(30) null,
	temporada nvarchar(255) null,
	tipo_envio nvarchar(255) null,
	metodo_pago nvarchar(255) null,
	puntaje_prod float null,
	suscripcion_activa nvarchar(255) null,
	descuento_aplicado nvarchar(255) null,
	cod_promocion nvarchar(255) null,
	compras_previas int null,
	ultima_carga datetime
);

alter table stg.tb_fact_purch
add load_date datetime

update stg.tb_fact_purch
set load_date = getdate()

drop table tb_fact_purch
alter table lnd.tb_fact_purch
alter column id_product nvarchar(255)

-- creación de procedimiento para pasar información de lnd a stg
-- En esa zona se irá añadiendo data (NO TRUNCATE)
create or alter procedure stg.sp_fact_cbp
as 
begin
	
	insert into stg.tb_fact_purch
	select x.* from(
		select
			p.id_purchase,
			p.date,
			p.date_int,
				case
				when LEN(p.id_customer) = 1 then  concat('C00',p.id_customer)
				else CONCAT('C0',p.id_customer)
			end as id_customer,
			p.location,
			case
				when LEN(p.id_product) = 1 then  concat('P00',p.id_product)
				else CONCAT('P0',p.id_product)
			end as id_product,
			p.units,
			p.[Purchase_price(USD)],
			p.[Purchase Amount (USD)],
			p.Size,
			p.Color,
			p.season,
			p.[Shipping Type],
			p.[Payment Method],
			p.[Review Rating],
			p.[Subscription Status],
			p.[Discount Applied],
			p.[Promo Code Used],
			p.[Previous Purchases],
			p.load_date as load_date_lnd,
			getdate() as load_date
		from lnd.tb_fact_purch p
	)x
end;
truncate table stg.tb_fact_purch
exec stg.sp_fact_cbp

--borrado controlado
delete from stg.tb_fact_purch
where year(fecha_compra) = '2023'

--corroborar
select * from stg.tb_fact_purch

/*****************ZONA DATAMART*******************/
--### DATA APTA PARA ANALISIS
--### LIMPIEZA Y TRASNFORMACIÓN MÁS PROFUNDA
--### DELETE CONTROLADO
/*******************************************/

select x.* into dtm.tb_fact_purch
	from (select * from stg.tb_fact_purch)x

--## añadimos el campo de load-date
alter table dtm.tb_fact_purch
add load_date datetime

update dtm.tb_fact_purch
set load_date = GETDATE()

create or alter proc dtm.sp_tb_fact_purch 
as 
begin
	--Nos va traer solo la ultima carga (máxima load date) de la tabla stg.
	insert into dtm.tb_fact_purch
		select * from stg.tb_fact_purch tfp
		where tfp.load_date = (select max(load_date) from stg.tb_fact_purch)

end;

exec dtm.sp_tb_fact_purch

select * from dtm.tb_fact_purch
truncate table dtm.tb_fact_purch
