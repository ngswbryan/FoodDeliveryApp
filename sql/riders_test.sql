--a)
-- SELECT get_current_job(2);

--conversion to 52 week
-- SELECT convert_to_week(2, 5);
-- SELECT convert_to_week(3, 1);

--b) working
-- SELECT get_weekly_statistics(2, 2, 4, 2020);
-- SELECT get_weekly_statistics(2, 5, 6, 2018);

--c) working
-- SELECT get_monthly_statistics(2, 6, 2018);

--d) 
-- SELECT update_departure_time(2, 1);
-- SELECT update_collected_time(2, 1);
-- SELECT update_delivery_start(2, 1);
SELECT update_done_status(2, 1);