-- Gold model: Customer revenue aggregated by nation
{{ config(materialized='table') }}

with customers as (
    select
        c_custkey   as customer_id,
        c_name      as customer_name,
        c_nationkey
    from {{ source('tpch', 'customer') }}
),

orders as (
    select
        o_orderkey as order_id,
        o_custkey  as customer_id
    from {{ source('tpch', 'orders') }}
),

lineitems as (
    select
        l_orderkey       as order_id,
        l_extendedprice,
        l_discount
    from {{ source('tpch', 'lineitem') }}
),

nations as (
    select
        n_nationkey,
        n_name as nation
    from {{ source('tpch', 'nation') }}
),

revenue as (
    select
        c.customer_id,
        c.customer_name,
        n.nation,
        sum(l.l_extendedprice * (1 - l.l_discount)) as total_revenue
    from orders o
    join customers c
        on o.customer_id = c.customer_id
    join lineitems l
        on o.order_id = l.order_id
    join nations n
        on c.c_nationkey = n.n_nationkey
    group by c.customer_id, c.customer_name, n.nation
)

select * from revenue
