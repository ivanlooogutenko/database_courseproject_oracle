INSERT INTO Products (product_id, product_name, product_description, category_id, stock_quantity, price)
VALUES (3, 'product3', 'description3', 3, 3, 3);

INSERT INTO Categories (category_id, category_name, category_description)
VALUES (12, 'category3', 'description3');

UPDATE Products SET price = 3 WHERE price = 2;

DELETE FROM Products WHERE price = 3;

DELETE FROM Products;
DELETE FROM Categories;

EXECUTE SAVE_PRODUCTS_XML;
EXECUTE SAVE_ORDERS_XML;
EXECUTE SAVE_ORDER_ITEMS_XML;
EXECUTE SAVE_CATEGORIES_XML;
EXECUTE SAVE_EMPLOYEES_XML;
EXECUTE SAVE_CUSTOMERS_XML; --
EXECUTE SAVE_AUCTIONS_XML;
EXECUTE SAVE_AUCTION_ITEMS_XML;
EXECUTE SAVE_AUCTION_BIDS_XML;



GRANT EXECUTE ON add_product TO manager_role;

GRANT EXECUTE ON procedure_name TO role_name;



ALTER SYSTEM SET utl_file_dir = 'c:\Tables_XML' SCOPE = spfile;

SELECT EXTRACTVALUE(xml_data, '/product/product_id/text()') FROM Products_XML;
SELECT xml_data FROM Products_XML;
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