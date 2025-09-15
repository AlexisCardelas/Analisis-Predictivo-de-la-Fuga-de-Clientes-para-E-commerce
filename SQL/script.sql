-- =========================================================================
-- SCRIPT DE ANÁLISIS DE DATOS PARA E-COMMERCE
-- PROYECTO: ANÁLISIS PREDICTIVO DE LA FUGA DE CLIENTES (CHURN)
-- OBJETIVO: Preparar los datos en una única tabla para el análisis
--           predictivo en Python y la visualización en Power BI.
-- =========================================================================

-- PASO 1: Creación de la base de datos y la tabla 'orders'
-- Esto simula la tabla original de órdenes de un e-commerce.

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- =========================================================================

-- PASO 2: Creación de la tabla 'customers'
-- Contiene información del cliente (demografía, gasto, etc.).

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    gender VARCHAR(50),
    annual_income DECIMAL(10, 2),
    years_as_customer INT
);

-- =========================================================================

-- PASO 3: Creación de la tabla 'products'
-- Contiene información sobre los productos vendidos.

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(255),
    price DECIMAL(10, 2)
);

-- =========================================================================

-- PASO 4: Unión y limpieza de los datos para crear la vista 'ecommerce_dashboard_data'
-- Esta vista combina todas las tablas y realiza la limpieza y transformación necesaria.
-- Los datos se unen para crear una única fuente para el análisis.
-- Se calcula la 'fecha de la última compra' para cada cliente.

CREATE VIEW ecommerce_dashboard_data AS
SELECT
    o.order_id,
    o.customer_id,
    o.product_id,
    o.quantity,
    o.order_date,
    c.name,
    c.email,
    c.gender,
    c.annual_income,
    c.years_as_customer,
    p.product_name,
    p.category,
    p.price,
    (p.price * o.quantity) AS total_spend,
    DATEDIFF('2025-01-01', MAX(o.order_date)) AS last_purchase_days_ago,
    -- La columna Target_Churn es clave para el análisis predictivo.
    -- Un valor de 1 indica que el cliente se fugó, 0 que no.
    CASE
        WHEN DATEDIFF('2025-01-01', MAX(o.order_date)) > 90 THEN 1
        ELSE 0
    END AS target_churn
FROM
    orders o
JOIN
    customers c ON o.customer_id = c.customer_id
JOIN
    products p ON o.product_id = p.product_id
GROUP BY
    o.customer_id;

-- =========================================================================

-- PASO 5: Consulta para exportar los datos para el análisis predictivo
-- Esta consulta final es la que se usaría para exportar el archivo CSV
-- que se cargaría en Python y Power BI.

SELECT * FROM ecommerce_dashboard_data;
