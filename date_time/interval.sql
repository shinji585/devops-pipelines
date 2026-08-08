SELECT
    max(hire_date),
    max(hire_date) + INTERVAL '1 days' as days,
    max(hire_date) + INTERVAL '1 month' as months,
    max(hire_date) + INTERVAL '1 years' as years,
    max(hire_date) + INTERVAL '1 years' + INTERVAL '1 days' as year_plus_one_day
FROM employees;