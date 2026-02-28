-- Library Management System Project 2 
-- create branch table 
use library_project2;
create table branch
           (
             branch_id varchar(10) Primary Key,
             manager_id	varchar(10),
             branch_address	varchar(50),
             contact_no varchar(10)
             );
alter table branch 
modify column contact_no varchar (15);


Drop table  if exists Employees;
create table Employees (
			emp_id	VARCHAR(10)PRIMARY KEY,
            emp_name VARCHAR(25),
            position VARCHAR(15),
            salary	INT(10),
            branch_id VARCHAR(25) -- FK
            );

create table books (
            isbn varchar(20)Primary Key,
            book_title Varchar(75),
            category varchar(10),
            rental_price Float,
            status varchar(15),
            author varchar(35),
            publisher varchar(55)
            );
create table members (
             member_id	varchar(10) Primary Key,
             member_name varchar(25),
             member_address	varchar(75),
             reg_date date 
             );
             
create table issued_status (
              issued_id	varchar(10) Primary key,
              issued_member_id varchar(10), -- FK
              issued_book_name varchar(75), 
              issued_date date, 
              issued_book_isbn varchar(25), -- FK
              issued_emp_id varchar(15) -- FK
              );
create table return_status (
             return_id	varchar(10) Primary key,
             issued_id	varchar(10), -- FK
             return_book_name varchar(75), 
             return_date date,
             return_book_isbn varchar(20) -- FK
             );
-- Foreign key 
alter table issued_status 
add constraint fk_members
foreign key (issued_member_id)
References members (member_id);

alter table issued_staus 
add constraint fk_books
foreign key (issued_book_isbn)
references books (isbn);

alter table issued_status 
add constraint fk_employees
foreign key (issued_emp_id) 
references employees (emp_id);

alter table Employees 
add constraint fk_branch 
foreign key (branch_id) 
references branch(branch_id);

alter table return_status 
add constraint fk_issued_status 
foreign key (issued_id)
references issued_status (issued_id);

-- alter table return_staus 
-- add constraint fk_isbn
-- foreign key (return_book_isbn)
-- references books (isbn);





