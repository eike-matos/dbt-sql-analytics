with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

renamed as (
    select
        order_id,
        order_item_id::int as order_item_id,
        product_id,
        seller_id,
        shipping_limit_date::timestamp_ntz as shipping_limit_at,
        price::number(10,2)          as price,
        freight_value::number(10,2)  as freight_value
    from source
)

select * from renamed
