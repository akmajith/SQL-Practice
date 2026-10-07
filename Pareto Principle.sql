-- pareto principle
-- states: 80 % of outcomes, comes from 20% of caused
-- example 1: 80 % of productivity comes from 20% of employee
-- 2: 80 % of sales comes from 20% of product



CREATE TABLE sql_practice.fi_stg.orders(
	row_id float NULL,
	order_id varchar(255) NULL,
	order_date datetime NULL,
	ship_date datetime NULL,
	ship_mode varchar(255) NULL,
	customer_id varchar(255) NULL,
	customer_name varchar(255) NULL,
	segment varchar(255) NULL,
	country varchar(255) NULL,
	city varchar(255) NULL,
	state varchar(255) NULL,
	postal_code float NULL,
	region varchar(255) NULL,
	product_id varchar(255) NULL,
	category varchar(255) NULL,
	sub_category varchar(255) NULL,
	product_name varchar(255) NULL,
	sales float NULL,
	quantity float NULL,
	discount float NULL,
	profit float NULL
) ;

select * from sql_practice.fi_stg.orders; 

with cte_total_sales as
(
    select sum(sales) * 0.8 from orders

)
--select * from cte_sales;
, cte_product_sales as
(
select product_id, sum(sales) as product_sales from orders group by 1 order by 2 desc
)
,cte_final as
(
select product_id, product_sales , sum(product_sales) over (order by sum(product_sales) desc) as running_sum,
sum(product_sales) over () as total_sales, 
total_sales *0.8 as "80_p_total_sales"
--sum(product_sales) over (order by sum(product_sales) desc rows between unbounded preceding and current row) as running_sum2
from cte_product_sales
group by product_id, product_sales
)
select * from cte_final where 1=1 and running_sum <= "80_p_total_sales";

select 233/1010;