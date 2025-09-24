-- Gold model: Revenue and order counts aggregated by year
{{ config(materialized='table') }}

select
    year(o_orderdate) as order_year,
    sum(o_totalprice) as total_revenue,
    count(*) as order_count
from {{ source('tpch', 'orders') }}
group by order_year
