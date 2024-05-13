/** ETL - CUSTOMER HABITS AND PREFERENCES PROJECT **/

-- Creación deL DWH
create database dwh_db_cbp
use dwh_db_cbp
-- Creación de los esquemas
create schema lnd
create schema stg
create schema dtm

-- creación de esquema para ejecución de la carga
create schema etl


/*Ejemplo, inserción de registro*/
insert into db_cbp.dbo.tb_customer values (51,'Patricia',35,'Female')
insert into db_cbp.dbo.tb_customer values (52,'Ezilda',32,'Female')
insert into db_cbp.dbo.tb_customer values (53,'Hilda',45,'Female')
insert into db_cbp.dbo.tb_customer values (54,'Augusto',34,'Male')
delete from db_cbp.dbo.tb_customer
where db_cbp.dbo.tb_customer.[Customer ID] in (52,53,54)

/*#### tabla - Product (destino) #######*/



