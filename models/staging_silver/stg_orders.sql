-- Staging model for orders enriched with customer data
{{ config(materialized='table') }}

with orders as (
    select
        o_orderkey   as order_id,
        o_custkey    as customer_id,
        o_orderdate  as order_date,
        o_totalprice as total_price
    from {{ source('tpch', 'orders') }}
),

customers as (
    select
        c_custkey   as customer_id,
        c_name      as customer_name
    from {{ source('tpch', 'customer') }}
)

select
    o.order_id,
    o.customer_id,
    c.customer_name,
    o.order_date,
    year(o.order_date) as order_year,
    o.total_price
from orders o
left join customers c
    on o.customer_id = c.customer_id
