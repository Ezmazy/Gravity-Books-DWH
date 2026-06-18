SELECT 
    o.order_id,
    o.customer_id,
    ol.book_id,
    o.shipping_method_id,
    -- Milestone Dates (Flattened)
    MAX(CASE WHEN oh.status_id = 1 THEN oh.status_date END) AS received_date,
    MAX(CASE WHEN oh.status_id = 2 THEN oh.status_date END) AS pending_date,
    MAX(CASE WHEN oh.status_id = 3 THEN oh.status_date END) AS inprogress_date,
    MAX(CASE WHEN oh.status_id = 4 THEN oh.status_date END) AS delivered_date,
    MAX(CASE WHEN oh.status_id = 5 THEN oh.status_date END) AS cancelled_date,
    MAX(CASE WHEN oh.status_id = 6 THEN oh.status_date END) AS returned_date,
    -- Most Recent Status
    (SELECT TOP 1 os.status_value 
     FROM order_history h 
     JOIN order_status os ON h.status_id = os.status_id 
     WHERE h.order_id = o.order_id 
     ORDER BY h.status_date DESC) as current_status
FROM cust_order o
JOIN order_line ol ON o.order_id = ol.order_id
JOIN order_history oh ON o.order_id = oh.order_id
GROUP BY 
    o.order_id, 
    o.customer_id, 
    ol.book_id, 
    o.shipping_method_id


