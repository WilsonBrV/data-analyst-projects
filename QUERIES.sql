-- Inspeccionando los datos
SELECT * FROM categories;

SELECT * FROM brands;

SELECT * FROM customers LIMIT 10;
-- Analizar valores repedidos

SELECT customer_id, count(*) AS repeticiones FROM customers
GROUP BY customer_id
HAVING count(*) > 1;

-- Habrá nombres repetidos 

SELECT 
    CONCAT(first_name, ' ', last_name) AS nombre_completo,
    COUNT(*) AS repeticiones
FROM
    customers
GROUP BY CONCAT(first_name, ' ', last_name)
HAVING COUNT(*) > 1;

-- Existe un nombre repetido veremos sus rejistros

SELECT * FROM customers
WHERE concat(first_name,' ', last_name)='Justina Jenkins';
-- Son registros diferentes a falta de información colocaremos en last_name un 2 cuando customer_id=1425

SET SQL_SAFE_UPDATES = 0;

UPDATE customers 
SET last_name='Jenkins2'
WHERE customer_id=1425;
-- ¿Todos los nombres inician con Mayúsculas? 
SELECT *
FROM customers
WHERE LEFT(first_name, 1) <> BINARY UPPER(LEFT(first_name, 1));

SELECT *
FROM customers
WHERE LEFT(last_name, 1) <> BINARY UPPER(LEFT(last_name, 1));

select first_name, last_name from customers
where first_name is null or last_name is null;

SELECT * FROM customers
where right(email, 4) <> '.com';

select * from order_items;
-- registros repetidos, aquí no hay id única 

SELECT COUNT(*) AS registros
FROM (
    SELECT DISTINCT * 
    FROM order_items
) AS registros_unicos;

-- resultados 4722 registros únicos

select count(*) from order_items;

-- resultados 4722 registros únicos por ende no hay registros duplicados

-- tendrá sentido los descuentos el menor es 5% y el mayor es 20% así que si
select max(discount*100) as maximo_descuento, min(discount*100) as minimo_descuento  from order_items;

select max(quantity) as maximo_cantidad, min(quantity) as minimo_cantidad  from order_items;

select * from orders;
-- 1: Pending, 2: Processing, 3: Rejected, 4: Completed
select order_status ,count(order_status) from orders
group by order_status;
select max(shipped_date) as ultima_entrega from orders;
-- la última fecha de entrega fue el 2018-04-02


select shipped_date as fecha_entrega, order_date as fecha_pedido, required_date as fecha_requerida, order_status from orders
where order_status < 4
order by order_status asc;
-- a partir del mes de abril no se entregaron productos se analizará stock después 
-- los pedidos rechazados se han dado durante todo el periodo de referencia

select distinct store_id from orders; -- son solo 3 tiendas

select * from products;

select product_id, count(*) as repeticiones from products
group by product_id
having count(*) > 1;

select product_name, count(product_name) as repeticiones from products
group by product_name;

-- tenemos nombres de productos iguales pero de diferentes categorías
select concat(product_name,'-',category_id) as key1, count(concat(product_name,'-',category_id)) as repeticiones from products
group by concat(product_name,'-',category_id)
having count(*) > 1;

select max(list_price) as max_precio, min(list_price) as min_precio from products;

select * from staffs; -- todo en orden

select * from stores; -- todo en orden

select * from stocks;

SELECT COUNT(*) AS registros_stocks
FROM (
    SELECT DISTINCT * 
    FROM stocks
) AS registros_unicos;

SELECT COUNT(*) from stocks;

-- 939 registros únicos y 0 repetidos.

-- ######################## Analisis ############################ y obtener visualizaciones para ver en power BI.

-- 	Información sobre las ventas

select stores.store_name, categories.category_name, order_date, required_date, shipped_date, sum(order_items.quantity) AS units, order_items.list_price,
sum(order_items.list_price*(1-order_items.discount)*order_items.quantity) AS revenue, CONCAT(customers.first_name,' ',customers.last_name) as complete_costumer_name,
CONCAT(staffs.first_name,' ',staffs.last_name) as complete_staff_name, brands.brand_name,
products.product_name, discount, stores.state as state_store, customers.state as state_customer, customers.city as customer_city, stores.city as store_city
FROM categories
INNER JOIN products ON products.category_id=categories.category_id
INNER JOIN brands ON products.brand_id = brands.brand_id
INNER JOIN order_items ON products.product_id=order_items.product_id
INNER JOIN orders ON order_items.order_id=orders.order_id
INNER JOIN customers ON orders.customer_id=customers.customer_id
INNER JOIN staffs ON orders.staff_id=staffs.staff_id
INNER JOIN stores ON staffs.store_id=stores.store_id

group by stores.store_name, categories.category_name, order_date, required_date, shipped_date, list_price,
complete_costumer_name, complete_staff_name, brand_name, product_name, discount, state_store, state_customer,
store_city, customer_city
order by order_date, store_name, category_name; 


CREATE TABLE resumen_ventas AS
SELECT 
    stores.store_name, 
    categories.category_name, 
    order_date, 
    required_date, 
    shipped_date, 
    SUM(order_items.quantity) AS units, 
    order_items.list_price,
    SUM(order_items.list_price * (1 - order_items.discount) * order_items.quantity) AS revenue, 
    CONCAT(customers.first_name, ' ', customers.last_name) AS complete_costumer_name,
    CONCAT(staffs.first_name, ' ', staffs.last_name) AS complete_staff_name, 
    brands.brand_name,
    products.product_name, 
    discount, 
    stores.state AS state_store, 
    customers.state AS state_customer, 
    customers.city AS customer_city, 
    stores.city AS store_city
FROM categories
INNER JOIN products ON products.category_id = categories.category_id
INNER JOIN brands ON products.brand_id = brands.brand_id
INNER JOIN order_items ON products.product_id = order_items.product_id
INNER JOIN orders ON order_items.order_id = orders.order_id
INNER JOIN customers ON orders.customer_id = customers.customer_id
INNER JOIN staffs ON orders.staff_id = staffs.staff_id
INNER JOIN stores ON staffs.store_id = stores.store_id
GROUP BY 
    stores.store_name, 
    categories.category_name, 
    order_date, 
    required_date, 
    shipped_date, 
    list_price,
    complete_costumer_name, 
    complete_staff_name, 
    brand_name, 
    product_name, 
    discount, 
    state_store, 
    state_customer,
    store_city, 
    customer_city
ORDER BY order_date, store_name, category_name;

select * from resumen_ventas;


