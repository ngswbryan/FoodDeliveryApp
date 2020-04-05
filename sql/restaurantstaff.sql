-- match staff_id to restaurant
CREATE OR REPLACE FUNCTION match_staff_to_rid(input_username VARCHAR)
RETURNS INTEGER AS $$
    SELECT DISTINCT RS.rid
    FROM RestaurantStaff RS join Users U on U.uid = RS.uid
    WHERE input_username = U.username;
 $$ LANGUAGE SQL; 
 
-- a) see menu items that belong to me
CREATE OR REPLACE FUNCTION bring_menu_up(staff_username VARCHAR)
RETURNS TABLE(
    food_item INTEGER,
    count INTEGER,
    cuisine_type VARCHAR,
    food_name VARCHAR
) AS $$
declare 
    uid_matched INTEGER;
begin 
    SELECT match_staff_to_rid(staff_username) INTO uid_matched;

    RETURN QUERY(
    SELECT FI.food_id, FI.quantity, FI.cuisine_type, FI.food_name
    FROM FoodItem FI
    WHERE uid_matched = FI.rid
    );
end
$$ LANGUAGE PLPGSQL;

--b) update menu items that belong -> can change count of food items, cuisine_type, food_name
CREATE OR REPLACE FUNCTION update_menu(staff_username VARCHAR, food_id INTEGER, count INTEGER, cuisine_type INTEGER, food_name VARCHAR)
RETURNS VOID AS $$
declare 
    uid_matched INTEGER;
begin 
    UPDATE 
$$ LANGUAGE PLPGSQL;

--a)
-- CREATE OR REPLACE FUNCTION new_customers(input_month INTEGER, input_year INTEGER)
-- RETURNS INTEGER AS $$
--     SELECT C.uid 
--     FROM Customers C join Users U on C.uid = U.uid
--     WHERE (SELECT EXTRACT(MONTH FROM U.date_joined)) = input_month
--     AND (SELECT EXTRACT(YEAR FROM U.date_joined)) = input_year;
-- $$ LANGUAGE SQL;