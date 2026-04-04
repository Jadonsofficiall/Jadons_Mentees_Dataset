## DQL Analysis

## Verification Query
SELECT 'employees' as table_name, COUNT(*) as row_count FROM employees
UNION
SELECT 'department', COUNT(*) FROM department
UNION
SELECT 'payroll', COUNT(*) FROM payroll
UNION
SELECT 'emp_location', COUNT(*) FROM emp_location;

-- Viewing the tables
SELECT *
FROM payroll;

SELECT *
FROM employees;

SELECT *
FROM department;

SELECT *
FROM emp_location;

## The "Big Picture" Roster
-- 1. List of all employees, their roles, and their specific departments?
SELECT 
    e.emp_name, 
    e.emp_role, 
    d.department, 
    d.segment
FROM employees e
JOIN department d
ON e.emp_id = d.employee_id
ORDER BY d.department ASC;

## Salary Leaderboard
-- 2. WHo are the top 5 highest-paid employees in the company?
SELECT 
    emp_name, 
    emp_role, 
    emp_salary
FROM employees
ORDER BY emp_salary DESC
LIMIT 5;

## Departmental Headcount
-- 3. How many employees are assigned to each department?
SELECT 
    department, 
    COUNT(employee_id) AS total_staff
FROM department
GROUP BY department
ORDER BY total_staff DESC;

## Total Compensation Analysis
-- 4. What is the total "Take Home" pay (Salary + Bonus) for every employee?
SELECT 
    e.emp_name, 
    p.salary, 
    p.bonus, 
    (p.salary + p.bonus) AS total_compensation
FROM employees e
INNER JOIN payroll p
ON e.emp_id = p.emp_id
ORDER BY total_compensation DESC;

## Age Demographics (The "Veteran" Check)
-- 5. How old is each employee, and who is the oldest person on the team?
SELECT 
    emp_name, 
    emp_date_of_birth,
    TIMESTAMPDIFF(YEAR, emp_date_of_birth, CURDATE()) AS age
FROM employees
ORDER BY age DESC;

## Regional Footprint
-- 6. Which geographical locations have the highest concentration of staff?
SELECT 
    d.location, 
    COUNT(l.location_id) AS location_count
FROM department d
INNER JOIN emp_location l ON d.employee_id = l.employee_id
GROUP BY d.location
ORDER BY location_count DESC;

## Average Pay by Role
-- 7. What is the average salary for each specific role within the company?
SELECT 
    emp_role, 
    ROUND(AVG(emp_salary), 2) AS average_role_salary
FROM employees
GROUP BY emp_role
ORDER BY average_role_salary DESC;

## Bonus vs. Base Salary Ratio
-- 8. Which employees are receiving a bonus that is more than 15% of their base salary?
SELECT 
    e.emp_name, 
    p.salary, 
    p.bonus,
    (p.bonus / p.salary) * 100 AS bonus_percentage
FROM employees e
INNER JOIN payroll p
ON e.emp_id = p.emp_id
WHERE (p.bonus / p.salary) > 0.15
ORDER BY bonus_percentage DESC;
