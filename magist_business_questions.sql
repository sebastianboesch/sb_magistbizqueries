/* In relation to the products */
-- What categories of tech products does magist have?
SELECT DISTINCT(pro_trans.product_category_name_english) as TECH
FROM product_category_name_translation as pro_trans
    JOIN products as pro
   ON pro_trans.product_category_name = pro.product_category_name
   WHERE pro_trans.product_category_name_english
    IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers") 
;
-- view result

-- How many products of these tech categories have been sold? What precentage does that represent from the overall number of products sold?
SELECT DISTINCT (pro_trans.product_category_name_english) AS tech, COUNT(oi.order_item_id) AS num_itens_sold
FROM product_category_name_translation as pro_trans
    JOIN products as pr
   ON pro_trans.product_category_name = pr.product_category_name
LEFT JOIN order_items as oi
        ON pr.product_id = oi.product_id
    LEFT JOIN orders as o
        ON oi.order_id = o.order_id
GROUP BY pro_trans.product_category_name_english 
HAVING pro_trans.product_category_name_english
        IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers") 
;
-- view result

-- What's the average price of the products being sold?       
SELECT ROUND(AVG(price),2) AS avg_price , pro_trans.product_category_name_english 
FROM product_category_name_translation as pro_trans
    JOIN products as pr
   ON pro_trans.product_category_name = pr.product_category_name
LEFT JOIN order_items as oi
        ON pr.product_id = oi.product_id
GROUP BY pro_trans.product_category_name_english 
HAVING (pro_trans.product_category_name_english) 
    IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers") ;
-- view result

-- Are expensive tech products popular? use CASE WHEN
SELECT COUNT(*) AS items_sold, pro_trans.product_category_name_english as TECH,
    CASE
    WHEN ord_it.price > 200 THEN "Expensive"
    ELSE "Cheap"
END AS "price_range"
FROM product_category_name_translation as pro_trans
    JOIN products as pro
   ON pro_trans.product_category_name = pro.product_category_name
    JOIN order_items as ord_it
        ON pro.product_id = ord_it.product_id
WHERE pro_trans.product_category_name_english
    IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers") 
GROUP BY price_range, pro_trans.product_category_name_english
ORDER BY TECH, price_range ASC
;

/* In relation to the sellers */
-- How many months of data are included in the magist database?
SELECT COUNT(*)
FROM (
	SELECT 
		YEAR(order_purchase_timestamp) AS year_,
		MONTH(order_purchase_timestamp) AS month_,
		COUNT(customer_id)
	FROM
		orders
	GROUP BY year_ , month_
) AS subquery;
-- result 25

-- Orjadas solution
SELECT TIMESTAMPDIFF(month,MIN(date(order_purchase_timestamp)), Max(date(order_purchase_timestamp))) as number_months 
FROM orders;
-- result 25

-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
SELECT COUNT(seller_id)
FROM sellers;
-- result 3095

SELECT COUNT(DISTINCT seller_id)
FROM order_items ord
JOIN products pro ON ord.product_id = pro.product_id
JOIN product_category_name_translation trans ON trans.product_category_name = pro.product_category_name
WHERE product_category_name_english IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers");
-- result 409 (based on English Tech list)

SELECT ROUND((409/3095)*100, 1);
-- result 13.2


-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers? Average monthly income of all sellers? Average monthly income of Tech sellers?

SELECT ROUND(SUM(price), 2)
FROM order_items;
-- all sellers earned 13591643.7

SELECT ROUND(SUM(price), 2)
FROM order_items ord
JOIN products pro ON ord.product_id = pro.product_id
JOIN product_category_name_translation trans ON trans.product_category_name = pro.product_category_name
-- WHERE pro.product_category_name IN ( "consoles_games", "dvds_blu_ray", "eletronicos", "eletroportateis" , "informatica_acessorios", "pc_gamer", "pcs");
WHERE product_category_name_english IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers")
;
-- all tech sellers earned 1460174.75

-- sum(months): 25; all sellers: 3095; Tech sellers: 409; total income: 13591643.7; tech income: 1460174.75
SELECT 13591643.7/25;
-- all income per month: 543665.75
SELECT 1460174.75/25;
-- tech income per month: 58406.99


/* In relation to the delivery time */

-- What's the average time between the order being placed and the product being delivered?
SELECT ROUND(AVG(TIMESTAMPDIFF(day, order_purchase_timestamp, order_delivered_customer_date)), 1)
FROM orders;
-- result 12.1 days

-- How many orders are delivered on time vs orders delivered with a delay?
SELECT COUNT(*),
	CASE
		WHEN TIMESTAMPDIFF(day, order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN "delayed"
        ELSE "on time"
	END AS "performance"
FROM orders
GROUP BY performance
;
-- view result

-- Is there any pattern for delayed orders, e.g. big products being delayed more often? Tech vs No-Tech products

SELECT pro_trans.product_category_name_english, COUNT(*),
	CASE
		WHEN TIMESTAMPDIFF(day, order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN "delayed"
        ELSE "on time"
	END AS "performance"   
FROM orders AS ord
JOIN order_items AS ord_it ON ord.order_id = ord_it.order_id
JOIN products AS pro ON ord_it.product_id = pro.product_id
JOIN product_category_name_translation AS pro_trans ON pro_trans.product_category_name = pro.product_category_name
GROUP BY product_category_name_english, performance
ORDER BY product_category_name_english, performance ASC
;
-- view result

SELECT pro_trans.product_category_name_english, COUNT(*),
	CASE
		WHEN TIMESTAMPDIFF(day, order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN "delayed"
        ELSE "on time"
	END AS "performance"   
FROM orders AS ord
JOIN order_items AS ord_it ON ord.order_id = ord_it.order_id
JOIN products AS pro ON ord_it.product_id = pro.product_id
JOIN product_category_name_translation AS pro_trans ON pro_trans.product_category_name = pro.product_category_name
WHERE product_category_name_english IN ( "consoles_games", "dvds_blu_ray", "electronics", "computers_accessories", "pc_gamer", "computers")
GROUP BY product_category_name_english, performance
ORDER BY product_category_name_english, performance ASC
;
-- view result