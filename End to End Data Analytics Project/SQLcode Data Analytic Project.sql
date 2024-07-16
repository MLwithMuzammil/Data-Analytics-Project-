SELECT * 
FROM df_orders

-- find top 10 highest revenue generating products

 SELECT TOP 10 product_id,SUM(sale_price) as sales
 FROM df_orders
 GROUP BY product_id
 ORDER BY sales desc;

 -- find top 5 selling products in each region

 with CTE as (
 SELECT region,product_id,SUM(sale_price) as sales
 FROM df_orders
 GROUP BY region,product_id)
 SELECT *
 FROM (SELECT * 
 ,ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales desc) as rn
 FROM CTE) A
 WHERE rn<=5;


 --find month over month growth comparison for 2022  and 2023 sales  eg: jan 2022 vs jan 2023

 WITH CTE as(
 SELECT YEAR(order_date) as order_year,MONTH(order_date) as order_month,
 SUM(sale_price) as sales
 FROM df_orders
 GROUP BY YEAR(order_date),MONTH(order_date)
 --ORDER BY YEAR(order_date),MONTH(order_date)
 )
 SELECT order_month,
 SUM(case when order_year=2022 then sales else 0 end) as sales_2022,
 SUM(case when order_year=2023 then sales else 0 end) as sales_2023
 FROM CTE 
 GROUP BY order_month
 ORDER BY order_month;



 --for each category which month had highest sales

 with CTE as(
 SELECT category, FORMAT(order_date,'yyyyMM') as order_year_month,SUM(sale_price) as sales
 FROM df_orders
 GROUP BY category, FORMAT(order_date,'yyyyMM')
 --ORDER BY category, FORMAT(order_date,'yyyyMM')
 )
 SELECT * 
 FROM (SELECT *,
 row_number()over(partition by category order by sales desc) as rn 
 FROM CTE) a
 WHERE rn=1;



 -- Which sub category had highest growth by profit in 2023 compare to 2022

 WITH CTE as(
 SELECT sub_category,YEAR(order_date) as order_year,
 SUM(sale_price) as sales
 FROM df_orders
 GROUP BY sub_category,YEAR(order_date)
 --ORDER BY YEAR(order_date),MONTH(order_date)
 ),
 CTE2 as (
 SELECT sub_category,
 SUM(case when order_year=2022 then sales else 0 end) as sales_2022,
 SUM(case when order_year=2023 then sales else 0 end) as sales_2023
 FROM CTE 
 GROUP BY sub_category
 )
 SELECT	TOP 1*,
 (sales_2023-sales_2022)*100/sales_2022
 FROM CTE2
 ORDER BY (sales_2023-sales_2022)*100/sales_2022 desc;


