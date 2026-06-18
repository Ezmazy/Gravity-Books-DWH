use gravity_books_DWH

delete from gravity_books_DWH.dbo.dim_customer

DBCC CHECKIDENT ('dim_customer',RESEED,0)

select * from dim_customer


delete from gravity_books_DWH.dbo.dim_address

DBCC CHECKIDENT ('dim_address',RESEED,0)

select * from dim_address


delete from gravity_books_DWH.dbo.dim_customer_address

DBCC CHECKIDENT ('dim_customer_address',RESEED,0)

select * from dim_customer_address


select da.address_SK,da.address_id_bk from dim_address da
where da.is_current = 1

select * from dim_customer

select dc.customer_SK,dc.customer_id_bk from dim_customer dc
where dc.is_Current = 1

delete from gravity_books_DWH.dbo.dim_book

DBCC CHECKIDENT ('dim_book',RESEED,0)


select * from dim_book


delete from gravity_books_DWH.dbo.dim_author

DBCC CHECKIDENT ('dim_author',RESEED,0)

select * from dim_author


delete from gravity_books_DWH.dbo.dim_book_author

DBCC CHECKIDENT ('dim_author',RESEED,0)




delete from gravity_books_DWH.dbo.dim_shipping_method

DBCC CHECKIDENT ('dim_shipping_method',RESEED,0)


select * from dim_shipping_method


select * from fact_order




select * from dim_address
select * from dim_author
select * from dim_book_author
select * from dim_book
select * from dim_customer
select * from dim_customer_address
select * from dim_shipping_method

select * from fact_order

