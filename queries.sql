-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

-- Retirement eligibility (1952)
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

-- Retirement eligibility (1953)
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1953-01-01' AND '1953-12-31';

-- Retirement eligibility (1954)
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1954-01-01' AND '1954-12-31';

-- Retirement eligibility (1955)
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1955-01-01' AND '1955-12-31';

-- Retirement eligibility (hired between 1985-1988)
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Create new table for retirement eligibility
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Creating emp_info table
SELECT e.emp_no, 
	e.first_name, 
	e.last_name, 
	e.gender,
	s.salary,
	de.to_date
INTO employees_info 
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_employees as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND ' 1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

-- List of managers per department
SELECT dm.dept_no,
		d.dept_name,
		dm.emp_no,
		ce.last_name,
		ce.first_name,
		dm.from_date,
		dm.to_date
INTO manager_info
FROM dept_manager AS dm
	INNER JOIN departments AS d
		ON (dm.dept_no = d.dept_no)
	INNER JOIN current_emp AS ce
		ON	(dm.emp_no = ce.emp_no);


-- List of current employees eligible for retirement
-- Retirement_info and dept_emp tables
SELECT ri.emp_no,
        ri.first_name,
        ri.last_name,
        de.to_date
INTO current_emp
FROM retirement_info AS ri
LEFT JOIN dept_employees AS de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');


-- List of department retirees info
SELECT ce.emp_no,
		ce.first_name,
		ce.last_name,
		d.dept_name
INTO dept_info
FROM current_emp AS ce
	INNER JOIN dept_employees AS de
	ON (ce.emp_no = de.emp_no)
	INNER JOIN departments AS d
	ON (de.dept_no = d.dept_no);

-- List of sales department retirees info
SELECT *
INTO sales_info
FROM dept_info AS di
WHERE di.dept_name = 'Sales';

-- List of sales and dev department retirees info
SELECT *
INTO sales_dev_info
FROM dept_info AS di
WHERE di.dept_name IN ('Sales', 'Development');
