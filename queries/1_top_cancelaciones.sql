SELECT 
  p.patient_id, 
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  COUNT(*) FILTER (WHERE a.status = 'Cancelled')::FLOAT / COUNT(*) * 100 AS cancel_rate
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY cancel_rate DESC
LIMIT 3;