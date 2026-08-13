with products as (
    select distinct
        product_id,
        product_category_name,
        product_category_name_english,
        product_weight_g
    from {{ ref('int_order_items_enriched') }}
),

sales_summary as (
    select
        product_id,
        count(distinct order_id) as total_orders,
        sum(price) as total_revenue,
        avg(price) as avg_price
    from {{ ref('int_order_items_enriched') }}
    group by product_id
),

final as (
    select
        products.product_id,
        products.product_category_name,
        products.product_category_name_english,
        products.product_weight_g,
        coalesce(sales_summary.total_orders, 0) as total_orders,
        coalesce(sales_summary.total_revenue, 0) as total_revenue,
        sales_summary.avg_price
    from products
    left join sales_summary
        on products.product_id = sales_summary.product_id
)

select * from final
