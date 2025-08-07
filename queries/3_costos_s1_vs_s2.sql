WITH monthly_avg AS (
  SELECT 
    a.reason_for_visit,
    EXTRACT(MONTH FROM t.treatment_date) AS month,
    EXTRACT(YEAR FROM t.treatment_date) AS year,
    AVG(t.cost) AS avg_cost
  FROM treatment t
  JOIN appointments a ON t.appointment_id = a.appointment_id
  WHERE EXTRACT(YEAR FROM t.treatment_date) = 2023
  GROUP BY a.reason_for_visit, month, year
),
first_half AS (
  SELECT reason_for_visit, AVG(avg_cost) AS avg_cost_h1
  FROM monthly_avg
  WHERE month BETWEEN 1 AND 6
  GROUP BY reason_for_visit
),
second_half AS (
  SELECT reason_for_visit, AVG(avg_cost) AS avg_cost_h2
  FROM monthly_avg
  WHERE month BETWEEN 7 AND 12
  GROUP BY reason_for_visit
)
SELECT sh.reason_for_visit
FROM second_half sh
JOIN first_half fh ON sh.reason_for_visit = fh.reason_for_visit
WHERE sh.avg_cost_h2 > fh.avg_cost_h1;