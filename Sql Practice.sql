CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);

INSERT INTO Employees (employee_id, employee_name, department, salary)
VALUES
    (1, 'Amit',  'IT', 90000),
    (2, 'Neha',  'IT', 80000),
    (3, 'Raj',   'IT', 80000),
    (4, 'Priya', 'HR', 75000),
    (5, 'Karan', 'HR', 65000),
    (6, 'Meera', 'HR', 60000);

with cte_data as
(
select *,  
row_number() over (partition by department order by salary desc) as rn,
rank() over (partition by department order by salary desc) as rk,
dense_rank() over (partition by department order by salary desc) as ds
from employees
)
select * from cte_data
where (ds <= 2 or rk <=2);


CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    sales_amount DECIMAL(10,2)
);

INSERT INTO Sales VALUES
(1, 101, 'Laptop', 'Electronics', 50000),
(2, 102, 'Mobile', 'Electronics', 40000),
(3, 103, 'Tablet', 'Electronics', 30000),
(4, 104, 'Headphones', 'Electronics', 20000),
(5, 101, 'Laptop', 'Electronics', 25000),
(6, 201, 'Shirt', 'Clothing', 15000),
(7, 202, 'Jeans', 'Clothing', 12000),
(8, 203, 'Jacket', 'Clothing', 10000),
(9, 204, 'Shoes', 'Clothing', 8000),
(10, 201, 'Shirt', 'Clothing', 5000);

with cte_sales as
(
select product_id, product_name, category, sum(sales_amount) as total_sales
from sales
group by all
)
--select * from cte_sales;
, cte_final as(
select *, dense_rank() over (partition by category order by total_sales desc) as drnk,
rank() over (partition by category order by total_sales desc) as rnk 
from cte_sales
)
select * from cte_final
where drnk <= 3;

CREATE TABLE Customer_Orders (
    order_id INT,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
);

INSERT INTO Customer_Orders VALUES
(101, 1, '2026-10-01', 500),
(102, 2, '2026-10-02', 700),
(103, 1, '2026-10-03', 600),
(104, 3, '2026-10-04', 800),
(105, 2, '2026-10-05', 900),
(106, 1, '2026-10-06', 750);

with cte_order as
(
select *, row_number() over (partition by customer_id order by order_date desc) as latest_order 
from customer_orders
)
select * from cte_order
where latest_order = 1;


CREATE TABLE Test_Orders (
    order_id INT,
    order_date DATE,
    revenue DECIMAL(12,2)
);

INSERT INTO Test_Orders VALUES
(1, '2026-01-05', 10000),
(2, '2026-01-15', 15000),
(3, '2026-02-10', 20000),
(4, '2026-02-20', 10000),
(5, '2026-03-05', 25000),
(6, '2026-03-15', 15000),
(7, '2026-04-10', 30000);

with cte_total_revenue as
(
select date_trunc('month', order_date) as order_month,
sum(revenue) as total_revenue
from Test_Orders
group by date_trunc('month', order_date)
)
select * ,
lag(total_revenue) over (order by order_month asc) as previous_month_revenue,
(total_revenue - previous_month_revenue) / previous_month_revenue  as percentage_growth
from cte_total_revenue;


WITH cte_total_revenue AS (
    SELECT
        DATE_TRUNC('MONTH', order_date) AS order_month,
        SUM(revenue) AS total_revenue
    FROM test_orders
    GROUP BY DATE_TRUNC('MONTH', order_date)
),
cte_previous AS (
    SELECT *,
           LAG(total_revenue) OVER (
               ORDER BY order_month
           ) AS previous_month_revenue
    FROM cte_total_revenue
)
SELECT *,
       ROUND(
           (total_revenue - previous_month_revenue)
           / NULLIF(previous_month_revenue, 0) * 100,
           2
       ) AS percentage_growth
FROM cte_previous
ORDER BY order_month;

truncate table test_orders;

INSERT INTO Test_Orders VALUES
(1, '2026-01-05', 10000),
(2, '2026-01-15', 15000),
(3, '2026-03-10', 20000),
(4, '2026-03-20', 10000),
(5, '2026-05-05', 25000),
(6, '2026-05-15', 15000),
(7, '2026-06-10', 30000);

select * from test_orders;


WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('MONTH', order_date) AS order_month,
        SUM(revenue) AS total_revenue
    FROM test_orders
    GROUP BY 1
),
calendar_months AS (
    SELECT
        DATEADD(MONTH, SEQ4(), '2026-01-01'::DATE) AS order_month
    FROM TABLE(GENERATOR(ROWCOUNT => 6))
),
monthly_data AS (
    SELECT
        c.order_month,
        COALESCE(m.total_revenue, 0) AS total_revenue
    FROM calendar_months c
    LEFT JOIN monthly_revenue m
        ON c.order_month = m.order_month
)
SELECT
    *,
    LAG(total_revenue) OVER (
        ORDER BY order_month
    ) AS previous_month_revenue
FROM monthly_data
ORDER BY order_month;


CREATE TABLE User_Orders (
    order_id INT,
    user_id INT,
    order_date DATE,
    order_amount DECIMAL(10,2)
);

INSERT INTO User_Orders VALUES
(101, 1, '2026-10-01', 500),
(102, 1, '2026-10-03', 800),
(103, 1, '2026-10-05', 300),
(104, 1, '2026-10-05', 900),
(105, 2, '2026-10-02', 400),
(106, 2, '2026-10-04', 600),
(107, 2, '2026-10-06', 200),
(108, 3, '2026-10-03', 700),
(109, 3, '2026-10-07', 1000);

with cte_data as
(
select *, row_number() over (partition by user_id order by order_id desc, order_date desc ) as rn from user_orders
)
select * from cte_data
where rn = 2;

with cte_data as
(
select *, dense_rank() over (partition by user_id order by order_id desc, order_date asc ) as drn from user_orders
)
select * from cte_data
where drn = 2;


select *, right(employee_name, 3), substr(employee_name, -3) from employees
order by right(employee_name, 3);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);

INSERT INTO Customers VALUES (1, 'Amit');
INSERT INTO Customers VALUES (2, 'Neha');
INSERT INTO Customers VALUES (3, 'Raj');
INSERT INTO Customers VALUES (4, 'Priya');


CREATE TABLE practice_Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2)
);

INSERT INTO practice_Orders VALUES (101, 1, 500);
INSERT INTO practice_Orders VALUES (102, 2, 700);
INSERT INTO practice_Orders VALUES (103, 1, 300);
INSERT INTO practice_Orders VALUES (104, 3, 400);
INSERT INTO practice_Orders VALUES (105, 2, 200);

WITH CTE_DATA AS
(
select c.customer_id, c.customer_name, COALESCE(SUM(o.amount),0), COUNT(o.order_id) AS CNT
from customers c
left join practice_orders o on c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
)
SELECT * FROM CTE_DATA
WHERE CNT > 1;


CREATE TABLE Practice_Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    manager_id INT,
    salary DECIMAL(10,2)
);

INSERT INTO Practice_Employees VALUES (1, 'Amit', NULL, 120000);
INSERT INTO Practice_Employees VALUES (2, 'Neha', 1, 90000);
INSERT INTO Practice_Employees VALUES (3, 'Raj', 1, 130000);
INSERT INTO Practice_Employees VALUES (4, 'Priya', 2, 80000);
INSERT INTO Practice_Employees VALUES (5, 'Karan', 2, 95000);
INSERT INTO Practice_Employees VALUES (6, 'Meera', 3, 110000);

select e.employee_name, e.salary as Employee_salary, m.employee_name as manager_name, m.salary as Manager_salary from Practice_Employees e 
join practice_employees m on e.manager_id = m.employee_id
where e.salary > m.salary;

with cte_data as
(
select distinct e1.employee_id, e1.employee_name, m.employee_id as manager_id, m.employee_name as manager_name
from Practice_Employees e1
join practice_employees e2 on e1.manager_id = e2.manager_id
join practice_employees m on e1.manager_id = m.employee_id ;--and e2.manager_id = m.employee_id
)
select * from cte_data where test >1 ;


SELECT
    e1.employee_id as employee_id1,
    e2.employee_id as employee_id2,
    e1.employee_name AS employee_1,
    e2.employee_name AS employee_2,
    m.employee_name AS manager_name
FROM Practice_Employees e1
JOIN Practice_Employees e2
    ON e1.manager_id = e2.manager_id
   AND e1.employee_id < e2.employee_id
JOIN Practice_Employees m
    ON e1.manager_id = m.employee_id;

select employee_name, salary * 12 as annual_salary
from practice_employees
where annual_salary > 1000000;


CREATE OR REPLACE TABLE Test_Employees (
    Employee_ID INT,
    Employee_Name VARCHAR(100),
    Manager_ID INT
);


INSERT INTO Test_Employees
    (Employee_ID, Employee_Name, Manager_ID)
VALUES
    (101, 'Amit', NULL),
    (102, 'Rahul', 101),
    (103, 'Priya', 101),
    (104, 'Neha', 102),
    (105, 'Karan', 102);


select * from orders;


CREATE OR REPLACE TABLE Test_Orders (
    Order_ID INT,
    Customer_ID INT,
    Revenue NUMBER(10,2)
);

INSERT INTO TEST_ORDERS (Order_ID, Customer_ID, Revenue)
VALUES
    (1, 101, 500),
    (2, 102, 800),
    (3, 103, 600),
    (4, 104, 900);


CREATE OR REPLACE TABLE Test_Customers (
    Customer_ID INT,
    Customer_Name VARCHAR(100)
);

INSERT INTO Test_Customers (Customer_ID, Customer_Name)
VALUES
    (101, 'Amit'),
    (102, 'Rahul'),
    (103, 'Priya');

SELECT
    o.Order_ID,
    o.Customer_ID,
    o.Revenue,
    c.Customer_Name
FROM Test_Orders o
LEFT JOIN test_Customers c
    ON o.Customer_ID = c.Customer_ID
WHERE c.Customer_Name IS NOT NULL;


SELECT
    o.Order_ID,
    o.Customer_ID,
    o.Revenue,
    c.Customer_Name
FROM Test_Orders o
LEFT JOIN test_Customers c
    ON o.Customer_ID = c.Customer_ID
AND c.Customer_Name IS NOT NULL;



SELECT
    o.Order_ID,
    o.Customer_ID,
    o.Revenue,
    c.Customer_Name
FROM Test_Orders o
LEFT JOIN test_Customers c
    ON o.Customer_ID = c.Customer_ID
AND c.customer_id = 101;


select e.employee_name as emp_name, m.employee_name as mgr_name from test_employees e
left join test_employees m
on e.manager_id = m.employee_id
where m.employee_name is not null; 






CREATE OR REPLACE TABLE Practice_Customers (
    Customer_ID INT,
    Customer_Name VARCHAR(100),
    city VARCHAR(100)
);

INSERT INTO Practice_Customers (Customer_ID, Customer_Name, city)
VALUES
    (101, 'Amit', 'Mumbai'),
    (102, 'Rahul', 'Mumbai'),
    (103, 'Priya', 'Pune'),
    (104, 'Neha', 'Mumbai'),
    (105, 'Karan', 'Pune');

select * from practice_customers;


select pc1.customer_name, pc2.customer_name, pc1.city from practice_customers pc1
left join practice_customers pc2  
on pc1.city = pc2.city
where  pc1.customer_id > pc2.customer_id;


select pc1.customer_name, pc2.customer_name, pc1.city from practice_customers pc1
inner join practice_customers pc2  
on pc1.city = pc2.city
where  pc1.customer_id != pc2.customer_id;

CREATE OR REPLACE TABLE BI_Customers (
    Customer_ID INT,
    Customer_Name VARCHAR(100)
);

INSERT INTO BI_Customers (Customer_ID, Customer_Name)
VALUES
    (101, 'Amit'),
    (102, 'Rahul'),
    (103, 'Priya');


CREATE OR REPLACE TABLE BI_Orders (
    Order_ID INT,
    Customer_ID INT
);

INSERT INTO BI_Orders (Order_ID, Customer_ID)
VALUES
    (1, 101),
    (2, 101),
    (3, 102),
    (4, 103);


CREATE OR REPLACE TABLE BI_Order_Items (
    Order_Item_ID INT,
    Order_ID INT,
    Product VARCHAR(100),
    Quantity INT,
    Unit_Price NUMBER(10,2)
);

INSERT INTO BI_Order_Items
    (Order_Item_ID, Order_ID, Product, Quantity, Unit_Price)
VALUES
    (1, 1, 'Laptop', 1, 50000),


 SELECT * FROM BI_Customers;
SELECT * FROM BI_Orders;
SELECT * FROM BI_Order_Items;

select bc.customer_name, SUM(boi.quantity * boi.unit_price) as revenue, count(distinct boi.order_id) as order_count
from bi_customers bc
left join bi_orders bo on bc.customer_id = bo.customer_id
left join bi_order_items boi on boi.order_id = bo.order_id
group by all;


INSERT INTO BI_Customers (Customer_ID, Customer_Name)
VALUES (104, 'Neha');


select * from bi_customers bc
left join bi_orders bo on bc.customer_id = bo.customer_id
where bo.customer_id is  null;


select * from bi_customers bc
where not exists (select 1 from bi_orders bo where bc.customer_id = bo.customer_id);



select bc.customer_id, count(bo.order_id) from bi_customers bc
left join bi_orders bo on bc.customer_id = bo.customer_id
where bo.customer_id is not  null
group by bc.customer_id
having count(bo.order_id) >= 1;


select bc.customer_id, bc.customer_name 
from bi_customers bc
inner join bi_orders bo on bc.customer_id = bo.customer_id;

select * from bi_customers bc
where exists (select 1 from bi_orders bo where bc.customer_id = bo.customer_id);


SELECT
    order_id,
    customer_id,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id order by amount desc
    ) AS customer_total_sales
FROM practice_orders
order by customer_id asc;

with cte_data as
(
select customer_id, rank() over (partition by customer_id order by amount desc) as rnk 
from practice_orders
)
select * from cte_data
where rnk in  (1,2);

select * from practice_orders;


CREATE OR REPLACE TABLE practice_customers2 (
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(255)
);

INSERT INTO practice_customers2
    (customer_id, customer_name, email)
VALUES
    (101, 'Amit', 'amit@gmail.com'),
    (102, 'Rahul', 'rahul@gmail.com'),
    (103, 'Amit', 'amit@gmail.com'),
    (104, 'Priya', 'priya@gmail.com'),
    (105, 'Amit', 'amit@gmail.com');



select email, count (email) from practice_customers2
group by email
having count(email) > 1;

with cte_duplicates as
(
select *, row_number() over (partition by email order by customer_id asc) as rn from practice_customers2
)
select * from cte_duplicates where rn > 1 ;



select customer_id, sum(amount)  as sales_per_customer,
SUM(sum(amount)) over () as total_company_sales
from practice_orders
group by customer_id
order by customer_id asc;

select * from practice_orders;

with cte_data as(
select date_trunc(month, order_date) as order_month, sum(sales) sales_month 
from orders
group by order_month
)
select *, lag(sales_month) over (order by order_month asc) as prev_month_sales,
nullif(prev_month_sales, 0) as previous_month_sales,
((sales_month - previous_month_sales)/ previous_month_sales) * 100 as per_grth
from cte_data;


with cte_data as(
select date_trunc(month, order_date) as order_month, sum(sales) sales_month 
from orders
group by order_month
--order by sales_month asc
)
select *, sum(sales_month) over (order by order_month asc) from cte_data;
--order by order_month asc;

with cte_data as(
select date_trunc(month, order_date) as order_month, sum(sales) sales_month 
from orders
group by order_month
)
select *, sum(sales_month) over (order by order_month asc rows between unbounded preceding and current row) 
from cte_data
order by order_month asc;



select customer_id, order_id, order_date, sales, 
sum(sales) over (partition by order_id) as order_sales,
SUM(sales) OVER (PARTITION BY order_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as cumulative_order_sales,
--SUM(sales) OVER (PARTITION BY order_id ORDER BY order_date RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
--sum(sales) over (partition by customer_id, order_id, order_date order by order_date) as cumulative_total,
from orders
order by customer_id, order_id, order_date, sales;


select * from orders;