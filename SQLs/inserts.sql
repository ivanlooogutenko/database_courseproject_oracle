-------------------------------------
-------------  INSERTS  -------------
-------------------------------------

CREATE OR REPLACE PROCEDURE insert_products AS
BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO Products (
            product_id,
            product_name,
            product_description,
            category_id,
            stock_quantity,
            price
        ) VALUES (
            i,
            'Product ' || i,
            'Product ' || i || ' description',
            TRUNC(DBMS_RANDOM.VALUE(1, 10)),
            TRUNC(DBMS_RANDOM.VALUE(1, 100)),
            TRUNC(DBMS_RANDOM.VALUE(1, 1000))
        );
    END LOOP;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE insert_orders AS
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO Orders (
            order_id,
            order_date,
            total_price
        ) VALUES (
            i,
            SYSDATE,
            TRUNC(DBMS_RANDOM.VALUE(1, 10000))
        );
    END LOOP;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE insert_order_items AS
BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO Order_Items (
            order_item_id,
            order_id,
            auction_bid_id,
            quantity,
            price_per_item
        ) VALUES (
            i,
            TRUNC(DBMS_RANDOM.VALUE(1, 100000)),
            TRUNC(DBMS_RANDOM.VALUE(1, 100000)),
            TRUNC(DBMS_RANDOM.VALUE(1, 10)),
            TRUNC(DBMS_RANDOM.VALUE(1, 100))
        );
    END LOOP;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE insert_customers AS
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO Customers (
            customer_id,
            customer_name,
            customer_email,
            customer_phone
        ) VALUES (
            i,
            'Customer ' || i,
            'customer' || i || '@example.com',
            '555-555-' || LPAD(i, 4, '0')
        );
    END LOOP;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE insert_categories AS
BEGIN
    FOR i IN 1..10 LOOP
        INSERT INTO Categories (
            category_id,
            category_name,
            category_description
        ) VALUES (
            i,
            'Category ' || i,
            'Category ' || i || ' description'
        );
    END LOOP;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE insert_auctions AS
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO Auctions (
            auction_id,
            auction_name,
            auction_date,
            auction_time,
            auction_location,
            seller_id
        ) VALUES (
            i,
            'Auction ' || i,
            TRUNC(SYSDATE + DBMS_RANDOM.VALUE(1, 30)),
            LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 23.99)), 2, '0') || ':' || LPAD(TRUNC(DBMS_RANDOM.VALUE(0, 59.99)), 2, '0'),
            'Location ' || i,
            TRUNC(DBMS_RANDOM.VALUE(1, 100000))
        );
    END LOOP;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE insert_employees AS
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO Employees (
            employee_id,
            employee_name,
            employee_position,
            employee_contact_info
        ) VALUES (
            i,
            'Employee ' || i,
            CASE WHEN MOD(i, 2) = 0 THEN 'seller' ELSE 'manager' END,
            'employee' || i || '@example.com'
        );
    END LOOP;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE insert_auction_items AS
BEGIN
    FOR i IN 1..100000 LOOP
        INSERT INTO Auction_Items (
            auction_item_id,
            auction_id,
            product_id,
            starting_price
        ) VALUES (
            i,
            TRUNC(DBMS_RANDOM.VALUE(1, 100000)),
            TRUNC(DBMS_RANDOM.VALUE(1, 100000)),
            TRUNC(DBMS_RANDOM.VALUE(1, 100))
        );
    END LOOP;
    COMMIT;
END;

CREATE OR REPLACE PROCEDURE insert_auction_bids AS
BEGIN
    FOR i IN 1..200000 LOOP
        INSERT INTO Auction_Bids (
            auction_bid_id,
            auction_item_id,
            bidder_id,
            bid_amount,
            bid_date,
            is_win
        ) VALUES (
            i,
            TRUNC(DBMS_RANDOM.VALUE(1, 100000)),
            TRUNC(DBMS_RANDOM.VALUE(1, 100000)),
            TRUNC(DBMS_RANDOM.VALUE(1, 1000)),
            SYSDATE,
            CASE WHEN MOD(i, 10) = 0 THEN 1 ELSE 0 END
        );
    END LOOP;
    COMMIT;
END;


EXEC insert_products;
EXEC insert_orders;
EXEC insert_order_items;
EXEC insert_employees;
EXEC insert_categories;
EXEC insert_customers;
EXEC insert_auctions;
EXEC insert_auction_items;
EXEC insert_auction_bids;

