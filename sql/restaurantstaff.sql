-- match staff_id to restaurant
CREATE OR REPLACE FUNCTION match_staff_to_rid(input_username VARCHAR)
RETURNS INTEGER AS $$
    SELECT DISTINCT RS.rid
    FROM RestaurantStaff RS join Users U on U.uid = RS.uid
    WHERE input_username = U.username;
 $$ LANGUAGE SQL; 


----- add menu item
CREATE OR REPLACE FUNCTION add_menu_item(new_food_name VARCHAR, food_price DECIMAL, food_cuisine VARCHAR, restaurant_id INTEGER, food_quantity INTEGER, food_available BOOLEAN)
RETURNS VOID AS $$
declare 
    fid INTEGER;
begin 
    INSERT into FoodItem VALUES(DEFAULT, restaurant_id, food_cuisine, new_food_name, food_quantity, 0, 0, food_available, false);
    SELECT F.food_id into fid from FoodItem F where F.food_name = new_food_name and F.rid = restaurant_id;
    INSERT into Sells VALUES(restaurant_id, fid, food_price);
end
$$ LANGUAGE PLPGSQL;

----- delete menu item
CREATE OR REPLACE FUNCTION delete_menu_item(delete_name VARCHAR, rest_id INTEGER)
RETURNS VOID AS $$
begin 
    UPDATE FoodItem F SET is_deleted = true where F.rid = rest_id and F.food_name = delete_name; 
end
$$ LANGUAGE PLPGSQL;

 
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
CREATE OR REPLACE FUNCTION update_food(id INTEGER, current_rid INTEGER, new_name VARCHAR, new_quantity INTEGER, new_price DECIMAL, new_type VARCHAR)
RETURNS VOID AS $$
BEGIN
    IF new_quantity IS NOT NULL then
    UPDATE FoodItem 
    SET restaurant_quantity = new_quantity
    WHERE rid = current_rid
    AND food_id = id;
    END IF;

    IF new_price IS NOT NULL then
    UPDATE Sells 
    SET price = new_price
    WHERE rid = current_rid
    AND food_id = id;
    END IF;
    
    IF new_name IS NOT NULL then
    UPDATE FoodItem 
    SET food_name = new_name
    WHERE rid = current_rid
    AND food_id = id;
    END IF;

    IF new_type IS NOT NULL then
    UPDATE FoodItem 
    SET cuisine_type = new_type
    WHERE rid = current_rid
    AND food_id = id;
    END IF;

END;
$$ LANGUAGE PLPGSQL;

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


--- PROMOTIONAL CAMPAIGN past promos
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
        SELECT (DATE_PART('day', (PC.end_date::timestamp - PC.start_date::timestamp)))
        FROM PromotionalCampaign PC
        INTO time_frame;
        
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


-- CREATING PROMOS for storewide discount
CREATE OR REPLACE FUNCTION add_promo(current_rid INTEGER, discount NUMERIC, description VARCHAR(100), start_date TIMESTAMP, end_date TIMESTAMP) 
RETURNS VOID 
AS $$
BEGIN
    INSERT INTO PromotionalCampaign VALUES(DEFAULT, current_rid, discount, description, start_date, end_date);  
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION checkTimeInterval()
  RETURNS TRIGGER as $$
BEGIN
   IF (NEW.start_date > NEW.end_date) THEN
       RAISE EXCEPTION 'Start date should be earlier than End date';
   END IF;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS check_time_trigger ON PromotionalCampaign CASCADE;
CREATE TRIGGER check_time_trigger
BEFORE UPDATE OR INSERT
ON PromotionalCampaign
FOR EACH ROW
EXECUTE FUNCTION checkTimeInterval();
