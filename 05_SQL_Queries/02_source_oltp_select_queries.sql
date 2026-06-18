use gravity_books

select c.customer_id,c.first_name,c.last_name,c.email from customer c

select * from address

select a.address_id,a.street_number,a.street_name,a.city,a.country_id ,c.country_name from address a 
left join country c
on a.country_id = c.country_id


select ca.customer_id,ca.address_id,ca.status_id,ads.address_status from customer_address ca
left join address_status ads
on ca.status_id = ads.status_id

select c.customer_id, from customer c inner join customer_address ca 
on c.customer_id = ca.customer_id
inner join address ads
on ads.address_id = ca.customer_id
left join address_status adds
on adds.status_id = ca.status_id




select b.book_id,b.isbn13,b.num_pages,b.publication_date,b.title,b.language_id,bl.language_code,bl.language_name,b.publisher_id,p.publisher_name from book b
left join book_language bl
on b.language_id = bl.language_id
left join publisher p
on b.publisher_id = p.publisher_id




select a.author_id,a.author_name from author a

select ba.author_id,ba.book_id from book_author ba

select sm.method_id,sm.method_name,sm.cost from shipping_method sm


select co.order_id,co.customer_id,co.shipping_method_id,co.order_date,co.dest_address_id,cl.book_id,cl.line_id,cl.price
from cust_order co inner join order_line cl on co.order_id = cl.order_id

select distinct os.status_value from order_history oh  join order_status os on oh.status_id = os.status_id




select cs.order_id,cs.customer_id,cs.shipping_method_id,oh.status_date,os.status_value from cust_order cs join order_history oh on cs.order_id = oh.order_id join order_status os on
oh.status_id = os.status_id

select * from cust_order co join order_line ol 
on ol.order_id = co.order_id join order_history oh 
on oh.order_id = co.order_id
where co.order_id = 1900

-- input to fact_order_process

SELECT 
    o.order_id AS order_id,
    MAX(CASE WHEN oh.status_id = 1 THEN oh.status_date END) AS Date_Received,
    MAX(CASE WHEN oh.status_id = 2 THEN oh.status_date END) AS Date_Pending,
    MAX(CASE WHEN oh.status_id = 3 THEN oh.status_date END) AS Date_InProgress,
    MAX(CASE WHEN oh.status_id = 4 THEN oh.status_date END) AS Date_Delivered,
    MAX(CASE WHEN oh.status_id = 5 THEN oh.status_date END) AS Date_Cancelled,
    MAX(CASE WHEN oh.status_id = 6 THEN oh.status_date END) AS Date_Returned,
    (SELECT TOP 1 os.status_value FROM order_history h 
     JOIN order_status os ON h.status_id = os.status_id 
     WHERE h.order_id = o.order_id ORDER BY h.status_date DESC) as Current_Status
FROM cust_order o
JOIN order_history oh ON o.order_id = oh.order_id
GROUP BY o.order_id

