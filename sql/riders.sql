-- --a)
--  -- get current job
  CREATE OR REPLACE FUNCTION get_current_job(input_rider_id INTEGER)
  RETURNS TABLE (
      order_id INTEGER,
      location VARCHAR(100),
      recipient VARCHAR(100),
      food_name VARCHAR(100),
      total_cost DECIMAL
  ) AS $$
      SELECT D.order_id, D.location, U.username, FI.food_name, D.delivery_cost + FO.order_cost
      FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id
      join Users U on FO.uid = U.uid 
      join Orders O on FO.order_id = O.order_id
      join FoodItem FI on FI.food_id = O.food_id
      WHERE input_rider_id = D.rider_id
      AND D.ongoing = TRUE;

  $$ LANGUAGE SQL;

-- --b)
-- -- get work schedule

-- -- manipulation to calculate week
 CREATE OR REPLACE FUNCTION convert_to_week(input_week INTEGER, input_month INTEGER)
 RETURNS INTEGER AS
 $$
 BEGIN
     IF input_month = 1 THEN
         RETURN input_week;
     ELSE 
         RETURN input_month*4 + input_week;
     END IF;
 END 
 $$ LANGUAGE PLPGSQL;

-- for WWS
-- --c)
-- -- get previous weekly salaries --for weekly
CREATE OR REPLACE FUNCTION get_weekly_statistics(input_rider_id INTEGER, input_week INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    week INTEGER,
    month INTEGER,
    year INTEGER,
    base_salary DECIMAL, --weekly
    total_commission BIGINT,
    total_num_orders BIGINT,
    total_num_hours_worked BIGINT
) AS $$
declare 
    salary_base DECIMAL;
    initial_commission BIGINT;
begin
    SELECT R.base_salary
    FROM Riders R
    WHERE R.rider_id = input_rider_id
    INTO salary_base;

    SELECT R.commission
    FROM Riders R
    WHERE R.rider_id = input_rider_id
    INTO initial_commission;

    RETURN QUERY(
        SELECT input_week, input_month, input_year, salary_base, (count(D.delivery_end_time) * initial_commission), count(*), SUM(end_hour - start_hour)
        FROM Riders R join Delivery D on D.rider_id = R.rider_id
        join WeeklyWorkSchedule WWS on WWS.rider_id = D.rider_id
        WHERE input_rider_id = D.rider_id
        AND (SELECT EXTRACT('day' from date_trunc('week', D.delivery_end_time) - date_trunc('week', date_trunc('month',  D.delivery_end_time))) / 7 + 1 ) = input_week --take in user do manipulation
        AND (SELECT EXTRACT(MONTH FROM D.delivery_end_time)) = input_month
        AND (SELECT EXTRACT(YEAR FROM D.delivery_end_time)) = input_year
        AND D.ongoing = False
    );
end
$$ LANGUAGE PLPGSQL;

-- -- --d)
-- -- -- get previous monthly salaries  --for month
CREATE OR REPLACE FUNCTION get_monthly_statistics(input_rider_id INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    month INTEGER,
    year INTEGER,
    base_salary DECIMAL, --weekly
    total_commission BIGINT,
    total_num_orders BIGINT,
    total_num_hours_worked BIGINT
) AS $$
    SELECT input_month, input_year, R.base_salary * 4, count(delivery_id) * R.commission, count(*), SUM(end_hour - start_hour)
    FROM Riders R join MonthlyWorkSchedule MWS on R.rider_id = MWS.rider_id
    join Delivery D on D.rider_id = MWS.rider_id
    join WeeklyWorkSchedule WWS on WWS.rider_id = MWS.rider_id
    WHERE input_rider_id = D.rider_id
    AND (SELECT EXTRACT(MONTH FROM D.delivery_end_time)) = input_month
    AND (SELECT EXTRACT(YEAR FROM D.delivery_end_time)) = input_year
    AND D.ongoing = False
    GROUP BY R.rider_id;
$$ LANGUAGE SQL;



--e)
-- Allow Part Time riders to see their weekly work schedule
CREATE OR REPLACE FUNCTION get_WWS(input_rider_id INTEGER, input_week INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    day INTEGER,
    week INTEGER,
    month INTEGER,
    year INTEGER,
    starthour INTEGER,
    endhour INTEGER
) AS $$
    SELECT day, week, month, year, start_hour, end_hour
    FROM WeeklyWorkSchedule WWS
    WHERE WWS.rider_id = input_rider_id
    AND WWS.week = input_week
    AND WWS.month = input_month
    AND WWS.year = input_year;
$$ LANGUAGE SQL;
 
 --f)
 -- Allow FULL TIME RIDERS to see their monthly work schedule
CREATE OR REPLACE FUNCTION get_MWS(input_rider_id INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    day INTEGER,
    week INTEGER,
    month INTEGER,
    year INTEGER,
    starthour INTEGER,
    endhour INTEGER
) AS $$
    SELECT day, week, month, year, start_hour, end_hour
    FROM WeeklyWorkSchedule WWS
    WHERE WWS.rider_id = input_rider_id
    AND WWS.month = input_month
    AND WWS.year = input_year;
$$ LANGUAGE SQL;



  --g)
  --Update WWS and MWS for full timer
 --Shift 1: 10am to 2pm and 3pm to 7pm.
 --Shift 2: 11am to 3pm and 4pm to 8pm.
 --Shift 3: 12pm to 4pm and 5pm to 9pm.
 --Shift 4: 1pm to 5pm and 6pm to 10pm.
  CREATE OR REPLACE FUNCTION update_fulltime_WWS(riderid INTEGER, WWSyear INTEGER, WWSmonth INTEGER, workingdays INTEGER, day1shift INTEGER, day2shift INTEGER, day3shift INTEGER, day4shift INTEGER, day5shift INTEGER)
  RETURNS VOID AS $$
  DECLARE
    day1 INTEGER;
    day2 INTEGER;
    day3 INTEGER;
    day4 INTEGER;
    day5 INTEGER;
  BEGIN
    IF (workingdays = 1) THEN
      day1 = 1;
      day2 = 2;
      day3 = 3;
      day4 = 4;
      day5 = 5;
    ELSIF (workingdays = 2) THEN
      day1 = 2;
      day2 = 3;
      day3 = 4;
      day4 = 5;
      day5 = 6;
    ELSIF (workingdays = 3) THEN
      day1 = 3;
      day2 = 4;
      day3 = 5;
      day4 = 6;
      day5 = 7;
    ELSIF (workingdays = 4) THEN
      day1 = 4;
      day2 = 5;
      day3 = 6;
      day4 = 7;
      day5 = 1;
    ELSIF (workingdays = 5) THEN
      day1 = 5;
      day2 = 6;
      day3 = 7;
      day4 = 1;
      day5 = 2;
    ELSIF (workingdays = 6) THEN
      day1 = 6;
      day2 = 7;
      day3 = 1;
      day4 = 2;
      day5 = 3;
    ELSE
      day1 = 7;
      day2 = 1;
      day3 = 2;
      day4 = 3;
      day5 = 4;
    END IF;
    IF (day1shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day1, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day1, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day1, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day1, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day1, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day1, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day1, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day1, 4, WWSmonth, WWSyear, 1);
    ELSIF (day1shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day1, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day1, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day1, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day1, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day1, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day1, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day1, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day1, 4, WWSmonth, WWSyear, 2);
    ELSIF (day1shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day1, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day1, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day1, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day1, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day1, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day1, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day1, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day1, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day1, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day1, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day1, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day1, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day1, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day1, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day1, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day1, 4, WWSmonth, WWSyear, 4);
    END IF;
    IF (day2shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day2, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day2, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day2, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day2, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day2, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day2, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day2, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day2, 4, WWSmonth, WWSyear, 1);
    ELSIF (day2shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day2, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day2, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day2, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day2, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day2, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day2, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day2, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day2, 4, WWSmonth, WWSyear, 2);
    ELSIF (day2shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day2, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day2, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day2, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day2, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day2, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day2, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day2, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day2, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day2, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day2, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day2, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day2, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day2, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day2, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day2, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day2, 4, WWSmonth, WWSyear, 4);
    END IF;
    IF (day3shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day3, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day3, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day3, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day3, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day3, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day3, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day3, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day3, 4, WWSmonth, WWSyear, 1);
    ELSIF (day3shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day3, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day3, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day3, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day3, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day3, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day3, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day3, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day3, 4, WWSmonth, WWSyear, 2);
    ELSIF (day3shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day3, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day3, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day3, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day3, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day3, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day3, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day3, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day3, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day3, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day3, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day3, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day3, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day3, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day3, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day3, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day3, 4, WWSmonth, WWSyear, 4);
    END IF;
        IF (day4shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day4, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day4, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day4, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day4, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day4, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day4, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day4, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day4, 4, WWSmonth, WWSyear, 1);
    ELSIF (day4shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day4, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day4, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day4, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day4, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day4, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day4, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day4, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day4, 4, WWSmonth, WWSyear, 2);
    ELSIF (day4shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day4, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day4, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day4, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day4, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day4, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day4, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day4, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day4, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day4, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day4, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day4, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day4, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day4, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day4, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day4, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day4, 4, WWSmonth, WWSyear, 4);
    END IF;
        IF (day5shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day5, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day5, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day5, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day5, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day5, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day5, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day5, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day5, 4, WWSmonth, WWSyear, 1);
    ELSIF (day5shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day5, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day5, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day5, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day5, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day5, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day5, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day5, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day5, 4, WWSmonth, WWSyear, 2);
    ELSIF (day5shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day5, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day5, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day5, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day5, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day5, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day5, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day5, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day5, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day5, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day5, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day5, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day5, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day5, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day5, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day5, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day5, 4, WWSmonth, WWSyear, 4);
    END IF;

  END
  $$ LANGUAGE PLPGSQL;






-- -- for WWS
CREATE OR REPLACE FUNCTION checkWWS()
  RETURNS trigger AS $$
DECLARE
   insufficientbreak integer;
BEGIN
   IF (NEW.start_hour > 22 OR NEW.start_hour < 10) OR (NEW.end_hour > 22 AND NEW.end_hour < 10) THEN
       RAISE EXCEPTION 'Time interval has to be between 1000 - 2200';
   END IF;
   IF (NEW.start_hour > NEW.end_hour) THEN
       RAISE EXCEPTION 'Start time cannot be later than end time';
   END IF;
   IF (NEW.end_hour - NEW.start_hour > 4) THEN
       RAISE EXCEPTION 'Time Interval cannot exceed 4 hours';
   END IF;
   SELECT 1 INTO insufficientbreak
   FROM WeeklyWorkSchedule WWS
   WHERE NEW.rider_id = WWS.rider_id AND NEW.day = WWS.day AND NEW.week = WWS.week AND NEW.month = WWS.month  AND NEW.year = WWS.year AND (WWS.end_hour > NEW.start_hour - 1 AND NEW.end_hour + 1 > WWS.start_hour); --at least 1 hour of break between consecutive hour interval
   IF (insufficientbreak = 1) THEN
       RAISE EXCEPTION 'There must be at least one hour break between consective hour intervals';
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION checktotalhourwws()
  RETURNS trigger as $$
DECLARE
  totalhours integer;
BEGIN
   SELECT SUM(WWS.end_hour - WWS.start_hour) INTO totalhours
   FROM WeeklyWorkSchedule WWS
   WHERE WWS.week = NEW.week AND NEW.rider_id = WWS.rider_id  AND NEW.month = WWS.month  AND NEW.year = WWS.year
   GROUP BY WWS.week;
   IF (totalhours < 10 OR totalhours > 48) THEN
       RAISE EXCEPTION 'The total number of hours in each WWS must be at least 10 and at most 48.';
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

 DROP TRIGGER IF EXISTS update_wws_trigger ON WeeklyWorkSchedule CASCADE;
 CREATE TRIGGER update_wws_trigger
  BEFORE UPDATE OR INSERT
  ON WeeklyWorkSchedule
  FOR EACH ROW
  EXECUTE FUNCTION checkWWS();

  DROP TRIGGER IF EXISTS check_wws_hours_trigger ON WeeklyWorkSchedule CASCADE;
  CREATE CONSTRAINT TRIGGER check_wws_hours_trigger
  AFTER UPDATE OR INSERT OR DELETE
  ON WeeklyWorkSchedule
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION checktotalhourwws();




-- to determine which is the delivery that needs to be found now

-------------- rider delivery process ----------------
-- departing to pick food button
CREATE OR REPLACE FUNCTION update_departure_time(input_rider_id INTEGER, input_delivery_id INTEGER)
RETURNS VOID AS $$
    UPDATE Delivery D SET departure_time = CURRENT_TIMESTAMP, ongoing = TRUE
    WHERE D.rider_id = input_rider_id
    AND D.delivery_id = input_delivery_id;
$$ LANGUAGE SQL;

-- reached restaurant button
CREATE OR REPLACE FUNCTION update_collected_time(input_rider_id INTEGER, input_delivery_id INTEGER)
RETURNS VOID AS $$
    UPDATE Delivery D SET collected_time = CURRENT_TIMESTAMP
    WHERE D.rider_id = input_rider_id
    AND D.delivery_id = input_delivery_id;
$$ LANGUAGE SQL;

-- delivery start-time button
CREATE OR REPLACE FUNCTION update_delivery_start(input_rider_id INTEGER, input_delivery_id INTEGER)
RETURNS VOID AS $$
    UPDATE Delivery D SET delivery_start_time = CURRENT_TIMESTAMP
    WHERE D.rider_id = input_rider_id
    AND D.delivery_id = input_delivery_id;
$$ LANGUAGE SQL;

 --when rider clicks completed button
 --foodorder status change to done
  --change ongoing to false in Delivery
  CREATE OR REPLACE FUNCTION update_done_status(input_rider_id INTEGER, input_delivery_id INTEGER)
  RETURNS VOID AS $$
  BEGIN 
      UPDATE FoodOrder
      SET completion_status = TRUE
      WHERE order_id = ( SELECT D.order_id FROM Delivery D WHERE D.delivery_id = input_delivery_id AND D.rider_id = input_rider_id);
 
      UPDATE Delivery
      SET ongoing = FALSE,
          delivery_end_time = CURRENT_TIMESTAMP,
          time_for_one_delivery = (SELECT EXTRACT(EPOCH FROM (current_timestamp - D.delivery_start_time)) FROM Delivery D WHERE D.delivery_id = input_delivery_id)/60::DECIMAL
      WHERE delivery_id = input_delivery_id
      AND rider_id = input_rider_id;
  END
  $$ LANGUAGE PLPGSQL;

-------------- rider delivery process ----------------

