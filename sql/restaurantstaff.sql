-- match staff_id to restaurant
CREATE OR REPLACE FUNCTION match_staff_to_rid(input_username VARCHAR)
RETURNS INTEGER AS $$
    SELECT DISTINCT RS.rid
    FROM RestaurantStaff RS join Users U on U.uid = RS.uid
    WHERE input_username = U.username;
 $$ LANGUAGE SQL; 
 
-- -- a) see menu items that belong to me
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

-- b) update menu items that belong -> can change count of food items, cuisine_type, food_name
CREATE OR REPLACE FUNCTION update_count(food_item INTEGER, current_rid INTEGER, new_count INTEGER)
RETURNS VOID AS $$
BEGIN TRANSACTION;
    UPDATE FoodItem  
    SET quantity = new_count
    WHERE rid = current_rid
    AND food_id = food_item;

    UPDATE FoodItem  
    SET ordered_count = ordered_count + 1
    WHERE rid = current_rid
    AND food_id = food_item;
COMMIT;
$$ LANGUAGE SQL;

--update cuisine_type
CREATE OR REPLACE FUNCTION update_type(food_item INTEGER, current_rid INTEGER, new_type VARCHAR)
RETURNS VOID AS $$
    UPDATE FoodItem  
    SET cuisine_type = new_type
    WHERE rid = current_rid
    AND food_id = food_item;
$$ LANGUAGE SQL;

-- --update food_name
CREATE OR REPLACE FUNCTION update_count(food_item INTEGER, current_rid INTEGER, new_name VARCHAR)
RETURNS VOID AS $$
    UPDATE FoodItem  
    SET food_name = new_name
    WHERE rid = current_rid
    AND food_id = food_item;
$$ LANGUAGE SQL;

--generates top five based on highest rating
CREATE OR REPLACE FUNCTION generate_top_five(current_rid INTEGER)
RETURNS TABLE (
    top_few VARCHAR,
    overall_rating DECIMAL
) AS $$
    SELECT DISTINCT food_name, FO.overall_rating
    FROM FoodItem FO
    WHERE FO.rid = current_rid
    ORDER BY FO.overall_rating DESC
    LIMIT(5); 
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION generate_total_num_of_orders(input_month INTEGER, input_year INTEGER, current_rid INTEGER)
RETURNS BIGINT AS $$
    SELECT count(*)
    FROM FoodOrder FO 
    WHERE FO.rid = current_rid
    AND (SELECT(EXTRACT(MONTH FROM FO.date_time))) = input_month
    AND (SELECT(EXTRACT(YEAR FROM FO.date_time))) = input_year
    AND FO.completion_status = TRUE;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION generate_total_cost_of_orders(input_month INTEGER, input_year INTEGER, current_rid INTEGER)
RETURNS DECIMAL AS $$
    SELECT SUM(FO.order_cost)
    FROM FoodOrder FO 
    WHERE FO.rid = current_rid
    AND (SELECT(EXTRACT(MONTH FROM FO.date_time))) = input_month
    AND (SELECT(EXTRACT(YEAR FROM FO.date_time))) = input_year
    AND FO.completion_status = TRUE;
$$ LANGUAGE SQL;


--- PROMOTIONAL CAMPAIGN
CREATE OR REPLACE FUNCTION generate_all_my_promos(current_rid INTEGER)
RETURNS TABLE (
    promo_id INTEGER,
    discount INTEGER,
    description VARCHAR(100),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    duration INTEGER
) AS $$
    declare
        time_frame INTEGER;
    begin
        SELECT (DATE_PART('day', (input_end_date::timestamp - input_start_date::timestamp))) INTO time_frame;
        
        RETURN QUERY(
            SELECT DISTINCT PC.promo_id, PC.discount, PC.description, PC.start_date, PC.end_date, time_frame
            FROM PromotionalCampaign PC
            WHERE PC.rid = current_rid
        );
    end
$$ LANGUAGE PLPGSQL;


--AVERAGE ORDERS DURING THIS PROMO
CREATE OR REPLACE FUNCTION average_orders_during_promo(current_rid INTEGER, input_start_date TIMESTAMP, input_end_date TIMESTAMP)
RETURNS DECIMAL 
AS $$
    declare 
        time_frame INTEGER;
    begin
         SELECT (DATE_PART('day', (input_end_date::timestamp - input_start_date::timestamp))) INTO time_frame;


        RETURN (
            SELECT count(*)::decimal/time_frame::decimal
            FROM FoodOrder FO join PromotionalCampaign PC
            ON FO.rid = PC.rid
            WHERE PC.rid = current_rid
            AND FO.date_time BETWEEN input_start_date and input_end_date
            AND FO.completion_status = TRUE
        );
    end
$$ LANGUAGE PLPGSQL;
