# SQL_project
Предметная область: данная база данных предназначена для управления онлайн-магазином включая товары, клиентов, заказы, отзывы о товарах.

Бизнес-правила:
1) Клиент может оформить несколько заказов.
2) В одном заказе может быть несколько товаров.
3) Статус заказа изменяется со временем (создан → оплачен → сборка → доставка → завершен).

Система позволяет:

Управлять клиентами — хранить информацию о покупателях, их контактах и активности

Вести каталог товаров — хранить данные о товарах, категориях, ценах, остатках на складе

Обрабатывать заказы — создавать заказы, отслеживать их статусы, историю изменений

Анализировать продажи — собирать данные о продажах, выручке, популярных товарах

Собирать обратную связь — хранить отзывы и оценки клиентов о товарах

База данных содержит следующие таблицы:

**customers** — информация о клиентах  
**products** — каталог товаров  
**orders** — заказы (основная таблица)  
**order_items** — таблица-связка (товары в заказе)  
**order_status_history** — версионная таблица — история статусов заказов  

<img width="4000" height="2250" alt="логический-физический" src="https://github.com/user-attachments/assets/35c6006d-635e-4305-8c94-3987f4113e1c" />

Для чего подойдет проект:

-Прототип для интернет-магазина

-Система управления заказами (OMS)

-Аналитическая платформа для e-commerce

-MVP для стартапа в сфере электронной коммерции


**Как запускать проект:**  
1. Установите PostgreSQL, DBeaver
2. Выполните скрипты в указанном порядке:

```CREATE SCHEMA st  


-- 1. Таблица клиентов  
CREATE TABLE st.customers (  
    customer_id    BIGSERIAL PRIMARY KEY,  
    email          VARCHAR(100) NOT NULL UNIQUE,  
    full_name      VARCHAR(150) NOT NULL,  
    phone          VARCHAR(20) NOT NULL,  
    address        TEXT NOT NULL,  
    city           VARCHAR(50) NOT NULL,  
    registered_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    is_active      BOOLEAN DEFAULT true  
)  

-- 2. Таблица товаров  
CREATE TABLE st.products (  
    product_id     BIGSERIAL PRIMARY KEY,  
    product_name   VARCHAR(200) NOT NULL,  
    category       VARCHAR(50) NOT NULL,  
    description    TEXT,  
    price          DECIMAL(10, 2) NOT NULL CHECK (price > 0),  
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),  
    manufacturer   VARCHAR(100),   
    weight_kg      DECIMAL(5, 2),  
    is_active      BOOLEAN DEFAULT true,   
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP  
)  

-- 3. Таблица заказов   
CREATE TABLE st.orders (  
    order_id        BIGSERIAL PRIMARY KEY,  
    customer_id     BIGINT NOT NULL,  
    order_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    total_amount    DECIMAL(10, 2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),  
    shipping_address TEXT NOT NULL,  
    payment_method  VARCHAR(20) NOT NULL CHECK (payment_method IN ('card', 'cash', 'paypal', 'crypto')),  
    delivery_date   DATE,  
    CONSTRAINT fk_orders_customer   
        FOREIGN KEY (customer_id) REFERENCES st.customers(customer_id)  
)  

-- 4. Таблица-связка (позиции заказа)  
CREATE TABLE st.order_items (  
    order_item_id   BIGSERIAL PRIMARY KEY,  
    order_id        BIGINT NOT NULL,  
    product_id      BIGINT NOT NULL,  
    quantity        INTEGER NOT NULL CHECK (quantity > 0),  
    price_at_order  DECIMAL(10, 2) NOT NULL CHECK (price_at_order > 0),  
    CONSTRAINT fk_order_items_order   
        FOREIGN KEY (order_id) REFERENCES st.orders(order_id) ON DELETE CASCADE,  
    CONSTRAINT fk_order_items_product   
        FOREIGN KEY (product_id) REFERENCES st.products(product_id)  
)  

-- 5. Версионная таблица (SCD Type 2) - история статусов заказов  
CREATE TABLE st.order_status_history (  
    history_id     BIGSERIAL PRIMARY KEY,  
    order_id       BIGINT NOT NULL,  
    status         VARCHAR(20) NOT NULL,   
    changed_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    comment        TEXT,  
    valid_from     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  
    valid_to       TIMESTAMP,  
    is_current     BOOLEAN NOT NULL DEFAULT true,  
    CONSTRAINT fk_status_history_order   
        FOREIGN KEY (order_id) REFERENCES st.orders(order_id) ON DELETE CASCADE,  
    CONSTRAINT check_status CHECK (  
        status IN ('created', 'paid', 'processing', 'shipped', 'delivered', 'cancelled')  
	)   
)  

-- 6.Таблица отзывы  
CREATE TABLE st.product_reviews (  
    review_id          BIGSERIAL PRIMARY KEY,  
    customer_id        BIGINT NOT NULL,  
    product_id         BIGINT NOT NULL,  
    order_id           BIGINT,  
    rating             INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),  
    review_text        TEXT,  
    is_verified_purchase BOOLEAN DEFAULT false,  
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    updated_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    CONSTRAINT fk_reviews_customer   
        FOREIGN KEY (customer_id) REFERENCES st.customers(customer_id),  
    CONSTRAINT fk_reviews_product   
        FOREIGN KEY (product_id) REFERENCES st.products(product_id),  
    CONSTRAINT fk_reviews_order   
        FOREIGN KEY (order_id) REFERENCES st.orders(order_id) ON DELETE SET NULL,  
    CONSTRAINT unique_customer_product_review   
        UNIQUE (customer_id, product_id)  
    )-- один клиент может оставить только один отзыв на товар   

-- Вставка данных в таблицы. Все данные сгенерированы ИИ.  

INSERT INTO st.customers (email, full_name, phone, address, city, registered_at, is_active) VALUES
    ('alex.ivanov@gmail.com', 'Alex Ivanov', '+7-999-111-2233', 'ул. Ленина, д. 10, кв. 15', 'Moscow', '2024-01-10 09:00:00', true),
    ('maria.petrova@yahoo.com', 'Maria Petrova', '+7-999-222-3344', 'ул. Пушкина, д. 5, кв. 8', 'Saint Petersburg', '2024-01-12 10:30:00', true),
    ('john.smith@gmail.com', 'John Smith', '+1-555-123-4567', '123 Main St, Apt 4B', 'New York', '2024-01-15 14:20:00', true),
    ('anna.kozlov@mail.ru', 'Anna Kozlov', '+7-999-333-4455', 'ул. Гагарина, д. 20, кв. 12', 'Moscow', '2024-01-18 16:45:00', true),
    ('david.wilson@outlook.com', 'David Wilson', '+1-555-234-5678', '456 Oak St, Apt 7C', 'Toronto', '2024-01-20 11:00:00', true),
    ('elena.sokolova@gmail.com', 'Elena Sokolova', '+7-999-444-5566', 'ул. Советская, д. 7, кв. 3', 'Novosibirsk', '2024-01-22 08:30:00', true),
    ('michael.brown@yahoo.com', 'Michael Brown', '+1-555-345-6789', '789 Pine St, Apt 2A', 'Los Angeles', '2024-01-25 13:40:00', true),
    ('olga.volkova@mail.ru', 'Olga Volkova', '+7-999-555-6677', 'пр. Мира, д. 15, кв. 22', 'Ekaterinburg', '2024-01-28 17:10:00', true),
    ('james.davis@gmail.com', 'James Davis', '+44-20-1234-5678', '10 Downing St, Apt 5', 'London', '2024-02-01 10:50:00', true),
    ('natalia.morozova@yahoo.com', 'Natalia Morozova', '+7-999-666-7788', 'ул. Кирова, д. 8, кв. 45', 'Kazan', '2024-02-03 12:25:00', true),
    ('robert.johnson@outlook.com', 'Robert Johnson', '+1-555-567-8901', '321 Elm St, Apt 9B', 'Chicago', '2024-02-05 09:00:00', true),
    ('ekaterina.novikova@gmail.com', 'Ekaterina Novikova', '+7-999-777-8899', 'ул. Невского, д. 25, кв. 7', 'Saint Petersburg', '2024-02-08 15:30:00', true),
    ('william.taylor@yahoo.com', 'William Taylor', '+1-555-678-9012', '654 Maple Ave, Apt 3', 'Vancouver', '2024-02-10 11:45:00', true),
    ('tatyana.fedorova@mail.ru', 'Tatyana Fedorova', '+7-999-888-9900', 'ул. Свердлова, д. 3, кв. 9', 'Nizhny Novgorod', '2024-02-12 14:15:00', true),
    ('richard.martinez@gmail.com', 'Richard Martinez', '+1-555-789-0123', '987 Cedar St, Apt 12', 'San Francisco', '2024-02-15 10:00:00', true),
    ('svetlana.grigorieva@yahoo.com', 'Svetlana Grigorieva', '+7-999-999-0011', 'ул. Чехова, д. 12, кв. 34', 'Rostov', '2024-02-18 16:20:00', true),
    ('thomas.anderson@outlook.com', 'Thomas Anderson', '+1-555-890-1234', '147 Birch St, Apt 6', 'Austin', '2024-02-20 09:30:00', true),
    ('irina.vasilieva@gmail.com', 'Irina Vasilieva', '+7-999-111-0022', 'ул. Московская, д. 9, кв. 5', 'Sochi', '2024-02-22 13:50:00', true),
    ('christopher.white@yahoo.com', 'Christopher White', '+1-555-901-2345', '258 Willow St, Apt 8', 'Boston', '2024-02-25 10:10:00', true),
    ('daria.lebedeva@mail.ru', 'Daria Lebedeva', '+7-999-222-1133', 'ул. Тверская, д. 14, кв. 18', 'Moscow', '2024-03-01 12:40:00', true),
    ('daniel.garcia@outlook.com', 'Daniel Garcia', '+1-555-012-3456', '369 Ash St, Apt 2C', 'Miami', '2024-03-05 14:00:00', false),
    ('olga.smirnova@gmail.com', 'Olga Smirnova', '+7-999-333-2244', 'ул. Садовая, д. 6, кв. 11', 'Voronezh', '2024-03-08 11:20:00', true),
    ('maksim.volkov@mail.ru', 'Maksim Volkov', '+7-999-444-3355', 'ул. Лермонтова, д. 4, кв. 21', 'Krasnodar', '2024-03-10 09:45:00', true),
    ('sarah.wilson@gmail.com', 'Sarah Wilson', '+1-555-123-7890', '456 Elm St, Apt 15', 'Seattle', '2024-03-12 16:30:00', true),
    ('andrey.medvedev@yandex.ru', 'Andrey Medvedev', '+7-999-555-4466', 'ул. Горького, д. 11, кв. 8', 'Ufa', '2024-03-15 13:10:00', true),
    ('jessica.taylor@yahoo.com', 'Jessica Taylor', '+1-555-234-8901', '789 Oak St, Apt 4D', 'Denver', '2024-03-18 10:20:00', true),
    ('viktor.sidorov@gmail.com', 'Viktor Sidorov', '+7-999-666-5577', 'ул. Победы, д. 2, кв. 33', 'Volgograd', '2024-03-20 15:40:00', true),
    ('emily.davis@outlook.com', 'Emily Davis', '+44-20-2345-6789', '22 Baker St, Apt 3', 'London', '2024-03-22 12:00:00', true),
    ('nadezhda.kuznetsova@mail.ru', 'Nadezhda Kuznetsova', '+7-999-777-6688', 'ул. Гоголя, д. 19, кв. 6', 'Saratov', '2024-03-25 08:50:00', true),
    ('kevin.martin@gmail.com', 'Kevin Martin', '+1-555-345-9012', '147 Pine St, Apt 7', 'Portland', '2024-03-28 17:15:00', true)
    
    INSERT INTO st.products (product_name, category, description, price, stock_quantity, manufacturer, weight_kg, is_active, created_at) VALUES
    ('iPhone 15 Pro Max', 'Smartphones', 'Apple flagship smartphone with A17 chip and 6.7-inch display', 1199.99, 45, 'Apple', 0.22, true, '2024-01-01 10:00:00'),
    ('Samsung Galaxy S24 Ultra', 'Smartphones', 'Premium Android phone with AI features and S-Pen', 1099.99, 38, 'Samsung', 0.23, true, '2024-01-02 11:00:00'),
    ('MacBook Pro 16', 'Laptops', 'Apple laptop with M3 chip and 16-inch Liquid Retina display', 2499.99, 20, 'Apple', 2.10, true, '2024-01-03 12:00:00'),
    ('Dell XPS 15', 'Laptops', 'Premium Windows laptop with OLED display and Intel Core i9', 1899.99, 25, 'Dell', 1.80, true, '2024-01-04 13:00:00'),
    ('Sony WH-1000XM5', 'Headphones', 'Wireless noise-cancelling headphones with exceptional sound quality', 399.99, 60, 'Sony', 0.25, true, '2024-01-05 14:00:00'),
    ('AirPods Pro 2', 'Headphones', 'Apple wireless earbuds with ANC and spatial audio', 249.99, 80, 'Apple', 0.05, true, '2024-01-06 15:00:00'),
    ('iPad Pro 12.9', 'Tablets', 'Apple tablet with M2 chip and Liquid Retina XDR display', 1099.99, 30, 'Apple', 0.68, true, '2024-01-07 16:00:00'),
    ('Samsung Galaxy Tab S9+', 'Tablets', 'High-performance Android tablet with S-Pen included', 999.99, 35, 'Samsung', 0.60, true, '2024-01-08 17:00:00'),
    ('PlayStation 5', 'Gaming Consoles', 'Sony gaming console with 4K gaming and SSD storage', 499.99, 15, 'Sony', 3.50, true, '2024-01-09 18:00:00'),
    ('Xbox Series X', 'Gaming Consoles', 'Microsoft gaming console with 4K gaming and Game Pass', 499.99, 18, 'Microsoft', 3.40, true, '2024-01-10 19:00:00'),
    ('Nintendo Switch OLED', 'Gaming Consoles', 'Hybrid gaming console with 7-inch OLED display', 349.99, 28, 'Nintendo', 0.40, true, '2024-01-11 20:00:00'),
    ('Apple Watch Ultra 2', 'Smartwatches', 'Premium smartwatch with advanced health features', 799.99, 40, 'Apple', 0.06, true, '2024-01-12 21:00:00'),
    ('Samsung Galaxy Watch 6', 'Smartwatches', 'Android smartwatch with comprehensive fitness tracking', 399.99, 45, 'Samsung', 0.05, true, '2024-01-13 22:00:00'),
    ('Logitech MX Master 3S', 'Accessories', 'Wireless mouse with ultra-precise scrolling and ergonomic design', 99.99, 75, 'Logitech', 0.15, true, '2024-01-14 23:00:00'),
    ('Keychron K8 Pro', 'Accessories', 'Wireless mechanical keyboard with RGB lighting and hot-swappable switches', 89.99, 70, 'Keychron', 0.80, true, '2024-01-15 09:00:00'),
    ('Samsung 1TB SSD T7', 'Storage', 'Portable SSD with 1TB capacity and USB 3.2 interface', 149.99, 55, 'Samsung', 0.08, true, '2024-01-16 10:00:00'),
    ('Asus ROG RTX 4090', 'Components', 'High-end graphics card for gamers and content creators', 1599.99, 8, 'Asus', 2.50, true, '2024-01-17 11:00:00'),
    ('Corsair Vengeance 32GB', 'Components', 'DDR5 RAM kit with 32GB capacity and RGB lighting', 159.99, 50, 'Corsair', 0.05, true, '2024-01-18 12:00:00'),
    ('LG 27" 4K Monitor', 'Monitors', '27-inch 4K UHD monitor with HDR10 and USB-C', 449.99, 20, 'LG', 5.00, true, '2024-01-19 13:00:00'),
    ('Dell 24" FHD Monitor', 'Monitors', '24-inch Full HD monitor for home and office use', 199.99, 32, 'Dell', 3.80, true, '2024-01-20 14:00:00'),
    ('Canon EOS R5', 'Cameras', 'Professional mirrorless camera with 45MP and 8K video', 3899.99, 5, 'Canon', 0.70, false, '2024-01-21 15:00:00')

  INSERT INTO st.orders (customer_id, order_date, total_amount, shipping_address, payment_method, delivery_date) VALUES
    (1, '2024-02-01 10:15:00', 1199.99, 'ул. Ленина, д. 10, кв. 15, Moscow', 'card', '2024-02-05'),
    (1, '2024-02-15 14:30:00', 249.99, 'ул. Ленина, д. 10, кв. 15, Moscow', 'paypal', '2024-02-19'),
    (2, '2024-02-03 09:20:00', 2499.99, 'ул. Пушкина, д. 5, кв. 8, Saint Petersburg', 'card', '2024-02-07'),
    (2, '2024-02-20 16:45:00', 399.99, 'ул. Пушкина, д. 5, кв. 8, Saint Petersburg', 'paypal', '2024-02-24'),
    (3, '2024-02-05 11:00:00', 1899.99, '123 Main St, Apt 4B, New York', 'card', '2024-02-09'),
    (3, '2024-02-25 13:15:00', 499.99, '123 Main St, Apt 4B, New York', 'paypal', '2024-03-01'),
    (4, '2024-02-07 08:30:00', 1099.99, 'ул. Гагарина, д. 20, кв. 12, Moscow', 'card', '2024-02-11'),
    (4, '2024-03-01 17:00:00', 89.99, 'ул. Гагарина, д. 20, кв. 12, Moscow', 'cash', '2024-03-05'),
    (5, '2024-02-10 12:45:00', 399.99, '456 Oak St, Toronto', 'card', '2024-02-14'),
    (5, '2024-03-05 10:30:00', 349.99, '456 Oak St, Toronto', 'paypal', '2024-03-09'),
    (6, '2024-02-12 15:20:00', 799.99, 'ул. Советская, д. 7, кв. 3, Novosibirsk', 'card', '2024-02-16'),
    (6, '2024-03-10 09:00:00', 1599.99, 'ул. Советская, д. 7, кв. 3, Novosibirsk', 'crypto', '2024-03-14'),
    (7, '2024-02-14 18:30:00', 499.99, '789 Pine St, Los Angeles', 'paypal', '2024-02-18'),
    (7, '2024-03-15 12:00:00', 99.99, '789 Pine St, Los Angeles', 'card', '2024-03-19'),
    (8, '2024-02-17 10:00:00', 399.99, 'пр. Мира, д. 15, кв. 22, Ekaterinburg', 'card', '2024-02-21'),
    (8, '2024-03-20 14:30:00', 449.99, 'пр. Мира, д. 15, кв. 22, Ekaterinburg', 'paypal', '2024-03-24'),
    (9, '2024-02-19 16:15:00', 2499.99, '10 Downing St, London', 'card', '2024-02-23'),
    (9, '2024-03-25 11:45:00', 159.99, '10 Downing St, London', 'paypal', '2024-03-29'),
    (10, '2024-02-21 13:40:00', 1599.99, 'ул. Кирова, д. 8, кв. 45, Kazan', 'card', '2024-02-25'),
    (10, '2024-04-01 09:30:00', 89.99, 'ул. Кирова, д. 8, кв. 45, Kazan', 'cash', '2024-04-05'),
    (11, '2024-02-24 19:00:00', 899.98, '321 Elm St, Chicago', 'paypal', '2024-02-28'),
    (12, '2024-02-27 11:20:00', 349.99, 'ул. Невского, д. 25, кв. 7, Saint Petersburg', 'card', '2024-03-02'),
    (13, '2024-03-02 15:30:00', 399.99, '654 Maple Ave, Vancouver', 'card', '2024-03-06'),
    (14, '2024-03-07 10:10:00', 449.99, 'ул. Свердлова, д. 3, кв. 9, Nizhny Novgorod', 'paypal', '2024-03-11'),
    (15, '2024-03-12 14:45:00', 299.98, '987 Cedar St, San Francisco', 'card', '2024-03-16'),
    (16, '2024-03-17 12:30:00', 1599.99, 'ул. Чехова, д. 12, кв. 34, Rostov', 'crypto', '2024-03-21'),
    (17, '2024-03-22 16:20:00', 1199.99, '147 Birch St, Austin', 'card', '2024-03-26'),
    (18, '2024-03-27 11:00:00', 399.99, 'ул. Московская, д. 9, кв. 5, Sochi', 'paypal', '2024-03-31'),
    (19, '2024-04-02 18:15:00', 2499.99, '258 Willow St, Boston', 'card', '2024-04-06'),
    (20, '2024-04-07 09:45:00', 149.99, 'ул. Тверская, д. 14, кв. 18, Moscow', 'cash', '2024-04-11'),
    (22, '2024-04-12 13:30:00', 199.99, 'ул. Садовая, д. 6, кв. 11, Voronezh', 'card', '2024-04-16'),
    (1, '2024-04-17 10:00:00', 499.99, 'ул. Ленина, д. 10, кв. 15, Moscow', 'paypal', '2024-04-21')
  
 INSERT INTO st.order_items (order_id, product_id, quantity, price_at_order) VALUES
    (1, 1, 1, 1199.99),
    (2, 6, 1, 249.99),
    (3, 3, 1, 2499.99),
    (4, 5, 1, 399.99),
    (5, 4, 1, 1899.99),
    (6, 9, 1, 499.99),
    (7, 7, 1, 1099.99),
    (8, 15, 1, 89.99),
    (9, 5, 1, 399.99),
    (10, 11, 1, 349.99),
    (11, 12, 1, 799.99),
    (12, 17, 1, 1599.99),
    (13, 10, 1, 499.99),
    (14, 14, 1, 99.99),
    (15, 5, 1, 399.99),
    (16, 19, 1, 449.99),
    (17, 3, 1, 2499.99),
    (18, 18, 1, 159.99),
    (19, 17, 1, 1599.99),
    (20, 15, 1, 89.99),
    (21, 5, 1, 399.99),
    (21, 14, 1, 99.99),
    (21, 15, 1, 89.99),
    (21, 6, 1, 249.99),
    (22, 11, 1, 349.99),
    (23, 5, 1, 399.99),
    (24, 19, 1, 449.99),
    (25, 14, 1, 99.99),
    (25, 15, 1, 89.99),
    (25, 6, 1, 249.99),
    (26, 17, 1, 1599.99),
    (27, 1, 1, 1199.99),
    (28, 5, 1, 399.99),
    (29, 3, 1, 2499.99),
    (30, 16, 1, 149.99),
    (31, 20, 1, 199.99),
    (32, 9, 1, 499.99)
  
 INSERT INTO st.order_status_history (order_id, status, changed_at, comment, valid_from, valid_to, is_current) VALUES
    -- Заказ 1: полный цикл (created → paid → processing → shipped → delivered)
    (1, 'created', '2024-02-01 10:15:00', 'Заказ создан клиентом', '2024-02-01 10:15:00', '2024-02-01 10:20:00', false),
    (1, 'paid', '2024-02-01 10:20:00', 'Оплата прошла успешно (карта)', '2024-02-01 10:20:00', '2024-02-02 09:00:00', false),
    (1, 'processing', '2024-02-02 09:00:00', 'Заказ передан в сборку', '2024-02-02 09:00:00', '2024-02-03 14:00:00', false),
    (1, 'shipped', '2024-02-03 14:00:00', 'Заказ отправлен курьерской службой', '2024-02-03 14:00:00', '2024-02-05 15:30:00', false),
    (1, 'delivered', '2024-02-05 15:30:00', 'Заказ доставлен получателю', '2024-02-05 15:30:00', NULL, true),
    
    -- Заказ 2: created → paid → processing → delivered
    (2, 'created', '2024-02-15 14:30:00', 'Заказ создан', '2024-02-15 14:30:00', '2024-02-15 14:35:00', false),
    (2, 'paid', '2024-02-15 14:35:00', 'Оплата через PayPal', '2024-02-15 14:35:00', '2024-02-16 10:00:00', false),
    (2, 'processing', '2024-02-16 10:00:00', 'Начата сборка заказа', '2024-02-16 10:00:00', '2024-02-19 16:00:00', false),
    (2, 'delivered', '2024-02-19 16:00:00', 'Доставлен курьером', '2024-02-19 16:00:00', NULL, true),
    
    -- Заказ 3: created → paid → processing → shipped → delivered
    (3, 'created', '2024-02-03 09:20:00', 'Заказ оформлен', '2024-02-03 09:20:00', '2024-02-03 09:25:00', false),
    (3, 'paid', '2024-02-03 09:25:00', 'Оплата картой', '2024-02-03 09:25:00', '2024-02-04 11:00:00', false),
    (3, 'processing', '2024-02-04 11:00:00', 'Сборка заказа начата', '2024-02-04 11:00:00', '2024-02-06 13:00:00', false),
    (3, 'shipped', '2024-02-06 13:00:00', 'Отправлен транспортной компанией', '2024-02-06 13:00:00', '2024-02-07 18:00:00', false),
    (3, 'delivered', '2024-02-07 18:00:00', 'Доставлен в пункт выдачи', '2024-02-07 18:00:00', NULL, true),
    
    -- Заказ 4: created → paid → processing → shipped → delivered
    (4, 'created', '2024-02-20 16:45:00', 'Заказ создан', '2024-02-20 16:45:00', '2024-02-20 16:50:00', false),
    (4, 'paid', '2024-02-20 16:50:00', 'Оплата через PayPal', '2024-02-20 16:50:00', '2024-02-21 09:00:00', false),
    (4, 'processing', '2024-02-21 09:00:00', 'Передан в обработку', '2024-02-21 09:00:00', '2024-02-23 15:00:00', false),
    (4, 'shipped', '2024-02-23 15:00:00', 'Отправлен', '2024-02-23 15:00:00', '2024-02-24 12:00:00', false),
    (4, 'delivered', '2024-02-24 12:00:00', 'Доставлен', '2024-02-24 12:00:00', NULL, true),
    
    -- Заказ 5: created → paid → processing → cancelled (отмена после оплаты)
    (5, 'created', '2024-02-05 11:00:00', 'Заказ оформлен', '2024-02-05 11:00:00', '2024-02-05 11:05:00', false),
    (5, 'paid', '2024-02-05 11:05:00', 'Оплата картой', '2024-02-05 11:05:00', '2024-02-06 10:00:00', false),
    (5, 'processing', '2024-02-06 10:00:00', 'Начата сборка', '2024-02-06 10:00:00', '2024-02-07 09:30:00', false),
    (5, 'cancelled', '2024-02-07 09:30:00', 'Заказ отменен по запросу клиента', '2024-02-07 09:30:00', NULL, true),
    
    -- Заказ 6: created → cancelled (отмена до оплаты)
    (6, 'created', '2024-02-25 13:15:00', 'Заказ создан', '2024-02-25 13:15:00', '2024-02-25 13:20:00', false),
    (6, 'cancelled', '2024-02-25 13:20:00', 'Отменен клиентом (передумал)', '2024-02-25 13:20:00', NULL, true),
    
    -- Заказ 7: created → paid → processing → shipped → delivered
    (7, 'created', '2024-02-07 08:30:00', 'Заказ создан', '2024-02-07 08:30:00', '2024-02-07 08:35:00', false),
    (7, 'paid', '2024-02-07 08:35:00', 'Оплата картой', '2024-02-07 08:35:00', '2024-02-08 10:00:00', false),
    (7, 'processing', '2024-02-08 10:00:00', 'Сборка заказа', '2024-02-08 10:00:00', '2024-02-10 12:00:00', false),
    (7, 'shipped', '2024-02-10 12:00:00', 'Отправлен', '2024-02-10 12:00:00', '2024-02-11 16:30:00', false),
    (7, 'delivered', '2024-02-11 16:30:00', 'Доставлен', '2024-02-11 16:30:00', NULL, true),
    
    -- Заказ 8: created → paid → shipped (сборка пропущена) → delivered
    (8, 'created', '2024-03-01 17:00:00', 'Заказ создан', '2024-03-01 17:00:00', '2024-03-01 17:05:00', false),
    (8, 'paid', '2024-03-01 17:05:00', 'Оплата наличными', '2024-03-01 17:05:00', '2024-03-02 09:00:00', false),
    (8, 'shipped', '2024-03-02 09:00:00', 'Передан в доставку', '2024-03-02 09:00:00', '2024-03-05 14:00:00', false),
    (8, 'delivered', '2024-03-05 14:00:00', 'Доставлен', '2024-03-05 14:00:00', NULL, true)
    
 INSERT INTO st.product_reviews (customer_id, product_id, order_id, rating, review_text, is_verified_purchase, created_at, updated_at) VALUES
    (1, 1, 1, 5, 'Отличный смартфон! Камера невероятная, работает очень быстро. Батареи хватает на целый день активного использования. Рекомендую всем!', true, '2024-02-06 10:00:00', '2024-02-06 10:00:00'),
    (1, 6, 2, 4, 'Хорошие наушники, шумодав работает отлично. Звук чистый и сбалансированный. Единственный минус - высокая цена.', true, '2024-02-20 11:30:00', '2024-02-20 11:30:00'),
    (2, 3, 3, 5, 'Лучший ноутбук для работы! Экран просто божественный, производительность на высоте. Для разработки подходит идеально.', true, '2024-02-08 14:20:00', '2024-02-08 14:20:00'),
    (2, 5, 4, 5, 'Лучшие наушники с шумоподавлением! В метро просто спасают. Звук объемный, басы глубокие.', true, '2024-02-25 09:15:00', '2024-02-25 09:15:00'),
    (3, 4, 5, 4, 'Хороший ноутбук, мощный и стильный. Экран яркий, работает быстро. Но немного перегревается под нагрузкой.', true, '2024-02-10 16:40:00', '2024-02-10 16:40:00'),
    (3, 9, 6, 5, 'PS5 - это просто космос! Графика невероятная, загрузки мгновенные. Лучшая консоль на рынке.', true, '2024-03-02 12:00:00', '2024-03-02 12:00:00'),
    (4, 7, 7, 5, 'iPad Pro - идеальный планшет для работы и творчества. Рисовать и работать одно удовольствие. Экран великолепный.', true, '2024-02-12 13:45:00', '2024-02-12 13:45:00'),
    (4, 15, 8, 3, 'Неплохая механическая клавиатура, но слишком высокая, неудобно печатать без подставки. Подсветка красивая.', true, '2024-03-06 10:30:00', '2024-03-06 10:30:00'),
    (5, 5, 9, 5, 'Шумодав просто спасает в дороге! Отличный звук, удобная посадка. Лучшие наушники за эти деньги.', true, '2024-02-15 15:20:00', '2024-02-15 15:20:00'),
    (5, 11, 10, 5, 'Nintendo Switch - отличная консоль для всей семьи. Дети в восторге, много интересных игр. Рекомендую!', true, '2024-03-10 11:50:00', '2024-03-10 11:50:00'),
    (6, 12, 11, 4, 'Часы мощные и надежные. Много функций, трекеры точные. Единственное - цена кусается, и батарея могла бы дольше держать.', true, '2024-02-17 09:00:00', '2024-02-17 09:00:00'),
    (6, 17, 12, 5, 'RTX 4090 - это просто монстр для игр! Все игры летают в 4K на максималках. Дорого, но стоит каждого рубля!', true, '2024-03-15 14:10:00', '2024-03-15 14:10:00'),
    (7, 10, 13, 4, 'Xbox Series X - мощная консоль, Game Pass просто шикарен! Интерфейс мог быть удобнее, но в целом отлично.', true, '2024-02-19 18:30:00', '2024-02-19 18:30:00'),
    (7, 14, 14, 5, 'Лучшая мышь для работы! Очень удобно лежит в руке, колесико плавное. Для дизайнеров и программистов идеально.', true, '2024-03-20 16:20:00', '2024-03-20 16:20:00'),
    (8, 5, 15, 4, 'Отличные наушники, но для больших ушей немного тесноваты. Звук качественный, шумодав эффективный.', true, '2024-02-22 13:10:00', '2024-02-22 13:10:00'),
    (8, 19, 16, 5, 'Шикарный монитор! Цвета точные, яркость отличная. Работать на нем одно удовольствие. Для дизайна и видео идеально.', true, '2024-03-25 10:40:00', '2024-03-25 10:40:00'),
    (9, 3, 17, 5, 'MacBook Pro - это мощь! Ноутбук просто летает, не шумит совсем. 3 дня работы без подзарядки - это космос!', true, '2024-02-24 17:00:00', '2024-02-24 17:00:00'),
    (9, 18, 18, 5, 'Отличная оперативная память! Работает как часы, подсветка красивая. Сборка качественная, рекомендую.', true, '2024-03-30 15:30:00', '2024-03-30 15:30:00'),
    (10, 17, 19, 5, 'Видеокарта для настоящих геймеров! 4K игры на максималках - легко! Очень доволен покупкой.', true, '2024-02-26 12:45:00', '2024-02-26 12:45:00'),
    (10, 15, 20, 4, 'Хорошая клавиатура для печати, но в офисе будет шумновата. Подсветка красивая, качество сборки отличное.', true, '2024-04-06 09:20:00', '2024-04-06 09:20:00'),
    (11, 5, 21, 4, 'Достойные наушники! Звук отличный, но немного тяжелые для долгого ношения. Шумодав работает хорошо.', true, '2024-03-01 14:30:00', '2024-03-01 14:30:00'),
    (12, 11, 22, 5, 'Отличный подарок для ребенка! Подарил племяннику, он в полном восторге. Игр много, консоль удобная.', true, '2024-03-03 18:00:00', '2024-03-03 18:00:00'),
    (13, 5, 23, 5, 'Магия отмены шума! Слушаю музыку и ничего не слышу вокруг. Качество звука невероятное!', true, '2024-03-07 11:15:00', '2024-03-07 11:15:00'),
    (14, 19, 24, 4, 'Хороший монитор для работы, но может быть ярковат для ночной работы. В целом качественный и надежный.', true, '2024-03-12 16:50:00', '2024-03-12 16:50:00'),
    (15, 14, 25, 5, 'Идеально для программиста! Работаю 12 часов, рука не устает. Лучшая мышь для работы, что у меня была.', true, '2024-03-17 10:30:00', '2024-03-17 10:30:00'),
    (16, 17, 26, 5, '4K 60 FPS без проблем! Видеокарта тянет всё на максималках. Дорого, но это инвестиция в будущее!', true, '2024-03-22 13:50:00', '2024-03-22 13:50:00'),
    (17, 1, 27, 5, 'Новый iPhone - просто космос! Камера бомба, работает без лагов. Лучший смартфон, что у меня был.', true, '2024-03-27 14:20:00', '2024-03-27 14:20:00'),
    (18, 5, 28, 4, 'Хороший звук, но для любителей мощного баса может не хватить. Шумодав отличный, качество сборки высокое.', true, '2024-04-01 09:40:00', '2024-04-01 09:40:00'),
    (19, 3, 29, 5, 'Лучший выбор для разработчиков под iOS! Работает без нареканий, производительность шикарная.', true, '2024-04-07 15:10:00', '2024-04-07 15:10:00'),
    (20, 16, 30, 5, 'Отличный внешний SSD! Очень быстрый и компактный, помещается в карман. Надежный и качественный!', true, '2024-04-12 11:30:00', '2024-04-12 11:30:00')

--Проверка, запустите следующий скрипт:  
SELECT 'customers' AS table_name, COUNT(*) AS count FROM st.customers
UNION ALL
SELECT 'products', COUNT(*) FROM st.products
UNION ALL
SELECT 'orders', COUNT(*) FROM st.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM st.order_items
UNION ALL
SELECT 'order_status_history', COUNT(*) FROM st.order_status_history
UNION ALL
SELECT 'product_reviews', COUNT(*) FROM st.product_reviews

--Ожидаемый вывод:  
customers	30  
products	21  
orders	32  
order_items	37  
order_status_history	34  
product_reviews	30  
