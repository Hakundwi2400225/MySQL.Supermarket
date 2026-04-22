
SET time_zone = '+02:00';

-- GROUP-19 SUPERMARKET --

-- CUSTOMER STORAGE TABLE
CREATE TABLE Customer (
    customerID INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) unique,
    Email VARCHAR(100) unique,
    Address VARCHAR(100)
);

-- CUSTOMER TRACKER FOR RECORD CHANGES ON THE TABLE LIST
CREATE TABLE Customer_Audit (
    auditID INT PRIMARY KEY AUTO_INCREMENT,
    customerID INT,
    action VARCHAR(10),
    action_time TIMESTAMP,
    name VARCHAR(100),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address VARCHAR(100)
);

-- EMPLOYEE STORAGE TABLE
CREATE TABLE Employee (
    employeeID INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    workTitle VARCHAR(50),
    Phone VARCHAR(20) unique,
    Email VARCHAR(100) unique,
    Address VARCHAR(100)
);

-- EMPLOYEE TRACKER FOR RECORD CHANGES ON THE TABLE
CREATE TABLE Employee_Audit (
    auditID INT PRIMARY KEY AUTO_INCREMENT,
    employeeID INT,
    action VARCHAR(10),
    action_time TIMESTAMP,
    name VARCHAR(100),
    workTitle VARCHAR(50),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address VARCHAR(100)
);

-- SUPPLIERS STORAGE TABLE
CREATE TABLE Suppliers (
    suppliersID INT PRIMARY KEY AUTO_INCREMENT,
    Institution VARCHAR(100),
    products VARCHAR(100),
    DelivererName VARCHAR(100),
    Phone VARCHAR(20) unique,
    DeliveryTime VARCHAR(50)
);

-- SUPPLIERS TRACKER FOR RECORD CHANGES ON THE TABLE
CREATE TABLE Suppliers_Audit (
    auditID INT PRIMARY KEY AUTO_INCREMENT,
    suppliersID INT,
    action VARCHAR(10),
    action_time TIMESTAMP,
    Institution VARCHAR(100),
    products VARCHAR(100),
    DelivererName VARCHAR(100),
    Phone VARCHAR(20),
    DeliveryTime VARCHAR(50)
);

-- PRODUCTS STORAGE TABLE
CREATE TABLE Products (
    productID INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    Expiring  VARCHAR(20),
    suppliersID INT,
    FOREIGN KEY (suppliersID) REFERENCES Suppliers(suppliersID)
);

-- PRODUCTS TRACKER FOR RECORD CHANGES IN THE TABLE
CREATE TABLE Products_Audit (
    auditID INT PRIMARY KEY AUTO_INCREMENT,
    productID INT,
    action VARCHAR(10),
    action_time TIMESTAMP,
    name VARCHAR(100),
    Price DECIMAL(10,2),
    category VARCHAR(50),
    Expiring  VARCHAR(20),
    suppliersID INT
);

-- TRANSACTIONS STORAGE TABLE
CREATE TABLE Transactions (
    transactionID INT PRIMARY KEY AUTO_INCREMENT,
    customerID INT,
    employeeID INT,
    TransactionDate VARCHAR(20),
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (customerID) REFERENCES Customer(customerID) ON DELETE CASCADE,
    FOREIGN KEY (employeeID) REFERENCES Employee(employeeID)
);

-- TRANSACTIONS TRACKER FOR RECORD CHANGES ON THE TABLE
CREATE TABLE Transactions_Audit (
    auditID INT PRIMARY KEY AUTO_INCREMENT,
    transactionID INT,
    action VARCHAR(10),
    action_time TIMESTAMP,
    customerID INT,
    employeeID INT,
    TransactionDate DATE,
    TotalAmount DECIMAL(10,2)
);

-- TRANSACTION DETAILS STORAGE TABLE
CREATE TABLE TransactionDetails (
    transactionID INT,
    productID INT,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2),
    PRIMARY KEY (transactionID, productID),
    FOREIGN KEY (transactionID) REFERENCES Transactions(transactionID),
    FOREIGN KEY (productID) REFERENCES Products(productID)
);

-- TRANSACTION DETAILS CHANGES TABLE
CREATE TABLE TransactionDetails_Audit (
    auditID INT PRIMARY KEY AUTO_INCREMENT,
    transactionID INT,
    productID INT,
    action VARCHAR(10),
    action_time TIMESTAMP,
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
    SELECT Price INTO unit_price FROM Products WHERE productID = NEW.productID;
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
        WHERE transactionID = NEW.transactionID
    )
    WHERE transactionID = NEW.transactionID;
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
        WHERE transactionID = NEW.transactionID
    )
    WHERE transactionID = NEW.transactionID;
END
//

-- SHOWING THE UPDATE THAT THE TRANASCTION HAS BEEN DELETED
CREATE TRIGGER update_total_after_delete
AFTER DELETE ON TransactionDetails
FOR EACH ROW
BEGIN
    UPDATE Transactions
    SET TotalAmount = (
        SELECT IFNULL(SUM(subtotal), 0)
        FROM TransactionDetails
        WHERE transactionID = OLD.transactionID
    )
    WHERE transactionID = OLD.transactionID;
END
//

-- AUDIT TRIGGERS: MONITORING THE AUTOMATIC ACTIONS

-- CUSTOMER
CREATE TRIGGER customer_after_insert
AFTER INSERT ON Customer
FOR EACH ROW
BEGIN
    INSERT INTO Customer_Audit (customerID, action, action_time, name, Phone, Email, Address)
    VALUES (NEW.customerID, 'INSERT', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.name, NEW.Phone, NEW.Email, NEW.Address);
END
//

CREATE TRIGGER customer_after_update  
AFTER UPDATE ON Customer
FOR EACH ROW
BEGIN
    INSERT INTO Customer_Audit (customerID, action, action_time, name, Phone, Email, Address)
    VALUES (NEW.customerID, 'UPDATE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.name, NEW.Phone, NEW.Email, NEW.Address);
END
//

CREATE TRIGGER customer_after_delete  
AFTER DELETE ON Customer
FOR EACH ROW
BEGIN
    INSERT INTO Customer_Audit (customerID, action, action_time, name, Phone, Email, Address)
    VALUES (OLD.customerID, 'DELETE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), OLD.name, OLD.Phone, OLD.Email, OLD.Address);
END
//

-- EMPLOYEE
CREATE TRIGGER employee_after_insert  
AFTER INSERT ON Employee
FOR EACH ROW
BEGIN
    INSERT INTO Employee_Audit (employeeID, action, action_time, name, workTitle, Phone, Email, Address)
    VALUES (NEW.employeeID, 'INSERT', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.name, NEW.workTitle, NEW.Phone, NEW.Email, NEW.Address);
END
//

CREATE TRIGGER employee_after_update  
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    INSERT INTO Employee_Audit (employeeID, action, action_time, name, workTitle, Phone, Email, Address)
    VALUES (NEW.employeeID, 'UPDATE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.name, NEW.workTitle, NEW.Phone, NEW.Email, NEW.Address);
END
//

CREATE TRIGGER employee_after_delete   
AFTER DELETE ON Employee
FOR EACH ROW
BEGIN
    INSERT INTO Employee_Audit (employeeID, action, action_time, name, workTitle, Phone, Email, Address)
    VALUES (OLD.employeeID, 'DELETE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), OLD.name, OLD.workTitle, OLD.Phone, OLD.Email, OLD.Address);
END
//

-- SUPPLIERS
CREATE TRIGGER suppliers_after_insert      
AFTER INSERT ON Suppliers
FOR EACH ROW
BEGIN
    INSERT INTO Suppliers_Audit (suppliersID, action, action_time, Institution, products, DelivererName, Phone, DeliveryTime)
    VALUES (NEW.suppliersID, 'INSERT', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.Institution, NEW.products, NEW.DelivererName, NEW.Phone, NEW.DeliveryTime);
END
//

CREATE TRIGGER suppliers_after_update   
AFTER UPDATE ON Suppliers
FOR EACH ROW
BEGIN
    INSERT INTO Suppliers_Audit (suppliersID, action, action_time, Institution, products, DelivererName, Phone, DeliveryTime)
    VALUES (NEW.suppliersID, 'UPDATE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.Institution, NEW.products, NEW.DelivererName, NEW.Phone, NEW.DeliveryTime);
END
//

CREATE TRIGGER suppliers_after_delete     
AFTER DELETE ON Suppliers
FOR EACH ROW
BEGIN
    INSERT INTO Suppliers_Audit (suppliersID, action, action_time, Institution, products, DelivererName, Phone, DeliveryTime)
    VALUES (OLD.suppliersID, 'DELETE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), OLD.Institution, OLD.products, OLD.DelivererName, OLD.Phone, OLD.DeliveryTime);
END
//

-- PRODUCTS
CREATE TRIGGER products_after_insert  
AFTER INSERT ON Products
FOR EACH ROW
BEGIN
    INSERT INTO Products_Audit (productID, action, action_time, name, Price, category, Expiring, suppliersID)
    VALUES (NEW.productID, 'INSERT', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.name, NEW.Price, NEW.category, NEW.Expiring, NEW.suppliersID);
END
//

CREATE TRIGGER products_after_update  
AFTER UPDATE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO Products_Audit (productID, action, action_time, name, Price, category, Expiring, suppliersID)
    VALUES (NEW.productID, 'UPDATE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.name, NEW.Price, NEW.category, NEW.Expiring, NEW.suppliersID);
END
//

CREATE TRIGGER products_after_delete    
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO Products_Audit (productID, action, action_time, name, Price, category, Expiring, suppliersID)
    VALUES (OLD.productID, 'DELETE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), OLD.name, OLD.Price, OLD.category, OLD.Expiring, OLD.suppliersID);
END
//

-- TRANSACTION
CREATE TRIGGER transactions_after_insert
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    INSERT INTO Transactions_Audit (transactionID, action, action_time, customerID, employeeID, TransactionDate, TotalAmount)
    VALUES (NEW.transactionID, 'INSERT', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.customerID, NEW.employeeID, STR_TO_DATE(NEW.TransactionDate, '%Y-%m-%d'), NEW.TotalAmount);
END
//

CREATE TRIGGER transactions_after_update
AFTER UPDATE ON Transactions
FOR EACH ROW
BEGIN
    INSERT INTO Transactions_Audit (transactionID, action, action_time, customerID, employeeID, TransactionDate, TotalAmount)
    VALUES (NEW.transactionID, 'UPDATE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.customerID, NEW.employeeID, STR_TO_DATE(NEW.TransactionDate, '%Y-%m-%d'), NEW.TotalAmount);
END
//

CREATE TRIGGER transactions_after_delete
AFTER DELETE ON Transactions
FOR EACH ROW
BEGIN
    INSERT INTO Transactions_Audit (transactionID, action, action_time, customerID, employeeID, TransactionDate, TotalAmount)
    VALUES (OLD.transactionID, 'DELETE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), OLD.customerID, OLD.employeeID, STR_TO_DATE(OLD.TransactionDate, '%Y-%m-%d'), OLD.TotalAmount);
END
//
-- TRANSACTION DETALS TRIGGER

CREATE TRIGGER transactionDetails_after_insert
AFTER INSERT ON TransactionDetails
FOR EACH ROW
BEGIN
    INSERT INTO TransactionDetails_Audit (transactionID, productID, action, action_time, quantity, subtotal)
    VALUES (NEW.transactionID, NEW.productID, 'INSERT', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.quantity, NEW.subtotal);
END
//

CREATE TRIGGER transactionDetails_after_update
AFTER UPDATE ON TransactionDetails
FOR EACH ROW
BEGIN
    INSERT INTO TransactionDetails_Audit (transactionID, productID, action, action_time, quantity, subtotal)
    VALUES (NEW.transactionID, NEW.productID, 'UPDATE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), NEW.quantity, NEW.subtotal);
END
//

CREATE TRIGGER transactionDetails_after_delete
AFTER DELETE ON TransactionDetails
FOR EACH ROW
BEGIN
    INSERT INTO TransactionDetails_Audit (transactionID, productID, action, action_time, quantity, subtotal)
    VALUES (OLD.transactionID, OLD.productID, 'DELETE', CONVERT_TZ(NOW(), @@session.time_zone, '+02:00'), OLD.quantity, OLD.subtotal);
END
//

DELIMITER ;



  
