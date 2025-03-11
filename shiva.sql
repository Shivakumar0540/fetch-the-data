-- Top 5 Brands by recipts scanned for most recent month:

SELECT b.brand_name, COUNT(*) as receipt_count
FROM RECEIPT_ITEMS_FACT ri
JOIN BRANDS_DIM b ON ri.brand_id = b.brand_id
JOIN RECEIPTS_FACT r ON ri.receipt_id = r.receipt_id
WHERE DATE_TRUNC('month', r.date_scanned) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
GROUP BY b.brand_name
ORDER BY receipt_count DESC
LIMIT 5;

-- Compare rankings month-over-month:

WITH current_month AS (
  SELECT b.brand_name, COUNT(*) as receipt_count,
  RANK() OVER (ORDER BY COUNT(*) DESC) as rank
  FROM RECEIPT_ITEMS_FACT ri
  JOIN BRANDS_DIM b ON ri.brand_id = b.brand_id
  JOIN RECEIPTS_FACT r ON ri.receipt_id = r.receipt_id
  WHERE DATE_TRUNC('month', r.date_scanned) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
  GROUP BY b.brand_name
),
previous_month AS (
  SELECT b.brand_name, COUNT(*) as receipt_count,
  RANK() OVER (ORDER BY COUNT(*) DESC) as rank
  FROM RECEIPT_ITEMS_FACT ri
  JOIN BRANDS_DIM b ON ri.brand_id = b.brand_id
  JOIN RECEIPTS_FACT r ON ri.receipt_id = r.receipt_id
  WHERE DATE_TRUNC('month', r.date_scanned) = DATE_TRUNC('month', CURRENT_DATE - INTERVAL '2 month')
  GROUP BY b.brand_name
)
SELECT 
  cm.brand_name,
  cm.rank as current_rank,
  pm.rank as previous_rank
FROM current_month cm
LEFT JOIN previous_month pm ON cm.brand_name = pm.brand_name
WHERE cm.rank <= 5;


-- Avg spend by receipt status:

SELECT 
  receipt_status,
  AVG(total_spent) as avg_spend
FROM RECEIPTS_FACT
WHERE receipt_status IN ('ACCEPTED', 'REJECTED')
GROUP BY receipt_status;

-- Total ietems purchased by receipt status:

SELECT 
  receipt_status,
  SUM(purchased_item_count) as total_items
FROM RECEIPTS_FACT
WHERE receipt_status IN ('ACCEPTED', 'REJECTED')
GROUP BY receipt_status;

-- Brand with spend for recent users:

SELECT 
  b.brand_name,
  SUM(ri.total_final_price) as total_spend
FROM RECEIPT_ITEMS_FACT ri
JOIN BRANDS_DIM b ON ri.brand_id = b.brand_id
JOIN RECEIPTS_FACT r ON ri.receipt_id = r.receipt_id
JOIN USERS_DIM u ON r.user_id = u.user_id
WHERE u.created_date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY b.brand_name
ORDER BY total_spend DESC
LIMIT 1;

-- Brand with most transactions for recent users:

SELECT 
  b.brand_name,
  COUNT(DISTINCT r.receipt_id) as transaction_count
FROM RECEIPT_ITEMS_FACT ri
JOIN BRANDS_DIM b ON ri.brand_id = b.brand_id
JOIN RECEIPTS_FACT r ON ri.receipt_id = r.receipt_id
JOIN USERS_DIM u ON r.user_id = u.user_id
WHERE u.created_date >= CURRENT_DATE - INTERVAL '6 months'
GROUP BY b.brand_name
ORDER BY transaction_count DESC
LIMIT 1;

