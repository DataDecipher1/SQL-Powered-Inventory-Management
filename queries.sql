-- Creating Warehouses Table
CREATE TABLE Warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    location VARCHAR(100),
    capacity INT
);

-- Creating Products Table
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- Creating Stock Levels Table
CREATE TABLE StockLevels (
    warehouse_id INT REFERENCES Warehouses(warehouse_id),
    product_id INT REFERENCES Products(product_id),
    quantity INT,
    last_updated DATE,
    PRIMARY KEY (warehouse_id, product_id)
);

-- Creating Suppliers Table
CREATE TABLE Suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(50),
    reliability_score DECIMAL(3,2)
);

-- Creating Orders Table
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES Suppliers(supplier_id),
    product_id INT REFERENCES Products(product_id),
    quantity INT,
    order_date DATE,
    delivery_date DATE
);

-- Creating Shipments Table
CREATE TABLE Shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Orders(order_id),
    status VARCHAR(50),
    delay_days INT
);

-- Inserting Sample Data
INSERT INTO Warehouses (location, capacity) VALUES
('New York', 5000),
('Los Angeles', 7000),
('Chicago', 6000);

INSERT INTO Products (name, category, price) VALUES
('Laptop', 'Electronics', 1200.00),
('Smartphone', 'Electronics', 800.00),
('Headphones', 'Accessories', 150.00);

INSERT INTO StockLevels (warehouse_id, product_id, quantity, last_updated) VALUES
(1, 1, 200, '2025-03-01'),
(1, 2, 150, '2025-03-01'),
(2, 3, 300, '2025-03-02');

INSERT INTO Suppliers (name, region, reliability_score) VALUES
('TechDistributors Inc.', 'East Coast', 4.8),
('WestTech Supplies', 'West Coast', 4.5);

INSERT INTO Orders (supplier_id, product_id, quantity, order_date, delivery_date) VALUES
(1, 1, 50, '2025-03-10', '2025-03-15'),
(2, 2, 100, '2025-03-12', '2025-03-18');

INSERT INTO Shipments (order_id, status, delay_days) VALUES
(1, 'Delivered', 2),
(2, 'Pending', NULL);

-- SQL Queries for Key Insights

-- 1. Stock Turnover Rate (Total orders per product)
SELECT p.name AS product_name, SUM(o.quantity) AS total_orders
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.name
ORDER BY total_orders DESC;

-- 2. Warehouse Utilization (Stock levels vs. Capacity)
SELECT w.location, SUM(s.quantity) AS total_stock, w.capacity,
       ROUND((SUM(s.quantity)::DECIMAL / w.capacity) * 100, 2) AS utilization_percentage
FROM Warehouses w
JOIN StockLevels s ON w.warehouse_id = s.warehouse_id
GROUP BY w.location, w.capacity;

-- 3. Supplier Performance Ranking (Based on reliability score)
SELECT name, region, reliability_score
FROM Suppliers
ORDER BY reliability_score DESC;

-- 4. Identifying Overstock and Understock Situations
SELECT p.name AS product_name, s.quantity, 
       CASE 
           WHEN s.quantity < 50 THEN 'Understock'
           WHEN s.quantity > 500 THEN 'Overstock'
           ELSE 'Optimal'
       END AS stock_status
FROM StockLevels s
JOIN Products p ON s.product_id = p.product_id;

-- 5. Delivery Delay Trends
SELECT s.status, AVG(s.delay_days) AS avg_delay
FROM Shipments s
WHERE s.status = 'Delivered'
GROUP BY s.status;
