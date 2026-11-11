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

