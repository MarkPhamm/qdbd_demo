select
    items.order_item_id,
    items.order_id,
    orders.customer_id,
    orders.order_date,
    items.product_name,
    items.quantity,
    items.unit_price,
    items.quantity * items.unit_price as line_amount
from {{ ref('stg_order_items') }} as items
inner join {{ ref('stg_orders') }} as orders
    on items.order_id = orders.order_id
