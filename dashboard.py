# =============================================================
# dashboard.py — PPE Monitoring System
# Reads from MySQL and displays a live web dashboard
#
# HOW TO RUN:
#   cd C:\ppe_project
#   python -m streamlit run dashboard.py
#
# Then open your browser to: http://localhost:8501
# =============================================================

import streamlit as st
import pandas as pd
import mysql.connector
import config
from datetime import datetime

# ── Page config ───────────────────────────────────────────────
st.set_page_config(
    page_title="PPE Monitoring System",
    page_icon="🦺",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ── Custom CSS ────────────────────────────────────────────────
st.markdown("""
<style>
    .main { background-color: #F8FAFC; }
    .block-container { padding: 1.5rem 2rem; }
    .kpi-card {
        background: white;
        border-radius: 10px;
        padding: 16px 20px;
        border-top: 4px solid #ccc;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
    }
    .kpi-label {
        font-size: 11px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.06em;
        color: #64748B;
        margin-bottom: 4px;
    }
    .kpi-number {
        font-size: 36px;
        font-weight: 700;
        line-height: 1;
        margin-bottom: 4px;
    }
    .kpi-desc {
        font-size: 11px;
        color: #94A3B8;
    }
    .status-active      { color: #059669; }
    .status-expiring    { color: #D97706; }
    .status-action      { color: #DC2626; }
    .status-expired     { color: #475569; }
    .status-returned    { color: #2563EB; }
    .status-total       { color: #B45309; }
    div[data-testid="stMetricValue"] { font-size: 2rem; }
    .stDataFrame { border-radius: 8px; }
    header[data-testid="stHeader"] { background: #1E293B; }
</style>
""", unsafe_allow_html=True)

# ── Database connection ───────────────────────────────────────
@st.cache_resource
def get_connection():
    return mysql.connector.connect(**config.DB_CONFIG)

@st.cache_data(ttl=30)
def load_data():
    conn = mysql.connector.connect(**config.DB_CONFIG)

    # Full status view
    df = pd.read_sql("""
        SELECT
            employee,
            designation,
            ppe_type,
            brand_model,
            issuance_date,
            expiry_date,
            source,
            condition_status,
            current_status
        FROM current_ppe_status
        ORDER BY employee, ppe_type
    """, conn)

    # KPI counts
    kpi = pd.read_sql("""
        SELECT
            SUM(current_status = 'Active')                                  AS active,
            SUM(current_status = 'Expiring Soon')                           AS expiring_soon,
            SUM(current_status IN ('For Replacement','Damaged',
                'Lost - For Replacement','Misplaced - For Replacement'))    AS needs_action,
            SUM(current_status = 'Expired')                                 AS expired,
            SUM(current_status IN ('Returned','Replaced'))                  AS returned_replaced,
            COUNT(*)                                                         AS total
        FROM current_ppe_status
    """, conn)

    # Expiring soon detail
    expiring = pd.read_sql("""
        SELECT employee, designation, ppe_type, issuance_date,
               expiry_date, days_remaining
        FROM expiring_soon
        ORDER BY days_remaining ASC
    """, conn)

    # Needs action detail
    action = pd.read_sql("""
        SELECT employee, designation, ppe_type,
               condition_status, issuance_date
        FROM needs_action
        ORDER BY condition_status, employee
    """, conn)

    # Status history
    history = pd.read_sql("""
        SELECT
            e.full_name  AS employee,
            c.ppe_type,
            l.old_condition,
            l.new_condition,
            l.old_status,
            l.new_status,
            l.changed_at
        FROM ppe_status_log l
        JOIN ppe_issuances  i ON i.issuance_id = l.issuance_id
        JOIN employees      e ON e.employee_id  = i.employee_id
        JOIN ppe_catalog    c ON c.catalog_id   = i.catalog_id
        ORDER BY l.changed_at DESC
        LIMIT 50
    """, conn)

    conn.close()
    return df, kpi, expiring, action, history

# ── Status badge colors ───────────────────────────────────────
STATUS_COLORS = {
    "Active":                    "🟢",
    "Expiring Soon":             "🟡",
    "For Replacement":           "🔴",
    "Damaged":                   "🟠",
    "Lost - For Replacement":    "🟣",
    "Misplaced - For Replacement":"🟣",
    "Expired":                   "⚫",
    "Returned":                  "🔵",
    "Replaced":                  "🔵",
}

def badge(status):
    icon = STATUS_COLORS.get(status, "⚪")
    return f"{icon} {status}"

# ── Header ────────────────────────────────────────────────────
col_logo, col_title, col_date = st.columns([1, 6, 2])
with col_logo:
    st.markdown("## 🦺")
with col_title:
    st.markdown("# PPE Monitoring System")
    st.markdown("**Real-Time PPE Status Dashboard** — Source: MySQL `ppe_tracking`")
with col_date:
    st.markdown(f"**{datetime.now().strftime('%b %d, %Y')}**")
    st.markdown(f"*Last loaded: {datetime.now().strftime('%H:%M:%S')}*")

st.divider()

# ── Load data ─────────────────────────────────────────────────
try:
    df, kpi, expiring, action, history = load_data()
except Exception as e:
    st.error(f"Could not connect to MySQL: {e}")
    st.info("Make sure MySQL is running and your config.py credentials are correct.")
    st.stop()

# ── Sidebar filters ───────────────────────────────────────────
with st.sidebar:
    st.markdown("## 🔍 Filters")
    st.markdown("---")

    # Employee filter
    all_employees = ["All"] + sorted(df["employee"].unique().tolist())
    selected_emp = st.selectbox("Employee", all_employees)

    # PPE Type filter
    all_ppe = ["All"] + sorted(df["ppe_type"].unique().tolist())
    selected_ppe = st.selectbox("PPE Type", all_ppe)

    # Status filter
    all_statuses = ["All"] + sorted(df["current_status"].unique().tolist())
    selected_status = st.selectbox("Status", all_statuses)

    # Designation filter
    all_desig = ["All"] + sorted(df["designation"].unique().tolist())
    selected_desig = st.selectbox("Designation", all_desig)

    st.markdown("---")
    st.markdown("### 📖 How to use")
    st.markdown("""
1. Add PPE in **Excel PPE_RECORDS**
2. Run `python sync.py` to push to MySQL
3. Refresh this page to see updates
4. Use filters above to drill down
    """)

    st.markdown("---")
    if st.button("🔄 Refresh data"):
        st.cache_data.clear()
        st.rerun()

# ── Apply filters ─────────────────────────────────────────────
filtered = df.copy()
if selected_emp    != "All": filtered = filtered[filtered["employee"]       == selected_emp]
if selected_ppe    != "All": filtered = filtered[filtered["ppe_type"]       == selected_ppe]
if selected_status != "All": filtered = filtered[filtered["current_status"] == selected_status]
if selected_desig  != "All": filtered = filtered[filtered["designation"]    == selected_desig]

# ── KPI Cards ─────────────────────────────────────────────────
st.markdown("### 📊 Overview")

k = kpi.iloc[0]
c1, c2, c3, c4, c5, c6 = st.columns(6)

with c1:
    st.markdown(f"""<div class="kpi-card" style="border-top-color:#059669">
        <div class="kpi-label">Active</div>
        <div class="kpi-number status-active">{int(k['active'])}</div>
        <div class="kpi-desc">Currently in use</div>
    </div>""", unsafe_allow_html=True)

with c2:
    st.markdown(f"""<div class="kpi-card" style="border-top-color:#D97706">
        <div class="kpi-label">Expiring Soon</div>
        <div class="kpi-number status-expiring">{int(k['expiring_soon'])}</div>
        <div class="kpi-desc">Within 30 days</div>
    </div>""", unsafe_allow_html=True)

with c3:
    st.markdown(f"""<div class="kpi-card" style="border-top-color:#DC2626">
        <div class="kpi-label">Needs Action</div>
        <div class="kpi-number status-action">{int(k['needs_action'])}</div>
        <div class="kpi-desc">Replace / Damaged / Lost</div>
    </div>""", unsafe_allow_html=True)

with c4:
    st.markdown(f"""<div class="kpi-card" style="border-top-color:#475569">
        <div class="kpi-label">Expired</div>
        <div class="kpi-number status-expired">{int(k['expired'])}</div>
        <div class="kpi-desc">Past expiry date</div>
    </div>""", unsafe_allow_html=True)

with c5:
    st.markdown(f"""<div class="kpi-card" style="border-top-color:#2563EB">
        <div class="kpi-label">Returned</div>
        <div class="kpi-number status-returned">{int(k['returned_replaced'])}</div>
        <div class="kpi-desc">Returned or replaced</div>
    </div>""", unsafe_allow_html=True)

with c6:
    st.markdown(f"""<div class="kpi-card" style="border-top-color:#B45309">
        <div class="kpi-label">Total Records</div>
        <div class="kpi-number status-total">{int(k['total'])}</div>
        <div class="kpi-desc">All PPE records</div>
    </div>""", unsafe_allow_html=True)

st.markdown("<br>", unsafe_allow_html=True)

# ── Alert banners ─────────────────────────────────────────────
if int(k['needs_action']) > 0:
    st.warning(f"⚠️ {int(k['needs_action'])} PPE item(s) need attention — check the Needs Action tab below.")
if int(k['expiring_soon']) > 0:
    st.info(f"📅 {int(k['expiring_soon'])} PPE item(s) expiring within 30 days.")

# ── Main tabs ─────────────────────────────────────────────────
tab1, tab2, tab3, tab4 = st.tabs([
    "📋 All PPE Records",
    "🔴 Needs Action",
    "📅 Expiring Soon",
    "📜 Status History"
])

# ── Tab 1: All PPE Records ────────────────────────────────────
with tab1:
    st.markdown(f"**{len(filtered)} records** matching current filters")

    display = filtered[[
        "employee", "ppe_type", "issuance_date",
        "expiry_date", "source", "condition_status", "current_status"
    ]].copy()

    display.columns = [
        "Employee", "PPE Type", "Issuance Date",
        "Expiry Date", "Source", "Condition", "Status"
    ]

    display["Status"] = display["Status"].apply(badge)

    st.dataframe(
        display,
        use_container_width=True,
        hide_index=True,
        column_config={
            "Issuance Date": st.column_config.DateColumn("Issuance Date", format="MMM DD, YYYY"),
            "Expiry Date":   st.column_config.DateColumn("Expiry Date",   format="MMM DD, YYYY"),
        }
    )

    # Download button
    csv = filtered.to_csv(index=False)
    st.download_button(
        label="⬇️ Download as CSV",
        data=csv,
        file_name=f"ppe_records_{datetime.now().strftime('%Y-%m-%d')}.csv",
        mime="text/csv"
    )

# ── Tab 2: Needs Action ───────────────────────────────────────
with tab2:
    if len(action) == 0:
        st.success("✅ No PPE currently needs action.")
    else:
        st.markdown(f"**{len(action)} item(s) need attention**")
        action_display = action.copy()
        action_display.columns = ["Employee", "Designation", "PPE Type", "Condition", "Issuance Date"]
        st.dataframe(action_display, use_container_width=True, hide_index=True)

# ── Tab 3: Expiring Soon ──────────────────────────────────────
with tab3:
    if len(expiring) == 0:
        st.success("✅ No PPE expiring in the next 30 days.")
    else:
        st.markdown(f"**{len(expiring)} item(s) expiring soon**")
        exp_display = expiring.copy()
        exp_display.columns = ["Employee", "Designation", "PPE Type",
                                "Issuance Date", "Expiry Date", "Days Remaining"]
        st.dataframe(
            exp_display,
            use_container_width=True,
            hide_index=True,
            column_config={
                "Days Remaining": st.column_config.NumberColumn(
                    "Days Remaining",
                    help="Days until expiry",
                    format="%d days"
                )
            }
        )

# ── Tab 4: Status History ─────────────────────────────────────
with tab4:
    if len(history) == 0:
        st.info("No status changes logged yet. Try updating a condition in MySQL.")
    else:
        st.markdown(f"**Last {len(history)} status changes** (most recent first)")
        hist_display = history.copy()
        hist_display.columns = ["Employee", "PPE Type", "Old Condition",
                                  "New Condition", "Old Status", "New Status", "Changed At"]
        st.dataframe(hist_display, use_container_width=True, hide_index=True)

# ── Footer ────────────────────────────────────────────────────
st.divider()
st.markdown("""
<div style="text-align:center; color:#94A3B8; font-size:11px; padding:8px 0">
    PPE Monitoring System · Built with Python + MySQL + Streamlit · Data refreshes every 30 seconds
</div>
""", unsafe_allow_html=True)
