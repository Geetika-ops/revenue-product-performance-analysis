-- Calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price)  / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;


-- Analyze the cumulative revenue generated over time
SELECT order_date, sum(revenue) over(order by order_date) as cum_revenue
from 
(SELECT orders.order_date, sum(order_details.quantity*pizzas.price) as Revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category
SELECT name, revenue from 
(SELECT category, name, revenue,
rank() over(partition by category order by revenue desc) as order_rank
from
(SELECT pizza_types.category, pizza_types.name, round(sum(order_details.quantity*pizzas.price),2) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category, pizza_types.name) as A) as B
where order_rank <= 3;



-- Calculate pizza category that performs best during peak hours
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
WHERE
    HOUR(o.order_time) BETWEEN 17 AND 22
GROUP BY pt.category
ORDER BY total_quantity DESC;


-- Calculate pizza category which generates the highest average order value
SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT o.order_id),
            2) AS avg_order_value
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY avg_order_value DESC;


-- Which day of the week generate the highest revenue
SELECT 
    DAYNAME(o.order_time) AS Day_name,
    SUM(od.quantity * p.price) AS Revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY day_name
ORDER BY revenue DESC;

