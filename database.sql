/* =========================================================
   1. DATABASE
========================================================= */
CREATE DATABASE CarRentalManagement;
USE CarRentalManagement;

/* =========================================================
   2. TABLES
========================================================= */

-- 1. Branches
CREATE TABLE Branches (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- 2. Employees
CREATE TABLE Employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    position VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    hire_date DATE,
    branch_id INT,
    FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
);

-- 3. Customers
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address VARCHAR(255),
    driver_license_no VARCHAR(50) UNIQUE,
    registration_date DATE DEFAULT (CURRENT_DATE)
);

-- 4. Vehicle Categories
CREATE TABLE VehicleCategories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50),
    daily_rate DECIMAL(10,2),
    description VARCHAR(255)
);

-- 5. Vehicles
CREATE TABLE Vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_number VARCHAR(20) UNIQUE,
    make VARCHAR(50),
    model VARCHAR(50),
    year YEAR,
    color VARCHAR(30),
    mileage INT DEFAULT 0,
    status ENUM('Available','Rented','Maintenance','Reserved') DEFAULT 'Available',
    category_id INT,
    branch_id INT,
    FOREIGN KEY (category_id) REFERENCES VehicleCategories(category_id),
    FOREIGN KEY (branch_id) REFERENCES Branches(branch_id)
);

-- 6. Reservations
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    vehicle_id INT,
    reservation_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    pickup_date DATE,
    return_date DATE,
    status ENUM('Pending','Confirmed','Cancelled','Completed') DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);

-- 7. Rentals
CREATE TABLE Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT,
    customer_id INT,
    vehicle_id INT,
    employee_id INT,
    rental_start DATE,
    rental_end DATE,
    actual_return_date DATE,
    total_amount DECIMAL(10,2),
    rental_status ENUM('Active','Completed','Late','Cancelled') DEFAULT 'Active',
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- 8. Payments
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2),
    payment_method ENUM('Cash','Card','Bank Transfer','Online'),
    payment_status ENUM('Pending','Paid','Failed','Refunded') DEFAULT 'Pending',
    FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id)
);

-- 9. Maintenance
CREATE TABLE Maintenance (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT,
    maintenance_date DATE,
    description VARCHAR(255),
    cost DECIMAL(10,2),
    service_provider VARCHAR(100),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);

-- 10. Insurance
CREATE TABLE Insurance (
    insurance_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT,
    provider_name VARCHAR(100),
    policy_number VARCHAR(100) UNIQUE,
    start_date DATE,
    expiry_date DATE,
    coverage_amount DECIMAL(12,2),
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);

/* =========================================================
   3. SAMPLE DATA
========================================================= */

INSERT INTO Branches(branch_name,address,city,phone,email)
VALUES
('Main Branch','Mall Road','Lahore','03001234567','main@car.com'),
('City Branch','GT Road','Gujranwala','03007654321','city@car.com');

INSERT INTO VehicleCategories(category_name,daily_rate,description)
VALUES
('Economy',2500,'Small cars'),
('SUV',5000,'Sports Utility Vehicles');

INSERT INTO Vehicles(registration_number,make,model,year,color,mileage,status,category_id,branch_id)
VALUES
('LEA-123','Toyota','Corolla',2022,'White',15000,'Available',1,1),
('GWA-456','Honda','Civic',2023,'Black',10000,'Available',1,2),
('ISB-789','Toyota','Fortuner',2021,'Grey',30000,'Available',2,1);

INSERT INTO Customers(first_name,last_name,email,phone,address,driver_license_no)
VALUES
('Ali','Khan','ali@gmail.com','03001112222','Lahore','DL123'),
('Sara','Ahmed','sara@gmail.com','03003334444','Karachi','DL456');

INSERT INTO Employees(first_name,last_name,position,phone,email,hire_date,branch_id)
VALUES
('Usman','Ali','Manager','03005556666','usman@car.com','2023-01-10',1);

/* =========================================================
   4. VIEWS
========================================================= */

-- Available Vehicles View
CREATE VIEW AvailableVehicles AS
SELECT * FROM Vehicles
WHERE status = 'Available';

-- Revenue View
CREATE VIEW MonthlyRevenue AS
SELECT
    YEAR(payment_date) AS year,
    MONTH(payment_date) AS month,
    SUM(amount) AS total_revenue
FROM Payments
WHERE payment_status='Paid'
GROUP BY YEAR(payment_date), MONTH(payment_date);

/* =========================================================
   5. STORED PROCEDURE
========================================================= */

DELIMITER //

CREATE PROCEDURE GetCustomerHistory(IN cid INT)
BEGIN
    SELECT r.rental_id, v.make, v.model, r.rental_start, r.rental_end
    FROM Rentals r
    JOIN Vehicles v ON r.vehicle_id = v.vehicle_id
    WHERE r.customer_id = cid;
END //

DELIMITER ;

/* =========================================================
   6. CORE BUSINESS QUERIES
========================================================= */

-- All customers
SELECT * FROM Customers;

-- All vehicles with category
SELECT v.vehicle_id, v.make, v.model, vc.category_name, vc.daily_rate
FROM Vehicles v
JOIN VehicleCategories vc ON v.category_id = vc.category_id;

-- Active rentals
SELECT * FROM Rentals WHERE rental_status='Active';

-- Reservations with customer
SELECT r.reservation_id, c.first_name, v.make, r.status
FROM Reservations r
JOIN Customers c ON r.customer_id=c.customer_id
JOIN Vehicles v ON r.vehicle_id=v.vehicle_id;

-- Total revenue
SELECT SUM(amount) AS total_revenue
FROM Payments
WHERE payment_status='Paid';

-- Most rented vehicles
SELECT v.make, v.model, COUNT(r.rental_id) AS total_rentals
FROM Vehicles v
JOIN Rentals r ON v.vehicle_id=r.vehicle_id
GROUP BY v.vehicle_id;

-- Overdue rentals
SELECT * FROM Rentals
WHERE rental_end < CURDATE()
AND actual_return_date IS NULL;

-- Insurance expiring soon
SELECT * FROM Insurance
WHERE expiry_date <= CURDATE() + INTERVAL 30 DAY;

/* =========================================================
   END OF PROJECT
========================================================= */
