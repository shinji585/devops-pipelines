SELECT
    hire_date,
    date_part('year', age(current_date, hire_date))::integer AS computed
FROM
    employees
ORDER BY hire_date DESC;


