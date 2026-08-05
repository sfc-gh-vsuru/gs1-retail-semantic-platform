import streamlit as st
from snowflake.snowpark.context import get_active_session

st.set_page_config(
    page_title="GS1 Retail Observability",
    layout="wide",
)

session = get_active_session()


@st.cache_data(ttl=300)
def run_query(sql):
    return session.sql(sql).to_pandas()


st.title("GS1 Retail Observability Platform")
st.caption("NovaBrand Foods Ltd + FreshMart Retail Group | Snowflake Semantic Views + DMFs + Cortex Analyst")

# ============================================================
# KPI ROW
# ============================================================

kpi_data = run_query("""
    SELECT
        COUNT(*) AS TOTAL_GTINS,
        COUNT_IF(gtin_status = 'ACTIVE') AS ACTIVE_GTINS,
        ROUND(AVG(attribute_completeness_pct), 1) AS AVG_COMPLETENESS,
        ROUND(MIN(attribute_completeness_pct), 1) AS MIN_COMPLETENESS,
        COUNT_IF(attribute_completeness_pct < 95) AS BELOW_95_COUNT
    FROM GS1_DB.DEMO.PRODUCT_ATTRIBUTES
""")

epcis_kpi = run_query("""
    SELECT COUNT(*) AS TOTAL_EVENTS,
           COUNT(DISTINCT gtin) AS TRACEABLE_GTINS
    FROM GS1_DB.DEMO.EPCIS_OBJECT_EVENTS
""")

sync_kpi = run_query("""
    SELECT COUNT(*) AS TOTAL_SYNCS,
           COUNT_IF(sync_status = 'FAILED') AS FAILED_SYNCS,
           COUNT_IF(sync_status = 'SUCCESS') AS SUCCESS_SYNCS
    FROM GS1_DB.DEMO.GDSN_SYNC_LOG
""")

verification_kpi = run_query("""
    SELECT COUNT(*) AS TOTAL_LOOKUPS,
           COUNT_IF(lookup_result = 'VALID') AS VALID_LOOKUPS,
           COUNT_IF(lookup_result = 'NOT_FOUND') AS NOT_FOUND,
           ROUND(COUNT_IF(lookup_result = 'VALID') * 100.0 / NULLIF(COUNT(*), 0), 1) AS SUCCESS_RATE
    FROM GS1_DB.DEMO.VERIFIED_BY_GS1_LOOKUPS
""")

with st.container(horizontal=True):
    st.metric(
        "Active GTINs",
        kpi_data["ACTIVE_GTINS"].iloc[0],
        delta=f"{kpi_data['ACTIVE_GTINS'].iloc[0]}/{kpi_data['TOTAL_GTINS'].iloc[0]} registered",
        border=True,
    )
    st.metric(
        "Avg Data Completeness",
        f"{kpi_data['AVG_COMPLETENESS'].iloc[0]}%",
        delta=f"Min: {kpi_data['MIN_COMPLETENESS'].iloc[0]}%",
        border=True,
    )
    st.metric(
        "Supply Chain Events",
        epcis_kpi["TOTAL_EVENTS"].iloc[0],
        delta=f"{epcis_kpi['TRACEABLE_GTINS'].iloc[0]} GTINs tracked",
        border=True,
    )
    st.metric(
        "GDSN Sync Health",
        f"{sync_kpi['SUCCESS_SYNCS'].iloc[0]} OK",
        delta=f"-{sync_kpi['FAILED_SYNCS'].iloc[0]} failures",
        delta_color="inverse",
        border=True,
    )
    st.metric(
        "Verification Rate",
        f"{verification_kpi['SUCCESS_RATE'].iloc[0]}%",
        delta=f"{verification_kpi['VALID_LOOKUPS'].iloc[0]} valid of {verification_kpi['TOTAL_LOOKUPS'].iloc[0]}",
        border=True,
    )


# ============================================================
# PRODUCT DATA QUALITY
# ============================================================

st.divider()
st.subheader("Product Data Quality — GDM Attribute Completeness")

col1, col2 = st.columns([3, 2])

with col1:
    completeness_by_category = run_query("""
        SELECT
            gpc_brick_name AS CATEGORY,
            ROUND(AVG(attribute_completeness_pct), 1) AS COMPLETENESS
        FROM GS1_DB.DEMO.PRODUCT_ATTRIBUTES
        GROUP BY 1
        ORDER BY 2 ASC
    """)
    with st.container(border=True):
        st.markdown("**Completeness by Product Category**")
        st.bar_chart(
            completeness_by_category,
            x="CATEGORY",
            y="COMPLETENESS",
            horizontal=True,
            color="#2563EB",
        )

with col2:
    products_detail = run_query("""
        SELECT
            product_description_short AS PRODUCT,
            gpc_brick_name AS CATEGORY,
            attribute_completeness_pct AS "COMPLETENESS %",
            TO_CHAR(gdsn_last_sync_date, 'YYYY-MM-DD') AS LAST_SYNC
        FROM GS1_DB.DEMO.PRODUCT_ATTRIBUTES
        ORDER BY attribute_completeness_pct ASC
    """)
    with st.container(border=True):
        st.markdown("**All Products — Ranked by Completeness**")
        st.dataframe(products_detail, hide_index=True, use_container_width=True)


# ============================================================
# SUPPLY CHAIN EVENTS (EPCIS)
# ============================================================

st.divider()
st.subheader("Supply Chain Visibility — EPCIS 2.0 Events")

col1, col2 = st.columns(2)

with col1:
    events_by_step = run_query("""
        SELECT
            INITCAP(biz_step) AS BUSINESS_STEP,
            COUNT(*) AS EVENTS
        FROM GS1_DB.DEMO.EPCIS_OBJECT_EVENTS
        GROUP BY 1
        ORDER BY 2 DESC
    """)
    with st.container(border=True):
        st.markdown("**Events by Business Step**")
        st.bar_chart(events_by_step, x="BUSINESS_STEP", y="EVENTS", color="#10B981")

with col2:
    events_by_location = run_query("""
        SELECT
            l.party_name AS LOCATION,
            l.location_type AS TYPE,
            COUNT(e.event_id) AS EVENTS
        FROM GS1_DB.DEMO.EPCIS_OBJECT_EVENTS e
        JOIN GS1_DB.DEMO.GLN_REGISTRY l ON e.biz_location_gln = l.gln
        GROUP BY 1, 2
        ORDER BY 3 DESC
    """)
    with st.container(border=True):
        st.markdown("**Events by Location**")
        st.dataframe(events_by_location, hide_index=True, use_container_width=True)


# ============================================================
# GDSN SYNCHRONIZATION + VERIFICATION (side by side)
# ============================================================

st.divider()
st.subheader("Data Exchange Health")

col1, col2, col3 = st.columns(3)

with col1:
    sync_by_status = run_query("""
        SELECT
            sync_status AS STATUS,
            COUNT(*) AS SYNCS
        FROM GS1_DB.DEMO.GDSN_SYNC_LOG
        GROUP BY 1
    """)
    with st.container(border=True):
        st.markdown("**GDSN Sync Results**")
        st.bar_chart(sync_by_status, x="STATUS", y="SYNCS", color="#6366F1")

with col2:
    by_result = run_query("""
        SELECT
            lookup_result AS RESULT,
            COUNT(*) AS LOOKUPS
        FROM GS1_DB.DEMO.VERIFIED_BY_GS1_LOOKUPS
        GROUP BY 1
        ORDER BY 2 DESC
    """)
    with st.container(border=True):
        st.markdown("**Verified by GS1 — Results**")
        st.bar_chart(by_result, x="RESULT", y="LOOKUPS", color="#F59E0B")

with col3:
    by_requester = run_query("""
        SELECT
            requester_type AS REQUESTER,
            COUNT(*) AS LOOKUPS
        FROM GS1_DB.DEMO.VERIFIED_BY_GS1_LOOKUPS
        GROUP BY 1
        ORDER BY 2 DESC
    """)
    with st.container(border=True):
        st.markdown("**Lookups by Requester Type**")
        st.bar_chart(by_requester, x="REQUESTER", y="LOOKUPS", color="#EC4899")


# ============================================================
# SYNC FAILURES + VERIFICATION BY COUNTRY
# ============================================================

col1, col2 = st.columns(2)

with col1:
    recent_failures = run_query("""
        SELECT
            p.product_description_short AS PRODUCT,
            s.sync_timestamp AS TIMESTAMP,
            s.error_message AS ERROR
        FROM GS1_DB.DEMO.GDSN_SYNC_LOG s
        LEFT JOIN GS1_DB.DEMO.PRODUCT_ATTRIBUTES p ON s.gtin = p.gtin
        WHERE s.sync_status = 'FAILED'
        ORDER BY s.sync_timestamp DESC
        LIMIT 10
    """)
    with st.container(border=True):
        st.markdown("**Recent GDSN Sync Failures**")
        if len(recent_failures) > 0:
            st.dataframe(recent_failures, hide_index=True, use_container_width=True)
        else:
            st.success("No sync failures detected")

with col2:
    by_country = run_query("""
        SELECT
            requester_country AS COUNTRY,
            COUNT(*) AS LOOKUPS
        FROM GS1_DB.DEMO.VERIFIED_BY_GS1_LOOKUPS
        GROUP BY 1
        ORDER BY 2 DESC
    """)
    with st.container(border=True):
        st.markdown("**Verification Lookups by Country**")
        st.bar_chart(by_country, x="COUNTRY", y="LOOKUPS", color="#8B5CF6")


# ============================================================
# LOCATION MAP
# ============================================================

st.divider()
st.subheader("GS1 Location Network — NovaBrand + FreshMart")

locations = run_query("""
    SELECT
        party_name AS PARTY_NAME,
        location_type AS LOCATION_TYPE,
        city AS CITY,
        latitude AS LATITUDE,
        longitude AS LONGITUDE
    FROM GS1_DB.DEMO.GLN_REGISTRY
    WHERE latitude IS NOT NULL
""")

col1, col2 = st.columns([3, 1])

with col1:
    with st.container(border=True):
        st.map(locations, latitude="LATITUDE", longitude="LONGITUDE")

with col2:
    with st.container(border=True):
        st.markdown("**Locations**")
        st.dataframe(
            locations[["PARTY_NAME", "LOCATION_TYPE", "CITY"]],
            hide_index=True,
            use_container_width=True,
        )


# ============================================================
# FOOTER
# ============================================================

st.divider()
st.caption(
    "GS1 Retail Observability Platform | Stage 1 MVP | "
    "Snowflake Semantic Views + Cortex Analyst + Data Metric Functions"
)
