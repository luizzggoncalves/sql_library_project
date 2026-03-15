# Library Management System using SQL Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

> **Note:** The `branch` table was initially created with a typo (`brach`) and later renamed using `ALTER TABLE brach RENAME TO branch;`. Foreign keys were added via `ALTER TABLE` statements after all tables were created.

```sql
-- Branch table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
    branch_id      VARCHAR(10) PRIMARY KEY,
    manager_id     VARCHAR(10),
    branch_address VARCHAR(55),
    contact_no     VARCHAR(10)
);

-- Employees table
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id    VARCHAR(10) PRIMARY KEY,
    emp_name  VARCHAR(25),
    position  VARCHAR(15),
    salary    FLOAT,
    branch_id VARCHAR(10) -- FK
);

-- Books table
DROP TABLE IF EXISTS books;
CREATE TABLE books (
    isbn         VARCHAR(20) PRIMARY KEY,
    book_title   VARCHAR(75),
    category     VARCHAR(25),
    rental_price FLOAT,
    status       VARCHAR(15),
    author       VARCHAR(35),
    publisher    VARCHAR(55)
);

-- Members table
DROP TABLE IF EXISTS members;
CREATE TABLE members (
    member_id      VARCHAR(10) PRIMARY KEY,
    member_name    VARCHAR(55),
    member_address VARCHAR(75),
    reg_date       DATE
);

-- Issued Status table
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status (
    issued_id        VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),  -- FK
    issued_book_name VARCHAR(80),
    issued_date      DATE,
    issued_book_isbn VARCHAR(50),  -- FK
    issued_emp_id    VARCHAR(10)   -- FK
);

-- Return Status table
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status (
    return_id        VARCHAR(10) PRIMARY KEY,
    issued_id        VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date      DATE,
    return_book_isbn VARCHAR(50)
);
```

**Foreign Keys (added after table creation):**

```sql
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id) REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id) REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id);
```

---

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `members` table.
- **Delete**: Removed records from the `issued_status` table.

**Task 1: Create a New Book Record**

```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;
```

**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '897 Winners Circle'
WHERE member_id = 'C102';
```

**Task 3: Delete a Record from the Issued Status Table**

Objective: Delete the record with `issued_id = 'IS121'` from the `issued_status` table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';

SELECT issued_id
FROM issued_status
ORDER BY 1 DESC;
```

**Task 4: Retrieve All Books Issued by a Specific Employee**

Objective: Select all books issued by the employee with `emp_id = 'E101'`.

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```

**Task 5: List Members Who Have Issued More Than One Book**

Objective: Use `GROUP BY` to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1;
```

---

### 3. CTAS (Create Table As Select)

**Task 6: Create Summary Table — Books and Total Issue Count**

Used CTAS to generate a new table based on query results, showing each book and how many times it has been issued.

```sql
CREATE TABLE book_cnts AS
SELECT
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN issued_status AS ist
    ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM book_cnts;
```

---

### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

**Task 7: Retrieve All Books in a Specific Category**

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

**Task 8: Find Total Rental Income by Category**

```sql
SELECT
    category,
    SUM(rental_price) AS total_rental_price,
    COUNT(*)
FROM books
GROUP BY category;
```

Alternatively, based only on books that were actually issued:

```sql
SELECT
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM issued_status AS ist
JOIN books AS b
    ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
```

**Task 9: List Members Who Registered in the Last 180 Days**

```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

**Task 10: List Employees with Their Branch Manager's Name and Branch Details**

```sql
SELECT
    e1.*,
    b.branch_id,
    b.manager_id,
    e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
    ON b.branch_id = e1.branch_id
JOIN employees AS e2
    ON b.manager_id = e2.emp_id;
```

**Task 11: Create a Table of Books with Rental Price Above a Certain Threshold**

```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

**Task 12: Retrieve the List of Books Not Yet Returned**

```sql
SELECT * FROM issued_status AS ist
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

---

## How to Run

1. Create a PostgreSQL database named `library_db`.
2. Run `schemas.sql` to create all tables and foreign key constraints.
3. Populate the tables with your data (INSERT statements).
4. Run `queries.sql` to execute all project tasks.

---

## Author

Project developed as an intermediate SQL exercise covering database design, CRUD operations, CTAS, and analytical queries using PostgreSQL.
