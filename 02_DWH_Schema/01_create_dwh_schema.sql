Create Database gravity_books_DWH
Go

create table dim_customer (
customer_SK int Identity (1,1) Primary Key,
customer_id_bk int,
first_name varchar(200),
last_name varchar(200),
email varchar(350)
)

create table dim_address(
address_SK int Identity (1,1) Primary Key ,
address_id_bk int,
street_number varchar(10),
street_name varchar(200),
city varchar(100),
country_id int,
country_name varchar(200)
)


create table dim_customer_address(
customer_SK_FK int,
address_SK_FK int ,
status_id_bk int,
address_status varchar(30), 
CONSTRAINT pk_customer_address
        PRIMARY KEY (customer_SK_FK, address_SK_FK)
)


create table dim_book(
book_SK int Identity(1,1) Primary Key ,
book_id_bk int,
title varchar(400),
isbn13 varchar(13),
language_id_bk int ,
language_code varchar(8),
language_name varchar(50),
num_pages int,
publication_date date ,
publisher_id_bk int,
publisher_name nvarchar(1000)
)

create table dim_author (
author_SK int Identity(1,1) Primary Key,
author_id_bk int ,
author_name varchar(400) 
)

create table dim_book_author (
book_SK_FK int,
author_SK_FK int,

Constraint pk_book_author
    Primary Key (book_SK_FK,author_SK_FK)
)

create table dim_shipping_method(
shipping_method_SK int Identity(1,1) Primary Key,
method_id_bk int,
method_name varchar(100),
cost decimal(6,2)
)




create table fact_order(
order_fact_SK int Identity(1,1) Primary Key ,
book_SK_FK int ,
customer_SK_FK int ,
shipping_method_SK_FK int,
-- address_SK_FK int ,
order_id_DD int,
order_line_id_DD int ,
order_date_SK_FK int ,
order_time_SK_FK int ,

Constraint order_fact_book Foreign key (book_SK_FK) references dim_book (book_SK),
Constraint order_fact_customer Foreign key (customer_SK_FK) references dim_customer (customer_SK),
Constraint order_fact_shipping_method Foreign key (shipping_method_SK_FK) references dim_shipping_method (shipping_method_SK),
Constraint order_fact_date_dim Foreign key (order_date_SK_FK) references Dim_date (Date_SK),
Constraint order_fact_time_dim Foreign key (order_time_SK_FK) references Dim_time (Time_SK),

)


create table fact_order_process(
order_id_BK int Primary Key,
received_date_SK_FK int,
pending_date_SK_FK int,
inprogress_date_SK_FK int,
delivered_date_SK_FK int,
cancelled_date_SK_FK int,
returned_date_SK_FK int,
current_status varchar(50),
days_to_ship int,
days_to_deliver int

CONSTRAINT FK_process_received_date FOREIGN KEY (received_date_SK_FK) REFERENCES Dim_date(Date_SK),
CONSTRAINT FK_process_pending_date FOREIGN KEY (pending_date_SK_FK) REFERENCES Dim_date(Date_SK),
CONSTRAINT FK_process_inprogress_date FOREIGN KEY (inprogress_date_SK_FK) REFERENCES Dim_date(Date_SK),
CONSTRAINT FK_process_delivered_date FOREIGN KEY (delivered_date_SK_FK) REFERENCES Dim_date(Date_SK),
CONSTRAINT FK_process_cancelled_date FOREIGN KEY (cancelled_date_SK_FK) REFERENCES Dim_date(Date_SK),
CONSTRAINT FK_process_returned_date FOREIGN KEY (returned_date_SK_FK) REFERENCES Dim_date(Date_SK)

)

ALTER TABLE fact_order_process ADD
    customer_SK_FK int,
    book_SK_FK int,
    shipping_method_SK_FK int

ALTER TABLE fact_order_process 
ADD CONSTRAINT FK_process_customer FOREIGN KEY (customer_SK_FK) REFERENCES dim_customer(customer_SK);

ALTER TABLE fact_order_process 
ADD CONSTRAINT FK_process_book FOREIGN KEY (book_SK_FK) REFERENCES dim_book(book_SK);

ALTER TABLE fact_order_process 
ADD CONSTRAINT FK_process_shipping FOREIGN KEY (shipping_method_SK_FK) REFERENCES dim_shipping_method(shipping_method_SK)



alter table dim_customer add
[start_date] date,
	[end_date] date,
	is_Current tinyint


alter table dim_address add
[start_date] date,
	[end_date] date,
	is_current tinyint

 EXEC sp_rename 'dim_address.country_id', 'country_id_bk', 'COLUMN';


 alter table dim_book add
[start_date] date,
	[end_date] date,
	is_current tinyint


alter table dim_shipping_method add
[start_date] date,
	[end_date] date,
	is_current tinyint


alter table fact_order add
address_SK_FK int

alter table fact_order add
Constraint order_fact_address Foreign key (address_SK_FK) references dim_address (address_SK)

alter table fact_order add
price decimal(5, 2)





ALTER TABLE fact_order_process drop column
 book_SK_FK


ALTER TABLE fact_order_process 
drop CONSTRAINT FK_process_book 



--ALTER TABLE fact_order_process 
--drop CONSTRAINT FK_process_shipping

--ALTER TABLE fact_order_process drop column
    --customer_SK_FK,
    --shipping_method_SK_FK

--ALTER TABLE fact_order_process 
--drop CONSTRAINT FK_process_customer


ALTER TABLE fact_order_process
ALTER COLUMN current_status NVARCHAR(50)


INSERT INTO Dim_Date (
    Date_SK,
    Date,
    Day,
    DaySuffix,
    DayOfWeek,
    DOWInMonth,
    DayOfYear,
    WeekOfYear,
    WeekOfMonth,
    Month,
    MonthName,
    Quarter,
    QuarterName,
    Year,
    StandardDate,
    Holiday_name_en
)
VALUES (
    -1,
    '1900-01-01',
    '00',
    'NA',
    'Unknown',
    0,
    0,
    0,
    0,
    '00',
    'Unknown',
    0,
    'Unknwn',
    '1900',
    NULL,
    NULL
);