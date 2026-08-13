"""
Ecommerce Analytics Dashboard.

Reads directly from the MARTS schema in Snowflake using READER_ROLE
(read-only access), following the least-privilege pattern established
across the rest of this project.
"""

import os
from pathlib import Path

import pandas as pd
import plotly.express as px
import snowflake.connector
import streamlit as st
from dotenv import load_dotenv

ENV_PATH = Path(__file__).resolve().parent / ".env"
load_dotenv(dotenv_path=ENV_PATH, override=True)

st.set_page_config(
    page_title="Ecommerce Analytics",
    page_icon="📊",
    layout="wide",
)


@st.cache_resource
def get_connection():
    return snowflake.connector.connect(
        account=f"{os.environ['SNOWFLAKE_ORGANIZATION_NAME']}-{os.environ['SNOWFLAKE_ACCOUNT_NAME']}",
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        role=os.environ["SNOWFLAKE_ROLE"],
        warehouse=os.environ["SNOWFLAKE_WAREHOUSE"],
        database=os.environ["SNOWFLAKE_DATABASE"],
        schema=os.environ["SNOWFLAKE_SCHEMA"],
    )


@st.cache_data(ttl=600)
def run_query(query: str) -> pd.DataFrame:
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(query)
    columns = [desc[0] for desc in cursor.description]
    rows = cursor.fetchall()
    return pd.DataFrame(rows, columns=columns)


st.title("📊 Ecommerce Analytics Dashboard")
st.caption("Data source: Olist Brazilian Ecommerce — served from Snowflake MARTS via READER_ROLE")

# --- Top-level KPIs -----------------------------------------------------
kpi_df = run_query("""
    select
        count(distinct order_id) as total_orders,
        count(distinct customer_id) as total_customers,
        sum(total_item_value) as total_revenue,
        avg(avg_review_score) as avg_review_score
    from fct_orders
""")

col1, col2, col3, col4 = st.columns(4)
col1.metric("Total Orders", f"{kpi_df['TOTAL_ORDERS'][0]:,}")
col2.metric("Total Customers", f"{kpi_df['TOTAL_CUSTOMERS'][0]:,}")
col3.metric("Total Revenue", f"R$ {kpi_df['TOTAL_REVENUE'][0]:,.2f}")
col4.metric("Avg Review Score", f"{kpi_df['AVG_REVIEW_SCORE'][0]:.2f} / 5")

st.divider()

# --- Revenue by category -------------------------------------------------
st.subheader("Revenue by Product Category")

category_df = run_query("""
    select
        product_category_name_english as category,
        sum(total_item_value) as revenue,
        count(distinct order_id) as orders
    from fct_orders
    where product_category_name_english is not null
    group by category
    order by revenue desc
    limit 15
""")

fig_category = px.bar(
    category_df,
    x="REVENUE",
    y="CATEGORY",
    orientation="h",
    labels={"REVENUE": "Revenue (BRL)", "CATEGORY": "Category"},
)
fig_category.update_layout(yaxis={"categoryorder": "total ascending"})
st.plotly_chart(fig_category, width='stretch')

st.divider()

# --- Delivery performance -------------------------------------------------
st.subheader("Delivery Performance")

col_a, col_b = st.columns(2)

with col_a:
    delivery_df = run_query("""
        select
            was_delivered_late,
            count(distinct order_id) as order_count
        from fct_orders
        where was_delivered_late is not null
        group by was_delivered_late
    """)
    delivery_df["STATUS"] = delivery_df["WAS_DELIVERED_LATE"].map(
        {True: "Late", False: "On time"}
    )
    fig_delivery = px.pie(
        delivery_df, names="STATUS", values="ORDER_COUNT", title="On-time vs Late Deliveries"
    )
    st.plotly_chart(fig_delivery, width='stretch')

with col_b:
    state_df = run_query("""
        select
            customer_state as state,
            count(distinct order_id) as orders
        from intermediate.int_orders_enriched
        where customer_state is not null
        group by state
        order by orders desc
        limit 10
    """)
    fig_state = px.bar(
        state_df, x="STATE", y="ORDERS", title="Top 10 States by Order Volume"
    )
    st.plotly_chart(fig_state, width='stretch')

st.divider()

# --- Top sellers -----------------------------------------------------------
st.subheader("Top Sellers by Revenue")

sellers_df = run_query("""
    select
        seller_id,
        seller_city,
        seller_state,
        total_orders,
        total_revenue
    from dim_sellers
    order by total_revenue desc
    limit 10
""")
st.dataframe(sellers_df, width='stretch', hide_index=True)
