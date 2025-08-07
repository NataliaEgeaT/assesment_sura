-- Tabla: patients
CREATE TABLE patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(10),
    date_of_birth DATE,
    contact_number VARCHAR(20),
    address TEXT,
    registration_date DATE,
    insurance_provider VARCHAR(100),
    insurance_number VARCHAR(50),
    email VARCHAR(150)
);

-- Tabla: doctors
CREATE TABLE doctors (
    doctor_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    specialization VARCHAR(100),
    phone_number VARCHAR(20),
    years_experience INTEGER,
    hospital_branch VARCHAR(100),
    email VARCHAR(150)
);

-- Tabla: appointments
CREATE TABLE appointments (
    appointment_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR REFERENCES patients(patient_id) ON DELETE CASCADE,
    doctor_id VARCHAR REFERENCES doctors(doctor_id) ON DELETE SET NULL,
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit TEXT,
    status VARCHAR(50)  -- ej: Scheduled, Cancelled, Completed
);

-- Tabla: treatment
CREATE TABLE treatment (
    treatment_id VARCHAR(10) PRIMARY KEY,
    appointment_id VARCHAR REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    treatment_type VARCHAR(100),
    description TEXT,
    cost NUMERIC(10,2),
    treatment_date DATE
);
