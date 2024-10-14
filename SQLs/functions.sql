-------------------------------------
------------  FUNCTIONS  ------------
-------------------------------------

-- (��������� ���������� � ������ �� ID)
CREATE OR REPLACE FUNCTION get_product_info_by_id(
    p_product_id IN NUMBER
) RETURN Products%ROWTYPE AS
    v_product_info Products%ROWTYPE;
BEGIN
    -- �������� ���������� � ������ �� ��� ID
    SELECT *
    INTO v_product_info
    FROM Products
    WHERE product_id = p_product_id;
    
    RETURN v_product_info;
END;

-- (��������� ���������� � ������ �� ID)
CREATE OR REPLACE FUNCTION get_order_info_by_id(
    p_order_id IN NUMBER
) RETURN Orders%ROWTYPE AS
    v_order_info Orders%ROWTYPE;
BEGIN
    -- �������� ���������� � ������ �� ��� ID
    SELECT *
    INTO v_order_info
    FROM Orders
    WHERE order_id = p_order_id;
    
    RETURN v_order_info;
END;

-- (��������� ���������� � ������� �� ID)
CREATE OR REPLACE FUNCTION get_customer_info_by_id(
    p_customer_id IN NUMBER
) RETURN Customers%ROWTYPE AS
    v_customer_info Customers%ROWTYPE;
BEGIN
    -- �������� ���������� � ���������� �� ID
    SELECT *
    INTO v_customer_info
    FROM Customers
    WHERE customer_id = p_customer_id;
    
    RETURN v_customer_info;
END;

-- (��������� ���������� � ���������� �� ID)
CREATE OR REPLACE FUNCTION get_employee_info_id(
    p_employee_id IN NUMBER
) RETURN Employees%ROWTYPE AS
    v_employee_info Employees%ROWTYPE;
BEGIN
    -- �������� ���������� � �������� �� ��� ID
    SELECT *
    INTO v_employee_info
    FROM Employees
    WHERE employee_id = p_employee_id;
    
    RETURN v_employee_info;
END;

-- (��������� ���������� � �������� �� ID)
CREATE OR REPLACE FUNCTION get_auction_bid_info_by_id(
    p_auction_bid_id IN NUMBER
) RETURN Auction_Bids%ROWTYPE AS
    v_auction_bid_info Auction_Bids%ROWTYPE;
BEGIN
    -- �������� ���������� � ������ �� ������� � �������� �� �� ID
    SELECT *
    INTO v_auction_bid_info
    FROM Auction_Bids
    WHERE auction_bid_id = p_auction_bid_id;
    
    RETURN v_auction_bid_info;
END;