# =============================================================
# dashboard.py — PPE Monitoring System
# Works both locally (MySQL) and on Streamlit Cloud (Aiven)
# =============================================================

import streamlit as st
import pandas as pd
import mysql.connector
from datetime import datetime

st.set_page_config(page_title="PPE Monitoring System", page_icon="🦺", layout="wide", initial_sidebar_state="expanded")

st.markdown("""
<style>
    .main { background-color: #F8FAFC; }
    .block-container { padding: 1.5rem 2rem; }
    .kpi-card { background: white; border-radius: 10px; padding: 16px 20px; border-top: 4px solid #ccc; box-shadow: 0 1px 3px rgba(0,0,0,0.08); }
    .kpi-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: #64748B; margin-bottom: 4px; }
    .kpi-number { font-size: 36px; font-weight: 700; line-height: 1; margin-bottom: 4px; }
    .kpi-desc { font-size: 11px; color: #94A3B8; }
    .status-active { color: #059669; } .status-expiring { color: #D97706; }
    .status-action { color: #DC2626; } .status-expired { color: #475569; }
    .status-returned { color: #2563EB; } .status-total { color: #B45309; }
</style>
""", unsafe_allow_html=True)

def get_db_config():
    try:
        return {"host": st.secrets["mysql"]["host"], "port": int(st.secrets["mysql"]["port"]),
                "user": st.secrets["mysql"]["user"], "password": st.secrets["mysql"]["password"],
                "database": st.secrets["mysql"]["database"], "ssl_disabled": False}
    except Exception:
        try:
            import config
            return config.DB_CONFIG
        except Exception:
            return None

@st.cache_data(ttl=60)
def load_data():
    cfg = get_db_config()
    if cfg is None:
        return None, None, None, None, None
    conn = mysql.connector.connect(**cfg)
    df = pd.read_sql("SELECT employee, designation, ppe_type, brand_model, issuance_date, expiry_date, source, condition_status, current_status FROM current_ppe_status ORDER BY employee, ppe_type", conn)
    kpi = pd.read_sql("SELECT SUM(current_status='Active') AS active, SUM(current_status='Expiring Soon') AS expiring_soon, SUM(current_status IN ('For Replacement','Damaged','Lost - For Replacement','Misplaced - For Replacement')) AS needs_action, SUM(current_status='Expired') AS expired, SUM(current_status IN ('Returned','Replaced')) AS returned_replaced, COUNT(*) AS total FROM current_ppe_status", conn)
    expiring = pd.read_sql("SELECT employee, designation, ppe_type, issuance_date, expiry_date, days_remaining FROM expiring_soon ORDER BY days_remaining ASC", conn)
    action = pd.read_sql("SELECT employee, designation, ppe_type, condition_status, issuance_date FROM needs_action ORDER BY condition_status, employee", conn)
    history = pd.read_sql("SELECT e.full_name AS employee, c.ppe_type, l.old_condition, l.new_condition, l.old_status, l.new_status, l.changed_at FROM ppe_status_log l JOIN ppe_issuances i ON i.issuance_id=l.issuance_id JOIN employees e ON e.employee_id=i.employee_id JOIN ppe_catalog c ON c.catalog_id=i.catalog_id ORDER BY l.changed_at DESC LIMIT 50", conn)
    conn.close()
    return df, kpi, expiring, action, history

STATUS_ICONS = {"Active":"🟢","Expiring Soon":"🟡","For Replacement":"🔴","Damaged":"🟠","Lost - For Replacement":"🟣","Misplaced - For Replacement":"🟣","Expired":"⚫","Returned":"🔵","Replaced":"🔵"}
def badge(s): return f"{STATUS_ICONS.get(s,'⚪')} {s}"

c1,c2,c3 = st.columns([1,6,2])
with c1: st.markdown("## 🦺")
with c2:
    st.markdown("# PPE Monitoring System")
    st.markdown("**Real-Time PPE Status Dashboard** — Source: MySQL `ppe_tracking`")
with c3:
    st.markdown(f"**{datetime.now().strftime('%b %d, %Y')}**")
    st.markdown(f"*{datetime.now().strftime('%H:%M:%S')}*")

st.divider()

try:
    df, kpi, expiring, action, history = load_data()
    if df is None:
        st.error("Could not connect to database.")
        st.stop()
except Exception as e:
    st.error(f"Database error: {e}")
    st.stop()

with st.sidebar:
    st.markdown("## 🔍 Filters")
    st.divider()
    sel_emp    = st.selectbox("Employee",    ["All"] + sorted(df["employee"].unique().tolist()))
    sel_ppe    = st.selectbox("PPE Type",    ["All"] + sorted(df["ppe_type"].unique().tolist()))
    sel_status = st.selectbox("Status",      ["All"] + sorted(df["current_status"].unique().tolist()))
    sel_desig  = st.selectbox("Designation", ["All"] + sorted(df["designation"].unique().tolist()))
    st.divider()
    st.markdown("### 📖 How to use\n1. Add PPE in **Excel PPE_RECORDS**\n2. Run `python sync.py`\n3. Refresh this page")
    st.divider()
    if st.button("🔄 Refresh data"):
        st.cache_data.clear()
        st.rerun()

filtered = df.copy()
if sel_emp    != "All": filtered = filtered[filtered["employee"]       == sel_emp]
if sel_ppe    != "All": filtered = filtered[filtered["ppe_type"]       == sel_ppe]
if sel_status != "All": filtered = filtered[filtered["current_status"] == sel_status]
if sel_desig  != "All": filtered = filtered[filtered["designation"]    == sel_desig]

st.markdown("### 📊 Overview")
k = kpi.iloc[0]
c1,c2,c3,c4,c5,c6 = st.columns(6)
with c1: st.markdown(f'<div class="kpi-card" style="border-top-color:#059669"><div class="kpi-label">Active</div><div class="kpi-number status-active">{int(k["active"])}</div><div class="kpi-desc">Currently in use</div></div>', unsafe_allow_html=True)
with c2: st.markdown(f'<div class="kpi-card" style="border-top-color:#D97706"><div class="kpi-label">Expiring Soon</div><div class="kpi-number status-expiring">{int(k["expiring_soon"])}</div><div class="kpi-desc">Within 30 days</div></div>', unsafe_allow_html=True)
with c3: st.markdown(f'<div class="kpi-card" style="border-top-color:#DC2626"><div class="kpi-label">Needs Action</div><div class="kpi-number status-action">{int(k["needs_action"])}</div><div class="kpi-desc">Replace / Damaged / Lost</div></div>', unsafe_allow_html=True)
with c4: st.markdown(f'<div class="kpi-card" style="border-top-color:#475569"><div class="kpi-label">Expired</div><div class="kpi-number status-expired">{int(k["expired"])}</div><div class="kpi-desc">Past expiry date</div></div>', unsafe_allow_html=True)
with c5: st.markdown(f'<div class="kpi-card" style="border-top-color:#2563EB"><div class="kpi-label">Returned</div><div class="kpi-number status-returned">{int(k["returned_replaced"])}</div><div class="kpi-desc">Returned or replaced</div></div>', unsafe_allow_html=True)
with c6: st.markdown(f'<div class="kpi-card" style="border-top-color:#B45309"><div class="kpi-label">Total Records</div><div class="kpi-number status-total">{int(k["total"])}</div><div class="kpi-desc">All PPE records</div></div>', unsafe_allow_html=True)

st.markdown("<br>", unsafe_allow_html=True)
if int(k['needs_action']) > 0: st.warning(f"⚠️ {int(k['needs_action'])} PPE item(s) need attention — check Needs Action tab.")
if int(k['expiring_soon']) > 0: st.info(f"📅 {int(k['expiring_soon'])} PPE item(s) expiring within 30 days.")

tab1,tab2,tab3,tab4 = st.tabs(["📋 All PPE Records","🔴 Needs Action","📅 Expiring Soon","📜 Status History"])

with tab1:
    st.markdown(f"**{len(filtered)} records** matching filters")
    d = filtered[["employee","ppe_type","issuance_date","expiry_date","source","condition_status","current_status"]].copy()
    d.columns = ["Employee","PPE Type","Issuance Date","Expiry Date","Source","Condition","Status"]
    d["Status"] = d["Status"].apply(badge)
    st.dataframe(d, use_container_width=True, hide_index=True, column_config={"Issuance Date":st.column_config.DateColumn(format="MMM DD, YYYY"),"Expiry Date":st.column_config.DateColumn(format="MMM DD, YYYY")})
    st.download_button("⬇️ Download as CSV", data=filtered.to_csv(index=False), file_name=f"ppe_records_{datetime.now().strftime('%Y-%m-%d')}.csv", mime="text/csv")

with tab2:
    if len(action)==0: st.success("✅ No PPE currently needs action.")
    else:
        a = action.copy(); a.columns=["Employee","Designation","PPE Type","Condition","Issuance Date"]
        st.dataframe(a, use_container_width=True, hide_index=True)

with tab3:
    if len(expiring)==0: st.success("✅ No PPE expiring in the next 30 days.")
    else:
        e = expiring.copy(); e.columns=["Employee","Designation","PPE Type","Issuance Date","Expiry Date","Days Remaining"]
        st.dataframe(e, use_container_width=True, hide_index=True, column_config={"Days Remaining":st.column_config.NumberColumn(format="%d days")})

with tab4:
    if len(history)==0: st.info("No status changes logged yet.")
    else:
        h = history.copy(); h.columns=["Employee","PPE Type","Old Condition","New Condition","Old Status","New Status","Changed At"]
        st.dataframe(h, use_container_width=True, hide_index=True)

st.divider()
st.markdown('<div style="text-align:center;color:#94A3B8;font-size:11px;padding:8px 0">PPE Monitoring System · Built with Python + MySQL + Streamlit · <a href="https://github.com/mase-rgb/ppe-tracking-system" target="_blank">GitHub</a></div>', unsafe_allow_html=True)