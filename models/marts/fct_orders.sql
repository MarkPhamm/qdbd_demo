with items as (
    select
        order_id,
        count(*) as line_count,
        sum(quantity * unit_price) as order_total
    from {{ ref('stg_order_items') }}
    group by order_id
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.status,
    coalesce(items.line_count, 0) as line_count,
    coalesce(items.order_total, 0) as order_total
from {{ ref('stg_orders') }} as orders
left join items
    on orders.order_id = items.order_id
