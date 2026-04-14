

-- GROUP-19 SUPERMARKET --

-- CUSTOMER STORAGE TABLE
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address VARCHAR(100)
);

-- CUSTOMER TRACKER FOR RECORD CHANGESS ON THE TABLE LIST
CREATE TABLE Customer_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    action VARCHAR(10),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    name VARCHAR(100),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address VARCHAR(100)
);

-- EMPLOYEE STORAGE TABLE
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    workTitle VARCHAR(50),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address VARCHAR(100)
);

-- EMPLOYEE TRACKER FOR RECORD CHANGES ON THE TABLE
CREATE TABLE Employee_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    action VARCHAR(10),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    name VARCHAR(100),
    workrole VARCHAR(50),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address VARCHAR(100)
);

-- SUPPLIERS STORAGE TABLE
CREATE TABLE Suppliers (
    suppliers_id INT PRIMARY KEY AUTO_INCREMENT,
    Institution VARCHAR(100),
    products VARCHAR(100),
    DelivererName VARCHAR(100),
    Phone VARCHAR(20),
    DeliveryTime VARCHAR(50)
);

-- SUPPLIERS TRACKER FOR RECORD CHANGES ON THE TABLE
CREATE TABLE Suppliers_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    suppliers_id INT,
    action VARCHAR(10),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Institution VARCHAR(100),
    products VARCHAR(100),
    DelivererName VARCHAR(100),
    Phone VARCHAR(20),
    DeliveryTime VARCHAR(50)
);

-- PRODUCTS STORAGE TABLE
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    Expiring  VARCHAR(20),
    suppliers_id INT,
    FOREIGN KEY (suppliers_id) REFERENCES Suppliers(suppliers_id)
);

-- PRODUCTS TRACKER FOR RECORD CHANGES IN THE TABLE
CREATE TABLE Products_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    action VARCHAR(10),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    name VARCHAR(100),
    Price DECIMAL(10,2),
    category VARCHAR(50),
    Expiring  VARCHAR(20),
    suppliers_id INT
);

-- TRANSACTIONS STORAGE TABLE
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    employee_id INT,
    TransactionDate VARCHAR(20),
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

-- TRANSACTIONS TRACKER FOR RECORD CHANGES ON THE TABLE
CREATE TABLE Transactions_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT,
    action VARCHAR(10),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    customer_id INT,
    employee_id INT,
    TransactionDate DATE,
    TotalAmount DECIMAL(10,2)
);

-- TRANSACTION DETAILS STORAGE TABLE
CREATE TABLE TransactionDetails (
    transaction_id INT,
    product_id INT,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- TRANSACTION DETAILS CHANGES TABLE
CREATE TABLE TransactionDetails_Audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT,
    product_id INT,
    action VARCHAR(10),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantity INT,
    subtotal DECIMAL(10,2)
);

DELIMITER //

-- TRIGGER: SUBTOTAL = quantity * PRODUCT PRICE (Calculating automatically)
CREATE TRIGGER calc_subtotal
BEFORE INSERT ON TransactionDetails
FOR EACH ROW                
BEGIN
    DECLARE unit_price DECIMAL(10,2);
    SELECT Price INTO unit_price FROM Products WHERE product_id = NEW.product_id;
    SET NEW.subtotal = NEW.quantity * unit_price;
END
//

SELECT TransactionDate, SUM(TotalAmount) AS DailySales
FROM Transactions
GROUP BY TransactionDate;
//

-- UPDATING THE INSERTED DATA ON THE TRANSACTION
CREATE TRIGGER update_total_after_insert 
AFTER INSERT ON TransactionDetails
FOR EACH ROW
BEGIN  
    UPDATE Transactions
    SET TotalAmount = (
        SELECT IFNULL(SUM(subtotal), 0)
        FROM TransactionDetails
        WHERE transaction_id = NEW.transaction_id
    )
    WHERE transaction_id = NEW.transaction_id;
END
//

-- RECALCULATING THE TOTALAMOUNT IN TRANSACTIONS BY SUMMING SUBTOTALS OF ALL RELATED ITEMS
CREATE TRIGGER update_total_after_update
AFTER UPDATE ON TransactionDetails
FOR EACH ROW
BEGIN
    UPDATE Transactions   
    SET TotalAmount = (
        SELECT IFNULL(SUM(subtotal), 0)
        FROM TransactionDetails
        WHERE transaction_id = NEW.transaction_id
    )
    WHERE transaction_id = NEW.transaction_id;
END
//

-- SHOWING THE UPDATE THAT THE TRASACTION HAS BEEN DELETED
CREATE TRIGGER update_total_after_delete
AFTER DELETE ON TransactionDetails
FOR EACH ROW
BEGIN
    UPDATE Transactions
    SET TotalAmount = (
        SELECT IFNULL(SUM(subtotal), 0)
        FROM TransactionDetails
        WHERE transaction_id = OLD.transaction_id
    )
    WHERE transaction_id = OLD.transaction_id;
END
//

-- After all CREATE TABLE and CREATE TRIGGER STATEMENT


SELECT * FROM Customer;
SELECT * FROM Customer_Audit;

SELECT * FROM Employee;
SELECT * FROM Employee_Audit;

SELECT * FROM Suppliers;
SELECT * FROM Suppliers_Audit;

SELECT * FROM Products;
SELECT * FROM Products_Audit;

SELECT * FROM Transactions;
SELECT * FROM Transactions_Audit;

SELECT * FROM TransactionDetails;
SELECT * FROM TransactionDetails_Audit;
// 


-- AUDIT TRIGGERS: MONITORING THE AUTOMATIC ACTIONS

-- CUSTOMER
CREATE TRIGGER customer_after_insert
AFTER INSERT ON Customer
FOR EACH ROW
BEGIN
    INSERT INTO Customer_Audit (customer_id, action, action_time, name, Phone, Email, Address)
    VALUES (NEW.customer_id, 'INSERT', NOW(), NEW.name, NEW.Phone, NEW.Email, NEW.Address);
END
//

CREATE TRIGGER customer_after_update  
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN
    INSERT INTO Customer_Audit (customer_id, action, action_time, name, Phone, Email, Address)
    VALUES (NEW.customer_id, 'UPDATE', NOW(), NEW.name, NEW.Phone, NEW.Email, NEW.Address);
END
//

CREATE TRIGGER customer_after_delete  
AFTER DELETE ON Customer
FOR EACH ROW
BEGIN
    INSERT INTO Customer_Audit (customer_id, action, action_time, name, Phone, Email, Address)
    VALUES (OLD.customer_id, 'DELETE', NOW(), OLD.name, OLD.Phone, OLD.Email, OLD.Address);
END
//

-- EMPLOYEE
CREATE TRIGGER employee_after_insert  
AFTER INSERT ON Employee
FOR EACH ROW
BEGIN
    INSERT INTO Employee_Audit (employee_id, action, action_time, name, workTitle, Phone, Email, Address)
    VALUES (NEW.employee_id, 'INSERT', NOW(), NEW.name, NEW.workTitle, NEW.Phone, NEW.Email, NEW.Address);
END
//

CREATE TRIGGER employee_after_update  
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    INSERT INTO Employee_Audit (employee_id, action, action_time, name, workTitle, Phone, Email, Address)
    VALUES (NEW.employee_id, 'UPDATE', NOW(), NEW.name, NEW.workTitle, NEW.Phone, NEW.Email, NEW.Address);
END
//

CREATE TRIGGER employee_after_delete   
AFTER DELETE ON Employee
FOR EACH ROW
BEGIN
    INSERT INTO Employee_Audit (employee_id, action, action_time, name, workTitle, Phone, Email, Address)
    VALUES (OLD.employee_id, 'DELETE', NOW(), OLD.name, OLD.workTitle, OLD.Phone, OLD.Email, OLD.Address);
END
//

-- SUPPLIERS
CREATE TRIGGER suppliers_after_insert      
AFTER INSERT ON Suppliers
FOR EACH ROW
BEGIN
    INSERT INTO Suppliers_Audit (suppliers_id, action, action_time, Institution, products, DelivererName, Phone, DeliveryTime)
    VALUES (NEW.suppliers_id, 'INSERT', NOW(), NEW.Institution, NEW.products, NEW.DelivererName, NEW.Phone, NEW.DeliveryTime);
END
//

CREATE TRIGGER suppliers_after_update   
AFTER UPDATE ON Suppliers
FOR EACH ROW
BEGIN
    INSERT INTO Suppliers_Audit (suppliers_id, action, action_time, Institution, products, DelivererName, Phone, DeliveryTime)
    VALUES (NEW.suppliers_id, 'UPDATE', NOW(), NEW.Institution, NEW.products, NEW.DelivererName, NEW.Phone, NEW.DeliveryTime);
END
//

CREATE TRIGGER suppliers_after_delete     
AFTER DELETE ON Suppliers
FOR EACH ROW
BEGIN
    INSERT INTO Suppliers_Audit (suppliers_id, action, action_time, Institution, products, DelivererName, Phone, DeliveryTime)
    VALUES (OLD.suppliers_id, 'DELETE', NOW(), OLD.Institution, OLD.products, OLD.DelivererName, OLD.Phone, OLD.DeliveryTime);
END
//

-- PRODUCTS
CREATE TRIGGER products_after_insert  
AFTER INSERT ON Products
FOR EACH ROW
BEGIN
    INSERT INTO Products_Audit (product_id, action, action_time, name, Price, category, Expiring, suppliers_id)
    VALUES (NEW.product_id, 'INSERT', NOW(), NEW.name, NEW.Price, NEW.category, NEW.Expiring, NEW.suppliers_id);
END
//

-- SHOWING THE PRODUCTS AFTER UPDATE
CREATE TRIGGER products_after_update  
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO Products_Audit (product_id, action, action_time, name, Price, category, Expiring, suppliers_id)
    VALUES (NEW.product_id, 'UPDATE', NOW(), NEW.name, NEW.Price, NEW.category, NEW.Expiring, NEW.suppliers_id);
END
//

-- SHOW THAT TRULY THE PRODUCTS HAS BEEN DELETED
CREATE TRIGGER products_after_delete    
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO Products_Audit (product_id, action, action_time, name, Price, category, Expiring, suppliers_id)
    VALUES (OLD.product_id, 'DELETE', NOW(), OLD.name, OLD.Price, OLD.category, OLD.Expiring, OLD.suppliers_id);
END
//



DELIMITER ;





