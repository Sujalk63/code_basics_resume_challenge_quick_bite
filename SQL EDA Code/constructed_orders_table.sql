select * from quick_bite_schema.fact_orders;

-- ORD202501000001	ITEM001	MENU04565_1683	REST04565	1	125.8	18.79	107.01
-- ORD202501000001	ITEM002	MENU04565_4202	REST04565	1	137.49	20.54	116.95

with missing_order_id_in_fact_orders as(
    SELECT 
        distinct t2.order_id
    FROM 
        quick_bite_schema.fact_order_items AS t2
    LEFT JOIN 
        quick_bite_schema.fact_orders AS t1
    ON 
        t1.order_id = t2.order_id
    WHERE 
        t1.order_id IS NULL
)
, constructed as (
select 
    order_id,
    null as customer_id,
    max(restaurant_id) as restaurant_id,
    null as delivery_partner_id,
    null as order_timestamp,
    round(SUM(line_total), 2) as subtotal_amount,
    round(sum(item_discount), 2) as discount_amount,
    0 as delivery_fee,
    0 as total_amount,
    null as is_cod,
    'N' as is_cancelled 
from 
    quick_bite_schema.fact_order_items
where
    order_id in (select order_id from missing_order_id_in_fact_orders)
group by
    order_id
)
,appended as (
select * from quick_bite_schema.fact_orders
UNION ALL
select * from constructed
)
SELECT *,
    FORMAT(DATEFROMPARTS(CAST(SUBSTRING(order_id, 4, 4) AS INT), CAST(SUBSTRING(order_id, 8, 2) AS INT), 1), 'MMM') AS ordered_month
FROM appended
ORDER BY order_id;








