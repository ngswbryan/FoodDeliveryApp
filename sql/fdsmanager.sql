-- FDS Manager
--a)
 CREATE OR REPLACE FUNCTION new_customers(input_month INTEGER, input_year INTEGER)
 RETURNS INTEGER AS $$
     SELECT C.uid 
     FROM Customers C join Users U on C.uid = U.uid
     WHERE (SELECT EXTRACT(MONTH FROM U.date_joined)) = input_month
     AND (SELECT EXTRACT(YEAR FROM U.date_joined)) = input_year;
 $$ LANGUAGE SQL;

 --b)
 CREATE OR REPLACE FUNCTION total_orders(input_month INTEGER, input_year INTEGER)
 RETURNS BIGINT AS $$
     SELECT count(*) AS total_order_numbers
     FROM FoodOrder FO
     WHERE (SELECT EXTRACT(MONTH FROM FO.date_time)) = input_month
     AND (SELECT EXTRACT(YEAR FROM FO.date_time)) = input_year
 $$ LANGUAGE SQL;

 --c)
 CREATE OR REPLACE FUNCTION total_cost(input_month INTEGER, input_year INTEGER)
 RETURNS FLOAT AS $$
     SELECT SUM(FO.order_cost)::FLOAT
     FROM FoodOrder FO
     WHERE (SELECT EXTRACT(MONTH FROM FO.date_time)) = input_month
     AND (SELECT EXTRACT(YEAR FROM FO.date_time)) = input_year;
 $$ LANGUAGE SQL;

 --d) STATISTICS OF ALL CUSTOMERS
 CREATE OR REPLACE FUNCTION customers_table()
 RETURNS TABLE (
     order_month BIGINT,
     order_year BIGINT,
     order_user_uid INTEGER,
     count BIGINT,
     sum DECIMAL
 ) AS $$
     SELECT (SELECT EXTRACT(MONTH FROM FO.date_time)::BIGINT) as order_month, (SELECT EXTRACT(YEAR FROM FO.date_time)::BIGINT) as order_year, FO.uid, count(*), SUM(FO.order_cost)
     FROM FoodOrder FO join Delivery D on FO.order_id = D.order_id
     GROUP BY order_month, order_year, FO.uid;
 $$ LANGUAGE SQL;

 --e)
 CREATE OR REPLACE FUNCTION filterByMonth(input_month BIGINT, input_year BIGINT)
 RETURNS TABLE (
     order_month BIGINT,
     order_year BIGINT,
     delivery_uid INTEGER,
     count BIGINT,
     sum DECIMAL
 ) AS $$
     SELECT * 
     FROM (
         SELECT (SELECT EXTRACT(MONTH FROM FO.date_time)::BIGINT) AS order_month, (SELECT EXTRACT(YEAR FROM FO.date_time)::BIGINT) as order_year, FO.uid, count(*), SUM(FO.order_cost)
         FROM FoodOrder FO join Delivery D on FO.order_id = D.order_id
         GROUP BY order_month, order_year, FO.uid
     ) AS CTE
     WHERE CTE.order_month = input_month
     AND CTE.order_year = input_year;
 $$ LANGUAGE SQL;

 CREATE OR REPLACE FUNCTION match_to_uid(input_name VARCHAR)
 RETURNS INTEGER AS $$
     SELECT U.uid
     FROM Users U
     WHERE input_name = U.username;
 $$ LANGUAGE SQL;

--f)
 CREATE OR REPLACE FUNCTION filter_by_uid(input_name VARCHAR)
 RETURNS TABLE ( 
     order_month BIGINT,
     order_year BIGINT,
     delivery_uid INTEGER,
     count BIGINT,
     sum DECIMAL
 ) AS $$
 declare 
     uid_matched INTEGER;
 begin
     SELECT match_to_uid(input_name) INTO uid_matched;

     RETURN QUERY( SELECT * 
     FROM (
         SELECT (SELECT EXTRACT(MONTH FROM FO.date_time)::BIGINT) AS order_month, (SELECT EXTRACT(YEAR FROM FO.date_time)::BIGINT) as order_year, FO.uid as uid, count(*), SUM(FO.order_cost)
         FROM FoodOrder FO join Delivery D on FO.order_id = D.order_id
         GROUP BY order_month, order_year, FO.uid
     ) AS CTE
     WHERE CTE.uid = uid_matched);
 end
 $$ LANGUAGE PLPGSQL;

-- g) statistics of riders 
-- input parameter to filter by month
 CREATE OR REPLACE FUNCTION riders_table()
 RETURNS TABLE (
     order_month BIGINT,
     order_year BIGINT,
     rider_id INTEGER,
     count BIGINT,
     total_hours_worked NUMERIC,
     total_salary NUMERIC,
     average_delivery_time NUMERIC,
     total_number_ratings BIGINT,
     average_ratings NUMERIC
 ) AS $$
 BEGIN
 RETURN QUERY
     SELECT ( EXTRACT(MONTH FROM FO.date_time)::BIGINT) as order_month,
     ( EXTRACT(YEAR FROM FO.date_time)::BIGINT) as order_year, 
     D.rider_id as rider_id,
     count(*) as count, ROUND((SUM(D.time_for_one_delivery)), 3) as total_hours_worked,

     CASE WHEN R.rider_type THEN R.base_salary * 4 + count(*) * 6 --salary x 4 weeks + commission 6 for ft
          ELSE R.base_salary * 4 + count(*) * 3 --salary * 4 weeks + commission 3 for pt
     END as total_salary,

     ROUND((sum(D.time_for_one_delivery)/count(*)), 3) as average_delivery_time,
     count(D.delivery_rating) as total_number_ratings, 
     ROUND((sum(D.delivery_rating)::DECIMAL/count(D.delivery_rating)), 3) as average_ratings
     FROM FoodOrder FO join Delivery D on FO.order_id = D.order_id join Riders R on R.rider_id = D.rider_id
     GROUP BY order_month, D.rider_id, order_year, rider_type, R.base_salary;
  END
 $$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION filter_riders_table_by_month(input_month INTEGER, input_year INTEGER, ridertype BOOLEAN)
RETURNS TABLE (
    order_month BIGINT,
     order_year BIGINT,
     rider_id INTEGER,
     count BIGINT,
     total_hours_worked NUMERIC,
     total_salary NUMERIC,
     average_delivery_time NUMERIC,
     total_number_ratings BIGINT,
     average_ratings NUMERIC
) AS $$
SELECT * 
FROM riders_table(ridertype) as curr_table
WHERE curr_table.order_month = input_month
AND curr_table.order_year = input_year;
$$ LANGUAGE SQL;


--h) statistic of location
-- input parameter to filter by month
CREATE OR REPLACE FUNCTION location_table()
RETURNS TABLE (
    delivery_location VARCHAR,
    month INTEGER,
    year INTEGER,
    count BIGINT,
    hour VARCHAR
) AS $$
begin
    RETURN QUERY
    SELECT D.location,EXTRACT(MONTH FROM FO.date_time)::INTEGER,  EXTRACT(YEAR FROM FO.date_time)::INTEGER,
    count(*), 
    CASE WHEN EXTRACT(HOUR FROM FO.date_time) = 10 THEN '1000 - 1100'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 11 THEN '1100 - 1200'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 12 THEN '1200 - 1300'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 13 THEN '1300 - 1400'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 14 THEN '1400 - 1500'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 15 THEN '1500 - 1600'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 16 THEN '1600 - 1700'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 17 THEN '1700 - 1800'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 18 THEN '1800 - 1900'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 19 THEN '1900 - 2000'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 20 THEN '2000 - 2100'::VARCHAR
        WHEN EXTRACT(HOUR FROM FO.date_time) = 21 THEN '2100 - 2200'::VARCHAR
        ELSE '2200 - 2300'

    END AS time_interval
    FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id
    WHERE FO.completion_status = TRUE
    AND D.ongoing = FALSE
    GROUP BY D.location, FO.date_time;
end;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION filter_location_table_by_location(input_location VARCHAR)
RETURNS TABLE (
delivery_location VARCHAR,
    count BIGINT,
    hour VARCHAR
) AS $$
BEGIN
    SELECT * 
    FROM location_table() as curr_table
    WHERE curr_table.delivery_location = input_location;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION filter_location_table_by_month(input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    delivery_location VARCHAR,
    month INTEGER,
    year INTEGER,
    count BIGINT,
    hour VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT * 
    FROM location_table() as curr_table
    WHERE curr_table.month = input_month
    AND curr_table.year = input_year;
END;
$$ LANGUAGE PLPGSQL;

---- function for fds-wide delivery cost discount
CREATE OR REPLACE FUNCTION insert_delivery_discount(discount NUMERIC, description VARCHAR, start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS VOID
AS $$
BEGIN 
    INSERT INTO PromotionalCampaign VALUES(DEFAULT, null, discount, description, start_date, end_date);
END
$$ LANGUAGE PLPGSQL;

---- button to apply delivery cost discount
-- CREATE OR REPLACE FUNCTION apply_delivery_discount(discount NUMERIC, description VARCHAR, start_date TIMESTAMP, end_date TIMESTAMP)
-- RETURNS VOID
-- AS $$
-- BEGIN 
--     UPDATE 
-- END
-- $$ LANGUAGE PLPGSQL;

---- function for fds-wide food price discount
CREATE OR REPLACE FUNCTION insert_food_discount(discount NUMERIC, description VARCHAR, start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS VOID
AS $$
BEGIN 
    INSERT INTO PromotionalCampaign VALUES(DEFAULT, null, discount, description, start_date, end_date);
END
$$ LANGUAGE PLPGSQL;

----- button to apply food_discount 
CREATE OR REPLACE FUNCTION apply_food_discount(discount NUMERIC, description VARCHAR, start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS VOID
AS $$
BEGIN 
    UPDATE Sells S
    SET price = ROUND(price - (price * discount), 2);
END
$$ LANGUAGE PLPGSQL;

