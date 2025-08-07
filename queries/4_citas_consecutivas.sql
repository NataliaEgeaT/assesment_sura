WITH ranked_appointments AS (
  SELECT 
    a.*,
    ROW_NUMBER() OVER (PARTITION BY a.patient_id ORDER BY a.appointment_date) AS rn
  FROM appointments a
)
SELECT 
  p.patient_id,
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  CONCAT(d.last_name, ' ', d.last_name) AS doctor_name,
  ra1.appointment_date AS first_date,
  ra2.appointment_date AS second_date
FROM ranked_appointments ra1
JOIN ranked_appointments ra2 
  ON ra1.patient_id = ra2.patient_id AND ra1.rn + 1 = ra2.rn
JOIN patients p ON ra1.patient_id = p.patient_id
JOIN doctors d ON ra1.doctor_id = d.doctor_id AND ra2.doctor_id = d.doctor_id;