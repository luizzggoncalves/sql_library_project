SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

-- project Task

-- Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;



-- Update an Existing Member's Address

UPDATE members
SET member_address = '897 Winners Circle'
WHERE member_id = 'C102'

;

-- Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121';

SELECT issued_id
FROM issued_status
ORDER BY 1 DESC;



-- Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

SELECT * FROM issued_status;


-- List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1


-- CTAS Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

CREATE TABLE book_cnts
AS
SELECT
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM book_cnts;

-- Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic';

-- Find Total Rental Income by Category

SELECT 
	category,
	SUM(rental_price) as total_rental_price,
	COUNT(*)
FROM books
GROUP BY category
;

SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1

-- List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';


-- List Employees with Their Branch Manager's Name and their branch details:

SELECT 
	el.*,
	b.branch_id,
	manager_id,
	e2.emp_name as manager
	
FROM employees as el
JOIN 
	branch as b
ON b.branch_id = el.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id;

-- Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

-- Retrieve the List of Books Not Yet Returned


SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;







