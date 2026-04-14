# 🦺 PPE Tracking System

A real-time Personal Protective Equipment (PPE) monitoring system built for workplace safety management. Tracks PPE issuance, condition, expiry, and status for all employees — with automated alerts, report generation, and a live web dashboard.

---

## 📌 Project Overview

This system was built to solve a real workplace problem: manually tracking PPE across multiple employees is time-consuming, error-prone, and provides no historical record of changes.

**The solution is a four-layer system:**

| Layer | Tool | Purpose |
|-------|------|---------|
| Data entry | Excel + OneDrive | Coworkers input PPE records |
| Database | MySQL | Stores all records with full history |
| Automation | Python | Syncs data, generates alerts and reports |
| Dashboard | Streamlit | Live web dashboard for real-time monitoring |

---

## 🚀 Features

- **Auto-calculated status** — Status updates automatically based on condition, return status, and expiry date
- **Full history tracking** — Every status change is logged with timestamp via MySQL triggers
- **Expiry auto-calculation** — Cartridge PPE expiry date calculated automatically on insert
- **Live web dashboard** — Real-time KPI cards, filters, and alert banners
- **Excel sync** — Python script bridges Excel and MySQL with duplicate detection
- **Automated alerts** — Terminal report showing expiring PPE, items needing action, and low inventory
- **Excel report generator** — Formatted multi-sheet Excel report generated from MySQL data

---

## 🛠️ Tech Stack

- **Excel** — Data entry interface (OneDrive for team collaboration)
- **MySQL 8.0** — Relational database with triggers and views
- **Python 3.14** — Data sync, automation, and reporting
- **Streamlit** — Web dashboard framework
- **pandas** — Excel file reading and data manipulation
- **openpyxl** — Excel report generation
- **mysql-connector-python** — MySQL database connection

---

## 📁 Project Structure

```
ppe-tracking-system/
│
├── dashboard.py      # Streamlit web dashboard
├── sync.py           # Excel → MySQL data sync
├── alerts.py         # PPE alert report (expiring, damaged, low stock)
├── report.py         # Automated Excel report generator
├── .gitignore        # Excludes config.py, Excel files, SQL files
│
└── config.py         # ⚠️ NOT included — create your own (see Setup)
```

---

## ⚙️ Setup

### 1. Clone the repository
```bash
git clone https://github.com/mase-rgb/ppe-tracking-system.git
cd ppe-tracking-system
```

### 2. Install dependencies
```bash
pip install mysql-connector-python pandas openpyxl streamlit
```

### 3. Create config.py
Create a `config.py` file in the project root with your credentials:
```python
DB_CONFIG = {
    "host":     "localhost",
    "user":     "root",
    "password": "your_mysql_password",
    "database": "ppe_tracking"
}

EXCEL_PATH = r"C:\path\to\your\PPE_System_RealData.xlsx"
```

### 4. Set up the MySQL database
- Run the schema SQL script in MySQL Workbench to create all tables, triggers, and views
- Run the migration SQL script to load your PPE data

### 5. Run the dashboard
```bash
python -m streamlit run dashboard.py
```

Open your browser to `http://localhost:8501`

---

## 📊 Database Schema

**6 tables:**
- `employees` — Employee records with designation
- `ppe_catalog` — PPE types with expiry rules
- `inventory` — Stock on hand with minimum levels
- `ppe_issuances` — Every PPE record issued to employees
- `ppe_status_log` — Automatic history of every status change
- `requests` — PPE request log linked to issuances

**2 triggers:**
- `trg_set_expiry_date` — Auto-calculates expiry date on insert
- `trg_log_status_change` — Logs every condition change with timestamp

**3 views:**
- `current_ppe_status` — All PPE with calculated current status
- `expiring_soon` — PPE expiring within 30 days
- `needs_action` — PPE requiring replacement or attention

---

## 📈 Status Logic

Status is calculated automatically from three fields:

| Condition | Returned/Replaced | Status |
|-----------|-------------------|--------|
| For Replacement | Yes | Returned |
| Lost | Yes | Replaced |
| Misplaced | Yes | Replaced |
| Any | Yes | Returned |
| Damaged | No | Damaged |
| Lost | No | Lost - For Replacement |
| Misplaced | No | Misplaced - For Replacement |
| For Replacement | No | For Replacement |
| Expired | No | Expired |
| Good + no expiry | — | Active |
| Good + expiry passed | — | Expired |
| Good + expiry ≤ 30 days | — | Expiring Soon |
| Good + expiry > 30 days | — | Active |

---

## 🔄 Daily Workflow

1. **Add new PPE** — Add row in Excel PPE_RECORDS sheet
2. **Sync to MySQL** — Run `python sync.py`
3. **Check alerts** — Run `python alerts.py`
4. **Generate report** — Run `python report.py`
5. **View dashboard** — Run `python -m streamlit run dashboard.py`

---

## 👤 Author

**mase-rgb**
- GitHub: [@mase-rgb](https://github.com/mase-rgb)

---

## 📝 License

This project is for portfolio and workplace use.
