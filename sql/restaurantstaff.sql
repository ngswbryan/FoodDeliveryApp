-- match staff_id to restaurant
-- CREATE OR REPLACE FUNCTION match_staff_to_rid(input_username VARCHAR)
-- RETURNS INTEGER AS $$
--     SELECT DISTINCT RS.rid
--     FROM RestaurantStaff RS join Users U on U.uid = RS.uid
--     WHERE input_username = U.username;
--  $$ LANGUAGE SQL; 
 
-- -- a) see menu items that belong to me
-- CREATE OR REPLACE FUNCTION bring_menu_up(staff_username VARCHAR)
-- RETURNS TABLE(
--     food_item INTEGER,
--     count INTEGER,
--     cuisine_type VARCHAR,
--     food_name VARCHAR
-- ) AS $$
-- declare 
--     uid_matched INTEGER;
-- begin 
--     SELECT match_staff_to_rid(staff_username) INTO uid_matched;

--     RETURN QUERY(
--     SELECT FI.food_id, FI.quantity, FI.cuisine_type, FI.food_name
--     FROM FoodItem FI
--     WHERE uid_matched = FI.rid
--     );
-- end
-- $$ LANGUAGE PLPGSQL;

--b) update menu items that belong -> can change count of food items, cuisine_type, food_name
-- CREATE OR REPLACE FUNCTION update_count(food_item INTEGER, current_rid INTEGER, new_count INTEGER)
-- RETURNS VOID AS $$
-- BEGIN TRANSACTION;
--     UPDATE FoodItem  
--     SET quantity = new_count
--     WHERE rid = current_rid
--     AND food_id = food_item;

--     UPDATE FoodItem  
--     SET ordered_count = ordered_count + 1
--     WHERE rid = current_rid
--     AND food_id = food_item;
-- COMMIT;
-- $$ LANGUAGE SQL;

-- --update cuisine_type
-- CREATE OR REPLACE FUNCTION update_type(food_item INTEGER, current_rid INTEGER, new_type VARCHAR)
-- RETURNS VOID AS $$
--     UPDATE FoodItem  
--     SET cuisine_type = new_type
--     WHERE rid = current_rid
--     AND food_id = food_item;
-- $$ LANGUAGE SQL;

-- --update food_name
-- CREATE OR REPLACE FUNCTION update_count(food_item INTEGER, current_rid INTEGER, new_name VARCHAR)
-- RETURNS VOID AS $$
--     UPDATE FoodItem  
--     SET food_name = new_name
--     WHERE rid = current_rid
--     AND food_id = food_item;
-- $$ LANGUAGE SQL;

--c) generate report for restaurant
-- CREATE OR REPLACE FUNCTION generate_report(input_month INTEGER)
-- RETURNS TABLE (
--     num_orders INTEGER,
--     num_cost DECIMAL,

-- ) AS $$

CREATE OR REPLACE FUNCTION generate_top_five(input_month INTEGER, current_rid INTEGER)
RETURNS TABLE (
    top_few VARCHAR
) AS $$
    SELECT food_name
    FROM FoodItem FO
    WHERE FO.rid = current_rid
    ORDER BY FO.overall_rating DESC
    LIMIT(5); 
$$ LANGUAGE SQL;

--a)
-- CREATE OR REPLACE FUNCTION new_customers(input_month INTEGER, input_year INTEGER)
-- RETURNS INTEGER AS $$
--     SELECT C.uid 
--     FROM Customers C join Users U on C.uid = U.uid
--     WHERE (SELECT EXTRACT(MONTH FROM U.date_joined)) = input_month
--     AND (SELECT EXTRACT(YEAR FROM U.date_joined)) = input_year;
-- $$ LANGUAGE SQL;