with customers as (
    select * from {{ ref('stg_customers') }}
),

orders_summary as (
    select
        customer_id,
        count(distinct order_id) as total_orders,
        min(order_purchase_at) as first_order_at,
        max(order_purchase_at) as last_order_at
    from {{ ref('int_orders_enriched') }}
    group by customer_id
),

final as (
    select
        customers.customer_id,
        customers.customer_unique_id,
        customers.customer_city,
        customers.customer_state,
        customers.customer_zip_code_prefix,
        coalesce(orders_summary.total_orders, 0) as total_orders,
        orders_summary.first_order_at,
        orders_summary.last_order_at
    from customers
    left join orders_summary
        on customers.customer_id = orders_summary.customer_id
)

select * from final
