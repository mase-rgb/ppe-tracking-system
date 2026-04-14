# =============================================================
# Script 1: sync.py
# Reads PPE_RECORDS from your Excel file and syncs new rows
# into MySQL ppe_issuances table.
#
# HOW TO RUN:
#   cd C:\ppe_project
#   python sync.py
# =============================================================

import mysql.connector
import pandas as pd
from datetime import datetime
import config

# ── Step 1: Test the connection ───────────────────────────────
def get_connection():
    return mysql.connector.connect(**config.DB_CONFIG)

def test_connection():
    try:
        conn = get_connection()
        print("✓ Connected to MySQL successfully")
        conn.close()
        return True
    except mysql.connector.Error as e:
        print(f"✗ Connection failed: {e}")
        return False

# ── Step 2: Load lookup tables from MySQL ────────────────────
def load_lookups(conn):
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT employee_id, full_name FROM employees")
    employees = {row["full_name"]: row["employee_id"] for row in cursor.fetchall()}

    cursor.execute("SELECT catalog_id, ppe_type FROM ppe_catalog")
    catalog = {row["ppe_type"]: row["catalog_id"] for row in cursor.fetchall()}

    cursor.close()
    return employees, catalog

# ── Step 3: Read Excel PPE_RECORDS sheet ─────────────────────
def read_excel():
    df = pd.read_excel(
        config.EXCEL_PATH,
        sheet_name="PPE_RECORDS",
        header=1,           # row 2 is the header (0-indexed = 1)
        usecols="A:L"
    )

    # Clean column names
    df.columns = [
        "employee", "designation", "ppe_type", "brand_model",
        "issuance_date", "expiry_date", "source", "condition_status",
        "returned_replaced", "returned_date", "status", "notes"
    ]

    # Drop empty rows
    df = df[df["employee"].notna() & (df["employee"] != "")]

    # Convert date columns
    for col in ["issuance_date", "expiry_date", "returned_date"]:
        df[col] = pd.to_datetime(df[col], errors="coerce").dt.date

    # Convert returned_replaced to 0/1
    df["returned_replaced"] = df["returned_replaced"].apply(
        lambda x: 1 if str(x).strip().lower() == "yes" else 0
    )

    # Clean text columns
    for col in ["employee", "ppe_type", "brand_model", "source",
                "condition_status", "notes"]:
        df[col] = df[col].fillna("").astype(str).str.strip()

    print(f"✓ Read {len(df)} rows from Excel PPE_RECORDS")
    return df

# ── Step 4: Get existing records from MySQL ──────────────────
def get_existing_keys(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT CONCAT(e.full_name, '|', c.ppe_type, '|', i.issuance_date)
        FROM   ppe_issuances i
        JOIN   employees     e ON e.employee_id = i.employee_id
        JOIN   ppe_catalog   c ON c.catalog_id  = i.catalog_id
    """)
    keys = {row[0] for row in cursor.fetchall()}
    cursor.close()
    print(f"✓ Found {len(keys)} existing records in MySQL")
    return keys

# ── Step 5: Insert new rows ───────────────────────────────────
def sync_to_mysql(df, conn, employees, catalog, existing_keys):
    cursor = conn.cursor()
    inserted = 0
    skipped  = 0
    errors   = 0

    for _, row in df.iterrows():
        emp_name = row["employee"]
        ppe_type = row["ppe_type"]
        iss_date = row["issuance_date"]

        # Skip if key already exists in MySQL
        key = f"{emp_name}|{ppe_type}|{iss_date}"
        if key in existing_keys:
            skipped += 1
            continue

        # Skip if employee or PPE type not found in MySQL lookups
        if emp_name not in employees:
            print(f"  ⚠ Employee not found in MySQL: '{emp_name}' — skipping")
            errors += 1
            continue
        if ppe_type not in catalog:
            print(f"  ⚠ PPE type not found in MySQL: '{ppe_type}' — skipping")
            errors += 1
            continue

        employee_id = employees[emp_name]
        catalog_id  = catalog[ppe_type]

        # Map condition
        valid_conditions = {"Good","Damaged","For Replacement","Lost","Misplaced","Expired"}
        condition = row["condition_status"] if row["condition_status"] in valid_conditions else "Good"

        # Map source
        source = "Auto" if row["source"] == "Auto" else "Manual"

        try:
            cursor.execute("""
                INSERT INTO ppe_issuances
                    (employee_id, catalog_id, brand_model, issuance_date,
                     source, condition_status, returned_replaced, returned_date, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                employee_id,
                catalog_id,
                row["brand_model"] or None,
                iss_date,
                source,
                condition,
                row["returned_replaced"],
                row["returned_date"] if pd.notna(row["returned_date"]) else None,
                row["notes"] or None,
            ))
            inserted += 1
        except mysql.connector.Error as e:
            print(f"  ✗ Error inserting {emp_name} / {ppe_type}: {e}")
            errors += 1

    conn.commit()
    cursor.close()
    print(f"\n── Sync complete ──────────────────────")
    print(f"  Inserted : {inserted}")
    print(f"  Skipped  : {skipped} (already in MySQL)")
    print(f"  Errors   : {errors}")
    return inserted

# ── Step 6: Show summary after sync ──────────────────────────
def show_summary(conn):
    cursor = conn.cursor()
    cursor.execute("""
        SELECT
            SUM(current_status = 'Active')                                           AS active,
            SUM(current_status = 'Expiring Soon')                                    AS expiring_soon,
            SUM(current_status IN ('For Replacement','Damaged',
                'Lost - For Replacement','Misplaced - For Replacement'))             AS needs_action,
            SUM(current_status = 'Expired')                                          AS expired,
            SUM(current_status IN ('Returned','Replaced'))                           AS returned_replaced,
            COUNT(*)                                                                  AS total
        FROM current_ppe_status
    """)
    row = cursor.fetchone()
    cursor.close()

    print(f"\n── MySQL Dashboard KPIs ───────────────")
    print(f"  Active            : {row[0]}")
    print(f"  Expiring Soon     : {row[1]}")
    print(f"  Needs Action      : {row[2]}")
    print(f"  Expired           : {row[3]}")
    print(f"  Returned/Replaced : {row[4]}")
    print(f"  Total Records     : {row[5]}")

# ── Main ──────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 40)
    print("PPE SYNC — Excel → MySQL")
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 40)

    if not test_connection():
        exit()

    conn = get_connection()
    try:
        employees, catalog = load_lookups(conn)
        df                 = read_excel()
        existing_keys      = get_existing_keys(conn)
        sync_to_mysql(df, conn, employees, catalog, existing_keys)
        show_summary(conn)
    finally:
        conn.close()
        print("\n✓ Connection closed")
