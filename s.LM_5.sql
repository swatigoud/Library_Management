-- CREATE DATABASE library;
use library_project2;
-- Create table "Branch"
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);


-- Project TASK


-- ### 2. CRUD Operations



-- Task 1. Create a New Book Record
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
update members
set member_address = '125 Main st'
where member_id =  'C101';


-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
Delete from issued_status 
where issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status 
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.
 select
       issued_member_id,
	   count(*)
 from issued_staus 
 group by issued_member_id
 having count(*) >1;

-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
create table book_counts
as 
select   
      b.isbn,
      b.book_title,
      count(ist.issued_id) as no_issued
from books as b 
join 
issued_status as ist
on b.isbn = issued_book_isbn
group by  b.isbn, b.book_title;

select * from book_counts ;

-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:
select * from books 
where category = 'classic';

-- Task 8: Find Total Rental Income by Category:
select 
	 b.category,
     sum(b.rental_price),
     Count(*)
from books as b 
join 
issued_status as ist 
on b.isbn = issued_book_isbn
group by b.category;


-- Task 9. **List Members Who Registered in the Last 180 Days**:
select * 
from members
where reg_date >= current_date - Interval 180 day;


insert into members(member_id, member_name, member_address, reg_date)
values ('C120','Swati', '39 whiteway street','2026-02-24'),
       ('C121', 'Shweta','29A Heron Mews ilford','2025-12-01'),
       ('C122','Bhanu Prasad','26 Forest gate London','2026-01-18');

-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:
select   
       e1. * ,
       e2.emp_name as manager,
       b.manager_id
from branch as b
join 
employees as e1
on b.branch_id = e1.branch_id
join 
employees as e2
on e2.emp_id = b.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
create table expensive_books as 
select 
      *
from books
where rental_price > 7;
select * from expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned
select 
      distinct ist.issued_book_name
from issued_status as ist
left join
return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null 

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
-- issued_status == members == books == return_status
-- filter books which is returned
-- overdue > 30 
select 
      ist.issued_member_id,
      m.member_name,
      bk.book_title,
      ist.issued_date,
      -- return_date,
      current_date - ist.issued_date as over_due_days
from issued_status as ist 
join 
members as m 
on m.member_id = ist.issued_member_id
join 
books as bk 
on bk.isbn = ist.issued_book_isbn
left join 
return_status as rs 
on  rs.issued_id = ist.issued_id
where 
     rs.return_date is NULL
     and 
     (current_date() - ist.issued_date)>30
order by 1 ; 

/* Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
select * from issued_status
where issued_book_isbn = '978-0-451-52994-2';

select * from books 
where isbn = '978-0-451-52994-2';
-- 
Insert into return_status (return_id, issued_id, return_date, book_quality)
values ('RS125', 'IS130',current_date, 'Good');
select * from return_status
where issued_id = 'IS130';

update  books 
set  status = 'no'
where isbn = '978-0-451-52994-2';

update books
set status = 'yes'
where isbn = '978-0-451-52994-2';

-- Stored Procedures


Delimiter $$
DROP PROCEDURE IF EXISTS add_return_records$$

create  procedure add_return_records(
      In p_return_id varchar(10), 
      In p_issued_id  varchar(10),
      In  p_book_quality varchar(50)
)
Begin
Declare  v_isbn VARCHAR(50);
Declare v_book_name VARCHAR (80);
      
  -- all your logic and code 
  -- inserting into returns based on users input 
  Insert into return_status (return_id, issued_id, return_date, book_quality)
  values 
  (p_return_id,p_issued_id, Current_date, p_book_quality);
  
  select 
       issued_book_isbn ,
       issued_book_name
       into 
       v_isbn,
       v_book_name
  from issued_status 
  where issued_id = p_issued_id;
  
  update books
  set status = 'yes'
  where isbn = v_isbn;
  
  select concat ('Thank you for returning the book: ',v_book_name) As Message;
End$$
DELIMITER  ;
CALL add_return_records;

call add_return_records;

-- Testing Function and return records 
update books
set status = 'yes'
where isbn = '978-0-307-58837-2';

select * from issued_status 
where issued_id = 'IS135';
select * from books 
where isbn = '978-0-307-58837-1';

select * from issued_status 
where issued_book_isbn = '978-0-553-29698-2';

select * from return_status ;
delete from return_status 
where issued_id = 'IS135';

call add_return_records('RS140','IS135','Good');

SHOW CREATE TABLE books;
INSERT INTO books (isbn, book_title)
VALUES ('', 'Moby Dick');
SELECT isbn, 
       isbn IS NULL AS is_null,
       LENGTH(isbn) AS length_value
FROM books;

UPDATE books
SET isbn = '978-0-307-58837-1'
WHERE book_title = 'Moby Dick';
/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/
select * from branch;
select * from issued_status;
select * from return_status;

create table branch_reports 
as 
select  
      bh.branch_id,
      bh.manager_id,
      count(ist.issued_id) as number_book_issued,
      count(rs.return_id ) as number_book_returned,
      sum(bk.rental_price) as total_revenue
from issued_status as ist 
join 
employees as e 
on ist.issued_emp_id = e.emp_id 
join 
branch as bh 
on e.branch_id = bh.branch_id
left join 
return_status as rs 
on rs.issued_id = ist.issued_id
join 
books as bk
on ist.issued_book_isbn = bk.isbn
group by bh.branch_id, bh.manager_id;
select * from branch_reports;

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table
active_members containing members who have issued at least one book in the last 2 months.
*/
-- select * from employees ;
-- select * from issued_status;

-- select date_sub(current_date, interval 6 month);

create table active_members 
as 
select * from members 
where member_id  IN (select 
                          distinct issued_member_id
                     from issued_status 
					 where issued_date >= current_date - interval 6 month
					 );
select * from active_members;
/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/
select 
       e.emp_name,
       bh.*,
       count(ist.issued_id) as no_issued_books
       
from issued_status as ist 
join    
employees as e 
on e.emp_id = ist.issued_emp_id
join 
branch as bh
on bh.branch_id = e.branch_id
group by e.emp_name, 2;

/*
Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/       
select 
     b.book_title,
     m.member_name,
     count(*) as damaged_count
from books as b
join 
issued_status as ist
on 
ist.issued_book_isbn = b.isbn
join 
return_status as rs 
on ist.issued_id = rs.issued_id
join 
members as m 
on ist.issued_member_id = m.member_id
where rs.book_quality = 'damaged'
group by b.book_title, m.member_name
having count(*) > 2;

/*
Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

select * from books ;
select * from issued_status;
delimiter $$ 
create  procedure issue_book(
					IN p_issued_id varchar(10), 
                    IN p_issued_member_id varchar(30),
                    IN p_issued_book_isbn varchar(30),
                    In p_issued_emp_id varchar(10)
)
Begin
Declare 
-- all the variable
   v_status Varchar(10);
 
-- all the code
    -- checking if the book is available 'yes'
    select 
        status 
        into 
        v_status
    from books 
    where isbn = p_issued_book_isbn;
    
    if v_status = 'yes' Then 
    
         insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		 values
         (p_issued_id, p_issued_member_id, current_date, p_issued_book_isbn, p_issued_emp_id);
         
		 update books
         set status = 'No'
         where isbn = p_issued_book_isbn;
         
         select concat ('Book records added successfully for book isbn:' , p_issued_book_isbn) As Message;
    else 
         select concat ('Sorry to inform you the book you have requested is unavailable book_isbn:' , p_issued_book_isbn) As Message;
    END IF ;
    
    
End$$ 
Delimiter ;

select * from books;
-- "978-0-553-29698-2" -- yes 
-- "978-0-375-41398-8" -- No
select * from issued_status;

call issue_book('IS155','C108','978-0-553-29698-2','E104');

call issue_book('IS156','C108','978-0-375-41398-8','E104');
                    
                    

