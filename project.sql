/*
This Database contains 8 tables named 
products,productlines,orders,orderdetails,customers,payments,employees and offices.
*/

-- Table information:
/*
    Customers: customer data
    Employees: all employee information
    Offices: sales office information
    Orders: customers' sales orders
    OrderDetails: sales order line for each sales order
    Payments: customers' payment records
    Products: a list of scale model cars
    ProductLines: a list of product line categories */
	
-- Table Relations:
/* products and orderdetails tables are linked through "productCode".
   products and productlines tables are linked through "productLine".
   orders and orderdetails tables are linked through "orderNumber".
   customers and orders tables are linked through "customerNumber".
   customers and payments tables are linked through "customerNumber".
	 customers and employees tables are linked through "employeeNumber" or " salesRepEmployeeNumber".
	 employees  table  self reference the table itself for attributes "employeeNumber" and "reportsTo".
	 employees and offices tables are linked through "officeCode".*/
	  
	
  
  -- Codes

SELECT 'Customers' AS table_name,
	   (SELECT COUNT(*)
	      FROM pragma_table_info('customers')
	   ) AS number_of_attributes,
	   COUNT(*) AS number_of_rows
  FROM customers
UNION ALL
SELECT 'Employees' AS table_name,
	   (SELECT COUNT(*)
	      FROM pragma_table_info('employees')
	   ) AS number_of_attributes,
	   COUNT(*) AS number_of_rows
  FROM employees
UNION ALL
SELECT 'Offices' AS table_name,
	   (SELECT COUNT(*)
	      FROM pragma_table_info('offices')
	   ) AS number_of_attributes,
	   COUNT(*) AS number_of_rows
  FROM offices
  UNION ALL
SELECT 'Orderdetails' AS table_name,
	   (SELECT COUNT(*)
	      FROM pragma_table_info('orderdetails')
	   ) AS number_of_attributes,
	   COUNT(*) AS number_of_rows
  FROM orderdetails
UNION ALL
SELECT 'Orders' AS table_name,
	   (SELECT COUNT(*)
	      FROM pragma_table_info('orders')
	   ) AS number_of_attributes,
	   COUNT(*) AS number_of_rows
  FROM orders
UNION ALL
SELECT 'Payments' AS table_name,
	   (SELECT COUNT(*)
	      FROM pragma_table_info('payments')
	   ) AS number_of_attributes,
	   COUNT(*) AS number_of_rows
  FROM payments
UNION ALL
SELECT 'Productlines' AS table_name,
	   (SELECT COUNT(*)
	      FROM pragma_table_info('productlines')
	   ) AS number_of_attributes,
	   COUNT(*) AS number_of_rows
  FROM orders
UNION ALL
SELECT 'Products' AS table_name,
	   (SELECT COUNT(*)
	      FROM pragma_table_info('products')
	   ) AS number_of_attributes,
	   COUNT(*) AS number_of_rows
  FROM products	


-- Prioriy products for restocking

WITH
low_stock AS (
SELECT p.productCode,
       p.productName,
       p.productLine,
       ROUND(SUM(o.quantityOrdered) * 1.0 / p.quantityInStock, 2) AS restock
  FROM products AS p
 INNER JOIN orderdetails AS o
    ON p.productCode = o.productCode
 GROUP BY p.productCode
 ORDER BY restock DESC
),
product_performance AS (
SELECT productCode,
       SUM(quantityOrdered * priceEach) AS product_sales
  FROM orderdetails
 GROUP BY productCode
 ORDER BY product_sales DESC
)
SELECT l.productName,
       l.restock
  FROM low_stock AS l
 WHERE l.productCode IN (
                        SELECT productCode
                          FROM product_performance)
													  
 --Top five VIP customers 

WITH customer_profit AS
(SELECT customerNumber,
       o.orderNumber,
       quantityOrdered,
       p.productCode,
       priceEach,
       buyPrice,
       SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
   FROM orders AS o
   JOIN orderdetails AS od
     ON o.orderNumber = od.orderNumber
   JOIN products AS p
     ON p.productCode = od.productCode
  GROUP By customerNumber)
  
SELECT contactLastName,contactFirstName,city,country,cp.profit
  FROM customers AS c
  JOIN customer_profit AS cp
    ON cp.customerNumber=c.customerNumber
 ORDER BY cp.customerNumber DESC
 LIMIT 5; 

--Top five least-engaging customers 

WITH customer_profit AS
(SELECT customerNumber,
       o.orderNumber,
       quantityOrdered,
       p.productCode,
       priceEach,
       buyPrice,
       SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
   FROM orders AS o
   JOIN orderdetails AS od
     ON o.orderNumber = od.orderNumber
   JOIN products AS p
     ON p.productCode = od.productCode
  GROUP By customerNumber)
  
SELECT contactLastName,contactFirstName,city,country,cp.profit
  FROM customers AS c
  JOIN customer_profit AS cp
    ON cp.customerNumber=c.customerNumber
 ORDER BY cp.customerNumber
 LIMIT 5; 

--AVG profit genertaed by customers 
 
WITH customer_profit AS
(SELECT customerNumber,
       o.orderNumber,
       quantityOrdered,
       p.productCode,
       priceEach,
       buyPrice,
       SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
   FROM orders AS o
   JOIN orderdetails AS od
     ON o.orderNumber = od.orderNumber
   JOIN products AS p
     ON p.productCode = od.productCode
  GROUP By customerNumber)
  
SELECT AVG(profit) AS average_profit
  FROM customer_profit;

/* 
Product Line Performance:
Classic Cars: Highest performance with the lowest stock.
Highest Demand Product: 1968 Ford Mustang.

Top VIP Customers:
Countries: Spain, USA, Australia, and France.
Top Two VIP Customers: Generated a profit above $200,000.
Significantly higher compared to the next top three VIP customers.
Next Top Three VIP Customers: Profit range: $60,000 - $73,000.

Least Engaged Customers:
Countries: USA, Italy, France, and UK.
Least Generated Profit: Below $3,000.

Average Profit and Customer Acquisition:
Average Profit Per Customer: $39,039.59
*/
 
