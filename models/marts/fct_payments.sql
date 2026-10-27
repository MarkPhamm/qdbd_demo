select
    payments.payment_id,
    payments.order_id,
    orders.customer_id,
    orders.order_date,
    payments.payment_method,
    payments.amount
from {{ ref('stg_payments') }} as payments
inner join {{ ref('stg_orders') }} as orders
    on payments.order_id = orders.order_id
