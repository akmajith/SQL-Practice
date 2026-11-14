select * from sql_practice.fi_stg.dim_customer;

select * from sql_practice.fi_stg.dim_date;

select * from SQL_PRACTICE.FI_STG.DIM_PRODUCT;

with cte_data as
(
select date_trunc(month, order_date) as order_month,
sum(gross_sales) as monthly_sales
from SQL_PRACTICE.FI_STG.FACT_SALES
group by date_trunc(month, order_date)
)
select *, lead(monthly_sales) over (order by order_month) as next_month_sales
from cte_data
order by order_month;

select date_trunc(month, order_date) as order_month,
brand,
sum(case when promotion_type = 'No Promotion' then NET_SALES else 0 END) as NON_PROMOTIONAL_SALES,
sum(case when promotion_type != 'No Promotion' then NET_SALES else 0 END) as PROMOTIONAL_SALES
from fact_sales fs 
left join dim_product dp on fs.product_id = dp.product_id
group by order_month, brand
order by order_month;


select product_id, row_number() over (partition by product_id order by product_id) from dim_product;

select product_id, count(*) from dim_product
group by product_id
having count(*) > 1;

with cte_data as
(
select product_id, row_number() over (partition by product_id order by updated_at desc) as rn
from dim_product
)
select * from cte_data where rn=1;

select coalesce(null,0);

select iff