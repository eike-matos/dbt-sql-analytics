with source as (
    select * from {{ source('raw', 'raw_geolocation') }}
),

renamed as (
    select
        geolocation_zip_code_prefix,
        geolocation_lat::float  as geolocation_lat,
        geolocation_lng::float  as geolocation_lng,
        geolocation_city,
        upper(geolocation_state) as geolocation_state
    from source
)

select * from renamed
