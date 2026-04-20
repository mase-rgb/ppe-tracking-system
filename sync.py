# =============================================================
# sync.py — Excel → MySQL
# Reads PPE_INPUT and REQUEST_INPUT from Excel
# No formulas in Excel — all logic lives in MySQL
# =============================================================

import mysql.connector
import pandas as pd
from datetime import datetime
import config


def get_connection():
    return mysql.connector.connect(**config.DB_CONFIG)


def load_lookups(conn):
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT employee_id, full_name FROM employees")
    employees = {r["full_name"]: r["employee_id"] for r in cursor.fetchall()}
    cursor.execute("SELECT catalog_id, ppe_type FROM ppe_catalog")
    catalog = {r["ppe_type"]: r["catalog_id"] for r in cursor.fetchall()}
    cursor.close()
    return employees, catalog


def read_ppe_input():
    df = pd.read_excel(config.EXCEL_PATH, sheet_name="PPE_INPUT", header=2, usecols="A:K")
    df.columns = ["employee","designation","ppe_type","brand_model","size",
                  "issuance_date","condition_status","returned_replaced",
                  "returned_date","source","notes"]
    df = df[df["employee"].notna() & (df["employee"].astype(str).str.strip() != "")]
    df = df.reset_index(drop=True)
    for col in ["issuance_date","returned_date"]:
        df[col] = pd.to_datetime(df[col], errors="coerce").dt.date
    text_cols = ["employee","designation","ppe_type","brand_model","size",
                 "source","condition_status","notes"]
    for col in text_cols:
        df[col] = df[col].fillna("").astype(str).str.strip()
    df["returned_replaced"] = df["returned_replaced"].apply(
        lambda x: 1 if str(x).strip().lower() == "yes" else 0)

    # Combine brand_model and size into one string per row
    combined = []
    for _, row in df.iterrows():
        parts = []
        if row["brand_model"] and row["brand_model"].lower() not in ["","nan","none"]:
            parts.append(row["brand_model"])
        if row["size"] and row["size"].lower() not in ["","nan","none"]:
            parts.append(row["size"])
        combined.append(" / ".join(parts) if parts else None)
    df["brand_model_combined"] = combined

    print(f"✓ PPE_INPUT: {len(df)} rows loaded from Excel")
    return df


def read_request_input():
    df = pd.read_excel(config.EXCEL_PATH, sheet_name="REQUEST_INPUT", header=2, usecols="A:I")
    df.columns = ["employee","designation","ppe_type","brand_preference",
                  "size","quantity","request_date","priority","notes"]
    df = df[df["employee"].notna() & (df["employee"].astype(str).str.strip() != "")]
    df = df.reset_index(drop=True)
    df["request_date"] = pd.to_datetime(df["request_date"], errors="coerce").dt.date
    text_cols = ["employee","designation","ppe_type","brand_preference","size","priority","notes"]
    for col in text_cols:
        df[col] = df[col].fillna("").astype(str).str.strip()
    df["quantity"] = pd.to_numeric(df["quantity"], errors="coerce").fillna(1).astype(int)
    print(f"✓ REQUEST_INPUT: {len(df)} rows loaded from Excel")
    return df


def get_existing_ppe_keys(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT CONCAT(e.full_name,'|',c.ppe_type,'|',i.issuance_date)
        FROM ppe_issuances i
        JOIN employees e ON e.employee_id=i.employee_id
        JOIN ppe_catalog c ON c.catalog_id=i.catalog_id
    """)
    keys = {r[0] for r in cursor.fetchall()}
    cursor.close()
    print(f"✓ MySQL has {len(keys)} existing PPE records")
    return keys


def get_existing_request_keys(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT CONCAT(e.full_name,'|',c.ppe_type,'|',r.request_date)
        FROM requests r
        JOIN employees e ON e.employee_id=r.employee_id
        JOIN ppe_catalog c ON c.catalog_id=r.catalog_id
    """)
    keys = {r[0] for r in cursor.fetchall()}
    cursor.close()
    print(f"✓ MySQL has {len(keys)} existing requests")
    return keys


def sync_ppe(df, conn, employees, catalog, existing_keys):
    cursor = conn.cursor()
    inserted = skipped = errors = 0

    for _, row in df.iterrows():
        emp = str(row["employee"]).strip()
        ppe = str(row["ppe_type"]).strip()
        dt  = row["issuance_date"]
        key = f"{emp}|{ppe}|{dt}"

        if key in existing_keys:
            skipped += 1
            continue
        if emp not in employees:
            print(f"  ⚠ Unknown employee: '{emp}' — add to Employees sheet first")
            errors += 1
            continue
        if ppe not in catalog:
            print(f"  ⚠ Unknown PPE type: '{ppe}' — add to Reference sheet first")
            errors += 1
            continue
        if not dt:
            print(f"  ⚠ Missing issuance date for {emp} / {ppe}")
            errors += 1
            continue

        try:
            cursor.execute("""
                INSERT INTO ppe_issuances
                    (employee_id, catalog_id, brand_model, issuance_date,
                     source, condition_status, returned_replaced, returned_date, notes)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                employees[emp],
                catalog[ppe],
                row["brand_model_combined"],
                dt,
                row["source"] if row["source"] not in ["","nan","none"] else "Manual",
                row["condition_status"] if row["condition_status"] not in ["","nan","none"] else "Good",
                row["returned_replaced"],
                row["returned_date"] if row["returned_date"] else None,
                row["notes"] if row["notes"] not in ["","nan","none"] else None
            ))
            inserted += 1
        except Exception as e:
            print(f"  ✗ Error inserting {emp}/{ppe}: {e}")
            errors += 1

    conn.commit()
    cursor.close()
    print(f"\n── PPE SYNC COMPLETE ──────────────────")
    print(f"  Inserted : {inserted}")
    print(f"  Skipped  : {skipped}  (already in MySQL)")
    print(f"  Errors   : {errors}")


def sync_requests(df, conn, employees, catalog, existing_keys):
    cursor = conn.cursor()
    inserted = skipped = errors = 0

    for _, row in df.iterrows():
        emp = str(row["employee"]).strip()
        ppe = str(row["ppe_type"]).strip()
        dt  = row["request_date"]
        key = f"{emp}|{ppe}|{dt}"

        if key in existing_keys:
            skipped += 1
            continue
        if emp not in employees:
            print(f"  ⚠ Unknown employee: '{emp}'")
            errors += 1
            continue
        if ppe not in catalog:
            print(f"  ⚠ Unknown PPE type: '{ppe}'")
            errors += 1
            continue
        if not dt:
            errors += 1
            continue

        # Check stock
        cursor.execute("""
            SELECT i.on_hand FROM inventory i
            JOIN ppe_catalog c ON c.catalog_id=i.catalog_id
            WHERE c.ppe_type=%s
        """, (ppe,))
        stock = cursor.fetchone()
        stock_status = "In Stock" if stock and stock[0] > 0 else "No Stock"
        status = "Ready to Issue" if stock_status == "In Stock" else "Waiting Stock"

        # Build notes
        parts = []
        if row["brand_preference"] not in ["","nan","none"]:
            parts.append(f"Preference: {row['brand_preference']}")
        if row["size"] not in ["","nan","none"]:
            parts.append(f"Size: {row['size']}")
        if row["priority"] not in ["","nan","none"]:
            parts.append(f"Priority: {row['priority']}")
        if row["notes"] not in ["","nan","none"]:
            parts.append(row["notes"])
        notes = " | ".join(parts) if parts else None

        try:
            cursor.execute("""
                INSERT INTO requests
                    (employee_id, catalog_id, quantity, request_date,
                     stock_status, status, notes)
                VALUES (%s,%s,%s,%s,%s,%s,%s)
            """, (
                employees[emp], catalog[ppe],
                int(row["quantity"]), dt,
                stock_status, status, notes
            ))
            inserted += 1
        except Exception as e:
            print(f"  ✗ Error request {emp}/{ppe}: {e}")
            errors += 1

    conn.commit()
    cursor.close()
    print(f"\n── REQUEST SYNC COMPLETE ──────────────")
    print(f"  Inserted : {inserted}")
    print(f"  Skipped  : {skipped}  (already in MySQL)")
    print(f"  Errors   : {errors}")


def show_kpis(conn):
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT
            SUM(current_status='Active')                                AS active,
            SUM(current_status='Expiring Soon')                         AS expiring_soon,
            SUM(current_status IN ('For Replacement','Damaged',
                'Lost - For Replacement','Misplaced - For Replacement')) AS needs_action,
            SUM(current_status='Expired')                               AS expired,
            SUM(current_status IN ('Returned','Replaced'))              AS returned_replaced,
            COUNT(*)                                                     AS total
        FROM current_ppe_status
    """)
    k = cursor.fetchone()
    cursor.close()
    print(f"\n── MYSQL DASHBOARD KPIs ───────────────")
    print(f"  Active            : {int(k['active'] or 0)}")
    print(f"  Expiring Soon     : {int(k['expiring_soon'] or 0)}")
    print(f"  Needs Action      : {int(k['needs_action'] or 0)}")
    print(f"  Expired           : {int(k['expired'] or 0)}")
    print(f"  Returned/Replaced : {int(k['returned_replaced'] or 0)}")
    print(f"  Total Records     : {int(k['total'] or 0)}")


if __name__ == "__main__":
    print("\n" + "="*42)
    print("PPE SYNC — Excel → MySQL")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*42)

    conn = get_connection()
    print("✓ Connected to MySQL successfully")

    try:
        employees, catalog = load_lookups(conn)
        ppe_df   = read_ppe_input()
        ppe_keys = get_existing_ppe_keys(conn)
        sync_ppe(ppe_df, conn, employees, catalog, ppe_keys)
        req_df   = read_request_input()
        req_keys = get_existing_request_keys(conn)
        sync_requests(req_df, conn, employees, catalog, req_keys)
        show_kpis(conn)
    finally:
        conn.close()
        print("\n✓ Connection closed")