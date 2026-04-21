# =============================================================
# sync.py — Excel → MySQL
# Reads PPE_INPUT and REQUEST_INPUT from Excel
# No formulas in Excel — all logic lives in MySQL
# NULL issuance_date allowed for legacy records
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


def clean(val):
    """Convert any value to clean string or None."""
    if val is None:
        return None
    s = str(val).strip()
    if s.lower() in ["nan", "none", "nat", ""]:
        return None
    return s


def clean_date(val):
    """Convert date value to date object or None."""
    if val is None:
        return None
    if str(val).lower().strip() in ["nan", "none", "nat", ""]:
        return None
    try:
        result = pd.to_datetime(val, errors="coerce")
        if pd.isna(result):
            return None
        return result.date()
    except Exception:
        return None


def read_ppe_input():
    df = pd.read_excel(
        config.EXCEL_PATH,
        sheet_name="PPE_INPUT",
        header=2,
        usecols="A:K",
        dtype=str  # read everything as string first to avoid NaN issues
    )
    df.columns = [
        "employee", "designation", "ppe_type", "brand_model", "size",
        "issuance_date", "condition_status", "returned_replaced",
        "returned_date", "source", "notes"
    ]

    # Keep only rows with a real employee name
    df = df[df["employee"].notna()].copy()
    df = df[df["employee"].str.strip().str.lower() != "nan"].copy()
    df = df[df["employee"].str.strip() != ""].copy()
    df = df.reset_index(drop=True)

    # Convert date columns
    df["issuance_date"] = df["issuance_date"].apply(clean_date)
    df["returned_date"] = df["returned_date"].apply(clean_date)

    # returned_replaced: 1 if Yes, else 0
    df["returned_replaced"] = df["returned_replaced"].apply(
        lambda x: 1 if str(x).strip().lower() == "yes" else 0
    )

    # Build brand_model_combined from brand_model + size
    combined = []
    for _, row in df.iterrows():
        b = clean(row["brand_model"])
        s = clean(row["size"])
        parts = [p for p in [b, s] if p]
        combined.append(" / ".join(parts) if parts else None)
    df["brand_model_combined"] = combined

    print(f"✓ PPE_INPUT: {len(df)} rows loaded from Excel")
    return df


def read_request_input():
    df = pd.read_excel(
        config.EXCEL_PATH,
        sheet_name="REQUEST_INPUT",
        header=2,
        usecols="A:I",
        dtype=str
    )
    df.columns = [
        "employee", "designation", "ppe_type", "brand_preference",
        "size", "quantity", "request_date", "priority", "notes"
    ]

    df = df[df["employee"].notna()].copy()
    df = df[df["employee"].str.strip().str.lower() != "nan"].copy()
    df = df[df["employee"].str.strip() != ""].copy()
    df = df.reset_index(drop=True)

    df["request_date"] = df["request_date"].apply(clean_date)
    df["quantity"] = pd.to_numeric(df["quantity"], errors="coerce").fillna(1).astype(int)

    print(f"✓ REQUEST_INPUT: {len(df)} rows loaded from Excel")
    return df


def get_existing_ppe_keys(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT CONCAT(e.full_name,'|',c.ppe_type,'|',
               COALESCE(i.issuance_date,'NULL'))
        FROM ppe_issuances i
        JOIN employees   e ON e.employee_id = i.employee_id
        JOIN ppe_catalog c ON c.catalog_id  = i.catalog_id
    """)
    keys = {r[0] for r in cursor.fetchall()}
    cursor.close()
    print(f"✓ MySQL has {len(keys)} existing PPE records")
    return keys


def get_existing_request_keys(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT CONCAT(e.full_name,'|',c.ppe_type,'|',
               COALESCE(r.request_date,'NULL'))
        FROM requests r
        JOIN employees   e ON e.employee_id = r.employee_id
        JOIN ppe_catalog c ON c.catalog_id  = r.catalog_id
    """)
    keys = {r[0] for r in cursor.fetchall()}
    cursor.close()
    print(f"✓ MySQL has {len(keys)} existing requests")
    return keys


def sync_ppe(df, conn, employees, catalog, existing_keys):
    cursor = conn.cursor()
    inserted = skipped = errors = 0

    for _, row in df.iterrows():
        emp  = clean(row["employee"])
        ppe  = clean(row["ppe_type"])
        dt   = row["issuance_date"]  # can be None now

        if not emp or not ppe:
            errors += 1
            continue

        # Build key — use 'NULL' string when date is None
        key = f"{emp}|{ppe}|{dt if dt else 'NULL'}"

        if key in existing_keys:
            skipped += 1
            continue

        if emp not in employees:
            print(f"  ⚠ Unknown employee: '{emp}' — add to Employees sheet")
            errors += 1
            continue

        if ppe not in catalog:
            print(f"  ⚠ Unknown PPE type: '{ppe}' — add to Reference sheet")
            errors += 1
            continue

        # Clean all values
        source    = clean(row["source"])            or "Manual"
        condition = clean(row["condition_status"])  or "Good"
        ret_date  = row["returned_date"]
        notes     = clean(row["notes"])
        brand     = row["brand_model_combined"]

        try:
            cursor.execute("""
                INSERT INTO ppe_issuances
                    (employee_id, catalog_id, brand_model, issuance_date,
                     source, condition_status, returned_replaced,
                     returned_date, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                employees[emp], catalog[ppe],
                brand, dt, source, condition,
                row["returned_replaced"],
                ret_date if ret_date else None,
                notes
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
        emp = clean(row["employee"])
        ppe = clean(row["ppe_type"])
        dt  = row["request_date"]

        if not emp or not ppe or not dt:
            errors += 1
            continue

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

        # Check stock
        cursor.execute("""
            SELECT i.on_hand FROM inventory i
            JOIN ppe_catalog c ON c.catalog_id = i.catalog_id
            WHERE c.ppe_type = %s
        """, (ppe,))
        stock = cursor.fetchone()
        stock_status = "In Stock" if stock and stock[0] > 0 else "No Stock"
        status       = "Ready to Issue" if stock_status == "In Stock" else "Waiting Stock"

        # Build notes
        parts = []
        bp = clean(row["brand_preference"])
        sz = clean(row["size"])
        pr = clean(row["priority"])
        nt = clean(row["notes"])
        if bp: parts.append(f"Preference: {bp}")
        if sz: parts.append(f"Size: {sz}")
        if pr: parts.append(f"Priority: {pr}")
        if nt: parts.append(nt)
        notes = " | ".join(parts) if parts else None

        try:
            cursor.execute("""
                INSERT INTO requests
                    (employee_id, catalog_id, quantity, request_date,
                     stock_status, status, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
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
            SUM(current_status = 'Active')                                AS active,
            SUM(current_status = 'Expiring Soon')                         AS expiring_soon,
            SUM(current_status IN ('For Replacement','Damaged',
                'Lost - For Replacement',
                'Misplaced - For Replacement'))                           AS needs_action,
            SUM(current_status = 'Expired')                               AS expired,
            SUM(current_status IN ('Returned','Replaced'))                AS returned_replaced,
            COUNT(*)                                                       AS total
        FROM current_ppe_status
    """)
    k = cursor.fetchone()
    cursor.close()
    print(f"\n── MYSQL DASHBOARD KPIs ───────────────")
    print(f"  Active            : {int(k['active']            or 0)}")
    print(f"  Expiring Soon     : {int(k['expiring_soon']     or 0)}")
    print(f"  Needs Action      : {int(k['needs_action']      or 0)}")
    print(f"  Expired           : {int(k['expired']           or 0)}")
    print(f"  Returned/Replaced : {int(k['returned_replaced'] or 0)}")
    print(f"  Total Records     : {int(k['total']             or 0)}")


if __name__ == "__main__":
    print("\n" + "=" * 42)
    print("PPE SYNC — Excel → MySQL")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 42)

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