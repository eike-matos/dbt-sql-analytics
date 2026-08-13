with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

sellers as (
    select * from {{ ref('stg_sellers') }}
),

category_translation as (
    select * from {{ ref('stg_product_category_translation') }}
),

products_with_category as (
    select
        products.product_id,
        products.product_category_name,
        coalesce(
            category_translation.product_category_name_english,
            products.product_category_name
        ) as product_category_name_english,
        products.product_weight_g,
        products.product_length_cm,
        products.product_height_cm,
        products.product_width_cm
    from products
    left join category_translation
        on products.product_category_name = category_translation.product_category_name
),

final as (
    select
        order_items.order_id,
        order_items.order_item_id,
        order_items.product_id,
        order_items.seller_id,
        order_items.shipping_limit_at,
        order_items.price,
        order_items.freight_value,
        order_items.price + order_items.freight_value as total_item_value,

        products_with_category.product_category_name,
        products_with_category.product_category_name_english,
        products_with_category.product_weight_g,

        sellers.seller_city,
        sellers.seller_state

    from order_items
    left join products_with_category
        on order_items.product_id = products_with_category.product_id
    left join sellers
        on order_items.seller_id = sellers.seller_id
)

select * from final
