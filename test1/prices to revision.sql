WITH pr_lst AS
  (SELECT vp.id,
          vehicle_id,
          price,
          created_at,
          acquisition_date,
          completion_date,
          lead(vp.created_at) OVER (PARTITION BY vp.vehicle_id
                                    ORDER BY vp.created_at) end_date
   FROM vehicle_price vp
   LEFT JOIN vehicle v ON vp.vehicle_id = v.id
   WHERE acquisition_date < '2020-01-01'
     AND (completion_date > '2019-12-01'
          OR completion_date IS NULL)
     AND vp.created_at < '2020-01-01')
SELECT id AS price_id,
       CASE
           WHEN completion_date BETWEEN '2019-12-01' AND '2019-12-31' THEN DATEDIFF (d, created_at, completion_date)
           WHEN (completion_date > '2019-12-31'
                 OR completion_date IS NULL)
                AND end_date IS NOT NULL THEN DATEDIFF (d, created_at, end_date)
           ELSE DATEDIFF (d, created_at, '2019-12-31')
       END days
FROM pr_lst
WHERE end_date >= '2019-12-01'
  OR end_date IS NULL
GROUP BY price_id
HAVING sum(days) > 14
ORDER BY days DESC,
         price_id ASC;