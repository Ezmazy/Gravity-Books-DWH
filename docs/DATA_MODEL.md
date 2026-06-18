# Data Model Documentation — Gravity Books DWH

## OLTP Source Schema — `gravity_books`

### Entity-Relationship Overview

```
publisher ────────┐
                  │
book_language ────┤
                  ▼
author ──── book_author ──── book
                              │
                              ▼
                          order_line ──── cust_order ──── customer
                                              │               │
                              shipping_method ┘    customer_address
                                                         │
                                                       address ──── country
                                                                  address_status
                              order_history ──── cust_order
                              order_status ──────┘
```

### OLTP Tables Detail

**`customer`**
| Column | Type | Notes |
|---|---|---|
| customer_id | int PK | |
| first_name | varchar | |
| last_name | varchar | |
| email | varchar | |

**`address`**
| Column | Type | Notes |
|---|---|---|
| address_id | int PK | |
| street_number | varchar | |
| street_name | varchar | |
| city | varchar | |
| country_id | int FK → country | |

**`customer_address`**
| Column | Type | Notes |
|---|---|---|
| customer_id | int FK → customer | |
| address_id | int FK → address | |
| status_id | int FK → address_status | |

**`book`**
| Column | Type | Notes |
|---|---|---|
| book_id | int PK | |
| title | varchar | |
| isbn13 | varchar | |
| language_id | int FK → book_language | |
| num_pages | int | |
| publication_date | date | |
| publisher_id | int FK → publisher | |

**`cust_order`**
| Column | Type | Notes |
|---|---|---|
| order_id | int PK | |
| customer_id | int FK → customer | |
| shipping_method_id | int FK → shipping_method | |
| order_date | datetime | |
| dest_address_id | int FK → address | |

**`order_line`**
| Column | Type | Notes |
|---|---|---|
| line_id | int PK | |
| order_id | int FK → cust_order | |
| book_id | int FK → book | |
| price | decimal | |

**`order_history`**
| Column | Type | Notes |
|---|---|---|
| history_id | int PK | |
| order_id | int FK → cust_order | |
| status_id | int FK → order_status | |
| status_date | datetime | Event timestamp |

**`order_status`**
| status_id | status_value |
|---|---|
| 1 | Order Received |
| 2 | Pending Delivery |
| 3 | Delivery In Progress |
| 4 | Delivered |
| 5 | Cancelled |
| 6 | Returned |

---

## DWH Star Schema — `gravity_books_DWH`

### Schema Diagram

```
                        Dim_Date ◄──────────────────────────┐
                                                            │ (order_date_SK_FK)
dim_customer ◄── fact_order ──► dim_book                   │
                    │                                       │
                    ▼                                       │
              dim_shipping_method                           │
                    │                                       │
                    ▼                                       │
              dim_address                                   │

                                                     fact_order_process
                                                     ┌─────────────────────┐
                                                     │ received_date_SK_FK  │──► Dim_Date
                                                     │ pending_date_SK_FK   │──► Dim_Date
                                                     │ inprogress_date_SK_FK│──► Dim_Date
                                                     │ delivered_date_SK_FK │──► Dim_Date
                                                     │ cancelled_date_SK_FK │──► Dim_Date
                                                     │ returned_date_SK_FK  │──► Dim_Date
                                                     │ customer_SK_FK       │──► dim_customer
                                                     │ shipping_method_SK_FK│──► dim_shipping_method
                                                     └─────────────────────┘
```

### DWH Tables Detail

#### dim_customer (SCD Type 2)
| Column | Type | Notes |
|---|---|---|
| customer_SK | int IDENTITY PK | Surrogate key |
| customer_id_bk | int | Business key from OLTP |
| first_name | varchar(200) | |
| last_name | varchar(200) | |
| email | varchar(350) | |
| start_date | date | SCD2 effective start |
| end_date | date | SCD2 effective end (NULL = current) |
| is_current | tinyint | 1 = current record |

#### dim_address (SCD Type 2)
| Column | Type | Notes |
|---|---|---|
| address_SK | int IDENTITY PK | Surrogate key |
| address_id_bk | int | Business key |
| street_number | varchar(10) | |
| street_name | varchar(200) | |
| city | varchar(100) | |
| country_id_bk | int | Original country ID |
| country_name | varchar(200) | Denormalized |
| start_date | date | SCD2 |
| end_date | date | SCD2 |
| is_current | tinyint | SCD2 |

#### dim_customer_address (Bridge)
| Column | Type | Notes |
|---|---|---|
| customer_SK_FK | int PK (composite) | FK → dim_customer |
| address_SK_FK | int PK (composite) | FK → dim_address |
| status_id_bk | int | |
| address_status | varchar(30) | Delivery / current / etc |

#### dim_book (SCD Type 2)
| Column | Type | Notes |
|---|---|---|
| book_SK | int IDENTITY PK | |
| book_id_bk | int | Business key |
| title | varchar(400) | |
| isbn13 | varchar(13) | |
| language_id_bk | int | |
| language_code | varchar(8) | |
| language_name | varchar(50) | Denormalized |
| num_pages | int | |
| publication_date | date | |
| publisher_id_bk | int | |
| publisher_name | nvarchar(1000) | Denormalized |
| start_date | date | SCD2 |
| end_date | date | SCD2 |
| is_current | tinyint | SCD2 |

#### dim_author
| Column | Type | Notes |
|---|---|---|
| author_SK | int IDENTITY PK | |
| author_id_bk | int | |
| author_name | varchar(400) | |

#### dim_book_author (Bridge — many-to-many)
| Column | Type | Notes |
|---|---|---|
| book_SK_FK | int PK (composite) | FK → dim_book |
| author_SK_FK | int PK (composite) | FK → dim_author |

#### dim_shipping_method (SCD Type 2)
| Column | Type | Notes |
|---|---|---|
| shipping_method_SK | int IDENTITY PK | |
| method_id_bk | int | |
| method_name | varchar(100) | |
| cost | decimal(6,2) | |
| start_date | date | SCD2 |
| end_date | date | SCD2 |
| is_current | tinyint | SCD2 |

#### fact_order
| Column | Type | Notes |
|---|---|---|
| order_fact_SK | int IDENTITY PK | |
| book_SK_FK | int FK | → dim_book |
| customer_SK_FK | int FK | → dim_customer |
| shipping_method_SK_FK | int FK | → dim_shipping_method |
| address_SK_FK | int FK | → dim_address |
| order_id_DD | int | Degenerate dimension |
| order_line_id_DD | int | Degenerate dimension |
| order_date_SK_FK | int FK | → Dim_Date |
| order_time_SK_FK | int FK | → Dim_Time |
| price | decimal(5,2) | Order line price |

#### fact_order_process
| Column | Type | Notes |
|---|---|---|
| order_id_BK | int PK | Business key (order_id from OLTP) |
| received_date_SK_FK | int FK | → Dim_Date |
| pending_date_SK_FK | int FK | → Dim_Date |
| inprogress_date_SK_FK | int FK | → Dim_Date |
| delivered_date_SK_FK | int FK | → Dim_Date |
| cancelled_date_SK_FK | int FK | → Dim_Date |
| returned_date_SK_FK | int FK | → Dim_Date |
| customer_SK_FK | int FK | → dim_customer |
| shipping_method_SK_FK | int FK | → dim_shipping_method |
| current_status | nvarchar(50) | Latest order status |
| days_to_ship | int | Days from received → in-progress |
| days_to_deliver | int | Days from received → delivered |

---

## ETL Load Order

SSIS packages must be run in the following dependency order:

```
1. dim_customer          (no dimension dependencies)
2. dim_address           (no dimension dependencies)
3. dim_customer_address  (depends on: dim_customer, dim_address)
4. dim_book              (no dimension dependencies)
5. dim_author            (no dimension dependencies)
6. dim_book_author       (depends on: dim_book, dim_author)
7. dim_shipping_method   (no dimension dependencies)
── All dimensions must be complete before facts ──
8. fact_order            (depends on: all dims + Dim_Date + Dim_Time)
9. fact_order_process    (depends on: dim_customer, dim_shipping_method, Dim_Date)
```

---

## SSAS Cube — Gravity Books DWH

### Fact: Fact Order Process

The primary measure group.

| Measure | Type | Description |
|---|---|---|
| days_to_ship | Numeric | Order fulfillment speed |
| days_to_deliver | Numeric | End-to-end delivery time |
| Order Count | Count | Number of orders (implicit) |

### Role-Playing Date Dimensions

The `Dim_Date` table is used 5 times in the cube, each with a different role:

| Role Name | Fact Column | Business Meaning |
|---|---|---|
| Dim Date (Order) | order_date_SK | When the order was placed |
| Dim Date received | received_date_SK_FK | When order was received into system |
| Dim Date pending | pending_date_SK_FK | When order moved to pending |
| Dim Date inprogress | inprogress_date_SK_FK | When shipping started |
| Dim Date cancelled | cancelled_date_SK_FK | When order was cancelled |
| Dim Date returned | returned_date_SK_FK | When order was returned |

### Typical Analysis Queries (MDX-style intent)

- Average days to deliver by shipping method
- Order volume by month received
- Cancellation rate by book category
- Customer order history by year
