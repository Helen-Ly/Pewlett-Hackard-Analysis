-- MODULE 7 CHALLENGE

-- Current_emp eligible for retirement with titles
SELECT ei.emp_no,
        ei.first_name,
        ei.last_name,
        t.title,
        t.from_date,
        ei.salary
INTO titles_info
FROM employees_info AS ei
    INNER JOIN titles AS t
    ON (ei.emp_no = t.emp_no);       

-- Finding duplicates
SELECT first_name,
		last_name,
		count(*)
FROM titles_info
GROUP BY first_name, last_name
HAVING count(*) > 1;

-- Display duplicate rows with all info
SELECT * FROM
	(SELECT *, count(*)
	OVER
		(PARTITION BY
			first_name,
			last_name
		) AS count
	FROM titles_info) tableWithCount
	WHERE tableWithCount.count > 1;

-- Delete unwanted duplicates and save exactly what you want into titles_info
ALTER TABLE titles_info ADD id SERIAL;

WITH titles AS
   (SELECT id, emp_no, first_name, last_name, title, from_date, salary 
    FROM
        (SELECT id, emp_no, first_name, last_name, title, from_date, salary,
            ROW_NUMBER() OVER
        (PARTITION BY (first_name, last_name) ORDER BY from_date DESC) rn
            FROM titles_info) tmp WHERE rn = 1)
        DELETE FROM titles_info WHERE titles_info.id NOT IN (SELECT id FROM titles);

-- Title count with all information with from_date DESC
SELECT * 
INTO title_count_info
FROM
	(SELECT *, count(*)
	OVER
		(PARTITION BY
			title
		) AS count
	FROM titles_info) tableWithCount
	WHERE tableWithCount.count > 1
	ORDER BY from_date DESC;

-- Title Frequency
SELECT COUNT(emp_no), title
INTO title_count
FROM title_count_info
GROUP BY title;

-- Current employees with birth_date in 1965
SELECT e.emp_no,
		e.first_name,
		e.last_name,
		t.title,
		t.from_date,
		t.to_date		
FROM employees AS e
INNER JOIN titles AS t
ON (e.emp_no = t.emp_no)
WHERE (e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (t.to_date = '9999-01-01');

-- Mentor Title Frequency
SELECT COUNT(emp_no), title
INTO mentors_count
FROM mentors_info
GROUP BY title;

-- Count mentors
SELECT COUNT(*)
FROM mentors_info;

-- Count retirees
SELECT COUNT(*)
FROM titles_info;