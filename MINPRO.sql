-- 1. Tạo Cơ sở dữ liệu
CREATE DATABASE SalesManagement;
USE SalesManagement;

-- 2. Tạo bảng Danh mục
CREATE TABLE Category (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- 3. Tạo bảng Khách hàng
CREATE TABLE Customer (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    gender TINYINT COMMENT '1: Nam, 0: Nữ',
    birthday DATE
);

CREATE TABLE Product (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Category(id)
);

CREATE TABLE `Order` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(id)
);

CREATE TABLE Order_Detail (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(15, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES `Order`(id),
    FOREIGN KEY (product_id) REFERENCES Product(id)
);




INSERT INTO Category (name) VALUES ('Điện tử'), ('Gia dụng'), ('Thời trang'), ('Thực phẩm'), ('Văn phòng phẩm');

INSERT INTO Customer (name, email, gender, birthday) VALUES 
('Nguyễn Văn An', 'anv@gmail.com', 1, '1995-05-15'),
('Trần Thị Bình', 'binhtt@yahoo.com', 0, '2002-10-20'),
('Lê Hoàng Nam', 'namlh@hotmail.com', 1, '1988-03-12'),
('Phạm Minh Thư', 'thupm@gmail.com', 0, '2005-12-01'),
('Hoàng Anh Tuấn', 'tuanha@outlook.com', 1, '1990-07-25');

INSERT INTO Product (name, price, category_id) VALUES 
('iPhone 15 Pro', 28000000, 1),
('Laptop Dell XPS', 35000000, 1),
('Nồi cơm điện', 1500000, 2),
('Áo sơ mi nam', 350000, 3),
('Chuột không dây', 500000, 1);

INSERT INTO `Order` (customer_id, order_date) VALUES (1, '2024-01-10'), (2, '2024-01-15'), (3, '2024-02-01');

INSERT INTO Order_Detail (order_id, product_id, quantity, price) VALUES 
(1, 1, 1, 28000000),
(1, 5, 2, 500000),
(2, 3, 1, 1500000),
(3, 2, 1, 35000000);

UPDATE Product SET price = 27500000 WHERE id = 1;
UPDATE Customer SET email = 'an.nguyen@gmail.com' WHERE id = 1;

DELETE FROM Order_Detail WHERE order_id = 3 AND product_id = 2;



SELECT name, email, 
    CASE WHEN gender = 1 THEN 'Nam' ELSE 'Nữ' END AS gender_text 
FROM Customer;

SELECT name, birthday, (YEAR(NOW()) - YEAR(birthday)) AS age 
FROM Customer 
ORDER BY birthday DESC 
LIMIT 3;

SELECT o.id AS order_id, o.order_date, c.name AS customer_name 
FROM `Order` o
INNER JOIN Customer c ON o.customer_id = c.id;

SELECT cat.name, COUNT(p.id) AS product_count 
FROM Category cat
LEFT JOIN Product p ON cat.id = p.category_id
GROUP BY cat.id, cat.name
HAVING product_count >= 2;

SELECT * FROM Product 
WHERE price > (SELECT AVG(price) FROM Product);

SELECT * FROM Customer 
WHERE id NOT IN (SELECT DISTINCT customer_id FROM `Order`);

SELECT cat.name, SUM(od.quantity * od.price) AS total_revenue
FROM Category
 cat
JOIN Product p ON cat.id = p.category_id
JOIN Order_Detail od ON p.id = od.product_id
GROUP BY cat.id
HAVING total_revenue > (
    SELECT AVG(rev_table.sub_total) * 1.2 
    FROM (SELECT SUM(quantity * price) AS sub_total FROM Order_Detail GROUP BY order_id) AS rev_table
);


SELECT p1.name, p1.price, p1.category_id
FROM Product p1
WHERE p1.price = (
    SELECT MAX(p2.price) 
    FROM Product p2 
    WHERE p2.category_id = p1.category_id
);


SELECT name FROM Customer 
WHERE id IN (
    SELECT customer_id FROM `Order` 
    WHERE id IN (
        SELECT order_id FROM Order_Detail 
        WHERE product_id IN (
            SELECT id FROM Product 
            WHERE category_id = (SELECT id FROM Category WHERE name = 'Điện tử')
        )
    )
);