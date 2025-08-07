SELECT 
  p.patient_id, 
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  COUNT(DISTINCT t.treatment_type) AS num_treatment_types
FROM treatment t
JOIN appointments a ON t.appointment_id = a.appointment_id
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
HAVING COUNT(DISTINCT t.treatment_type) > 1;