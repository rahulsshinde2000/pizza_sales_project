CREATE DATABASE RSS;
USE RSS;



CREATE TABLE ORDERS(
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id));

CREATE TABLE ORDERS_DETAILS(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id));

select * from orders;
select * from orders_details;
select * from pizza_types;
select * from pizzas;


-- Basic:
-- 1) Retrieve the total number of orders placed.

select count(order_id) as total_num_orders from orders;  -- ans is the 21350

-- 2) Calculate the total revenue generated from pizza sales.

select sum(price) from pizzas; -- this quarys only the count in the price

SELECT 
    SUM(orders_details.quantity * pizzas.price) AS total_sales
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;
    
-- 3) Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4) Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- 5) List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS order_pizza_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY order_pizza_quantity DESC
LIMIT 5;


-- Intermediate:

-- 1) Join the necessary tables to find the total quantity of each pizza category ordered.

 SELECT 
    pizza_types.category AS category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY category
ORDER BY quantity DESC;

-- 2) Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY COUNT(order_id) DESC;


-- 3) Join relevant tables to find the category-wise distribution of pizzas.


select category,count(name) from pizza_types
group by category;

-- 4) Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(quantity)
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY order_date) AS order_quantity;


SELECT 
        orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY order_date;

-- 5) Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue
LIMIT 3;



-- Advanced:

--  1) Calculate the percentage contribution of each pizza type to total revenue.


SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    orders_details
                        JOIN
                    pizzas ON pizzas.pizza_id = orders_details.pizza_id),4)* 100 AS revenue
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY revenue DESC; 


-- 2) Analyze the cumulative revenue generated over time.

/*  cumulative revenue: 
100
200+100=300
500+300=800
250+800=1050
400+1050=1450
*/


select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(orders_details.quantity * pizzas.price) as revenue
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders_details.order_id = orders.order_id
group by orders.order_date) as sales;


-- 3) Determine the top 3 most ordered pizza types based on revenue for each pizza category.


select name,revenue from
(select category,name,revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum(orders_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;





