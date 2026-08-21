--ЗАПРОСЫ

--Все отзывы с деталями клиентов и товаров

SELECT 
    r.review_id,
    c.full_name AS customer_name,
    p.product_name,
    r.rating,
    r.review_text,
    r.is_verified_purchase,
    r.created_at
FROM st.product_reviews r
JOIN st.customers c ON r.customer_id = c.customer_id
JOIN st.products p ON r.product_id = p.product_id
ORDER BY r.created_at;

--Найти все активные товары категории 'Smartphones' дороже 1000$, отсортированные по цене

SELECT 
    product_name,
    category,
    price,
    stock_quantity,
    manufacturer
FROM st.products
WHERE category = 'Smartphones' 
  AND price > 1000
  AND is_active = true
ORDER BY price desc;

--Вывести общую сумму заказов и количество заказов для каждого клиента (только с заказами)

SELECT 
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value
FROM st.customers c
INNER JOIN st.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent desc;

--Все клиенты и количество их заказов (включая тех, у кого нет заказов)

SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM st.customers c
LEFT JOIN st.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email
ORDER BY order_count DESC;

--Категории товаров со средней ценой выше 500$ и количеством товаров не менее 2

SELECT 
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM st.products
WHERE is_active = true
GROUP BY category
HAVING AVG(price) > 500 AND COUNT(*) >= 2
ORDER BY avg_price DESC;

--Товары, цена которых выше средней цены по всем товарам

SELECT 
    product_name,
    category,
    price,
    ROUND((SELECT AVG(price) FROM st.products), 2) AS avg_price_all
FROM st.products
WHERE price > (SELECT AVG(price) FROM st.products)
ORDER BY price DESC;

--Клиенты, которые делали заказы с оплатой картой

SELECT 
    customer_id,
    full_name,
    email
FROM st.customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id 
    FROM st.orders 
    WHERE payment_method = 'card'
)
ORDER BY full_name;

--Товары, которые были хотя бы раз заказаны

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM st.products p
WHERE EXISTS (
    SELECT 1 
    FROM st.order_items oi 
    WHERE oi.product_id = p.product_id
)
ORDER BY p.product_name;

--Товары дороже хотя бы одного товара из категории 'Laptops'

SELECT 
    product_name,
    category,
    price
FROM st.products
WHERE price > ANY (
    SELECT price 
    FROM st.products 
    WHERE category = 'Laptops' 
      AND is_active = true
)
AND category != 'Laptops'
ORDER BY price desc;

--Товары дороже всех товаров категории 'Headphones'

SELECT 
    product_name,
    category,
    price
FROM st.products
WHERE price > ALL (
    SELECT price 
    FROM st.products 
    WHERE category = 'Headphones'
)
ORDER BY price desc;

--Топ-2 самых дорогих товара в каждой категории

WITH ranked_products AS (
    SELECT 
        product_name,
        category,
        price,
        RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank
    FROM st.products
    WHERE is_active = true
)
SELECT 
    category,
    product_name,
    price,
    price_rank
FROM ranked_products
WHERE price_rank <= 2
ORDER BY category, price_rank;

--Накопительная выручка по дням (кумулятивная сумма заказов)

SELECT 
    DATE(order_date) AS order_day,
    COUNT(*) AS orders_count,
    SUM(total_amount) AS daily_revenue,
    SUM(SUM(total_amount)) OVER (ORDER BY DATE(order_date)) AS cumulative_revenue
FROM st.orders
GROUP BY DATE(order_date)
ORDER BY order_day;



--Товары, у которых цена выше средней цены товаров в их категории

SELECT 
    p1.product_name,
    p1.category,
    p1.price,
    ROUND((SELECT AVG(p2.price) 
           FROM st.products p2 
           WHERE p2.category = p1.category), 2) AS avg_category_price,
    ROUND(p1.price - (SELECT AVG(p2.price) 
                      FROM st.products p2 
                      WHERE p2.category = p1.category), 2) AS price_diff
FROM st.products p1
WHERE p1.is_active = true
  AND p1.price > (
      SELECT AVG(p2.price) 
      FROM st.products p2 
      WHERE p2.category = p1.category
  )
ORDER BY p1.category, p1.price DESC;

--Товары, которые никогда не заказывались

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price
FROM st.products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM st.order_items oi 
    WHERE oi.product_id = p.product_id
)
AND p.is_active = true
ORDER BY p.product_name

--Клиенты, которые потратили больше среднего и имеют более 1 заказа

SELECT 
    c.customer_id,
    c.full_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM st.customers c
JOIN st.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name
HAVING SUM(o.total_amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(total_amount) AS total_spent
        FROM st.orders
        GROUP BY customer_id
    ) AS customer_spending
)
AND COUNT(o.order_id) > 1
ORDER BY total_spent DESC