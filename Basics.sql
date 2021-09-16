

-- creating multiple connected tables to work with 

CREATE TABLE employee (
  emp_id INT PRIMARY KEY,
  first_name VARCHAR(40),
  last_name VARCHAR(40),
  birth_day DATE,
  sex VARCHAR(1),
  salary INT,
  super_id INT,
  branch_id INT
);

CREATE TABLE branch (
  branch_id INT PRIMARY KEY,
  branch_name VARCHAR(40),
  mgr_id INT,
  mgr_start_date DATE,
  FOREIGN KEY(mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

ALTER TABLE employee
ADD FOREIGN KEY(branch_id)
REFERENCES branch(branch_id)
ON DELETE SET NULL;

ALTER TABLE employee
ADD FOREIGN KEY(super_id)
REFERENCES employee(emp_id)
ON DELETE SET NULL;

CREATE TABLE client (
  client_id INT PRIMARY KEY,
  client_name VARCHAR(40),
  branch_id INT,
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL
);

CREATE TABLE works_with (
  emp_id INT,
  client_id INT,
  total_sales INT,
  PRIMARY KEY(emp_id, client_id),
  FOREIGN KEY(emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE,
  FOREIGN KEY(client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TABLE branch_supplier (
  branch_id INT,
  supplier_name VARCHAR(40),
  supply_type VARCHAR(40),
  PRIMARY KEY(branch_id, supplier_name),
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE
);



-- -----------------------------------------------------------------------------

-- Corporate
INSERT INTO employee VALUES(100, 'David', 'Wallace', '1967-11-17', 'M', 250000, NULL, NULL);

INSERT INTO branch VALUES(1, 'Corporate', 100, '2006-02-09');

UPDATE employee
SET branch_id = 1
WHERE emp_id = 100;

INSERT INTO employee VALUES(101, 'Jan', 'Levinson', '1961-05-11', 'F', 110000, 100, 1);

-- Scranton
INSERT INTO employee VALUES(102, 'Michael', 'Scott', '1964-03-15', 'M', 75000, 100, NULL);

INSERT INTO branch VALUES(2, 'Scranton', 102, '1992-04-06');

UPDATE employee
SET branch_id = 2
WHERE emp_id = 102;

INSERT INTO employee VALUES(103, 'Angela', 'Martin', '1971-06-25', 'F', 63000, 102, 2);
INSERT INTO employee VALUES(104, 'Kelly', 'Kapoor', '1980-02-05', 'F', 55000, 102, 2);
INSERT INTO employee VALUES(105, 'Stanley', 'Hudson', '1958-02-19', 'M', 69000, 102, 2);

-- Stamford
INSERT INTO employee VALUES(106, 'Josh', 'Porter', '1969-09-05', 'M', 78000, 100, NULL);

INSERT INTO branch VALUES(3, 'Stamford', 106, '1998-02-13');

UPDATE employee
SET branch_id = 3
WHERE emp_id = 106;

INSERT INTO employee VALUES(107, 'Andy', 'Bernard', '1973-07-22', 'M', 65000, 106, 3);
INSERT INTO employee VALUES(108, 'Jim', 'Halpert', '1978-10-01', 'M', 71000, 106, 3);


-- BRANCH SUPPLIER
INSERT INTO branch_supplier VALUES(2, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Patriot Paper', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'J.T. Forms & Labels', 'Custom Forms');
INSERT INTO branch_supplier VALUES(3, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(3, 'Stamford Labels', 'Custom Forms');

-- CLIENT
INSERT INTO client VALUES(400, 'Dunmore Highschool', 2);
INSERT INTO client VALUES(401, 'Lackawana Country', 2);
INSERT INTO client VALUES(402, 'FedEx', 3);
INSERT INTO client VALUES(403, 'John Daly Law, LLC', 3);
INSERT INTO client VALUES(404, 'Scranton Whitepages', 2);
INSERT INTO client VALUES(405, 'Times Newspaper', 3);
INSERT INTO client VALUES(406, 'FedEx', 2);

-- WORKS_WITH
INSERT INTO works_with VALUES(105, 400, 55000);
INSERT INTO works_with VALUES(102, 401, 267000);
INSERT INTO works_with VALUES(108, 402, 22500);
INSERT INTO works_with VALUES(107, 403, 5000);
INSERT INTO works_with VALUES(108, 403, 12000);
INSERT INTO works_with VALUES(105, 404, 33000);
INSERT INTO works_with VALUES(107, 405, 26000);
INSERT INTO works_with VALUES(102, 406, 15000);
INSERT INTO works_with VALUES(105, 406, 130000);

-- -----------------------------------------------------------------------------

-- performing some basic queries 


-- find all employees ordered by salary 

select * 
from employee
order by salary desc; 

-- find first names of 5 youngest female employees 

select first_name as forename, last_name as surname, birth_day as 'date of birth'
from employee
where sex = 'F'
order by birth_day desc
limit 5;

-- find all different genders 
select distinct sex
from employee;

-- how many employees do we have? 

select count(emp_id)
from employee;

select count(super_id)
from employee;

select count(emp_id)
from employee
where sex = 'M' and birth_day > '1970-01-01'; 

select avg(salary), sex, count(sex)
from employee 
group by sex;

-- total sales of each salesman 

select sum(total_sales), emp_id
from works_with
group by emp_id;


-- find supplier probably working with labels
select * 
from branch_supplier 
where supplier_name like '%label%';


-- find emp born in feb
select *
from employee 
where birth_day like '%-02-%';


-- find list of employees and branch names

select last_name as 'List of names and company names'
from employee
union
select branch_name
from branch;

-- list all clients and branch suppliers' names 

select client_name as 'List of client and branch suppliers\' names', client.branch_id
from client
union
select supplier_name, branch_supplier.branch_id
from branch_supplier;

-- list money spent and earned 

select sum(salary) as 'money spent and earned'
from employee
union
select sum(total_sales)
from works_with;

-- find all branches and the names of their managers 

insert into branch values(4, 'Buffalo', null, null);

select employee.emp_id, concat_ws(' ', employee.first_name, employee.last_name) as Full_Name, branch.branch_name
from employee
right join branch
on employee.emp_id = branch.mgr_id;


 -- find names of all employees who have sold over 30k to a client
 
 select concat_ws(' ', employee.first_name, employee.last_name) as Full_Name
 from  employee
 where employee.emp_id in (
	select works_with.emp_id
    from works_with
    where works_with.total_sales > 30000);

-- find client names of branches managed by Michael Scott

select client.client_name 
from client
where branch_id in(
	select branch.branch_id
    from branch
    where branch.mgr_id in(
		select employee.emp_id
		from employee
		where first_name = 'Michael' and last_name = 'Scott'));
        
        
-- triggers 

create table trigger_test (
	message VARCHAR(20));
    
Delimiter $$
create 
	trigger my_trigger before insert 
    on employee
    for each row begin 
		insert into trigger_test values('added new employee');
	end$$
delimiter ;

-- test trigger 

insert into employee
values(110, 'Martin', 'Dishman', '1987-08-29', 'M', 98000, 106, 3);

select * from trigger_test;  


delimiter $$
create 
	trigger my_trigger1 after insert
    on employee
    for each row begin
		if new.sex = 'M' then
			insert into trigger_test values('male employee added');
		elseif new.sex = 'F' then
			insert into trigger_test values('female employee added');
		else 
			insert into trigger_test values('another employee added');
		end if;
	end$$
delimiter ;

insert into employee
values('111', 'Pam', 'Dill', '1989-02-15', 'F', 84000, 105, 1);

select * from trigger_test; 