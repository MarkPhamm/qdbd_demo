with bounds as (
    select
        min(order_date) as start_date,
        max(order_date) as end_date
    from {{ ref('stg_orders') }}
)

select
    cast(series.date_day as date) as date_day,
    extract(year from series.date_day) as year,
    extract(month from series.date_day) as month,
    extract(day from series.date_day) as day
from bounds
cross join generate_series(bounds.start_date, bounds.end_date, interval 1 day) as series(date_day)
