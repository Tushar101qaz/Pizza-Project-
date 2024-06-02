/* Basic:
Retrieve the total number of orders placed.
Calculate the total revenue generated from pizza sales.
Identify the highest-priced pizza.
Identify the most common pizza size ordered.
List the top 5 most ordered pizza types along with their quantitie.

Intermediate:
Find the total quantity of each pizza category ordered (this will help us to understand the category which customers prefer the most).
Determine the distribution of orders by hour of the day (at which time the orders are maximum (for inventory management and resource allocation).
Find the category-wise distribution of pizzas (to understand customer behaviour).
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue (let's see the revenue wise pizza orders to understand from sales perspective which pizza is the best selling)

Advanced:
Calculate the percentage contribution of each pizza type to total revenue (to understand % of contribution of each pizza in the total revenue)
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category (In each category which pizza is the most selling */


Create database Pizza_pr ; 
use pizza_pr ; 

--  Total Number Of Orders (The total number of orderes placed )

Select Count(order_id) Total_orders 
from orders ; 

-- Total pizzas sold 
select sum(quantity) Pizzas_ordered 
from order_details ; 

-- Total Revenue Generated 
select 
Round(sum(price*quantity),2) Revenue 
from order_details join pizzas 
on pizzas.pizza_id = order_details.pizza_id 
; 

-- Number of unique pizzas  
Select count(distinct(name)) from pizza_types ; 

-- Highest priced pizza 
Select 
 name , size , price 
 from 
 pizza_types join pizzas 
 on pizzas.pizza_type_id = pizza_types.pizza_type_id 
 order by price desc 
 limit 1 ; 

-- Top 5 Priced pizzas 
 
Select 
 name , size , price 
 from 
 pizza_types join pizzas 
 on pizzas.pizza_type_id = pizza_types.pizza_type_id 
 order by price desc 
 limit 5 ; 

-- Most Common Pizza size 

Select  size , count(size) over(partition by pizza_id) Orders 
from order_details join pizzas using(pizza_id) 
order by orders desc 
limit 1 ; 

-- Most popular pizza among people 

Select name , count(order_id) orders 
from pizza_types join pizzas 
using (pizza_type_id)
join order_details 
using(pizza_id)
group by name 
order by orders desc 
limit 3 ; 

--  top 5 ordered pizza type 

Select pizza_type_id , count(order_id) Orders 
from order_details join pizzas 
using(pizza_id)
join pizza_types using(pizza_type_id) 
group by pizza_type_id
order by Orders desc
limit 5 ; 

-- Quantity of each category 

select category , count(order_id) orders , round(sum(price*quantity),2) Amount
from pizza_types join pizzas using(pizza_type_id) 
join 
order_details using(pizza_id) 
group by category 
order by orders desc 
; 


-- Category wise distribution of Pizzas (This shows what is the pizza popularity among the categories )

select * from (Select category , name , count(order_id) Count ,
dense_rank() over(partition by category order by count(order_id) desc) rnk
from order_details join pizzas using(pizza_id)
join pizza_types using(pizza_type_id) 
group by category , name ) Top_3 
where rnk <= 3 
; 

-- Time analysis of Orders  

-- Hourly order analysis (This will help to understand the customer patterns and inventory management ) 
select Time , sum(Orders) Total_Orders from (Select hour(time) as Time , count(order_id) Orders 
from orders 
group by Time 
order by orders desc ) A
group by Time 
order by Total_orders desc ; 

-- Average Pizza orders 

Select  round(sum(quantity)/count(distinct(date)),2) as Average_orders_in_year 
from order_details join orders 
on orders.order_id = order_details.order_id ; 

-- Daily order Stats  (This can help to understand the trends of ordres like for perticular days their might be high orders than other )

Select distinct(date) Day  , sum(quantity) Pizza_ordered
from order_details join orders using(order_id) 
group by Day 
order by Pizza_ordered desc ; 

-- Monthly order & revenue analysis 

Select monthname(date) MONTH ,
 count(order_id) orders ,
 sum(quantity) qty_ordered,
 round(sum(quantity*price),2) Revenue 
 from orders join order_details using(order_id)
 join 
 pizzas using(pizza_id)
 group by month  ;	

-- Top 5 Revenue generating types 

Select pizza_type_id ,category ,sum(price*quantity) Revenue 
from order_details join pizzas on order_details.pizza_id=pizzas.pizza_id
join pizza_types using (pizza_type_id) 
group by pizza_type_id , category
order by Revenue Desc 
limit 5 ;

-- Monthly cumulative sales 

Select distinct(monthname(date) ) Month,
round(sum(price*quantity) over( order by monthname(date)),2) as Cumulative_sum
from orders join order_details using(order_id) 
join pizzas using(pizza_id) 
; 

-- % cantribution of pizza type to reveue 

SELECT pizza_type_id, 
concat(round(SUM(price * quantity) / MAX(revenue) *100 ,2),"%")AS revenue_percentage
FROM (SELECT pizza_type_id, 
SUM(price * quantity) OVER() AS revenue,
price, 
quantity
FROM 
order_details JOIN 
pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types USING (pizza_type_id)
) AS A 
GROUP BY pizza_type_id
ORDER BY revenue_percentage DESC ;

-- Veg and Non veg sales (Customer segmentation)

select type , count(order_id) Orders ,
round(sum(quantity*price),2) Revenue 
from 
(SELECT pizza_type_id, category, ingredients, 
CASE 
	WHEN category = 'veggie' THEN 'Veg'
	ELSE 'Non-Veg'
END AS type
FROM pizza_types
ORDER BY type, 
category ) as a 
join pizzas using(pizza_type_id) 
join order_details using(pizza_id)
group by type  ;

-- Average  ticket size for categories 

select distinct(pizza_type_id) , 
round(avg(price) over(partition by pizza_type_id),2 ) as Average_price
from pizza_types join pizzas using(pizza_type_id)
order by average_price  ; 














