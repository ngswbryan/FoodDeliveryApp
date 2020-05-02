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
     delivery_uid INTEGER,
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
     WHERE CTE.order_month = input_month;
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
 CREATE OR REPLACE FUNCTION riders_table(ridertype BOOLEAN)
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
     count(*) as count, SUM(D.time_for_one_delivery) as total_hours_worked,

     CASE WHEN ridertype THEN SUM(D.time_for_one_delivery) *  + count(*) * 15
          ELSE (sum(D.time_for_one_delivery) * 10 + count(*) * 10)
     END as total_salary,

     sum(D.time_for_one_delivery)/count(*) as average_delivery_time,
     count(D.delivery_rating) as total_number_ratings, 
     sum(D.delivery_rating)::DECIMAL/count(D.delivery_rating) as average_ratings
     FROM FoodOrder FO join Delivery D on FO.order_id = D.order_id join Riders R on R.rider_id = D.rider_id
     GROUP BY order_month, D.rider_id, order_year, rider_type;
  END
 $$ LANGUAGE PLPGSQL;

 --h) statistic of location
 CREATE OR REPLACE FUNCTION location_table()
 RETURNS TABLE (
     delivery_location VARCHAR,
     count BIGINT,
     hour VARCHAR
 ) AS $$
     SELECT D.location, count(*), 
     CASE WHEN EXTRACT(HOUR FROM FO.date_time) = 10 THEN '1000 - 1100'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 11 THEN '1100 - 1200'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 12 THEN '1200 - 1300'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 13 THEN '1300 - 1400'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 14 THEN '1400 - 1500'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 15 THEN '1500 - 1600'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 16 THEN '1600 - 1700'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 17 THEN '1700 - 1800'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 18 THEN '1800 - 1900'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 19 THEN '1900 - 2000'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 20 THEN '2000 - 2100'
          WHEN EXTRACT(HOUR FROM FO.date_time) = 21 THEN '2100 - 2200'
         ELSE '2200 - 2300'
     END AS time_interval
     FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id
     GROUP BY D.location, EXTRACT(HOUR FROM FO.date_time);
 $$ LANGUAGE SQL;
