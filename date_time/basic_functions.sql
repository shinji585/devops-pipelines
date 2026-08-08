SELECT 
    now(),
    CURRENT_DATE as current_date,
    CURRENT_TIME as current_time,
    date_part('hours', now()) as hours,
    date_part('minutes', now()) as minutes,
    date_part('seconds', now()) as seconds,
    date_part('days', now()) as days,
    date_part('months', now()) as months,
    date_part('years', now()) as years;