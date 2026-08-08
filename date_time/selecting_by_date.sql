SELECT *
FROM employees
WHERE hire_date > DATE('1998-02-05')
ORDER BY hire_date ASC;


SELECT max(hire_date) as last_employee, min(hire_date) as first_empleyee
from employees;

SELECT *
FROM employees
WHERE hire_date BETWEEN DATE('1995-02-05') AND DATE('2000-02-05')
ORDER BY hire_date ASC;