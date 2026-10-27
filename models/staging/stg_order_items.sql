select
    order_item_id,
    order_id,
    product_name,
    quantity,
    cast(unit_price as decimal(10, 2)) as unit_price
from {{ source('erp', 'order_items') }}
