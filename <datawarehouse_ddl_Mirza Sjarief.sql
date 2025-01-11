
--membuat table product category
 CREATE TABLE product_category(
product_category_id SERIAL PRIMARY KEY,
product_category VARCHAR (100)
 );

 -- mengisi table product category
 INSERT INTO product_category (product_category)
SELECT DISTINCT product_category
FROM products_data


-- membuat table dim product
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    product_brand VARCHAR(255),
    department VARCHAR(255),
    sku VARCHAR(255),
	product_category_id INT,
	FOREIGN KEY (product_category_id) REFERENCES product_category(product_category_id)
);
-- mengisi table dim product dan menyambungkan pada product category
INSERT INTO dim_product (product_id, product_name, product_brand, department, sku, product_category_id)
SELECT DISTINCT 
    pd.id, 
    pd.product_name, 
    pd.product_brand, 
    pd.department,
    pd.sku,
    pc.product_category_id
FROM products_data AS pd
LEFT JOIN product_category AS pc ON pc.product_category_id = pd.id 



-- membuat table dim orders
 CREATE TABLE dim_orders (
    orders_id INT PRIMARY KEY,
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    returned_at TIMESTAMP
	);
	
-- memasukan data ke dim orders
 INSERT INTO dim_orders (orders_id,shipped_at,delivered_at,returned_at)
SELECT DISTINCT id,shipped_at,delivered_at,returned_at
FROM orders_data
SELECT * FROM orders_data

--membuat table distribution center
CREATE TABLE dim_distribution_center(
distribution_center_id INT PRIMARY KEY,
name VARCHAR (100),
distribution_center_geom VARCHAR (100)
);

----mengisi table distribution center
 INSERT INTO dim_distribution_center (distribution_center_id,name,distribution_center_geom)
SELECT DISTINCT id,name,distribution_center_geom
FROM DISTRIBUTION_data

SELECT * FROM country
--membuat table country
CREATE TABLE country(
country_id SERIAL PRIMARY KEY,
country VARCHAR(50)
);
--mengisi table country
INSERT INTO country (country)
SELECT DISTINCT country
FROM customer_data

--membuat table state
CREATE TABLE state(
state_id SERIAL PRIMARY KEY,
state VARCHAR(50)
);
--memasukan data table state
SELECT DISTINCT state
FROM customer_data

--membuat table city
CREATE TABLE city(
city_id SERIAL PRIMARY KEY,
city VARCHAR(50)
);
--mengisi table
INSERT INTO city (city)
SELECT DISTINCT city
FROM customer_data

SELECT * FROM customer_data


--membuat table dim customers
 CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    age VARCHAR(50),
	street_address VARCHAR (100),
	postal_code VARCHAR(50),
	traffic_source(100),
	user_geom(100),
	country_id INT,
	state_id INT,
	city_id INT,
	FOREIGN KEY (country_id) REFERENCES country(country_id),
    FOREIGN KEY (state_id) REFERENCES state(state_id),
    FOREIGN KEY (city_id) REFERENCES city(city_id)
);

-- mengisi tabel dim costumers dan join dengan table state,country dan city
INSERT INTO dim_customers (customer_id, first_name, last_name, email, age, street_address, postal_code,traffic_source,user_geom, country_id, state_id, city_id)
SELECT DISTINCT
    cs.id, 
    cs.first_name, 
    cs.last_name, 
    cs.email, 
    cs.age,
    cs.street_address,
    cs.postal_code,
	cs.traffic_source,
	cs.user_geom,
    c.country_id,
    s.state_id,
    ct.city_id
FROM customer_data AS cs

LEFT JOIN country AS c ON cs.id = c.country_id 
LEFT JOIN state AS s ON cs.id = s.state_id  
LEFT JOIN city AS ct ON cs.id = ct.city_id ; 
 

--membuat table dim date
CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    weekday VARCHAR(10)
);

--mengisi table dimdate dengan data sold at pada inventory
INSERT INTO dim_date (full_date, year, quarter, month, day, weekday)
SELECT DISTINCT
	created_at AS DATE,
    EXTRACT(YEAR FROM created_at) AS year,
    EXTRACT(QUARTER FROM created_at) AS quarter,
    EXTRACT(MONTH FROM created_at) AS month,
    EXTRACT(DAY FROM created_at) AS day,
    TO_CHAR(created_at, 'Day') AS weekday
FROM orders_data;

-- Buat fact delivery status table
CREATE TABLE fact_delivery_status (
    delivery_id SERIAL PRIMARY KEY,
    orders_id INT,
    product_id INT,
    date_id INT,
	distribution_center_id INT,
    delivery_status Varchar (100),
    FOREIGN KEY (orders_id) REFERENCES dim_orders(orders_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (distribution_center_id) REFERENCES dim_distribution_center(distribution_center_id)
);

--isi delivery fact table
INSERT INTO fact_delivery_status (orders_id, product_id, date_id, distribution_center_id, delivery_status)
	SELECT  
        oi.order_id,
        oi.product_id,
        dd.date_id,
        dc.distribution_center_id,
        o.status
    FROM
        orders_data o
    INNER JOIN
        order_items_data oi ON o.id = oi.order_id
    INNER JOIN 
        inventory_data inv ON inv.id = oi.inventory_item_id
    INNER JOIN 
        dim_date dd ON o.created_at = dd.full_date
    INNER JOIN 
        dim_distribution_center dc ON inv.product_distribution_center_id = dc.distribution_center_id

    
    -- membuat fact table sales
CREATE TABLE fact_sales (
    sales_id SERIAL PRIMARY KEY,
    orders_id INT,
    customer_id INT,
    product_id INT,
    date_id INT,
	distribution_center_id INT,
    product_cost FLOAT,
    retail_price FLOAT,
    orders_quantity INT,
    FOREIGN KEY (orders_id) REFERENCES dim_orders(orders_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
	FOREIGN KEY (distribution_center_id) REFERENCES dim_distribution_center(distribution_center_id)
);


--mengisi fact sales table 
INSERT INTO fact_sales (orders_id, customer_id, product_id, date_id, distribution_center_id, product_cost, retail_price, orders_quantity)
    SELECT  
        o.id,
        cd.id, 
        oi.product_id,
        dd.date_id,
        dc.distribution_center_id,
        inv.cost,
        inv.product_retail_price,
        o.order_quantity
    FROM
        orders_data o
    INNER JOIN
        order_items_data oi ON oi.order_id = o.id
    INNER JOIN 
        inventory_data inv ON inv.id = oi.inventory_item_id
    INNER JOIN 
        dim_date dd ON o.created_at = dd.full_date
	INNER JOIN 
        customer_data cd ON cd.id = oi.order_id
	INNER JOIN 
        products_data pd ON pd.id = oi.product_id
    INNER JOIN 
        dim_distribution_center dc ON inv.product_distribution_center_id = dc.distribution_center_id
; 

--Membuat schema data mart
CREATE SCHEMA data_mart_sales;

--membuat table data mart fact sales
CREATE TABLE data_mart_sales.sales_summary (
    customer_id INT,
    order_date DATE,
	age VARCHAR(50),
	traffic_source VARCHAR(100),
    total_sales NUMERIC
);
--memasukan data  data mart fact sales
INSERT INTO data_mart_sales.sales_summary (customer_id, order_date, age, traffic_source, total_sales)
SELECT
    f.customer_id,
    d.full_date AS order_date,
    cs.age,
    cs.traffic_source,
    SUM(f.retail_price) AS total_sales
FROM
    fact_sales f
JOIN
    dim_customers cs ON f.customer_id = cs.customer_id
JOIN
    dim_date d ON f.date_id = d.date_id
GROUP BY
    f.customer_id, d.full_date, cs.age, cs.traffic_source;

	SELECT* FROM data_mart_sales.sales_summary  



--membuat table data mart fact dilevery status
CREATE TABLE data_mart_sales.status_summary (
    customer_id INT,
    order_date DATE,
	country VARCHAR(50),
	status VARCHAR(100),
    total_order NUMERIC
);
-- memasukan data pada data mart fact dilevery status
INSERT INTO data_mart_sales.status_summary (customer_id, order_date, country, status,total_order)
SELECT
    f.customer_id,
    d.full_date AS order_date,
    cs.country,
    fd.delivery_status,
    SUM(f.orders_quantity) AS total_order
FROM
    fact_sales f
JOIN
    dim_customers cs ON f.customer_id = cs.customer_id
JOIN
    dim_date d ON f.date_id = d.date_id
	
JOIN fact_delivery_status fd ON f.orders_id = fd.orders_id

GROUP BY
    f.customer_id, d.full_date, cs.country, fd.delivery_status;


--JAWABAN 5 W 1 H

-- top 5 produk target promosi quantity terbanyak dalam 1 tahun
SELECT p.product_name, SUM(f.orders_quantity) AS total_quantity
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_date d ON f.date_id = d.date_id
WHERE d.full_date >= CURRENT_DATE - INTERVAL '1 Year'
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 5;

-- Top 10 berdasarkan segmen umur dan traffic source
SELECT 
    customer_id, 
    age,
    traffic_source, 
    SUM(total_sales) AS total_revenue
FROM 
    data_mart_sales.sales_summary
GROUP BY 
    customer_id, age, traffic_source
ORDER BY 
    total_revenue DESC
LIMIT 10;

-- Trend penjual per bulan
SELECT DATE_TRUNC('month', order_date) AS month, traffic_source, SUM(total_sales) AS total_revenue
FROM data_mart_sales.sales_summary
GROUP BY DATE_TRUNC('month', order_date), traffic_source
ORDER BY month, traffic_source;

--Negara dengan total revenue terendah untuk target pemasaran
SELECT 
	ds.country, 
    SUM(f.retail_price) AS total_revenue
FROM 
    fact_sales f
JOIN 
    dim_customers ds ON f.customer_id = ds.customer_id
GROUP BY 
	ds.country 
ORDER BY 
    total_revenue ASC;

-- Negara dengan total cancel status terbanyak
SELECT 
    country,
    COUNT(status='cancelled') AS total_cancelled
FROM 
    data_mart_sales.status_summary
GROUP BY 
    country
ORDER BY 
    total_cancelled DESC
LIMIT 5;

-- Negara dengan target distribution center baru
SELECT * FROM  data_mart_sales.status_summary

SELECT 
	country, 
    SUM(total_order) AS total_order
FROM 
    data_mart_sales.status_summary
GROUP BY 
    country
ORDER BY 
    total_order DESC
LIMIT 5;
