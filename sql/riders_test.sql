--a)
-- SELECT get_current_job(2);

--b) doesnt work
-- SELECT get_weekly_salaries(2, convert_to_week(2,5), 5, 2018);

--conversion to 52 week
-- SELECT convert_to_week(2, 5);
-- SELECT convert_to_week(3, 1);

-- SELECT EXTRACT(WEEK FROM '2018-06-22 05:00:06');
SELECT (EXTRACT(MONTH FROM '2018-06-22 05:00:06')::BIGINT);
