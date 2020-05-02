--a)
 -- get current job
--  CREATE OR REPLACE FUNCTION get_current_job(input_rider_id INTEGER)
--  RETURNS TABLE (
--      order_id INTEGER,
--      location VARCHAR(100),
--      recipient VARCHAR(100),
--      food_name VARCHAR(100),
--      total_cost DECIMAL
--  ) AS $$
--      SELECT D.order_id, D.location, U.username, FI.food_name, D.delivery_cost + FO.order_cost
--      FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id
--      join Users U on FO.uid = U.uid 
--      join Orders O on FO.order_id = O.order_id
--      join FoodItem FI on FI.food_id = O.food_id
--      WHERE input_rider_id = D.rider_id
--      AND D.ongoing = TRUE;

--  $$ LANGUAGE SQL;

--b)
-- get work schedule

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
        SELECT input_week, input_month, input_year, salary_base, (count(D.delivery_end_time) * initial_commission)
        FROM Riders R join Delivery D on D.rider_id = R.rider_id
        WHERE input_rider_id = D.rider_id
        AND (SELECT EXTRACT('day' from date_trunc('week', D.delivery_end_time) - date_trunc('week', date_trunc('month',  D.delivery_end_time))) / 7 + 1 ) = input_week --take in user do manipulation
        AND (SELECT EXTRACT(MONTH FROM D.delivery_end_time)) = input_month
        AND (SELECT EXTRACT(YEAR FROM D.delivery_end_time)) = input_year
    );
end
$$ LANGUAGE PLPGSQL;

-- --d)
-- -- get previous monthly salaries DOESNT WORK 
CREATE OR REPLACE FUNCTION get_monthly_salaries(input_rider_id INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    month INTEGER,
    year INTEGER,
    base_salary DECIMAL,
    total_commission BIGINT
) AS $$
    SELECT input_month, input_year, R.base_salary, count(delivery_id) * R.commission
    FROM Riders R join MonthlyWorkSchedule MWS on R.rider_id = MWS.rider_id
    join Delivery D on D.rider_id = MWS.rider_id
    WHERE input_rider_id = D.rider_id
    AND (SELECT EXTRACT(MONTH FROM D.delivery_end_time)) = input_month
    AND (SELECT EXTRACT(YEAR FROM D.delivery_end_time)) = input_year
    AND D.ongoing = False
    GROUP BY R.rider_id;
$$ LANGUAGE SQL;


 --e)
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







-- for WWS
CREATE OR REPLACE FUNCTION checkWWS()
  RETURNS trigger AS $$
DECLARE
   insufficientbreak integer;
BEGIN
   IF (NEW.start_hour > 22 OR NEW.start_hour < 10) OR (NEW.end_hour > 22 AND NEW.end_hour < 10) THEN
       RAISE EXCEPTION 'Time interval has to be between 1000 - 2200';
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

