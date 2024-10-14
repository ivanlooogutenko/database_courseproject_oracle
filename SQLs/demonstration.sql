---admin_user
--xml
SELECT COUNT(xml_data) FROM Products_XML;
SELECT xml_data FROM Orders_XML;
SELECT xml_data FROM Order_Items_XML;
SELECT xml_data FROM Employees_XML;
SELECT xml_data FROM Customers_XML;
SELECT xml_data FROM Categories_XML;
SELECT xml_data FROM Auctions_XML;
SELECT xml_data FROM Auction_Items_XML;
SELECT xml_data FROM Auction_Bids_XML;

SELECT * FROM Products WHERE category_id = 3;
SELECT * FROM Orders;
SELECT * FROM Order_Items;
SELECT * FROM Employees;
SELECT * FROM Customers;
SELECT * FROM Categories;
SELECT * FROM Auctions;
SELECT * FROM Auction_Items;
SELECT * FROM Auction_Bids;

DELETE FROM Products;
DELETE FROM Categories;
DELETE FROM Employees;
DELETE FROM Customers;
DELETE FROM Orders;
DELETE FROM Order_Items;
DELETE FROM Auctions;
DELETE FROM Auction_Items;
DELETE FROM Auction_Bids;

UPDATE Categories SET category_name = 'anticategory'  WHERE category_name = 'Category 1';

DELETE FROM Categories WHERE category_name = 'anticategory';
---


--- manager
EXECUTE add_product(100003, 'product', 'description', 3, 3, 3);

