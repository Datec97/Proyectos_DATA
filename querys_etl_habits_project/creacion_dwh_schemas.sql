/** ETL - CUSTOMER HABITS AND PREFERENCES PROJECT **/

-- Creaci�n deL DWH
create database dwh_db_cbp
use dwh_db_cbp
-- Creaci�n de los esquemas
create schema lnd
create schema stg
create schema dtm

-- creaci�n de esquema para ejecuci�n de la carga
create schema etl


/*Ejemplo, inserci�n de registro*/
insert into db_cbp.dbo.tb_customer values (51,'Patricia',35,'Female')
insert into db_cbp.dbo.tb_customer values (52,'Ezilda',32,'Female')
insert into db_cbp.dbo.tb_customer values (53,'Hilda',45,'Female')
insert into db_cbp.dbo.tb_customer values (54,'Augusto',34,'Male')
delete from db_cbp.dbo.tb_customer
where db_cbp.dbo.tb_customer.[Customer ID] in (52,53,54)

/*#### tabla - Product (destino) #######*/



