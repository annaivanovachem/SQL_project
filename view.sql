-- Представление: текущие статусы всех заказов
CREATE VIEW st.v_current_order_status AS
SELECT 
    o.order_id,
    o.customer_id,
    c.full_name AS customer_name,
    o.total_amount,
    h.status AS current_status,
    h.changed_at AS last_status_change,
    h.comment
FROM st.orders o
JOIN st.customers c ON o.customer_id = c.customer_id
JOIN st.order_status_history h ON o.order_id = h.order_id
WHERE h.is_current = true;

-- Представление: итоги по товарам (количество продаж, выручка, средний рейтинг)
CREATE VIEW st.v_product_performance AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    COALESCE(SUM(oi.quantity), 0) AS total_sold,
    COALESCE(SUM(oi.quantity * oi.price_at_order), 0) AS total_revenue,
    COALESCE(ROUND(AVG(r.rating), 2), 0) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM st.products p
LEFT JOIN st.order_items oi ON p.product_id = oi.product_id
LEFT JOIN st.product_reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, p.category;

-- Представление: клиенты с их суммарными тратами и количеством заказов
CREATE VIEW st.v_customer_spending AS
SELECT 
    c.customer_id,
    c.full_name,
    c.email,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    COALESCE(ROUND(AVG(o.total_amount), 2), 0) AS avg_order_value
FROM st.customers c
LEFT JOIN st.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.full_name, c.email
