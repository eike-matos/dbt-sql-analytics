{{
    config(
        materialized='incremental',
        unique_key=['order_id', 'order_item_id'],
        incremental_strategy='merge',
        on_schema_change='sync_all_columns'
    )
}}

-- Grain: one row per order item (order_id + order_item_id).
-- Incremental strategy note: this is a historical, closed dataset (Olist),
-- so there's no true "new data" arriving over time. The incremental
-- configuration here is intentional, to demonstrate the pattern used in
-- production pipelines with continuously arriving order data. The filter
-- below simulates that behavior using order_purchase_at.

with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

order_items as (
    select * from {{ ref('int_order_items_enriched') }}
),

payments_summary as (
    select
        order_id,
        sum(payment_value) as total_payment_value,
        count(*) as payment_count
    from {{ ref('stg_order_payments') }}
    group by order_id
),

reviews_summary as (
    select
        order_id,
        avg(review_score) as avg_review_score
    from {{ ref('stg_order_reviews') }}
    group by order_id
),

final as (
    select
        order_items.order_id,
        order_items.order_item_id,
        orders.customer_id,
        order_items.product_id,
        order_items.seller_id,

        orders.order_status,
        orders.order_purchase_at,
        orders.order_delivered_customer_at,
        orders.delivery_days,
        orders.days_late,
        orders.was_delivered_late,

        order_items.price,
        order_items.freight_value,
        order_items.total_item_value,
        order_items.product_category_name_english,

        payments_summary.total_payment_value,
        payments_summary.payment_count,
        reviews_summary.avg_review_score

    from order_items
    left join orders
        on order_items.order_id = orders.order_id
    left join payments_summary
        on order_items.order_id = payments_summary.order_id
    left join reviews_summary
        on order_items.order_id = reviews_summary.order_id
)

select * from final

{% if is_incremental() %}
where order_purchase_at > (select max(order_purchase_at) from {{ this }})
{% endif %}
