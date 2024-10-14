-------------------------------------
-------------  INSERTS  -------------
-------------------------------------
DROP TRIGGER update_products_stats;
DROP TRIGGER update_orders_stats;
DROP TRIGGER update_order_items_stats;
DROP TRIGGER update_employees_stats;
DROP TRIGGER update_customers_stats;
DROP TRIGGER update_categories_stats;
DROP TRIGGER update_auctions_stats;
DROP TRIGGER update_auction_items_stats;
DROP TRIGGER update_auction_bids_stats;

---- (обновление статистики таблицы ...
-- ... products)
CREATE OR REPLACE TRIGGER update_products_stats
AFTER INSERT OR UPDATE OR DELETE ON Products
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => USER,
    tabname => 'Products'
  );
END;

-- ... orders)
CREATE OR REPLACE TRIGGER update_orders_stats
AFTER INSERT OR UPDATE OR DELETE ON Orders
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => USER,
    tabname => 'Orders'
  );
END;

-- ... customers)
CREATE OR REPLACE TRIGGER update_customers_stats
AFTER INSERT OR UPDATE OR DELETE ON Customers
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => USER,
    tabname => 'Customers'
  );
END;

-- ... auctions)
CREATE OR REPLACE TRIGGER update_auctions_stats
AFTER INSERT OR UPDATE OR DELETE ON Auctions
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => USER,
    tabname => 'Auctions'
  );
END;

-- ... auctions_items)
CREATE OR REPLACE TRIGGER update_auction_items_stats
AFTER INSERT OR UPDATE OR DELETE ON Auction_Items
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => USER,
    tabname => 'Auction_Items'
  );
END;

-- ... auction_bids)
CREATE OR REPLACE TRIGGER update_auction_bids_stats
AFTER INSERT OR UPDATE OR DELETE ON Auction_Bids
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => USER,
    tabname => 'Auction_Bids'
  );
END;

-- ... categories)
CREATE OR REPLACE TRIGGER update_categories_stats
AFTER INSERT OR UPDATE OR DELETE ON Categories
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => USER,
    tabname => 'Categories'
  );
END;

-- ... employees)
DROP TRIGGER check_bid_amount;
CREATE OR REPLACE TRIGGER update_employees_stats
AFTER INSERT OR UPDATE OR DELETE ON Employees
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(
    ownname => USER,
    tabname => 'Employees'
  );
END;


-- (проверяет, чтобы размер новой ставки был больше последней)
CREATE OR REPLACE TRIGGER check_bid_amount
BEFORE INSERT ON Auction_Bids
FOR EACH ROW
DECLARE
  last_bid_amount NUMBER;
BEGIN
  SELECT bid_amount INTO last_bid_amount
  FROM Auction_Bids
  WHERE auction_item_id = :NEW.auction_item_id
  ORDER BY bid_date DESC
  FETCH FIRST 1 ROW ONLY;
  
  IF last_bid_amount IS NOT NULL AND :NEW.bid_amount <= last_bid_amount THEN
    RAISE_APPLICATION_ERROR(-20001, 'Bid amount must exceed last bid amount');
  END IF;
END;



--------------------
------- XML --------
--------------------
CREATE TABLE Products_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;

CREATE TABLE Orders_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;

CREATE TABLE Order_Items_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;

CREATE TABLE Customers_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;

CREATE TABLE Categories_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;

CREATE TABLE Employees_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;

CREATE TABLE Auctions_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;

CREATE TABLE Auction_Items_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;

CREATE TABLE Auction_Bids_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;



-- insert
CREATE OR REPLACE TRIGGER trg_products_insert
AFTER INSERT ON Products
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<product>' ||
           '<product_id>' || :new.product_id || '</product_id>' ||
           '<product_name>' || :new.product_name || '</product_name>' ||
           '<product_description>' || :new.product_description || '</product_description>' ||
           '<category_id>' || :new.category_id || '</category_id>' ||
           '<stock_quantity>' || :new.stock_quantity || '</stock_quantity>' ||
           '<price>' || :new.price || '</price>' ||
           '</product>'
         )
  INTO v_xml
  FROM dual;

  INSERT INTO Products_XML (xml_data) VALUES (v_xml);
END;
/

CREATE OR REPLACE TRIGGER trg_orders_insert
AFTER INSERT ON Orders
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<order>' ||
           '<order_id>' || :new.order_id || '</order_id>' ||
           '<order_date>' || :new.order_date || '</order_date>' ||
           '<total_price>' || :new.total_price || '</total_price>' ||
           '</order>'
         )
  INTO v_xml
  FROM dual;

  INSERT INTO Orders_XML (xml_data) VALUES (v_xml);
END;
/

CREATE OR REPLACE TRIGGER trg_order_items_insert
AFTER INSERT ON Order_Items
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<order_item>' ||
           '<order_item_id>' || :new.order_item_id || '</order_item_id>' ||
           '<order_id>' || :new.order_id || '</order_id>' ||
           '<auction_bid_id>' || :new.auction_bid_id || '</auction_bid_id>' ||
           '<quantity>' || :new.quantity || '</quantity>' ||
           '<price_per_item>' || :new.price_per_item || '</price_per_item>' ||
           '</order_item>'
         )
  INTO v_xml
  FROM dual;

  INSERT INTO Order_Items_XML (xml_data) VALUES (v_xml);
END;
/

CREATE OR REPLACE TRIGGER trg_customers_insert
AFTER INSERT ON Customers
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<customer>' ||
           '<customer_id>' || :new.customer_id || '</customer_id>' ||
           '<customer_name>' || :new.customer_name || '</customer_name>' ||
           '<customer_email>' || :new.customer_email || '</customer_email>' ||
           '<customer_phone>' || :new.customer_phone || '</customer_phone>' ||
           '</customer>'
         )
  INTO v_xml
  FROM dual;

  INSERT INTO Products_XML (xml_data) VALUES (v_xml);
END;
/

CREATE OR REPLACE TRIGGER trg_categories_insert
AFTER INSERT ON Categories
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<category>' ||
           '<category_id>' || :new.category_id || '</category_id>' ||
           '<category_name>' || :new.category_name || '</category_name>' ||
           '<category_description>' || :new.category_description || '</category_description>' ||
           '</category>'
         )
  INTO v_xml
  FROM dual;

  INSERT INTO Categories_XML (xml_data) VALUES (v_xml);
END;
/

CREATE OR REPLACE TRIGGER trg_employees_update
AFTER UPDATE ON Employees
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<employee>' ||
           '<employee_id>' || :new.employee_id || '</employee_id>' ||
           '<employee_name>' || :new.employee_name || '</employee_name>' ||
           '<employee_position>' || :new.employee_position || '</employee_position>' ||
           '<employee_contact_info>' || :new.employee_contact_info || '</employee_contact_info>' ||
           '</employee>'
         )
  INTO v_xml
  FROM dual;

  INSERT INTO Employees_XML (xml_data) VALUES (v_xml);
END;
/

CREATE OR REPLACE TRIGGER trg_auctions_update
AFTER UPDATE ON Auctions
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<auction>' ||
           '<auction_id>' || :new.auction_id || '</auction_id>' ||
           '<auction_name>' || :new.auction_name || '</auction_name>' ||
           '<auction_date>' || :new.auction_date || '</auction_date>' ||
           '<auction_time>' || :new.auction_time || '</auction_time>' ||
           '<auction_location>' || :new.auction_location || '</auction_location>' ||
           '<seller_id>' || :new.seller_id || '</seller_id>' ||
           '</auction>'
         )
  INTO v_xml
  FROM dual;

  INSERT INTO Auctions_XML (xml_data) VALUES (v_xml);
END;
/

CREATE OR REPLACE TRIGGER trg_auction_items_insert
AFTER INSERT ON Auction_Items
FOR EACH ROW
DECLARE
v_xml XMLType;
BEGIN
    SELECT XMLType(
        '<auction_item>' ||
        '<auction_item_id>' || :new.auction_item_id || '</auction_item_id>' ||
        '<auction_id>' || :new.auction_id || '</auction_id>' ||
        '<product_id>' || :new.product_id || '</product_id>' ||
        '<starting_price>' || :new.starting_price || '</starting_price>' ||
        '</auction_item>'
    )
    INTO v_xml
    FROM dual;

    INSERT INTO Auction_Items_XML (xml_data) VALUES (v_xml);
END;
/

CREATE OR REPLACE TRIGGER trg_auction_bids_insert
AFTER INSERT ON Auction_Bids
FOR EACH ROW
DECLARE
v_xml XMLType;
BEGIN
    SELECT XMLType(
        '<auction_bid>' ||
        '<auction_bid_id>' || :new.auction_bid_id || '</auction_bid_id>' ||
        '<auction_item_id>' || :new.auction_item_id || '</auction_item_id>' ||
        '<bidder_id>' || :new.bidder_id || '</bidder_id>' ||
        '<bid_amount>' || :new.bid_amount || '</bid_amount>' ||
        '<bid_date>' || :new.bid_date || '</bid_date>' ||
        '<is_win>' || :new.is_win || '</is_win>' ||
        '</auction_bid>'
    )
    INTO v_xml
    FROM dual;

    INSERT INTO Auction_Bids_XML (xml_data) VALUES (v_xml);
END;
/
----


---- update
CREATE OR REPLACE TRIGGER trg_products_update
AFTER UPDATE ON Products
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<product>' ||
           '<product_id>' || :new.product_id || '</product_id>' ||
           '<product_name>' || :new.product_name || '</product_name>' ||
           '<product_description>' || :new.product_description || '</product_description>' ||
           '<category_id>' || :new.category_id || '</category_id>' ||
           '<stock_quantity>' || :new.stock_quantity || '</stock_quantity>' ||
           '<price>' || :new.price || '</price>' ||
           '</product>'
         )
  INTO v_xml
  FROM dual;

  UPDATE Products_XML SET xml_data = v_xml WHERE EXTRACTVALUE(xml_data, '/product/product_id/text()') = :new.product_id;
END;
/

CREATE OR REPLACE TRIGGER trg_orders_update
AFTER UPDATE ON Orders
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<order>' ||
           '<order_id>' || :new.order_id || '</order_id>' ||
           '<order_date>' || :new.order_date || '</order_date>' ||
           '<total_price>' || :new.total_price || '</total_price>' ||
           '</order>'
         )
  INTO v_xml
  FROM dual;

  UPDATE Orders_XML SET xml_data = v_xml WHERE EXTRACTVALUE(xml_data, '/order/order_id/text()') = :new.order_id;
END;
/

CREATE OR REPLACE TRIGGER trg_customers_update
AFTER UPDATE ON Customers
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<customer>' ||
           '<customer_id>' || :new.customer_id || '</customer_id>' ||
           '<customer_name>' || :new.customer_name || '</customer_name>' ||
           '<customer_email>' || :new.customer_email || '</customer_email>' ||
           '<customer_phone>' || :new.customer_phone || '</customer_phone>' ||
           '</customer>'
         )
  INTO v_xml
  FROM dual;

  UPDATE Customers_XML SET xml_data = v_xml WHERE EXTRACTVALUE(xml_data, '/customer/customer_id/text()') = :new.customer_id;
END;
/

CREATE OR REPLACE TRIGGER trg_order_items_update
AFTER UPDATE ON Order_Items
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<order_item>' ||
           '<order_item_id>' || :new.order_item_id || '</order_item_id>' ||
           '<order_id>' || :new.order_id || '</order_id>' ||
           '<auction_bid_id>' || :new.auction_bid_id || '</auction_bid_id>' ||
           '<quantity>' || :new.quantity || '</quantity>' ||
           '<price_per_item>' || :new.price_per_item || '</price_per_item>' ||
           '</order_item>'
         )
  INTO v_xml
  FROM dual;

  UPDATE Order_Items_XML SET xml_data = v_xml WHERE EXTRACTVALUE(xml_data, '/order_item/order_item_id/text()') = :new.order_item_id;
END;
/

CREATE OR REPLACE TRIGGER trg_categories_update
AFTER UPDATE ON Categories
FOR EACH ROW
DECLARE
v_xml XMLType;
BEGIN
    SELECT XMLType(
        '<category>' ||
        '<category_id>' || :new.category_id || '</category_id>' ||
        '<category_name>' || :new.category_name || '</category_name>' ||
        '<category_description>' || :new.category_description || '</category_description>' ||
        '</category>'
    )
    INTO v_xml
    FROM dual;

    UPDATE Categories_XML SET xml_data = v_xml WHERE EXTRACTVALUE(xml_data, '/category/category_id/text()') = :new.category_id;
END;
/

CREATE OR REPLACE TRIGGER trg_employees_update
AFTER UPDATE ON Employees
FOR EACH ROW
DECLARE
v_xml XMLType;
BEGIN
    SELECT XMLType(
        '<employee>' ||
        '<employee_id>' || :new.employee_id || '</employee_id>' ||
        '<employee_name>' || :new.employee_name || '</employee_name>' ||
        '<employee_position>' || :new.employee_position || '</employee_position>' ||
        '<employee_contact_info>' || :new.employee_contact_info || '</employee_contact_info>' ||
        '</employee>'
    )
    INTO v_xml
    FROM dual;

    UPDATE Employees_XML SET xml_data = v_xml WHERE EXTRACTVALUE(xml_data, '/employee/employee_id/text()') = :new.employee_id;
END;
/

CREATE OR REPLACE TRIGGER trg_auctions_update
AFTER UPDATE ON Auctions
FOR EACH ROW
DECLARE
v_xml XMLType;
BEGIN
    SELECT XMLType(
        '<auction>' ||
        '<auction_id>' || :new.auction_id || '</auction_id>' ||
        '<auction_name>' || :new.auction_name || '</auction_name>' ||
        '<auction_date>' || :new.auction_date || '</auction_date>' ||
        '<auction_time>' || :new.auction_time || '</auction_time>' ||
        '<auction_location>' || :new.auction_location || '</auction_location>' ||
        '<seller_id>' || :new.seller_id || '</seller_id>' ||
        '</auction>'
    )
    INTO v_xml
    FROM dual;

    UPDATE Auctions_XML SET xml_data = v_xml WHERE EXTRACTVALUE(xml_data, '/auction/auction_id/text()') = :new.auction_id;
END;
/

CREATE OR REPLACE TRIGGER trg_auction_items_update
AFTER UPDATE ON Auction_Items
FOR EACH ROW
DECLARE
v_xml XMLType;
BEGIN
SELECT XMLType(
        '<auction_item>' ||
        '<auction_item_id>' || :new.auction_item_id || '</auction_item_id>' ||
        '<auction_id>' || :new.auction_id || '</auction_id>' ||
        '<product_id>' || :new.product_id || '</product_id>' ||
        '<starting_price>' || :new.starting_price || '</starting_price>' ||
        '</auction_item>'
    )
    INTO v_xml
    FROM dual;

    UPDATE Auction_Items_XML SET xml_data = v_xml WHERE EXTRACTVALUE(xml_data, '/auction_item/auction_item_id/text()') = :new.auction_item_id;
END;
/

CREATE OR REPLACE TRIGGER trg_auction_bids_update
AFTER UPDATE ON Auction_Bids
FOR EACH ROW
DECLARE
v_xml XMLType;
BEGIN
    SELECT XMLType(
        '<auction_bid>' ||
        '<auction_bid_id>' || :new.auction_bid_id || '</auction_bid_id>' ||
        '<auction_item_id>' || :new.auction_item_id || '</auction_item_id>' ||
        '<bidder_id>' || :new.bidder_id || '</bidder_id>' ||
        '<bid_amount>' || :new.bid_amount || '</bid_amount>' ||
        '<bid_date>' || :new.bid_date || '</bid_date>' ||
        '<is_win>' || :new.is_win || '</is_win>' ||
        '</auction_bid>'
    )
    INTO v_xml
    FROM dual;

    UPDATE Auction_Bids_XML SET xml_data = v_xml WHERE EXTRACTVALUE(xml_data, '/auction_bid/auction_bid_id/text()') = :new.auction_bid_id;
END;
/
----


---- delete
CREATE OR REPLACE TRIGGER trg_customers_delete
AFTER DELETE ON Customers
FOR EACH ROW
BEGIN
    DELETE FROM Customers_XML WHERE EXTRACTVALUE(xml_data, '/customer/customer_id/text()') = :old.customer_id;
END;
/

CREATE OR REPLACE TRIGGER trg_categories_delete
AFTER DELETE ON Categories
FOR EACH ROW
BEGIN
    DELETE FROM Categories_XML WHERE EXTRACTVALUE(xml_data, '/category/category_id/text()') = :old.category_id;
END;
/

CREATE OR REPLACE TRIGGER trg_order_items_delete
AFTER DELETE ON Order_Items
FOR EACH ROW
BEGIN
    DELETE FROM Order_Items_XML WHERE EXTRACTVALUE(xml_data, '/order_item/order_item_id/text()') = :old.order_item_id;
END;
/

CREATE OR REPLACE TRIGGER trg_orders_delete
AFTER DELETE ON Orders
FOR EACH ROW
BEGIN
    DELETE FROM Orders_XML WHERE EXTRACTVALUE(xml_data, '/order/order_id/text()') = :old.order_id;
END;
/

CREATE OR REPLACE TRIGGER trg_products_delete
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    DELETE FROM Products_XML WHERE EXTRACTVALUE(xml_data, '/product/product_id/text()') = :old.product_id;
END;
/

CREATE OR REPLACE TRIGGER trg_employees_delete
AFTER DELETE ON Employees
FOR EACH ROW
BEGIN
    DELETE FROM Employees_XML WHERE EXTRACTVALUE(xml_data, '/employee/employee_id/text()') = :old.employee_id;
END;
/

CREATE OR REPLACE TRIGGER trg_auctions_delete
AFTER DELETE ON Auctions
FOR EACH ROW
BEGIN
    DELETE FROM Auctions_XML WHERE EXTRACTVALUE(xml_data, '/auction/auction_id/text()') = :old.auction_id;
END;
/

CREATE OR REPLACE TRIGGER trg_auction_items_delete
AFTER DELETE ON Auction_Items
FOR EACH ROW
BEGIN
    DELETE FROM Auction_Items_XML WHERE EXTRACTVALUE(xml_data, '/auction_item/auction_item_id/text()') = :old.auction_item_id;
END;
/

CREATE OR REPLACE TRIGGER trg_auction_bids_delete
AFTER DELETE ON Auction_Bids
FOR EACH ROW
BEGIN
    DELETE FROM Auction_Bids_XML WHERE EXTRACTVALUE(xml_data, '/auction_bid/auction_bid_id/text()') = :old.auction_bid_id;
END;
/
----



