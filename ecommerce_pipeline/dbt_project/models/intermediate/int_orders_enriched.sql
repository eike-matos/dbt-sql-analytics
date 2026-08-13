with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

geolocation as (
    select
        geolocation_zip_code_prefix,
        avg(geolocation_lat) as avg_lat,
        avg(geolocation_lng) as avg_lng
    from {{ ref('stg_geolocation') }}
    group by geolocation_zip_code_prefix
),

orders_with_customer as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_status,
        orders.order_purchase_at,
        orders.order_approved_at,
        orders.order_delivered_carrier_at,
        orders.order_delivered_customer_at,
        orders.order_estimated_delivery_at,
        customers.customer_unique_id,
        customers.customer_city,
        customers.customer_state,
        customers.customer_zip_code_prefix
    from orders
    left join customers
        on orders.customer_id = customers.customer_id
),

final as (
    select
        orders_with_customer.*,
        geolocation.avg_lat as customer_lat,
        geolocation.avg_lng as customer_lng,

        datediff(
            'day',
            orders_with_customer.order_purchase_at,
            orders_with_customer.order_delivered_customer_at
        ) as delivery_days,

        datediff(
            'day',
            orders_with_customer.order_estimated_delivery_at,
            orders_with_customer.order_delivered_customer_at
        ) as days_late,

        case
            when orders_with_customer.order_delivered_customer_at is null then null
            when orders_with_customer.order_delivered_customer_at
                 > orders_with_customer.order_estimated_delivery_at
                then true
            else false
        end as was_delivered_late

    from orders_with_customer
    left join geolocation
        on orders_with_customer.customer_zip_code_prefix
           = geolocation.geolocation_zip_code_prefix
)

select * from final
