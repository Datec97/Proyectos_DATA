-- Elección de base de datos  -> db_csp

use db_cbp

/*
	Consulta de la tabla general, en este caso solo los 100 primeros, para no agilizar el 
	procesamiento del motor.
*/

select top(10) * from dbo.tb_fact_purch

select * from dbo.tb_fact_purch tfp
--where YEAR(tfp.date) = '2024' and location = 'Wisconsin'

select * from dbo.tb_product

select * from dbo.tb_customer


/*///////////// PREGUNTAS /////////////////// */

--¿Top 5 de los establecimientos en donde se realizó una mayor actividad de consumo en el año 2023?
select top(5)
tfp.location as region,
sum ( tfp.units ) as unidades_vendidas
from dbo.tb_fact_purch tfp
where YEAR(tfp.date) = '2023'
group by location
order by unidades_vendidas desc

--¿Cuál fue el producto más vendido en esa tienda el 2024, por genero?

select 
case 
	when tbc.Gender = 'Female' THEN 'Mujeres'
	else 'Hombres'
end as genero,
tbp.[Item Purchased] as producto,
count(tbp.[Item Purchased]) as Tot_prod_vendidos
from tb_fact_purch tbfp
LEFT join tb_product tbp on tbfp.id_product = tbp.cod_item
left join tb_customer tbc on tbfp.id_customer = tbc.[Customer ID]
group by tbp.[Item Purchased] ,
case 
	when tbc.Gender = 'Female' THEN 'Mujeres'
	else 'Hombres'
end
order by Tot_prod_vendidos desc



-- Preferencias de compra por rango de edades

select 
	CASE
		WHEN tbc.Age BETWEEN 18 and 44	THEN '18 - 44 años' 
		WHEN tbc.Age BETWEEN 45 and 70	THEN '45 - 70 años' 
 
		ELSE 'adulto mayor de 70 años'
	END AS rango_etario,
	tbp.[Item Purchased] as producto,
	SUM(tfpp.units) as tot_prod
from tb_fact_purch tfpp
LEFT join tb_product tbp on tfpp.id_product = tbp.cod_item
left join tb_customer tbc on tfpp.id_customer = tbc.[Customer ID]
group by tbp.[Item Purchased],
CASE
		WHEN tbc.Age BETWEEN 18 and 44	THEN '18 - 44 años' 
		WHEN tbc.Age BETWEEN 45 and 70	THEN '45 - 70 años' 
 
		ELSE 'adulto mayor de 70 años'
END
order by tot_prod desc

-- Preferencias de compra por producto y genero

select TOP(1)
	tbc.Gender as genero,
	tbp.[Item Purchased] as producto,
	sum ( tfp.units ) as unidades_vendidas
from dbo.tb_fact_purch tfp
left join dbo.tb_product tbp on tbp.cod_item = tfp.id_product
left join dbo.tb_customer tbc on tbc.[Customer ID] = tfp.id_customer
where tbc.Gender = 'Female' 
and tfp.units IN (select max(units) from tb_fact_purch)

group by tbc.Gender, tbp.[Item Purchased]
order by unidades_vendidas desc

-- Calificación de satisfacción del cliente por producto recibido en el 2023

select 
	tbp.[Item Purchased] as articulo,
	sum(tfp.[Review Rating]) as Calific_articulo
from tb_fact_purch tfp
left join tb_product tbp on tfp.id_product = tbp.cod_item
where year(tfp.date) = '2023'
group by tbp.[Item Purchased]
order by Calific_articulo desc


-- Método de pago más utiizado por rango de edad

SELECT 

CASE
	WHEN tbc.Age BETWEEN 18 and 44	THEN '18 - 44 años' 
	WHEN tbc.Age BETWEEN 45 and 70	THEN '45 - 70 años' 
 
	ELSE 'adulto mayor de 70 años'
END AS rango_etario,
tbp_.[Payment Method],
count(tbp_.[Payment Method]) as Metodo_pago
FROM tb_fact_purch tbp_ 
left join tb_customer tbc on tbc.[Customer ID] = tbp_.id_customer
group by tbp_.[Payment Method],
CASE
	WHEN tbc.Age BETWEEN 18 and 44	THEN '18 - 44 años' 
	WHEN tbc.Age BETWEEN 45 and 70	THEN '45 - 70 años' 
 
	ELSE 'adulto mayor de 70 años'
END
order by Metodo_pago desc



-- Tipo de envío mas solicitado por genero

select 
case 
	when tbc.Gender = 'Female' THEN 'Mujeres'
	else 'Hombres'
end as genero,
tbfp.[Shipping Type] as tipo_envio,
count(tbfp.[Shipping Type]) as Tot_tipo_envio
from tb_fact_purch tbfp
LEFT join tb_customer tbc on tbfp.id_customer = tbc.[Customer ID]
group by tbfp.[Shipping Type],
case 
	when tbc.Gender = 'Female' THEN 'Mujeres'
	else 'Hombres'
end
order by Tot_tipo_envio desc



-- Top 15 de los clientes más fieles (hasta 2022)

select 
tbcu.Name as nombre_customer,
tbf.[Subscription Status] as suscripcion_activa
from tb_fact_purch tbf 
left join tb_customer tbcu on tbf.id_customer = tbcu.[Customer ID]
where [Subscription Status] = 'yes' and tbf.date between '01/11/2022' and GETDATE()
group by tbcu.Name,tbf.[Subscription Status]


--Ingresos por temporada en 2023

	select 
		season as temporada,
		SUM([Purchase Amount (USD)]) as Ingresos
	from tb_fact_purch 
	where YEAR(date) = '2023'
	group by season
	order by Ingresos desc


-- Productos que generaron altos ingresos en el ultimo trimestre del 2023

	select 
		case 
			when tbfa.date between '01/10/2023' and '31/12/2023' then 'OCT_DIC'
			else 'OTHER_MONTH'
		end as last_quarter_2023,
	tbp.[Item Purchased] as producto,
	SUM(tbfa.[Purchase Amount (USD)]) as Monto
	from tb_fact_purch tbfa 
	left join dbo.tb_product tbp on tbp.cod_item = tbfa.id_product
	left join dbo.tb_customer tbc on tbc.[Customer ID] = tbfa.id_customer
	where tbfa.date between '01/10/2023' and '31/12/2023'
	group by tbp.[Item Purchased],
	case 
			when tbfa.date between '01/10/2023' and '31/12/2023' then 'OCT_DIC'
			else 'OTHER_MONTH'
	end
	order by Monto desc