# GROUP-19 SUPERMARKET DATABASE DOCUMENTATION 

##  Project Overview

This is a complete **supermarket database system** that manages customers, employees, suppliers, products, transactions, and audit logging. The database is fully normalized to **Third Normal Form (3NF)** and includes automated triggers for calculations and audit trails.

---

##  Database Structure (12 Tables)

### Main Tables (6)
| Table | Purpose |
|-------|---------|
| **Customer** | Stores customer information |
| **Employee** | Stores employee information |
| **Suppliers** | Stores supplier information |
| **Products** | Stores product inventory |
| **Transactions** | Stores sales transactions |
| **TransactionDetails** | Stores individual items in each transaction |

### Audit Tables (6)
| Table | Purpose |
|-------|---------|
| **Customer_Audit** | Tracks all changes to Customer table |
| **Employee_Audit** | Tracks all changes to Employee table |
| **Suppliers_Audit** | Tracks all changes to Suppliers table |
| **Products_Audit** | Tracks all changes to Products table |
| **Transactions_Audit** | Tracks all changes to Transactions table |
| **TransactionDetails_Audit** | Tracks all changes to TransactionDetails table |

---

##  Relationships between the tables

```
Customer (1) ──"makes"──▶ (M) Transactions
Employee (1) ──"handles"─▶ (M) Transactions
Suppliers (1) ──"supplies"─▶ (M) Products
Transactions (1) ──"contains"─▶ (M) TransactionDetails
Products (1) ──"referenced in"─▶ (M) TransactionDetails

Each Main Table (1) ──"audits"─▶ (M) Corresponding Audit Table
```

**All relationships are ONE-TO-MANY (1:M)**

---

##  Triggers 

### Business Logic Triggers (4)
| Trigger | Purpose |
|---------|---------|
| `calc_subtotal` | Auto-calculates subtotal = quantity × product price |
| `update_total_after_insert` | Updates transaction total when item added |
| `update_total_after_update` | Updates transaction total when item changed |
| `update_total_after_delete` | Updates transaction total when item removed |

### Audit Triggers (18)
- **3 triggers per main table** (INSERT, UPDATE, DELETE)
- Records: action type, timestamp (UTC+02:00), and complete record state

---

##  Key Constraints

| Constraint Type | Details |
|----------------|---------|
| **Primary Keys** | 12 tables have PKs (customerID, employeeID, suppliersID, productID, transactionID, auditID, composite PK for TransactionDetails) |
| **Foreign Keys** | 5 FKs linking tables together |
| **Unique Constraints** | Phone and Email in Customer/Employee, Phone in Suppliers |
| **NOT NULL** | name (Customer/Employee/Products), Price, quantity |
| **DELETE** | Transactions.customerID → Customer.customerID |

---

##  Sample Queries (copy each sample and test it) 

```sql
-- INSERTING CUSTOMER
INSERT INTO Customer (name, Phone, Email, Address)
VALUES ('Daswa VTR', '0821167281', 'Daswa@gmail.com', '123 Main Street'), 
('Masenya BT', '0715548772', 'Masenya1@gmail.com', 'block G Street');

SELECT * FROM Customer_Audit;
SELECT * FROM Customer;
```
 <img width="941" height="290" alt="customer" src="https://github.com/user-attachments/assets/0407e934-e63b-4d61-84ff-7d0d7ce900c4" />

-- ----------------------------------------
```sql
-- INSERT EMPLOYEE
INSERT INTO Employee (name, workTitle, Phone, Email, Address)
VALUES ('Randima N', 'Cashier', '0812240688', 'Randima1@gmail.com', '7sibasastreet'), 
('Tshifhulufhelwi H', 'Manager', '0660495086', 'Tshifhulufhelwi@gmail.com', 'duthuni');

SELECT * FROM Employee_Audit;
SELECT * FROM Employee;
```
<img width="1174" height="311" alt="EMPLOYEE" src="https://github.com/user-attachments/assets/cf03e2d2-5b68-45e6-b31e-a6124eaadeb4" />

-- --------------------------------------------
```sql
-- INSERT SUPPLIERS
INSERT INTO Suppliers (Institution, products, DelivererName, Phone, DeliveryTime)
VALUES ('DairyWorld', 'milk & cheese', 'Mahadulula M', '0725476878', '2026-04-22 09:00'), ('Freshloaf', 'bread', 'Nethabakone LD', '0712957281', '2026-04-30 15:00');

SELECT * FROM Suppliers_Audit;
SELECT * FROM Suppliers;
```
<img width="1070" height="303" alt="Screenshot 2026-04-22 202958" src="https://github.com/user-attachments/assets/208dd024-697a-4d14-9e08-3715e109fbee" />

-- -----------------------------------------------
```sql
-- INSERT PRODUCTS
INSERT INTO Products (name, Price, category, Expiring, suppliersID)
VALUES ('INKOMASI', 25.99, 'dairy', '2026-07-10', 1), 
('bread', 7.50, 'Bakery', '2024-06-28', 2);

SELECT * FROM Products_Audit;
SELECT * FROM Products;
```
<img width="882" height="243" alt="2" src="https://github.com/user-attachments/assets/8370713c-f1a1-4e19-9983-755044805112" />

-- -------------------------------------------
```sql
-- INSERT TRANSACTIONS
INSERT INTO Transactions (customerID, employeeID, TransactionDate, TotalAmount)
VALUES (1, 1, '2026-04-24', 0.00), (2, 1, '2026-04-24', 0.00);

SELECT * FROM Transactions_Audit;
SELECT * FROM Transactions;
```
<img width="915" height="244" alt="3" src="https://github.com/user-attachments/assets/620b0274-4ac9-4dfe-8acf-d9a4d9866f14" />

-- -------------------------------------------
```sql
-- INSERT TRANSACTION DETAILS 
INSERT INTO TransactionDetails (transactionID, productID, quantity, subtotal)
VALUES (1, 1, 3, 77.97), (2, 2, 2, 15.00);

SELECT * FROM TransactionDetails_Audit;
SELECT * from Transactiondetails;
```
<img width="754" height="238" alt="4" src="https://github.com/user-attachments/assets/aeee841c-ce48-42bd-8a31-56121af1ffd5" />

-- ----------------------------------------------
```sql
-- Daily sales report
SELECT TransactionDate, SUM(TotalAmount) AS DailySales
FROM Transactions
GROUP BY TransactionDate;
```
<img width="271" height="104" alt="5" src="https://github.com/user-attachments/assets/37c489b9-60fc-4c23-bc11-7b9e68ed5b72" />


```sql
-- Customer purchase history
SELECT c.name, t.TransactionDate, t.TotalAmount
FROM Customer c
JOIN Transactions t ON c.customerID = t.customerID;
```
<img width="378" height="121" alt="6" src="https://github.com/user-attachments/assets/99d067f5-4d35-4a29-8b38-6ee5722b6d95" />

```sql
-- Product sales report
SELECT p.name, SUM(td.quantity) AS TotalSold, SUM(td.subtotal) AS Revenue
FROM Products p
JOIN TransactionDetails td ON p.productID = td.productID
GROUP BY p.productID;
```
<img width="284" height="125" alt="7" src="https://github.com/user-attachments/assets/74cc5470-91e5-4f4d-b5bf-913c07eddf5e" />


```sql
-- View audit log
SELECT * FROM Customer_Audit;

-- deleting entities
DELETE FROM <ENTITY> WHERE entityID = <IDnumber>;

SELECT * FROM <ENTITY_AUDIT> WHERE entityID= <IDnumber>;
-- -----------
-- UPDATING DATA
SET <ATTRIBUTE> ='NEW UPDATE' WHERE entityID = <IDnumber>
SELECT * FROM <ENTITY_AUDIT> WHERE entityID = <IDnumber>
```
## Running the queries: Installation (One Compiler)
1. **Go to github and copy the code:** https://github.com/Hakundwi2400225/MySQL.Supermarket/tree/master
2. **Go to:** https://onecompiler.com/mysql
3. **paste the code:** the complete SQL script
4. **Copy and paste each sample query on starndard input box (STDIN)**
5. **Test with sample data**
6. **Click Run**  button
7. **Verify:** 12 tables and 22 triggers created
---

##  3NF Compliance

| Table | 3NF Status |
|-------|------------|
| Customer | satisfied |
| Employee | satisfied |
| Suppliers | satisfied |
| Products | satisfied |
| Transactions | satisfied |
| TransactionDetails | satisfied |
| All 6 Audit Tables | satisfied |

**No transitive dependencies, no partial dependencies, all atomic values**

---

##  Database statictics 

| Item | Count |
|------|-------|
| Total Tables | 12 |
| Total Triggers | 22 |
| Primary Keys | 12 |
| Foreign Keys | 5 |
| Unique Constraints | 5 |
| NOT NULL Constraints | 4 |

---

##  Key Features

-  **Auto-calculation** of subtotals and transaction totals
-  **Complete audit trail** for all main tables
-  **Timezone support** (UTC+02:00)
-  **Referential integrity** with foreign keys
-  **3NF Compliant** - no redundancy
-  **ON DELETE CASCADE** for customer transactions

---

##  Authors

## Authors

**GROUP-19 SUPERMARKET MEMBERS**

| Name | Student No |
| --- | --- |
| BT Masenya | 24018708 |
| H Tshifhulufhelwi | 24000225 |
| LD Nethabakone | 25015023 |
| M Mahadulula | 24020598 |
| N Randima | 23005659 |
| T Nengovhela | 25001502 |
| V.T.R Daswa | 23014829 |

University of Venda
 University of venda
---

