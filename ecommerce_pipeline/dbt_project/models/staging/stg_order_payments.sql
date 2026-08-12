with source as (
    select * from {{ source('raw', 'raw_order_payments') }}
),

renamed as (
    select
        order_id,
        payment_sequential::int      as payment_sequential,
        payment_type,
        payment_installments::int    as payment_installments,
        payment_value::number(10,2)  as payment_value
    from source
)

select * from renamed
