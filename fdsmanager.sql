--- FDS Manager

--a)
CREATE OR REPLACE FUNCTION new_customers(input_month INTEGER)
RETURNS INTEGER AS $$
    SELECT uid 
    FROM Customers C join Users U on C.uid = U.uid
    WHERE EXTRACT(MONTH FROM U.date_joined) = "month input by user";
$$ LANGUAGE SQL;

--b)
CREATE OR REPLACE FUNCTION total_orders(input_month INTEGER)
RETURNS INTEGER AS $$
    SELECT count(*)
    FROM FoodOrder FO
    WHERE EXTRACT(MONTH FROM FO.order_date) = "user input";
$$ LANGUAGE SQL;

--c)
CREATE OR REPLACE FUNCTION total_cost(input_month INTEGER)
RETURNS INTEGER AS $$
    SELECT SUM(FO.total_cost)
    FROM FoodOrder FO
    WHERE EXTRACT(MONTH FROM FO.order_date) = "user input";
$$ LANGUAGE SQL;

--d) STATISTICS OF ALL CUSTOMERS
CREATE OR REPLACE FUNCTION customers_table
RETURNS TABLE AS $$
    SELECT EXTRACT(MONTH FROM FO.order_date), D.uid, count(*), SUM(FO.total_cost)
    FROM FoodOrder FO join Delivery D on FO.uid = D.uid
    GROUP BY EXTRACT(MONTH FROM FO.order_date), FO.uid;
$$ LANGUAGE SQL

--e)
CREATE OR REPLACE FUNCTION filterByMonth(input_month INTEGER)
RETURNS TABLE AS $$
    SELECT * 
    FROM (
        SELECT EXTRACT(MONTH FROM FO.order_date) AS order_month, D.uid, count(*), SUM(FO.total_cost)
        FROM FoodOrder FO join Delivery D on FO.uid = D.uid
        GROUP BY EXTRACT(MONTH FROM FO.order_date), FO.uid
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
RETURNS TABLE AS $$
declare 
    uid_matched INTEGER;
begin
    SELECT match_to_uid(input_name) INTO uid_matched;

    SELECT * 
    FROM (
        SELECT EXTRACT(MONTH FROM FO.order_date) AS order_month, D.uid, count(*), SUM(FO.total_cost)
        FROM FoodOrder FO join Delivery D on FO.uid = D.uid
        GROUP BY order_month, FO.uid
    ) AS CTE
    WHERE CTE.uid = uid_matched;
end
$$ LANGUAGE PLPGSQL;

--g) statistics of riders 
CREATE OR REPLACE FUNCTION riders_table(rider_type BOOLEAN)
RETURNS TABLE AS $$
    SELECT EXTRACT(MONTH FROM FO.order_date) AS order_month, D.rider_id, count(*), SUM(D.time_for_one_delivery) as total_hours_worked, 
    (CASE WHEN rider_type THEN (SUM(D.time_for_one_delivery) *  + count(*) * 15) --FT
         ELSE (SUM(D.time_for_one_delivery) * 10 + count(*) * 10)) as total_salary_earned, (total_hours_worked/count(*)) as average_delivery_time,
    count(D.delivery_rating) as total_number_ratings, (sum(D.delivery_rating)/total_number_ratings) as average_ratings
    FROM FoodOrder FO join Delivery D on FO.rider_id = D.rider_id join Riders R on R.rider_id = D.rider_id
    GROUP BY order_month, FO.rider_id
$$ LANGUAGE SQL 

--h) statistic of location
CREATE OR REPLACE FUNCTION location_table
RETURNS TABLE AS $$
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

--- FDS Manager

CREATE OR REPLACE FUNCTION addUser(username VARCHAR, password VARCHAR, name VARCHAR, access_right RIGHTS)
RETURNS INTEGER AS $$
    INSERT INTO Users
    VALUES (DEFAULT, username, password, name, NOW(), access_right)
    RETURNING id;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION addFdsManager(username VARCHAR, password VARCHAR, name VARCHAR)
RETURNS void AS $$
declare 
    userId integer;
begin
    select addUser(username, password, name, 'FDS_Manager') into userId;

    INSERT INTO FDS_Managers
    VALUES (DEFAULT, userId);
end
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION getRestaurants() 
RETURNS TABLE(name VARCHAR, info text, category VARCHAR) AS $$
    SELECT name, info, category
    FROM Restaurants
    ORDER BY name asc;
$$ LANGUAGE SQL;