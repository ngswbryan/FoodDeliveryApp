--a)
-- SELECT get_current_job(2);

--conversion to 52 week
-- SELECT convert_to_week(2, 5);
-- SELECT convert_to_week(3, 1);

--b) working
-- SELECT get_weekly_statistics(2, 2, 4, 2020);
-- SELECT get_weekly_statistics(2, 5, 6, 2018);

 --f)
  --Update WWS and MWS for full timer
 --Shift 1: 10am to 2pm and 3pm to 7pm.
 --Shift 2: 11am to 3pm and 4pm to 8pm.
 --Shift 3: 12pm to 4pm and 5pm to 9pm.
 --Shift 4: 1pm to 5pm and 6pm to 10pm.
--SELECT update_fulltime_WWS(2, 2020, 7, 1, 1, 2, 3, 4, 1);
--c) working
-- SELECT get_monthly_statistics(2, 6, 2018);

--d) 
-- SELECT update_departure_time(2, 1);
-- SELECT update_collected_time(2, 1);
-- SELECT update_delivery_start(2, 1);
SELECT update_done_status(2, 1);
