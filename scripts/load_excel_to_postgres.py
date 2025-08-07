import os
import pandas as pd
import psycopg2
from datetime import datetime, timedelta, time
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

DB_PARAMS = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", 5432),
    "dbname": os.getenv("POSTGRES_DB"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD")
}

# Ruta del archivo Excel
excel_path = "./data/Base_de_datos.xlsx"

# Función para insertar datos
def insert_dataframe(df, table_name, cursor):
    cols = ",".join(df.columns)
    values = ",".join(["%s"] * len(df.columns))
    insert_query = f"INSERT INTO {table_name} ({cols}) VALUES ({values}) ON CONFLICT DO NOTHING"

    for row in df.itertuples(index=False):
        cursor.execute(insert_query, tuple(row))
    
    print(f"✔ Datos insertados en {table_name}")

# Convertir fechas seriales de Excel (como 45147 → datetime)
def convert_excel_date(value):
    try:
        if pd.isna(value):
            return None
        return (datetime(1899, 12, 30) + timedelta(days=float(value))).date()
    except:
        return None

# Convertir hora decimal (como 0.63 → 15:07:00)
def convert_excel_time(value):
    try:
        if pd.isna(value):
            return None
        seconds = int(value * 24 * 60 * 60)
        return time(hour=seconds // 3600, minute=(seconds % 3600) // 60, second=seconds % 60)
    except:
        return None

# Convertir treatment_date desde datetime64 o timestamp int64
def convert_treatment_date(value):
    try:
        if pd.isna(value):
            return None
        if isinstance(value, pd.Timestamp):
            return value.date()
        if isinstance(value, (int, float)) and value > 1e15:
            return pd.to_datetime(value, unit="ns").date()
        return pd.to_datetime(value, errors="coerce").date()
    except:
        return None

try:
    # Leer el Excel
    sheets = pd.read_excel(excel_path, sheet_name=None)

    # Conectar a la base de datos
    conn = psycopg2.connect(**DB_PARAMS)
    cur = conn.cursor()

    # Tablas en orden de inserción
    insert_order = ["patients", "doctors", "appointments", "treatment"]

    # Columnas a convertir
    date_columns = {
        "appointments": ["appointment_date"],
        "treatment": ["treatment_date"],
        "patients": ["date_of_birth", "registration_date"]
    }

    time_columns = {
        "appointments": ["appointment_time"]
    }

    for table in insert_order:
        if table not in sheets:
            raise KeyError(f"❌ Hoja '{table}' no encontrada en el Excel")

        df = sheets[table]

        # Conversión de fechas
        if table in date_columns:
            for col in date_columns[table]:
                if table == "appointments":
                    df[col] = df[col].apply(convert_excel_date)
                elif table == "treatment":
                    df[col] = df[col].apply(convert_treatment_date)
                else:
                    df[col] = pd.to_datetime(df[col], errors='coerce').dt.date

        # Conversión de horas
        if table in time_columns:
            for col in time_columns[table]:
                df[col] = df[col].apply(convert_excel_time)

        # Insertar en base de datos
        insert_dataframe(df, table, cur)

    conn.commit()
    print("✅ Inserción completada con éxito.")

except Exception as e:
    print(f"❌ Error durante el proceso: {e}")
    if 'conn' in locals():
        conn.rollback()

finally:
    if 'cur' in locals():
        cur.close()
    if 'conn' in locals():
        conn.close()


