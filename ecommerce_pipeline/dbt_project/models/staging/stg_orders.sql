with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

renamed as (
    select
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp::timestamp_ntz    as order_purchase_at,
        order_approved_at::timestamp_ntz            as order_approved_at,
        order_delivered_carrier_date::timestamp_ntz as order_delivered_carrier_at,
        order_delivered_customer_date::timestamp_ntz as order_delivered_customer_at,
        order_estimated_delivery_date::timestamp_ntz as order_estimated_delivery_at
    from source
)

select * from renamed
