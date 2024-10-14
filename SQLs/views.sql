-------------------------------------
--------------  VIEWS  --------------
-------------------------------------
-- (информация о продуктах и их количестве)
CREATE VIEW Products_Inventory AS
SELECT product_id, product_name, stock_quantity
FROM Products;

-- (информация о заявках на участие в аукционе)
CREATE VIEW Auction_Bids_Info AS
SELECT ab.auction_bid_id, ai.auction_id, p.product_name, c.customer_name, ab.bid_amount, ab.bid_date
FROM Auction_Bids ab
JOIN Auction_Items ai ON ab.auction_item_id = ai.auction_item_id
JOIN Products p ON ai.product_id = p.product_id
JOIN Customers c ON ab.bidder_id = c.customer_id;


-- (информация о продавцах и товарах, которые они выставили на аукцион)
CREATE VIEW Auction_Sellers AS
SELECT e.employee_name, p.product_name, ai.starting_price
FROM Auctions a
JOIN Employees e ON a.seller_id = e.employee_id
JOIN Auction_Items ai ON a.auction_id = ai.auction_id
JOIN Products p ON ai.product_id = p.product_id;


-- (информация о заказах и соответствующим им товарах)
CREATE VIEW Order_Details AS
SELECT o.order_id, o.order_date, c.customer_name, p.product_name, oi.quantity, oi.price_per_item, o.total_price
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id;


-- (сколько товаров было продано на аукционе)
CREATE VIEW Auction_Sales AS
SELECT a.auction_id, a.auction_name, COUNT(DISTINCT ab.auction_bid_id) AS num_sales
FROM Auctions a
JOIN Auction_Items ai ON a.auction_id = ai.auction_id
JOIN Auction_Bids ab ON ai.auction_item_id = ab.auction_item_id
WHERE ab.is_win = TRUE
GROUP BY a.auction_id, a.auction_name;
