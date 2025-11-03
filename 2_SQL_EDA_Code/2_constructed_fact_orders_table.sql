-- Since the fact_orders table contained around 16,425 missing records, we are retrieving and appending those missing values from the fact_order_items table.
-- During this process, we apply appropriate data imputation methods to fill missing values in each column accurately.
-- The following steps create a new table, constructed_orders, in SQL Server with all corrected and imputed data.
-- The only unfilled data we have is for customer_id and delivery_partner_id.


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
    31.48 as delivery_fee, -- why 31.48, discussed in ETL.ipynb file, filling missing values with the median value of delivery_fee
    round(round(SUM(line_total), 2) + 31.48 - round(sum(item_discount), 2), 2) as total_amount,
    'N' as is_cod, -- as in the data online payments are double the offiline payments, so it is safe to take it 'N'
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
,adding_month_names as(
SELECT *,
    FORMAT(DATEFROMPARTS(CAST(SUBSTRING(order_id, 4, 4) AS INT), CAST(SUBSTRING(order_id, 8, 2) AS INT), 1), 'MMM') AS ordered_month
FROM appended
)
select * into quick_bite_schema.constructed_fact_orders_table  from adding_month_names


-- reensuring if we have the correct data 16425(missing data) + count(*) fact_orders shoudl be equal to 1,65,591
select count(*) cnt from quick_bite_schema.constructed_fact_orders_table;
select count(*) cnt from quick_bite_schema.fact_orders; -- + 16,425

select * from quick_bite_schema.constructed_fact_orders_table;