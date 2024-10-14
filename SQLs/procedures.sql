-------------------------------------
-----------  PROCEDURES  ------------
-------------------------------------
----insert
CREATE OR REPLACE PROCEDURE add_product (
    p_id IN NUMBER,
    p_name IN VARCHAR2,
    p_desc IN VARCHAR2,
    cat_id IN NUMBER,
    stock_qty IN NUMBER,
    p_price IN NUMBER
) AS
BEGIN
    INSERT INTO Products (product_id, product_name, product_description, category_id, stock_quantity, price)
    VALUES (p_id, p_name, p_desc, cat_id, stock_qty, p_price);
END;

CREATE OR REPLACE PROCEDURE add_order (
    o_id IN NUMBER,
    o_date IN DATE,
    o_total_price IN NUMBER
) AS
BEGIN
    INSERT INTO Orders (order_id, order_date, total_price)
    VALUES (o_id, o_date, o_total_price);
END;

CREATE OR REPLACE PROCEDURE add_order_item (
    oi_id IN NUMBER,
    o_id IN NUMBER,
    ab_id IN NUMBER,
    qty IN NUMBER,
    price_per_item IN NUMBER
) AS
BEGIN
    INSERT INTO Order_Items (order_item_id, order_id, auction_bid_id, quantity, price_per_item)
    VALUES (oi_id, o_id, ab_id, qty, price_per_item);
END;


----update
CREATE OR REPLACE PROCEDURE update_product (
    p_id IN NUMBER,
    p_name IN VARCHAR2,
    p_desc IN VARCHAR2,
    cat_id IN NUMBER,
    stock_qty IN NUMBER,
    p_price IN NUMBER
) AS
BEGIN
    UPDATE Products
    SET product_name = p_name,
        product_description = p_desc,
        category_id = cat_id,
        stock_quantity = stock_qty,
        price = p_price
    WHERE product_id = p_id;
END;

CREATE OR REPLACE PROCEDURE update_order (
    o_id IN NUMBER,
    o_date IN DATE,
    o_total_price IN NUMBER
) AS
BEGIN
    UPDATE Orders
    SET order_date = o_date,
        total_price = o_total_price
    WHERE order_id = o_id;
END;

CREATE OR REPLACE PROCEDURE update_order_item (
    oi_id IN NUMBER,
    o_id IN NUMBER,
    ab_id IN NUMBER,
    qty IN NUMBER,
    price_per_item IN NUMBER
) AS
BEGIN
    UPDATE Order_Items
    SET order_id = o_id,
        auction_bid_id = ab_id,
        quantity = qty,
        price_per_item = price_per_item
    WHERE order_item_id = oi_id;
END;


----delete
CREATE OR REPLACE PROCEDURE delete_product (p_id IN NUMBER) AS
BEGIN
    DELETE FROM Products WHERE product_id = p_id;
END;

CREATE OR REPLACE PROCEDURE delete_order (o_id IN NUMBER) AS
BEGIN
    DELETE FROM Orders WHERE order_id = o_id;
END;

CREATE OR REPLACE PROCEDURE delete_order_item (oi_id IN NUMBER) AS
BEGIN
    DELETE FROM Order_Items WHERE order_item_id = oi_id;
END;


------------------
---- customer ----
------------------
-- (размещение ставки клиентом)
CREATE OR REPLACE PROCEDURE place_bid(
    p_customer_id IN NUMBER,
    p_auction_item_id IN NUMBER,
    p_bid_amount IN NUMBER
) AS
    v_current_bid_amount NUMBER;
BEGIN
    -- Получаем текущую максимальную ставку на данный товар
    SELECT MAX(bid_amount)
    INTO v_current_bid_amount
    FROM Auction_Bids
    WHERE auction_item_id = p_auction_item_id;
    
    -- Проверяем, что новая ставка больше текущей максимальной ставки
    IF p_bid_amount > v_current_bid_amount THEN
        -- Добавляем новую ставку в таблицу Auction_Bids
        INSERT INTO Auction_Bids(auction_bid_id, auction_item_id, bidder_id, bid_amount, bid_date, is_win)
        VALUES (auction_bid_id_seq.NEXTVAL, p_auction_item_id, p_customer_id, p_bid_amount, SYSDATE, 0);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Your bid has been placed successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Your bid amount must be greater than the current highest bid.');
    END IF;
END place_bid;
-- (получение списка всех выигранных ставок клиента)
CREATE OR REPLACE PROCEDURE get_customer_winning_bids(
    p_customer_id IN NUMBER,
    p_bids OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_bids FOR
    SELECT *
    FROM Auction_Bids
    WHERE bidder_id = p_customer_id
    AND is_win = 1;
END get_customer_winning_bids;
-- (получение списка всех ставок клиента)
CREATE OR REPLACE PROCEDURE get_customer_bids(
    p_customer_id IN NUMBER,
    p_bids OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_bids FOR
    SELECT *
    FROM Auction_Bids
    WHERE bidder_id = p_customer_id;
END get_customer_bids;



----------------
---- seller ----
----------------
-- (добавление товара на аукцион)
CREATE OR REPLACE PROCEDURE add_auction_item(
    p_auction_id IN NUMBER,
    p_product_id IN NUMBER,
    p_starting_price IN NUMBER
) AS
BEGIN
    -- Проверяем, что аукцион существует
    IF NOT EXISTS(SELECT 1 FROM Auctions WHERE auction_id = p_auction_id) THEN
        DBMS_OUTPUT.PUT_LINE('Auction with ID ' || p_auction_id || ' does not exist.');
        RETURN;
    END IF;
    
    -- Проверяем, что товар существует
    IF NOT EXISTS(SELECT 1 FROM Products WHERE product_id = p_product_id) THEN
        DBMS_OUTPUT.PUT_LINE('Product with ID ' || p_product_id || ' does not exist.');
        RETURN;
    END IF;
    
    -- Добавляем новый товар на аукцион
    INSERT INTO Auction_Items(auction_item_id, auction_id, product_id, starting_price)
    VALUES (auction_item_id_seq.NEXTVAL, p_auction_id, p_product_id, p_starting_price);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('New auction item has been added successfully.');
END add_auction_item;
-- (определение выигрышной ставки и добавление её в заказы)
CREATE OR REPLACE PROCEDURE mark_bid_as_winner(
    p_auction_bid_id IN NUMBER,
    p_quantity IN NUMBER
) AS
    v_auction_item_id NUMBER;
    v_product_id NUMBER;
    v_seller_id NUMBER;
    v_bid_amount NUMBER;
BEGIN
    -- Получаем информацию о ставке
    SELECT ai.auction_item_id, ai.product_id, a.seller_id, ab.bid_amount
    INTO v_auction_item_id, v_product_id, v_seller_id, v_bid_amount
    FROM Auction_Bids ab
    JOIN Auction_Items ai ON ab.auction_item_id = ai.auction_item_id
    JOIN Auctions a ON ai.auction_id = a.auction_id
    WHERE ab.auction_bid_id = p_auction_bid_id;
    
    -- Помечаем ставку как выигрышную
    UPDATE Auction_Bids
    SET is_win = 1
    WHERE auction_bid_id = p_auction_bid_id;
    
    -- Создаем новый заказ
    INSERT INTO Orders(order_id, order_date, total_price)
    VALUES (order_id_seq.NEXTVAL, SYSDATE, v_bid_amount * p_quantity);
    
    -- Добавляем запись в таблицу Order_Items
    INSERT INTO Order_Items(order_item_id, order_id, auction_bid_id, quantity, price_per_item)
    VALUES (order_item_id_seq.NEXTVAL, order_id_seq.CURRVAL, p_auction_bid_id, p_quantity, v_bid_amount);
    
    -- Обновляем количество товара на складе
    UPDATE Products
    SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = v_product_id;
    
    -- Удаляем товар из таблицы Products, если его количество на складе стало равным 0
    IF (SELECT stock_quantity FROM Products WHERE product_id = v_product_id) = 0 THEN
        DELETE FROM Products WHERE product_id = v_product_id;
    END IF;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Bid with ID ' || p_auction_bid_id || ' has been marked as winner and a new order has been created.');
END mark_bid_as_winner;
-- (получение списка всех товаров продавца)
CREATE OR REPLACE PROCEDURE get_seller_orders(
    p_seller_id IN NUMBER,
    p_orders OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_orders FOR
    SELECT *
    FROM Orders o
    JOIN Order_Items oi ON o.order_id = oi.order_id
    JOIN Auction_Bids ab ON oi.auction_bid_id = ab.auction_bid_id
    JOIN Auction_Items ai ON ab.auction_item_id = ai.auction_item_id
    JOIN Auctions a ON ai.auction_id = a.auction_id
    WHERE a.seller_id = p_seller_id;
END get_seller_orders;



-----------------
---- manager ----
-----------------
-- (обновление информации о товаре)
CREATE OR REPLACE PROCEDURE update_product(
    p_product_id IN NUMBER,
    p_product_name IN VARCHAR2,
    p_product_description IN VARCHAR2,
    p_category_id IN NUMBER,
    p_stock_quantity IN NUMBER,
    p_price IN NUMBER
) AS
BEGIN
    -- Обновляем информацию о товаре
    UPDATE Products
    SET product_name = p_product_name,
        product_description = p_product_description,
        category_id = p_category_id,
        stock_quantity = p_stock_quantity,
        price = p_price
    WHERE product_id = p_product_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Product with ID ' || p_product_id || ' has been updated.');
END update_product;
-- (удаление заказа)
CREATE OR REPLACE PROCEDURE delete_order(
    p_order_id IN NUMBER
) AS
BEGIN
    -- Удаляем запись из таблицы Order_Items
    DELETE FROM Order_Items WHERE order_id = p_order_id;
    
    -- Удаляем запись из таблицы Orders
    DELETE FROM Orders WHERE order_id = p_order_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Order with ID ' || p_order_id || ' has been deleted.');
END delete_order;






--------------------
------- XML --------
--------------------
-- products
CREATE OR REPLACE PROCEDURE SAVE_PRODUCTS_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'products.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<products>');
    
    FOR rec IN (SELECT xml_data FROM Products_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;
    
    UTL_FILE.PUT_LINE(v_file, '</products>');

    UTL_FILE.FCLOSE(v_file);
END;
/
--orders
CREATE OR REPLACE PROCEDURE SAVE_ORDERS_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'orders.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<orders>');
    
    FOR rec IN (SELECT xml_data FROM Orders_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;
    
    UTL_FILE.PUT_LINE(v_file, '</orders>');

    UTL_FILE.FCLOSE(v_file);
END;
/
--order_items
CREATE OR REPLACE PROCEDURE SAVE_ORDER_ITEMS_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'order_items.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<order_items>');
    
    FOR rec IN (SELECT xml_data FROM Order_Items_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;
    
    UTL_FILE.PUT_LINE(v_file, '</order_items>');

    UTL_FILE.FCLOSE(v_file);
END;
/
--employees
CREATE OR REPLACE PROCEDURE SAVE_EMPLOYEES_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'employees.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<employees>');
    
    FOR rec IN (SELECT xml_data FROM Employees_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;
    
    UTL_FILE.PUT_LINE(v_file, '</employees>');

    UTL_FILE.FCLOSE(v_file);
END;
/
--customers
CREATE OR REPLACE PROCEDURE SAVE_CUSTOMERS_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'customers.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<customers>');
    
    FOR rec IN (SELECT xml_data FROM Customers_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;
    
    UTL_FILE.PUT_LINE(v_file, '</customers>');

    UTL_FILE.FCLOSE(v_file);
END;
/
--categories
CREATE OR REPLACE PROCEDURE SAVE_CATEGORIES_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'categories.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<categories>');
    
    FOR rec IN (SELECT xml_data FROM Categories_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;
    
    UTL_FILE.PUT_LINE(v_file, '</categories>');

    UTL_FILE.FCLOSE(v_file);
END;
/
--auctions
CREATE OR REPLACE PROCEDURE SAVE_AUCTIONS_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'auctions.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<auctions>');
    
    FOR rec IN (SELECT xml_data FROM Auctions_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;
    
    UTL_FILE.PUT_LINE(v_file, '</auctions>');

    UTL_FILE.FCLOSE(v_file);
END;
/
--auction_items
CREATE OR REPLACE PROCEDURE SAVE_AUCTION_ITEMS_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'auction_items.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<auction_items>');
    
    FOR rec IN (SELECT xml_data FROM Auction_Items_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;
    
    UTL_FILE.PUT_LINE(v_file, '</auction_items>');

    UTL_FILE.FCLOSE(v_file);
END;
/
--auction_bids
CREATE OR REPLACE PROCEDURE SAVE_AUCTION_BIDS_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'auction_bids.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<auction_bids>');
    
    FOR rec IN (SELECT xml_data FROM Auction_Bids_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;
    
    UTL_FILE.PUT_LINE(v_file, '</auction_bids>');

    UTL_FILE.FCLOSE(v_file);
END;
/



