/*
1)  Missing Orders in fact_orders

What we did:
We performed a RIGHT JOIN between "fact_orders" and "fact_order_items" on order_id to check if any order_id exists in "fact_order_items" but not in "fact_orders".

What we found:
There are 16425 orders in "fact_order_items" that do not have a matching record in "fact_orders", meaning these orders were not captured in the main order table even though order items exist.
*/
SELECT 
	count(distinct t2.order_id)
FROM 
	quick_bite_schema.fact_order_items AS t2
LEFT JOIN 
	quick_bite_schema.fact_orders AS t1
ON 
	t1.order_id = t2.order_id
WHERE 
	t1.order_id IS NULL




/*
2) Orders Missing Ratings

What we did:
We performed a LEFT JOIN between "fact_orders" and "fact_ratings" on order_id to identify whether every order received a rating.

What we found:
Some orders do not appear in "fact_ratings", which is expected since not all customers leave ratings or reviews. This is normal behavior.
*/
select 
	*
from
	quick_bite_schema.fact_orders as t1
left join 
	quick_bite_schema.fact_ratings as t2
on
	t1.order_id = t2.order_id;




/*
3) Missing Delivery Performance Records

What we did:
We performed a LEFT JOIN between "fact_orders" and "fact_delivery_performance" on order_id to check whether all orders have performance tracking.

What we found:
All orders in "fact_orders" have corresponding delivery performance records, no missing entries.
*/
select 
	*
from
	quick_bite_schema.fact_orders as t1
left join 
	quick_bite_schema.fact_delivery_performance as t2
on
	t1.order_id = t2.order_id
where
	t2.order_id is null;




/*
4) Missing Customer Details

What we did:
We performed a LEFT JOIN between "fact_orders" and "dim_customer" on customer_id to verify whether every order has a valid customer.

What we found:
There are 5,053 orders that reference customers not found in the "dim_customer" table.
This means customer dimension data is incomplete for those transactions.
*/
select 
	count(*) as missing_customers_in_dim
from
	quick_bite_schema.fact_orders as t1
left join 
	quick_bite_schema.dim_customer as t2
on
	t1.customer_id = t2.customer_id
where
	t2.customer_id is null;




/*
5) Restaurant Validation

What we did:
We performed a LEFT JOIN between "fact_orders" and "dim_restaurant" on restaurant_id to check if all restaurants involved in orders exist in the restaurant dimension.

What we found:
All restaurants in "fact_orders" exist in "dim_restaurant", no missing or invalid restaurants.
*/
select 
	*
from
	quick_bite_schema.fact_orders as t1
left join 
	quick_bite_schema.dim_restaurant as t2
on
	t1.restaurant_id = t2.restaurant_id
where
	t2.restaurant_id is null;




/*
6) Delivery Partners Assigned to Cancelled Orders

What we did:
We performed a LEFT JOIN between "fact_orders" and "dim_delivery_partner" to analyze orders that were cancelled but still had delivery partners assigned.

What we found:
Some cancelled orders had delivery partners assigned even though the monetary fields (subtotal_amount, total_amount, delivery_fee) were 0, indicating these were cancelled after partner assignment, a data inconsistency worth noting.
*/
select 
	*
from
	quick_bite_schema.fact_orders as t1
left join 
	quick_bite_schema.dim_delivery_partner as t2
on
	t1.delivery_partner_id = t2.delivery_partner_id
where
	t2.delivery_partner_id is not null and t1.is_cancelled = 'Y';




/*
7) Restaurants Without Menu Items

What we did:
We performed a LEFT JOIN between "dim_restaurant" and "dim_menu_item" on restaurant_id to identify restaurants that have no menu items listed.

What we found:
Some restaurants exist in "dim_restaurant" but have no corresponding menu items in "dim_menu_item".
Further analysis of "fact_orders" showed that orders from these restaurants were all cancelled, confirming these restaurants might be inactive or not onboarded fully.
*/
select 
	*
from
	quick_bite_schema.dim_restaurant as t1
left join 
	quick_bite_schema.dim_menu_item as t2
on
	t1.restaurant_id = t2.restaurant_id
where
	t2.restaurant_id is null;
-- Restaurants wuth no menu details in the dim_menu_item
select
	*
from
	quick_bite_schema.fact_orders
where 
	restaurant_id in ('REST19114', 'REST18903', 'REST04209', 'REST07109', 'REST19114');








-- this is how we will form the rows for missing order id in the fact_orders
-- order_id: can get directly
-- customer_id: unknown
-- resturant_id: can get directly 
-- delivery partner unknonw
-- order_timestamp unknown
-- subtotal_amount : sum(unit_price) 
-- discount_amount:sum(item_discount)
-- delievry_fee: unknown
-- total_amount: subtotal_amount - discount_delivery_fee(unknown)
-- is_cod: unknown
-- is_cancelld: N