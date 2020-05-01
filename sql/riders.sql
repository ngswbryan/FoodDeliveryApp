--a)
-- -- get current job
-- CREATE OR REPLACE FUNCTION get_current_job(input_rider_id INTEGER)
-- RETURNS TABLE (
--     order_id INTEGER,
--     location VARCHAR(100),
--     recipient VARCHAR(100),
--     food_name VARCHAR(100),
--     total_cost DECIMAL
-- ) AS $$
--     SELECT D.order_id, D.location, U.username, FI.food_name, D.delivery_cost + FO.order_cost
--     FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id
--     join Users U on FO.uid = U.uid 
--     join Orders O on FO.order_id = O.order_id
--     join FoodItem FI on FI.food_id = O.food_id
--     WHERE input_rider_id = D.rider_id
--     AND D.ongoing = TRUE;

-- $$ LANGUAGE SQL;

--b)
-- get work schedule

--c)
-- get previous weekly salaries
CREATE OR REPLACE FUNCTION get_weekly_salaries(input_rider_id INTEGER, input_week INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    week INTEGER,
    month INTEGER,
    year INTEGER,
    base_salary DECIMAL,
    total_commission BIGINT
) AS $$
    SELECT input_week, input_month, input_year, R.base_salary, (count(delivery_id) * R.commission)
    FROM Riders R join WeeklyWorkSchedule WWS on R.rider_id = WWS.rider_id
    join Delivery D on D.rider_id = WWS.rider_id
    WHERE input_rider_id = WWS.rider_id
    AND (SELECT EXTRACT(WEEK FROM D.delivery_end_time)) = input_week --take in user do manipulation
    AND (SELECT EXTRACT(MONTH FROM D.delivery_end_time)) = input_month
    AND (SELECT EXTRACT(YEAR FROM D.delivery_end_time)) = input_year
    GROUP BY WWS.rider_id, R.rider_id;
$$ LANGUAGE SQL;

-- manipulation to calculate week
-- CREATE OR REPLACE FUNCTION convert_to_week(input_week INTEGER, input_month INTEGER)
-- RETURNS INTEGER AS
-- $$
-- BEGIN
--     IF input_month = 1 THEN
--         RETURN input_week;
--     ELSE 
--         RETURN input_month*4 + input_week;
--     END IF;
-- END 
-- $$ LANGUAGE PLPGSQL;

-- --d)
-- -- get previous monthly salaries DOESNT WORK 
-- CREATE OR REPLACE FUNCTION get_monthly_salaries(input_rider_id INTEGER, input_month INTEGER, input_year INTEGER)
-- RETURNS TABLE (
--     month INTEGER,
--     year INTEGER,
--     base_salary DECIMAL,
--     total_commission BIGINT
-- ) AS $$
--     SELECT MWS.month, MWS.year, R.base_salary, count(delivery_id) * R.commission
--     FROM Riders R join MonthlyWorkSchedule MWS on R.rider_id = MWS.rider_id
--     join Delivery D on D.rider_id = MWS.rider_id
--     WHERE input_rider_id = MWS.rider_id
--     AND MWS.month = input_month
--     AND MWS.year = input_year
--     AND (SELECT EXTRACT(MONTH FROM D.delivery_end_time)) = input_month
--     AND (SELECT EXTRACT(YEAR FROM D.delivery_end_time)) = input_year
--     GROUP BY MWS.rider_id, MWS.month, MWS.year, R.base_salary, R.commission;
-- $$ LANGUAGE SQL;


 --E)
 --when rider clicks completed
 --foodorder status change to done
  --change ongoing to false in Delivery
--  CREATE OR REPLACE FUNCTION update_done_status(deliveryid INTEGER)
--  RETURNS VOID AS $$
--  BEGIN 
--      UPDATE FoodOrder
--      SET completion_status = TRUE
--      WHERE order_id = ( SELECT D.order_id FROM Delivery D WHERE D.delivery_id = deliveryid);
 
--      UPDATE Delivery
--      SET ongoing = FALSE,
--          delivery_end_time = current_timestamp,
--          time_for_one_delivery = (SELECT EXTRACT(EPOCH FROM (current_timestamp - D.delivery_start_time)) FROM Delivery D WHERE D.delivery_id = deliveryid)/60::DECIMAL
--      WHERE delivery_id = deliveryid;
--  END
--  $$ LANGUAGE PLPGSQL;