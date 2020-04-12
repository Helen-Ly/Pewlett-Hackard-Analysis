# Pewlett Hackard Analysis

## Project Overview

As an HR analyst at Pewlett Hackard, you are tasked with a challenge to use advanced queries and joins to create a list of candidates for a mentorship program.

1. Create a query that returns a list of current employees eligible for retirement with their most recent titles.
    - Partition the data so that each employee is only included on the list once
2. Create a query that returns the potential mentor's information.

Before starting any project, we should keep the following in mind:

> ***"If you fail to plan, you are planning to fail!"* - Benjamin Franklin**

As per our dear friend Benjamin, we created an entity relationship diagram (ERD) to show the properties of each table and the relations they have with each other.

![](https://github.com/Helen-Ly/Pewlett-Hackard-Analysis/blob/master/EmployeesDB.png)

As shown in the ERD, we are able to display the primary keys of each table and link the connections between each table. This will help us map out the information we need in order to query the requested list.

### Part 1

In the first part of this project, we would like to understand how many of the employees are eligible to retire. To plan for the future, we want to look at the number of titles retiring.

We used an *INNER JOIN* to compile the required information into a new table. This new table consists of current employees who are eligible for retirement and displayed the following.

1. Employee number
2. First and last name
3. Title
4. From date
5. Salary

**The Code:**
```
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
```
**The Output (top 5 rows):**

|emp_no (INT)|first__name (VARCHAR)|last_name (VARCHAR)|title (VARCHAR)|from_date (DATE)|salary (INT)|
|------------|---------------------|-------------------|---------------|----------------|------------|
|10001|Georgi|Facello|Senior Engineer|1986-06-26|60117|
|10004|Chirstian|Koblick|Engineer|1986-12-01|40054|
|10004|Chirstian|Koblick|Senior Engineer|1995-12-01|40054|
|10009|Sumant|Peac|Assistant Engineer|1985-02-18|60929|
|10009|Sumant|Peac|Engineer|1990-02-18|60929|

After the list was compiled, we noticed that there were duplicate employees with different titles. This shows that there were internal promotions within the company. However, we would like to create a list that is most accurate with the number of employees in their current title that are eligible for retirement.

To exclude the duplicate names, we added an *id* column, partitioned the duplicates and selected the title with the most current start date. We were able to choose the most current date by ordering the data by the title's *from_date* in a descending order, selecting the top row, and saving the data to a temporary table. With the addition of the *id* column, we deleted the rows from the original table where the ids were not in the temporary table.

**The Code:**
```
ALTER TABLE titles_info ADD id SERIAL;

WITH titles AS
   (SELECT id, emp_no, first_name, last_name, title, from_date, salary 
    FROM
        (SELECT id, emp_no, first_name, last_name, title, from_date, salary,
            ROW_NUMBER() OVER
        (PARTITION BY (first_name, last_name) ORDER BY from_date DESC) rn
            FROM titles_info) tmp WHERE rn = 1)
        DELETE FROM titles_info WHERE titles_info.id NOT IN (SELECT id FROM titles);
```
**The Output (top 5 rows):**

|emp_no (INT)|first__name (VARCHAR)|last_name (VARCHAR)|title (VARCHAR)|from_date (DATE)|salary (INT)|id (INT)|
|------------|---------------------|-------------------|---------------|----------------|------------|--------|
|10001|Georgi|Facello|Senior Engineer|6-26-1986|60117|1|
|10004|Chirstian|Koblick|Senior Engineer|12-1-1995|40054|3|
|10009|Sumant|Peac|Senior Engineer|2-18-1995|60929|6|
|10018|Kazuhide|Peha|Senior Engineer|4-3-1995|55881|8|
|10035|Alain|Chappelet|Senior Engineer|9-5-1996|41538|10|

 We then grouped the data by titles and counted how many employees shared the same title.

**The Code:**
```
SELECT COUNT(emp_no), title
INTO title_count
FROM title_count_info
GROUP BY title;
```
**The Output:**

|count (BIGINT)|title (VARCHAR)|
|--------------|---------------|
|2696|Engineer|
|13538|Senior Engineer|
|2|Manager|
|251|Assistant Engineer|
|2012|Staff|
|12771|Senior Staff|
|1589|Technique Leader|

In the table above, we are able to get a clear picture of how many current employees are eligible for retirement that share the same title. This will give Pewlett Hackard a future projection of how many employees they will need to fill those roles.

### Part 2

Now that we are able to identify how many current employees are eligible for reitrement and how many share the same title, we want to query a list of candidates for the mentoring program. This table will present experienced and successful candidates who can mentor the newly hired employees.

**The Code:**
```
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
```
**The Output (top 5 rows):**

|emp_no (INT)|first__name (VARCHAR)|last_name (VARCHAR)|title (VARCHAR)|from_date (DATE)|to_date (DATE)|
|------------|---------------------|-------------------|---------------|----------------|--------------|
|10095|Hilari|Morton|Senior Staff|3-9-2000|1-1-9999|
|10291|Dipayan|Seghrouchni|Senior Staff|3-30-1994|1-1-9999|
|10476|Kokou|Iisaka|Senior Staff|9-20-1994|1-1-9999|
|13499|Kazuhiko|Sidou|Technique Leader|9-1-1991|1-1-9999|
|14104|Sudhanshu|Demian|Senior Staff|7-23-1999|1-1-9999|

As you can see with the code, there were 3 conditions an employee had to meet. Following a similar format to compile the list, the candidates were born in 1965, hired between 1985-1988 and are currently employed at Pewlett Hackard. The output shows all the qualified employees for the mentorship program who are currently still working at Pewlett Hackard with their current title.

We took one step further and wanted to see how many of these employees shared the same title.

**The Code:**
```
SELECT COUNT(emp_no), title
INTO mentors_count
FROM mentors_info
GROUP BY title;
```
**The Output:**

|count (BIGINT)|title (VARCHAR)|
|--------------|---------------|
|6|Assistant Engineer|
|40|Staff|
|283|Senior Staff|
|31|Technique Leader|
|52|Engineer|
|279|Senior Engineer|

With this table, we will be able to compare how many potential mentors are able to mentor the newly hired employees with the same title.

## Summary

After running the queries, the project shows the following:

1. A total of 32,859 current employees are eligible for retirement.
2. As a result, Pewlett Hackard will need to hire roughly 32,859 new employees to replace the ones retiring.
3. In hopes to pitch the mentorship program, there are 691 current employees eligible to be a mentor.

## Recommendations

Looking at the result of our analysis, we were able to scratch the surface. However, knowing how many employees are able to retire, how many we need to hire, and how many current employees are eligible to be a mentor poses new questions for further analysis.

1. Will there be a transition period placed to train the new employees as the current employees eligible for retirement start to retire?
2. Considering that the overall number of employees eligible for retirement is around 48% more than the ones eligible to mentor, will Pewlett Hackard explore internal promotions to reduce the amount of newly hired employees needed to be mentored?
3. If we break down the numbers per title, the ratio between mentors and newly hired employees is significantly lower for the mentors. How will Pewlett Hackard overcome this?
4. Another issue we see is who will mentor the new managers as there are no managers eligible for the mentorship program? 
4. If the mentorship program is approved, how many of the mentor candidates be willing to be a part of the program? Will the mentors work part-time? If so, how will they train all the newly hired employees on part-time hours? How will their salaries and the benefits provided to them change?

## Usage

**Note**: To use these codes, you should already have PostgreSQL and pgAdmin downloaded on your computer.

1. Download the 6 CSV files depicted in the ERD.
2. Go on https://www.quickdatabasediagrams.com/ and click *Try the app*.
3. Map out the tables, their data types, the primary keys and the foreign keys that link the tables together.

    - **Note**: The PNG we have provided in this project shows a method that works to map out the connections. However, it is best practice to only have **one primary key per table**.
    - To do this, it is best practice to have *ID* columns to link the tables.
    - Please refer to https://www.postgresqltutorial.com/postgresql-sample-database/ for an example.
    
4. Open pgAdmin and create your tables. Once created for each table, import the CSV file to its corresponding table.
5. Now that you have your data imported, you can create your queries.
6. A few key things to keep in mind:

    - If you have written new code, pgAdmin will not let you excute just the new code by pressing the PLAY symbol or F5. To run the newly written code, highlight the code you want to run and then press the PLAY symbol or press F5.
    - You can only run your *'CREATE TABLE'* code once. If you made a mistake, you will need to *'DROP TABLE'*, fix the mistake and recreate the table.
    - The same thing happens when you run a *'SELECT'* query that puts the data into a new table using *'INTO'*. If you run into this, comment out your *'INTO'* line with '--' in front of it, or press the following for that line (CTRL + /).
