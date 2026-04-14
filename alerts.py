# =============================================================
# Script 2: alerts.py
# Checks MySQL for PPE expiring within 30 days and prints
# an alert report. Can be extended to send email later.
#
# HOW TO RUN:
#   cd C:\ppe_project
#   python alerts.py
# =============================================================

import mysql.connector
import pandas as pd
from datetime import datetime
import config

def get_connection():
    return mysql.connector.connect(**config.DB_CONFIG)

# ── Check expiring soon ───────────────────────────────────────
def get_expiring_soon(conn):
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT
            employee,
            designation,
            ppe_type,
            issuance_date,
            expiry_date,
            days_remaining
        FROM expiring_soon
        ORDER BY days_remaining ASC
    """)
    rows = cursor.fetchall()
    cursor.close()
    return rows

# ── Check needs action ────────────────────────────────────────
def get_needs_action(conn):
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT
            employee,
            designation,
            ppe_type,
            condition_status,
            issuance_date
        FROM needs_action
        ORDER BY condition_status, employee
    """)
    rows = cursor.fetchall()
    cursor.close()
    return rows

# ── Check low inventory ───────────────────────────────────────
def get_low_inventory(conn):
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT
            c.ppe_type,
            i.on_hand,
            i.min_stock
        FROM inventory    i
        JOIN ppe_catalog  c ON c.catalog_id = i.catalog_id
        WHERE i.on_hand <= i.min_stock
        ORDER BY i.on_hand ASC
    """)
    rows = cursor.fetchall()
    cursor.close()
    return rows

# ── Print formatted alert report ─────────────────────────────
def print_report(expiring, needs_action, low_inventory):
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    print("=" * 55)
    print("  PPE ALERT REPORT")
    print(f"  Generated: {now}")
    print("=" * 55)

    # Expiring soon
    print(f"\n⚠  EXPIRING SOON ({len(expiring)} items)")
    print("-" * 55)
    if expiring:
        for r in expiring:
            print(f"  {r['employee']:<20} {r['ppe_type']:<22} "
                  f"Expires: {r['expiry_date']}  ({r['days_remaining']} days)")
    else:
        print("  No PPE expiring in the next 30 days.")

    # Needs action
    print(f"\n🔴  NEEDS ACTION ({len(needs_action)} items)")
    print("-" * 55)
    if needs_action:
        for r in needs_action:
            print(f"  {r['employee']:<20} {r['ppe_type']:<22} "
                  f"Condition: {r['condition_status']}")
    else:
        print("  No PPE needs action.")

    # Low inventory
    print(f"\n📦  LOW INVENTORY ({len(low_inventory)} items)")
    print("-" * 55)
    if low_inventory:
        for r in low_inventory:
            status = "OUT OF STOCK" if r["on_hand"] == 0 else "LOW STOCK"
            print(f"  {r['ppe_type']:<30} On Hand: {r['on_hand']}  "
                  f"Min: {r['min_stock']}  [{status}]")
    else:
        print("  All inventory above minimum levels.")

    print("\n" + "=" * 55)

    # Summary line
    total_alerts = len(expiring) + len(needs_action) + len(low_inventory)
    if total_alerts == 0:
        print("  ✓ All clear — no alerts today.")
    else:
        print(f"  Total alerts: {total_alerts} items need attention.")
    print("=" * 55)

# ── Main ──────────────────────────────────────────────────────
if __name__ == "__main__":
    try:
        conn        = get_connection()
        expiring    = get_expiring_soon(conn)
        needs       = get_needs_action(conn)
        low_inv     = get_low_inventory(conn)
        conn.close()
        print_report(expiring, needs, low_inv)
    except mysql.connector.Error as e:
        print(f"✗ Database error: {e}")
