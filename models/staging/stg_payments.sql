select
    payment_id,
    order_id,
    payment_method,
    cast(amount as decimal(10, 2)) as amount
from {{ source('erp', 'payments') }}
