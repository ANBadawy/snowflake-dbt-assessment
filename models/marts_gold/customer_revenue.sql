-- Gold model: Revenue aggregated by customer
{{ config(materialized='table') }}
with orders as (
    select * from {{ ref('stg_orders') }}
),

lineitems as (
    select
        l_orderkey   as order_id,
        l_extendedprice,
        l_discount
    from {{ source('tpch', 'lineitem') }}
),

revenue as (
    select
        o.customer_id,
        o.customer_name,
        sum(l.l_extendedprice * (1 - l.l_discount)) as total_revenue
    from orders o
    join lineitems l
        on o.order_id = l.order_id
    group by o.customer_id, o.customer_name
)

select * from revenue