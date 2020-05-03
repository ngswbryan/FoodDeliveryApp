-- ENTITIES

CREATE TABLE Users (
    uid SERIAL PRIMARY KEY,
    name VARCHAR(100),
    username VARCHAR(100),
    password VARCHAR(100),
    role_type VARCHAR(100),
    date_joined TIMESTAMP,
    UNIQUE(username)
);

CREATE TABLE Riders (
    rider_id INTEGER REFERENCES Users(uid)
        ON DELETE CASCADE,
    rating DECIMAL,
    working BOOLEAN, --to know if he's working now or not
    is_delivering BOOLEAN,--to know if he's free or not
    base_salary DECIMAL, --in terms of per month
    rider_type BOOLEAN, --pt f or ft t
    commission INTEGER, --PT is $2, FT is $3
    PRIMARY KEY(rider_id),
    UNIQUE(rider_id)
);

CREATE TABLE Restaurants (
    rid INTEGER PRIMARY KEY,
    rname VARCHAR(100),
    min_order_price DECIMAL,
    unique(rid)
);

CREATE TABLE RestaurantStaff (
    uid INTEGER REFERENCES Users
        ON DELETE CASCADE,
    rid INTEGER REFERENCES Restaurants(rid)
        ON DELETE CASCADE
);

CREATE TABLE FDSManager (
    uid INTEGER REFERENCES Users
        ON DELETE CASCADE PRIMARY KEY
);

CREATE TABLE Customers (
    uid INTEGER REFERENCES Users
        ON DELETE CASCADE PRIMARY KEY,
    points INTEGER,
    credit_card VARCHAR(100)
    -- recentFirst VARCHAR(100),
    -- recentSecond VARCHAR(100),
    -- recentThird VARCHAR(100),
    -- recentFourth VARCHAR(100),
    -- recentFIfth VARCHAR(100)
);

CREATE TABLE FoodOrder (
    order_id SERIAL PRIMARY KEY NOT NULL,
    uid INTEGER REFERENCES Users NOT NULL,
    rid INTEGER REFERENCES Restaurants NOT NULL,
    have_credit_card BOOLEAN,
    order_cost DECIMAL NOT NULL,
    date_time TIMESTAMP NOT NULL,
    completion_status BOOLEAN,
    UNIQUE(order_id)
);

CREATE TABLE FoodItem (
    food_id INTEGER, 
    rid INTEGER REFERENCES Restaurants
        ON DELETE CASCADE,
    cuisine_type VARCHAR(100),
    food_name VARCHAR(100),
    quantity INTEGER,
    overall_rating DECIMAL,
    ordered_count INTEGER,
    availability_status BOOLEAN,
    PRIMARY KEY(food_id, rid),
    UNIQUE(food_id)
);

CREATE TABLE PromotionalCampaign (
    promo_id INTEGER PRIMARY KEY,
    rid INTEGER REFERENCES Restaurants 
        ON DELETE CASCADE,
    discount INTEGER,
    description VARCHAR(100),
    start_date TIMESTAMP,
    end_date TIMESTAMP
);

CREATE TABLE WeeklyWorkSchedule (
    wws_id SERIAL PRIMARY KEY NOT NULL,
    rider_id INTEGER references Riders(rider_id),
    start_hour INTEGER,
    end_hour INTEGER,
    day INTEGER,
    week INTEGER,
    month INTEGER,
    year INTEGER,
    shift INTEGER
);

CREATE TABLE MonthlyWorkSchedule (
    mws_id SERIAL PRIMARY KEY,
    rider_id INTEGER REFERENCES Riders(rider_id), 
    month INTEGER,
    year INTEGER,
    firstWWS INTEGER REFERENCES WeeklyWorkSchedule(wws_id),
    secondWWS INTEGER REFERENCES WeeklyWorkSchedule(wws_id),
    thirdWWS INTEGER REFERENCES WeeklyWorkSchedule(wws_id),
    fourthWWS INTEGER REFERENCES WeeklyWorkSchedule(wws_id)
);
--ENTITIES

--RELATIONSHIPS

CREATE TABLE Sells (
    rid INTEGER REFERENCES Restaurants(rid) NOT NULL, 
    food_id INTEGER REFERENCES FoodItem(food_id) NOT NULL,
    price DECIMAL NOT NULL,
    PRIMARY KEY(rid, food_id)
);

CREATE TABLE Orders (
    order_id INTEGER REFERENCES FoodOrder(order_id),
    food_id INTEGER REFERENCES FoodItem(food_id),
    PRIMARY KEY(order_id,food_id)
);

CREATE TABLE Receives (
    order_id INTEGER REFERENCES FoodOrder(order_id),
    promo_id INTEGER REFERENCES PromotionalCampaign(promo_id)
);

CREATE TABLE Delivery (
    delivery_id SERIAL NOT NULL,
    order_id INTEGER REFERENCES FoodOrder(order_id),
    rider_id INTEGER REFERENCES Riders(rider_id),
    delivery_cost DECIMAL NOT NULL,
    delivery_start_time TIMESTAMP NOT NULL,
    delivery_end_time TIMESTAMP,
    time_for_one_delivery DECIMAL, --in minutes
    location VARCHAR(100),
    delivery_rating INTEGER, 
    food_review varchar(100),
    ongoing BOOLEAN, --true means delivering, false means done
    PRIMARY KEY(delivery_id),
    UNIQUE(delivery_id)
);

CREATE TABLE Contain (
    order_id INTEGER REFERENCES FoodOrder(order_id),
    food_id INTEGER REFERENCES FoodItem(food_id),
    PRIMARY KEY(order_id, food_id),
    UNIQUE(order_id, food_id)
);

--RELATIONSHIPS


-------- POPULATION -------------
INSERT INTO Users VALUES(DEFAULT, 'lawnce', 'lawnce23', '1234', 'customer', '2018-06-22 04:00:06'); --1
INSERT INTO Users VALUES(DEFAULT, 'joshua', 'joshua11', '1111', 'rider', '2018-06-22 04:00:06'); --2
INSERT INTO Users VALUES(DEFAULT, 'bryan', 'bry15', '2222', 'manager', '2018-06-22 04:00:06');
INSERT INTO Users VALUES(DEFAULT, 'jess', 'jess10', '3333', 'staff', '2018-06-22 04:00:06');
INSERT INTO Users VALUES(DEFAULT, 'yongcheng', 'yc15', '4444', 'rider', '2018-06-22 04:00:06'); --5

INSERT INTO Users VALUES(DEFAULT, 'lance', 'lance', '1234', 'customer', '2019-05-27 04:00:06'); --6
INSERT INTO Users VALUES(DEFAULT, 'eq', 'eq', '1111', 'rider', '2018-06-22 04:00:06'); --7
INSERT INTO Users VALUES(DEFAULT, 'jq', 'jq', '2222', 'manager', '2018-06-22 04:00:06');
INSERT INTO Users VALUES(DEFAULT, 'jordan', 'jord', '3333', 'staff', '2018-06-22 04:00:06');
INSERT INTO Users VALUES(DEFAULT, 'sally', 'sally', '4444', 'rider', '2018-06-22 04:00:06'); --10

INSERT INTO Users VALUES(DEFAULT, 'hazel', 'hazel', '1234', 'customer', '2018-05-26 04:00:06'); --11
INSERT INTO Users VALUES(DEFAULT, 'charlotte', 'char', '1111', 'rider', '2018-06-22 04:00:06'); --12
INSERT INTO Users VALUES(DEFAULT, 'jamie', 'jam', '2222', 'manager', '2018-06-22 04:00:06');
INSERT INTO Users VALUES(DEFAULT, 'rachie', 'rach', '3333', 'staff', '2018-06-22 04:00:06');
INSERT INTO Users VALUES(DEFAULT, 'knottedboys', 'kb69', '4444', 'rider', '2018-06-22 04:00:06'); --15

INSERT INTO RIDERS VALUES(2, 0.0, true, false, 15, TRUE, 3);
INSERT INTO RIDERS VALUES(5, 0.0, false, false, 15, TRUE, 3);
INSERT INTO RIDERS VALUES(7, 0.0, true, false, 15, TRUE, 3);
INSERT INTO RIDERS VALUES(12, 0.0, false,false, 10, TRUE, 3);
INSERT INTO RIDERS VALUES(15, 0.0, true, true, 10, TRUE, 3);

INSERT INTO Restaurants VALUES (1, 'kfc', 5.0);
INSERT INTO Restaurants VALUES (2, 'mac', 8.0);
INSERT INTO Restaurants VALUES (3, 'sweechoon', 4.0);
INSERT INTO Restaurants VALUES (4, 'reedz', 10.0);
INSERT INTO Restaurants VALUES (5, 'nanathai', 6.0);

INSERT INTO RestaurantStaff VALUES(4, 1);
INSERT INTO RestaurantStaff VALUES(9, 2);
INSERT INTO RestaurantStaff VALUES(14, 3);

INSERT INTO Customers VALUES(1, 0.0, '1234 5678 9432 1234');
INSERT INTO Customers VALUES(6, 0.0, '4321 7777 9432 8888');
INSERT INTO Customers VALUES(11, 0.0, '4222 5678 1243 9808');

INSERT INTO PromotionalCampaign values (100, 1, 20, 'this is discount 1', '2018-06-22 04:00:06', '2018-12-19 04:00:06');  
INSERT INTO PromotionalCampaign values (101, 2, 30, 'this is discount 2', '2018-04-22 04:00:06', '2018-12-20 04:00:06');  
INSERT INTO PromotionalCampaign values (102, 3, 40, 'this is discount 3', '2018-05-22 04:00:06', '2018-12-21 04:00:06');  

INSERT INTO FoodItem VALUES (1, 1, 'asian', 'chicken rice', 20, 0, 0, true);
INSERT INTO FoodItem VALUES (2, 2, 'western', 'pork chop', 15, 0, 0, true);
INSERT INTO FoodItem VALUES (3, 3, 'western', 'pork chop', 15, 0, 0, true);
INSERT INTO FoodItem VALUES (4, 4, 'thai', 'pineapple rice', 12, 0, 0, true);
INSERT INTO FoodItem VALUES (5, 5, 'western', 'pork chop', 12, 0, 0, true);

INSERT INTO FoodItem VALUES (6, 1, 'western', 'good stuff', 12, 2);
INSERT INTO FoodItem VALUES (7, 1, 'western', 'stuff good', 12, 3);
INSERT INTO FoodItem VALUES (8, 1, 'western', 'pork loin', 12, 5);
INSERT INTO FoodItem VALUES (9, 1, 'western', 'pork bone', 12, 4);
INSERT INTO FoodItem VALUES (10, 1, 'western', 'pork jizz', 12, 3.3);

INSERT INTO FoodItem VALUES (11, 1, 'western', 'dog chop', 12, 4.4);
INSERT INTO FoodItem VALUES (12, 1, 'western', 'horse chop', 12, 1.9);

INSERT INTO FoodOrder VALUES(DEFAULT, 1, 1, TRUE, 50.0,'2018-06-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 6, 2, FALSE, 46.0,'2018-05-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 11, 3, TRUE, 30.0,'2018-05-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 1, 4, FALSE, 20.0,'2018-08-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 6, 5, TRUE, 10.0,'2018-05-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 1, 1, TRUE, 50.0,'2019-06-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 6, 2, FALSE, 46.0,'2019-05-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 11, 3, TRUE, 30.0,'2019-05-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 1, 4, FALSE, 20.0,'2019-08-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 6, 5, TRUE, 10.0,'2019-05-22 04:00:06', TRUE);



INSERT INTO Sells VALUES (1,1,5.5);
INSERT INTO Sells VALUES (2,2,4.5);
INSERT INTO Sells VALUES (3,3,2.5);
INSERT INTO Sells VALUES (4,4,3.5);
INSERT INTO Sells VALUES (5,5,6.5);

INSERT INTO Orders VALUES (6, 2);
INSERT INTO Orders VALUES (7, 3);
INSERT INTO Orders VALUES (8, 4);
INSERT INTO Orders VALUES (9, 5);
INSERT INTO Orders VALUES (10, 6);
INSERT INTO Orders VALUES (6, 7);
INSERT INTO Orders VALUES (7, 8);
INSERT INTO Orders VALUES (8, 1);
INSERT INTO Orders VALUES (9, 2);
INSERT INTO Orders VALUES (10, 3);

INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-22 04:00:06', '2018-06-22 05:00:06', 1, 'kovan', 4.0, 'nice', TRUE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-19 04:00:06', '2018-06-19 05:00:06', 1, 'kovan', 4.0, 'nice', TRUE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-23 04:00:06', '2018-06-23 05:00:06', 1, 'kovan', 4.0, 'nice', TRUE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-24 04:00:06', '2018-06-24 05:00:06', 1, 'kovan', 4.0, 'nice', TRUE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-25 04:00:06', '2018-06-25 05:00:06', 1, 'kovan', 4.0, 'nice', TRUE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-26 04:00:06', '2018-06-26 05:00:06', 1, 'kovan', 4.0, 'nice', TRUE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-27 04:00:06', '2018-06-27 05:00:06', 1, 'kovan', 4.0, 'nice', TRUE);

INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-22 04:00:06', '2018-06-22 05:00:06', 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-19 04:00:06', '2018-06-19 05:00:06', 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-23 04:00:06', '2018-06-23 05:00:06', 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-24 04:00:06', '2018-06-24 05:00:06', 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-25 04:00:06', '2018-06-25 05:00:06', 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-26 04:00:06', '2018-06-26 05:00:06', 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-27 04:00:06', '2018-06-27 05:00:06', 1, 'kovan', 4.0, 'nice', FALSE);

INSERT INTO Delivery VALUES(DEFAULT, 7, 5, 5.0, '2018-06-22 04:00:06', '2018-06-22 05:00:06', 1, 'serangoon', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 8, 15, 5.0, '2018-06-22 04:00:06', '2018-06-22 05:00:06', 1, 'little inda', 4.0, 'nice', FALSE);

INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, 2, 11, 15, 2, 2, 5, 2018, 2);
INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, 2, 16, 20, 2, 2, 5, 2018, 2);
INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, 7, 10, 14, 3, 3, 5, 2018, 1);
INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, 7, 15, 19, 3, 3, 5, 2018, 1);

INSERT INTO MonthlyWorkSchedule VALUES (DEFAULT, 2, 5, 2018, 1, 2, NULL, NULL);

-------- POPULATION -------------


------- USERS ----------
-- for user creation
create or replace function create_user(new_name VARCHAR, new_username VARCHAR, new_password VARCHAR, new_role_type VARCHAR, rider_type VARCHAR, restaurant_name VARCHAR)
returns void as $$
declare
    uid integer;
    rid integer;
begin
INSERT INTO users (name, username, password, role_type, date_joined) VALUES (new_name, new_username, new_password, new_role_type, current_timestamp);
select U.uid into uid from users U where U.username = new_username;
if new_role_type = 'rider' then
    if rider_type = 'part' then
        INSERT INTO RIDERS VALUES (uid, 0.0, FALSE, FALSE, 0, FALSE, 2);
    else 
        INSERT INTO RIDERS VALUES (uid, 0.0, FALSE, FALSE, 10, TRUE, 3);
    end if;
end if;
if new_role_type = 'customer' then
    INSERT INTO customers (uid, points, credit_card) VALUES (uid, 0, '0');
end if;
if new_role_type = 'manager' then
    INSERT INTO fdsmanager (uid) VALUES (uid);
end if;
if new_role_type = 'staff' then
    select R.rid into rid from restaurants R where R.rname = restaurant_name;
    INSERT INTO RestaurantStaff (uid, rid) VALUES (uid, rid);
end if;
end;
$$ language plpgsql;

------ CUSTOMERS ------
--a)
-- past delivery ratings
CREATE OR REPLACE FUNCTION past_delivery_ratings(customers_uid INTEGER)
 RETURNS TABLE (
     order_id INTEGER,
     delivery_ratings INTEGER,
     delivery_location VARCHAR
 ) AS $$
     SELECT D.order_id, D.delivery_rating, D.location
     FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id
     WHERE FO.uid = customers_uid;
 $$ LANGUAGE SQL;


 --b)
 --past food reviews
 CREATE OR REPLACE FUNCTION past_food_reviews(customers_uid INTEGER)
 RETURNS TABLE (
     order_id INTEGER,
     restaurant_name VARCHAR,
     food_review VARCHAR
 ) AS $$
     SELECT D.order_id, R.rname, D.food_review
     FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id join Restaurants R on R.rid = FO.rid
     WHERE FO.uid = customers_uid;
 $$ LANGUAGE SQL;


 --c)
 --List of restaurants
  CREATE OR REPLACE FUNCTION list_of_restaurant()
 RETURNS TABLE (
     restaurant_id INTEGER,
     restaurant_name VARCHAR,
     min_order_price DECIMAL
 ) AS $$
     SELECT R.rid, R.rname, R.min_order_price
     FROM Restaurants R
 $$ LANGUAGE SQL;


 --d)
 --List of available food items
 CREATE OR REPLACE FUNCTION list_of_fooditems(restaurant_id INTEGER)
 RETURNS TABLE (
     food_name VARCHAR,
     food_price DECIMAL,
     cuisine_type VARCHAR,
     overall_rating DECIMAL,
     availability_status BOOLEAN
 ) AS $$
     SELECT FI.food_name, S.price, FI.cuisine_type, FI.overall_rating, FI.availability_status
     FROM FoodItem FI join Sells S on FI.food_id = S.food_id
     WHERE FI.rid = restaurant_id
 $$ LANGUAGE SQL;

 --trigger when choosen quantity > available quantity
 CREATE OR REPLACE FUNCTION notify_user() RETURNS TRIGGER AS $$
 BEGIN
    IF  NEW.ordered_count > OLD.quantity THEN
        RAISE EXCEPTION 'ordered quantity more than available quantity';
    END IF;
    RETURN NEW;
 END;
 $$ LANGUAGE PLPGSQL;
 DROP TRIGGER IF EXISTS notify_user_trigger ON FoodItem CASCADE;
 CREATE TRIGGER notify_user_trigger
  BEFORE UPDATE OF ordered_count
  ON FoodItem
  FOR EACH ROW
  EXECUTE FUNCTION notify_user();

  --trigger to update isdelivering for the particular rider
 CREATE OR REPLACE FUNCTION update_rider_isdelivering() RETURNS TRIGGER AS $$
 BEGIN
    UPDATE Riders
    SET is_delivering = TRUE
    WHERE rider_id = NEW.rider_id;
    RETURN NEW;
 END;
 $$ LANGUAGE PLPGSQL;
 DROP TRIGGER IF EXISTS update_rider_isdelivering_trigger ON Delivery CASCADE;
 CREATE TRIGGER update_rider_isdelivering_trigger
  AFTER INSERT
  ON Delivery
  FOR EACH ROW
  EXECUTE FUNCTION update_rider_isdelivering();

CREATE TYPE orderdeliveryid AS (
  order_id   integer,
  delivery_id  integer
);

--e)
 --create new foodorder, create new delivery, update order count
 --returns orderid and deliveryid as a tuple
 --currentorder is a 2d array which consist of the { {foodid,quantity}, {foodid2,quantity} }

 CREATE OR REPLACE FUNCTION update_order_count(currentorder INTEGER[][], customer_uid INTEGER, restaurant_id INTEGER, have_credit BOOLEAN, total_order_cost DECIMAL, delivery_location VARCHAR(100))
 RETURNS orderdeliveryid AS $$
 DECLARE
    orderid INTEGER;
    deliveryid INTEGER;
    orderedcount INTEGER;
    foodquantity INTEGER;
    item INTEGER[];
 BEGIN
      INSERT INTO FoodOrder(uid, rid, have_credit_card, order_cost, date_time, completion_status)
      VALUES (customer_uid, restaurant_id, have_credit, total_order_cost, current_timestamp, FALSE)
      RETURNING order_id into orderid;

      INSERT INTO Delivery(order_id, rider_id, delivery_cost, delivery_start_time, location, ongoing)
      VALUES (orderid,
              (SELECT CASE WHEN (SELECT R.rider_id FROM Riders R WHERE R.working = TRUE AND R.is_delivering = FALSE ORDER BY random() LIMIT 1) IS NOT NULL
                       THEN (SELECT R.rider_id FROM Riders R WHERE R.working = TRUE AND R.is_delivering = FALSE  ORDER BY random() LIMIT 1)
                       ELSE (SELECT R.rider_id FROM Riders R WHERE R.working = TRUE ORDER BY random() LIMIT 1)
                       END),
              5.5,
              current_timestamp,
              delivery_location,
              TRUE) --flat fee of 5.5 for delivery cost
      RETURNING delivery_id into deliveryid;



       FOREACH item SLICE 1 IN ARRAY currentorder LOOP
          SELECT ordered_count into orderedcount FROM FoodItem WHERE food_id = item[1];
          SELECT quantity into foodquantity FROM FoodItem WHERE food_id = item[1];

            UPDATE FoodItem FI
            SET ordered_count = ordered_count + item[2]
            WHERE item[1] = FI.food_id;

            IF orderedcount + item[2] = foodquantity THEN
              UPDATE FoodItem FI
              SET availability_status = false
              WHERE item[1] = FI.food_id;
            END IF;

            INSERT INTO Orders(order_id,food_id)
            VALUES (orderid,item[1]);

       END loop;

       RETURN  (orderid,deliveryid);

 END
 $$ LANGUAGE PLPGSQL;




 --f)
 -- reward balance
 CREATE OR REPLACE FUNCTION reward_balance(customer_id INTEGER)
 RETURNS INTEGER AS $$
     SELECT C.points
     FROM Customers C
     WHERE C.uid = customer_id;
 $$ LANGUAGE SQL;

  --g)
  --delivery page
  -- rider name/id
 CREATE OR REPLACE FUNCTION rider_name(deliveryid INTEGER)
 RETURNS VARCHAR AS $$
     SELECT U.name
     FROM Delivery D join Users U on D.rider_id = U.uid
     WHERE D.delivery_id = deliveryid;
 $$ LANGUAGE SQL;

 --delivery id

 --start time
 CREATE OR REPLACE FUNCTION start_time(deliveryid INTEGER)
 RETURNS TIMESTAMP AS $$
     SELECT D.delivery_start_time
     FROM Delivery D
     WHERE D.delivery_id = deliveryid;
 $$ LANGUAGE SQL;

 --location
 CREATE OR REPLACE FUNCTION location(deliveryid INTEGER)
 RETURNS VARCHAR AS $$
     SELECT D.location
     FROM Delivery D
     WHERE D.delivery_id = deliveryid;
 $$ LANGUAGE SQL;

 --rider rating
 CREATE OR REPLACE FUNCTION rider_rating(deliveryid INTEGER)
 RETURNS DECIMAL AS $$
     SELECT R.rating
     FROM Delivery D join Riders R on D.rider_id = R.rider_id
     WHERE D.delivery_id = deliveryid;
 $$ LANGUAGE SQL;


 --i)
 --delivery end time
 CREATE OR REPLACE FUNCTION delivery_endtime(deliveryid INTEGER)
 RETURNS TIMESTAMP AS $$
     SELECT D.delivery_end_time
     FROM Delivery D
     WHERE D.delivery_id = deliveryid;
 $$ LANGUAGE SQL;

 --review food update
 CREATE OR REPLACE FUNCTION food_review_update(foodreview VARCHAR, deliveryid INTEGER)
 RETURNS VOID AS $$
    UPDATE Delivery
    SET food_review = foodreview
    WHERE delivery_id = deliveryid;
 $$ LANGUAGE SQL;

 --trigger rating update
 CREATE OR REPLACE FUNCTION update_rider_ratings() RETURNS TRIGGER AS $$
 BEGIN
    UPDATE Riders
    set rating = (SELECT (sum(D.delivery_rating)::DECIMAL/count(D.delivery_rating))::DECIMAL as average_ratings FROM Delivery D WHERE D.rider_id = OLD.rider_id GROUP BY D.rider_id)
    WHERE rider_id = OLD.rider_id;
    RETURN NEW;
 END;
 $$ LANGUAGE PLPGSQL;

 DROP TRIGGER IF EXISTS update_rating_trigger ON Delivery CASCADE;
 CREATE TRIGGER update_rating_trigger
    AFTER UPDATE OF delivery_rating ON Delivery
    FOR EACH ROW
    EXECUTE FUNCTION update_rider_ratings();

--Update delivery rating which triggers rider rating update
  CREATE OR REPLACE FUNCTION update_delivery_rating(deliveryid INTEGER, deliveryrating INTEGER)
  RETURNS VOID AS $$
      UPDATE Delivery
      SET delivery_rating = deliveryrating
      WHERE delivery_id = deliveryid;
  $$ LANGUAGE SQL;

------ CUSTOMERS ------

------ RESTAURANT STAFF ------
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

------ RESTAURANT STAFF ------

------ FDS MANAGER ------
-- FDS Manager
--a)
 CREATE OR REPLACE FUNCTION new_customers(input_month INTEGER, input_year INTEGER)
 RETURNS setof record AS $$
     SELECT C.uid, U.username 
     FROM Customers C join Users U on C.uid = U.uid
     WHERE (SELECT EXTRACT(MONTH FROM U.date_joined)) = input_month
     AND (SELECT EXTRACT(YEAR FROM U.date_joined)) = input_year;
 $$ LANGUAGE SQL;

 --b)
 CREATE OR REPLACE FUNCTION total_orders(input_month INTEGER, input_year INTEGER)
 RETURNS setof record AS $$
     SELECT *
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

------ FDS MANAGER ------
------ RIDERS ------
--a)
 -- get current job
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

--b)
-- get work schedule

-- manipulation to calculate week
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
  CREATE OR REPLACE FUNCTION update_done_status(deliveryid INTEGER)
  RETURNS VOID AS $$
  BEGIN 
      UPDATE FoodOrder
      SET completion_status = TRUE
      WHERE order_id = ( SELECT D.order_id FROM Delivery D WHERE D.delivery_id = deliveryid);
 
      UPDATE Delivery
      SET ongoing = FALSE,
          delivery_end_time = current_timestamp,
          time_for_one_delivery = (SELECT EXTRACT(EPOCH FROM (current_timestamp - D.delivery_start_time)) FROM Delivery D WHERE D.delivery_id = deliveryid)/60::DECIMAL
      WHERE delivery_id = deliveryid;
  END
  $$ LANGUAGE PLPGSQL;

-- for WWS
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


------ RIDERS ------
