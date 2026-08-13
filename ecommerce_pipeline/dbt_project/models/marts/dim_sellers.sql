with sellers as (
    select * from {{ ref('stg_sellers') }}
),

sales_summary as (
    select
        seller_id,
        count(distinct order_id) as total_orders,
        sum(price) as total_revenue
    from {{ ref('int_order_items_enriched') }}
    group by seller_id
),

final as (
    select
        sellers.seller_id,
        sellers.seller_city,
        sellers.seller_state,
        coalesce(sales_summary.total_orders, 0) as total_orders,
        coalesce(sales_summary.total_revenue, 0) as total_revenue
    from sellers
    left join sales_summary
        on sellers.seller_id = sales_summary.seller_id
)

select * from final
