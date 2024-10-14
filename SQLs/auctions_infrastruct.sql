-------------------------------------
----------  TABLESPACES  ------------
-------------------------------------
CREATE TABLESPACE AUCTIONS
DATAFILE 'AUCTIONS.dat'
SIZE 2G
AUTOEXTEND ON
NEXT 500M
MAXSIZE 10G;

CREATE TEMPORARY TABLESPACE AUCTIONS_TEMP
TEMPFILE 'AUCTIONS_TEMP.dat'
SIZE 1G
AUTOEXTEND ON
NEXT 300M
MAXSIZE 5G;





-------------------------------------
-------------  TABLES  --------------
-------------------------------------
-- создание таблицы "Products"
CREATE TABLE Products (
  product_id NUMBER PRIMARY KEY,
  product_name VARCHAR2(50),
  product_description VARCHAR2(200),
  category_id NUMBER REFERENCES Categories(category_id),
  stock_quantity NUMBER,
  price NUMBER
) TABLESPACE AUCTIONS;

-- создание таблицы "Orders"
CREATE TABLE Orders (
  order_id NUMBER PRIMARY KEY,
  order_date DATE,
  total_price NUMBER
) TABLESPACE AUCTIONS;

-- создание таблицы "Order_Items"
-- таблица "Order_Items" содержит те товары, которые приобрёл определённый покупатель во время аукциона.
CREATE TABLE Order_Items (
  order_item_id NUMBER PRIMARY KEY,
  order_id NUMBER REFERENCES Orders(order_id),
  auction_bid_id NUMBER REFERENCES Auction_Bids(auction_bid_id),
  quantity NUMBER,
  price_per_item NUMBER
) TABLESPACE AUCTIONS;

-- создание таблицы "Customers"
CREATE TABLE Customers (
  customer_id NUMBER PRIMARY KEY,
  customer_name VARCHAR2(50),
  customer_email VARCHAR2(50),
  customer_phone VARCHAR2(20)
) TABLESPACE AUCTIONS;

-- создание таблицы "Categories"
CREATE TABLE Categories (
  category_id NUMBER PRIMARY KEY,
  category_name VARCHAR2(50),
  category_description VARCHAR2(200)
) TABLESPACE AUCTIONS;

-- создание таблицы "Employees"
CREATE TABLE Employees (
employee_id NUMBER PRIMARY KEY,
employee_name VARCHAR2(50),
employee_position VARCHAR2(50) CHECK (employee_position IN ('seller', 'manager')),
employee_contact_info VARCHAR2(200)
) TABLESPACE AUCTIONS;

-- создание таблицы "Auctions"
CREATE TABLE Auctions (
  auction_id NUMBER PRIMARY KEY,
  auction_name VARCHAR2(50),
  auction_date DATE,
  auction_time VARCHAR2(20),
  auction_location VARCHAR2(50),
  seller_id NUMBER REFERENCES Employees(employee_id)
) TABLESPACE AUCTIONS;

-- создание таблицы "Auction_Items"
-- таблица "Auction_Items" содержит те товары, которые были проданы во время определенного аукциона.
CREATE TABLE Auction_Items (
  auction_item_id NUMBER PRIMARY KEY,
  auction_id NUMBER REFERENCES Auctions(auction_id),
  product_id NUMBER REFERENCES Products(product_id),
  starting_price NUMBER
) TABLESPACE AUCTIONS;

-- создание таблицы "Auction_Bids"
-- таблица "Auction_Bids" содержит информацию о заявках на участие в аукционе.
CREATE TABLE Auction_Bids (
  auction_bid_id NUMBER PRIMARY KEY,
  auction_item_id NUMBER REFERENCES Auction_Items(auction_item_id),
  bidder_id NUMBER REFERENCES Customers(customer_id),
  bid_amount NUMBER,
  bid_date DATE,
  is_win BOOLEAN
) TABLESPACE AUCTIONS;





-------------------------------------
-------------  INDEXES  -------------
-------------------------------------
--Products
CREATE INDEX idx_products_category_id ON Products(category_id);
CREATE INDEX idx_products_price ON Products(price);
CREATE INDEX idx_products_product_name ON Products(product_name);
--Orders
CREATE INDEX idx_orders_order_date ON Orders(order_date);
CREATE INDEX idx_orders_total_price ON Orders(total_price);
--Order_Items
CREATE INDEX idx_order_items_order_id ON Order_Items(order_id);
CREATE INDEX idx_order_items_auction_bid_id ON Order_Items(auction_bid_id);
CREATE INDEX idx_order_items_quantity ON Order_Items(quantity);
CREATE INDEX idx_order_items_price_per_item ON Order_Items(price_per_item);
--Customers
CREATE INDEX idx_customers_customer_email ON Customers(customer_email);
CREATE INDEX idx_customers_customer_name ON Customers(customer_name);
--Categories
CREATE INDEX idx_categories_category_name ON Categories(category_name);
--Employees
CREATE INDEX idx_employees_employee_position ON Employees(employee_position);
CREATE INDEX idx_employees_employee_name ON Employees(employee_name);
--Auctions
CREATE INDEX idx_auctions_seller_id ON Auctions(seller_id);
CREATE INDEX idx_auctions_auction_date ON Auctions(auction_date);
--Auction_Items
CREATE INDEX idx_auction_items_auction_id ON Auction_Items(auction_id);
CREATE INDEX idx_auction_items_product_id ON Auction_Items(product_id);
CREATE INDEX idx_auction_items_starting_price ON Auction_Items(starting_price);
--Auction_Bids
CREATE INDEX idx_auction_bids_auction_item_id ON Auction_Bids(auction_item_id);
CREATE INDEX idx_auction_bids_bidder_id ON Auction_Bids(bidder_id);
CREATE INDEX idx_auction_bids_bid_amount ON Auction_Bids(bid_amount);
CREATE INDEX idx_auction_bids_bid_date ON Auction_Bids(bid_date);
CREATE INDEX idx_auction_bids_is_win ON Auction_Bids(is_win);


DROP INDEX idx_products_product_name;

-------------------------------------
-------------  ROLES  ---------------
-------------------------------------
--manager_role
CREATE ROLE manager_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON Orders TO manager_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Order_Items TO manager_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Customers TO manager_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO manager_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Auctions TO manager_role;

--seller_role
CREATE ROLE seller_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON Orders TO seller_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Order_Items TO seller_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Customers TO seller_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Auction_Items TO seller_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON Auction_Bids TO seller_role;
GRANT SELECT, UPDATE, DELETE ON Products TO manager_role;
GRANT SELECT ON Auctions TO seller_role;
GRANT SELECT ON Products TO seller_role;


--customer_role
CREATE ROLE customer_role;

GRANT SELECT, INSERT, UPDATE ON Auction_Bids TO customer_role;
GRANT SELECT ON Orders TO customer_role;
GRANT SELECT ON Products TO customer_role;
GRANT SELECT ON seller_employees TO customer_role;

----------
CREATE VIEW seller_employees AS
SELECT *
FROM Employees
WHERE employee_position = 'seller';
----------

--admin_role
CREATE ROLE admin_role;

GRANT dba TO admin_role;
GRANT CREATE ANY DIRECTORY TO admin_role;
GRANT WRITE ON DIRECTORY xml_dir TO admin_role;
GRANT SELECT ANY DICTIONARY TO admin_role;
GRANT SELECT_CATALOG_ROLE TO admin_role;
GRANT SELECT ANY TRANSACTION TO admin_role;
GRANT SELECT ANY TABLE TO admin_role;
GRANT ALTER SYSTEM TO admin_role;


-------------------------------------
------------  PROFILE  --------------
-------------------------------------
CREATE PROFILE PF_USER LIMIT
SESSIONS_PER_USER 3
CPU_PER_SESSION 30000
CPU_PER_CALL 1000
CONNECT_TIME 180
IDLE_TIME 30
LOGICAL_READS_PER_SESSION 10000
LOGICAL_READS_PER_CALL 1000
PRIVATE_SGA 20M
COMPOSITE_LIMIT 200M
PASSWORD_LIFE_TIME 180
PASSWORD_REUSE_TIME 365
PASSWORD_REUSE_MAX UNLIMITED
PASSWORD_LOCK_TIME 1
PASSWORD_GRACE_TIME 7;

CREATE USER admin_user
IDENTIFIED BY password
DEFAULT TABLESPACE AUCTIONS
TEMPORARY TABLESPACE AUCTIONS_TEMP
PROFILE PF_USER
ACCOUNT UNLOCK
PASSWORD EXPIRE;




-------------------------------------
-------------  USERS  ---------------
-------------------------------------
--manager
CREATE USER manager_user
IDENTIFIED BY password
DEFAULT TABLESPACE AUCTIONS
TEMPORARY TABLESPACE AUCTIONS_TEMP
PROFILE PF_USER
ACCOUNT UNLOCK
PASSWORD EXPIRE;

GRANT manager_role TO manager_user;



--seller
CREATE USER seller_user
IDENTIFIED BY password
DEFAULT TABLESPACE AUCTIONS
TEMPORARY TABLESPACE AUCTIONS_TEMP
PROFILE PF_USER
ACCOUNT UNLOCK
PASSWORD EXPIRE;

GRANT seller_role TO seller_user;



--customer
CREATE USER customer_user
IDENTIFIED BY password
DEFAULT TABLESPACE AUCTIONS
TEMPORARY TABLESPACE AUCTIONS_TEMP
PROFILE PF_USER
ACCOUNT UNLOCK
PASSWORD EXPIRE;

GRANT customer_role TO customer_user;



--admin
CREATE USER admin_user
IDENTIFIED BY password
DEFAULT TABLESPACE AUCTIONS
TEMPORARY TABLESPACE AUCTIONS_TEMP
PROFILE PF_ADMIN
ACCOUNT UNLOCK
PASSWORD EXPIRE;

GRANT admin_role TO admin_user;
