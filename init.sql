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
    base_salary DECIMAL, --in terms of per week
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
);

CREATE TABLE FoodOrder (
    order_id SERIAL PRIMARY KEY NOT NULL,
    uid INTEGER REFERENCES Customers NOT NULL,
    rid INTEGER REFERENCES Restaurants NOT NULL,
    have_credit_card BOOLEAN,
    order_cost DECIMAL NOT NULL,
    date_time TIMESTAMP NOT NULL,
    completion_status BOOLEAN,
    UNIQUE(order_id)
);

CREATE TABLE FoodItem (
    food_id SERIAL NOT NULL, 
    rid INTEGER REFERENCES Restaurants
        ON DELETE CASCADE,
    cuisine_type VARCHAR(100),
    food_name VARCHAR(100),
    quantity INTEGER,
    overall_rating DECIMAL,
    ordered_count INTEGER,
    availability_status BOOLEAN,
    is_deleted BOOLEAN,
    PRIMARY KEY(food_id, rid),
    UNIQUE(food_id)
);

CREATE TABLE PromotionalCampaign (
    promo_id SERIAL PRIMARY KEY,
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
    food_id INTEGER REFERENCES FoodItem(food_id) ON DELETE CASCADE,
    price DECIMAL NOT NULL check (price > 0),
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

--new updated delivery table
CREATE TABLE Delivery (
    delivery_id SERIAL NOT NULL,
    order_id INTEGER REFERENCES FoodOrder(order_id),
    rider_id INTEGER REFERENCES Riders(rider_id),
    delivery_cost DECIMAL NOT NULL,
    departure_time TIMESTAMP,
    collected_time TIMESTAMP,
    delivery_start_time TIMESTAMP, --start delivering to customer
    delivery_end_time TIMESTAMP,
    time_for_one_delivery DECIMAL, --in hours
    location VARCHAR(100),
    delivery_rating INTEGER, 
    food_review varchar(100),
    ongoing BOOLEAN, --true means delivering, false means done
    PRIMARY KEY(delivery_id),
    UNIQUE(delivery_id)
);


--CREATE TABLE Delivery (
--    delivery_id SERIAL NOT NULL,
--    order_id INTEGER REFERENCES FoodOrder(order_id),
--    rider_id INTEGER REFERENCES Riders(rider_id),
--    delivery_cost DECIMAL NOT NULL,
--    delivery_start_time TIMESTAMP NOT NULL,
--    delivery_end_time TIMESTAMP,
--    time_for_one_delivery DECIMAL, --in minutes
--    location VARCHAR(100),
--    delivery_rating INTEGER, 
--    food_review varchar(100),
--    ongoing BOOLEAN, --true means delivering, false means done
--    PRIMARY KEY(delivery_id),
--    UNIQUE(delivery_id)
--);

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

INSERT INTO PromotionalCampaign values (DEFAULT, 1, 20, 'this is discount 1', '2018-06-22 04:00:06', '2018-12-19 04:00:06'); 

INSERT INTO FoodItem VALUES (DEFAULT, 1, 'asian', 'chicken rice', 20, 0, 2, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 1, 'asian', 'chicken noodles', 30, 0, 1, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 1, 'asian', 'chicken kway teow', 15, 0, 1, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 1, 'asian', 'fried chicken thigh', 15, 0, 14, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 2, 'western', 'porkchop', 15, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 2, 'western', 'chicken chop', 16, 0, 2, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 2, 'western', 'fish n chips', 17, 0, 4, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 2, 'western', 'grilled fish', 18, 0, 5, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 2, 'western', 'steak', 19, 0, 6, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 3, 'mexican', 'tacos', 15, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 3, 'mexican', 'burrito', 15, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 3, 'mexican', 'burrito bowl', 10, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 4, 'thai', 'pineapple rice', 12, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 4, 'thai', 'pad thai', 12, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 4, 'thai', 'tom yum soup', 12, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 4, 'thai', 'mookata', 12, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 5, 'indian', 'garlic naan', 13, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 5, 'indian', 'chicken taandori', 9, 0, 0, true, false);
INSERT INTO FoodItem VALUES (DEFAULT, 5, 'indian', 'roti john', 2, 0, 0, true, false);

--INSERT INTO FoodItem VALUES (DEFAULT,1, 'western', 'good stuff', 12, 2,0,true,false);
--INSERT INTO FoodItem VALUES (DEFAULT,1, 'western', 'stuff good', 12, 3,0,true,false);
--INSERT INTO FoodItem VALUES (DEFAULT,1, 'western', 'pork loin', 12, 5,0,true,false);
--INSERT INTO FoodItem VALUES (DEFAULT,1, 'western', 'pork bone', 12, 4,0,true,false);
--INSERT INTO FoodItem VALUES (DEFAULT,1, 'western', 'pork jizz', 12, 3.3,0,true,false);


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
INSERT INTO FoodOrder VALUES(DEFAULT, 6, 5, TRUE, 10.0,current_timestamp, TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 1, 1, TRUE, 23.3,current_timestamp, TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 6, 1, TRUE, 23.3,'2020-04-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 6, 1, TRUE, 23.3,'2020-04-22 04:00:06', TRUE);
INSERT INTO FoodOrder VALUES(DEFAULT, 11, 2, TRUE, 23.3,current_timestamp, TRUE);


INSERT INTO Sells VALUES (1,1,5.5);
INSERT INTO Sells VALUES (1,2,4.5);
INSERT INTO Sells VALUES (1,3,3.5);
INSERT INTO Sells VALUES (1,4,2.5);
INSERT INTO Sells VALUES (2,5,4.5);
INSERT INTO Sells VALUES (2,6,5.5);
INSERT INTO Sells VALUES (2,7,1.5);
INSERT INTO Sells VALUES (2,8,4.5);
INSERT INTO Sells VALUES (2,9,4.5);
INSERT INTO Sells VALUES (3,10,2.5);
INSERT INTO Sells VALUES (3,11,3.5);
INSERT INTO Sells VALUES (3,12,2.0);
INSERT INTO Sells VALUES (4,13,3.3);
INSERT INTO Sells VALUES (4,14,2.5);
INSERT INTO Sells VALUES (4,15,3.1);
INSERT INTO Sells VALUES (4,16,3.4);
INSERT INTO Sells VALUES (5,17,5.0);
INSERT INTO Sells VALUES (5,18,6.3);
INSERT INTO Sells VALUES (5,19,7.5);


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


INSERT INTO Delivery VALUES(DEFAULT, 11, 2, 5.0, current_timestamp, current_timestamp,current_timestamp, current_timestamp, 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 12, 2, 5.0, current_timestamp, current_timestamp,current_timestamp, current_timestamp, 1, 'bishan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 13, 2, 5.0,'2020-04-22 04:00:06','2020-04-22 04:00:06',current_timestamp, current_timestamp, 1, 'yishun', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 14, 2, 5.0, '2020-04-22 04:00:06', '2020-04-22 04:00:06',current_timestamp, current_timestamp, 1, 'khatib', 4.0, 'nice', FALSE);

INSERT INTO Delivery VALUES(DEFAULT, 15, 2, 5.0, current_timestamp, current_timestamp,current_timestamp, current_timestamp, 1, 'bishan', 4.0, 'nice', FALSE);

INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-22 04:00:06', '2018-06-22 05:00:06',current_timestamp, current_timestamp, 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-19 04:00:06', '2018-06-19 05:00:06',current_timestamp, current_timestamp, 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-23 04:00:06', '2018-06-23 05:00:06',current_timestamp, current_timestamp, 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-24 04:00:06', '2018-06-24 05:00:06',current_timestamp, current_timestamp, 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-25 04:00:06', '2018-06-25 05:00:06',current_timestamp, current_timestamp, 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-26 04:00:06', '2018-06-26 05:00:06',current_timestamp, current_timestamp, 1, 'kovan', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 6, 2, 5.0, '2018-06-27 04:00:06', '2018-06-27 05:00:06',current_timestamp, current_timestamp, 1, 'kovan', 4.0, 'nice', FALSE);

INSERT INTO Delivery VALUES(DEFAULT, 7, 5, 5.0, '2018-06-22 04:00:06', '2018-06-22 05:00:06',current_timestamp, current_timestamp, 1, 'serangoon', 4.0, 'nice', FALSE);
INSERT INTO Delivery VALUES(DEFAULT, 8, 15, 5.0, '2018-06-22 04:00:06', '2018-06-22 05:00:06',current_timestamp, current_timestamp, 1, 'little inda', 4.0, 'nice', FALSE);

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
     order_time TIMESTAMP,
     delivery_ratings INTEGER,
     rider_name VARCHAR
 ) AS $$
     SELECT D.order_id, FO.date_time, D.delivery_rating, U.name
     FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id
     join Users U on D.rider_id = U.uid
     WHERE FO.uid = customers_uid
     AND D.delivery_rating IS NOT NULL;
 $$ LANGUAGE SQL;


 --b)
 --past food reviews
 CREATE OR REPLACE FUNCTION past_food_reviews(customers_uid INTEGER)
 RETURNS TABLE (
     order_id INTEGER,
     order_time TIMESTAMP,
     restaurant_name VARCHAR,
     food_review VARCHAR
 ) AS $$
     SELECT D.order_id, FO.date_time, R.rname, D.food_review
     FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id join Restaurants R on R.rid = FO.rid
     WHERE FO.uid = customers_uid
     AND D.food_review IS NOT NULL;
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
     food_id INTEGER,
     food_name VARCHAR,
     food_price DECIMAL,
     cuisine_type VARCHAR,
     overall_rating DECIMAL,
     availability_status BOOLEAN,
     is_deleted BOOLEAN,
        quantity INTEGER
 ) AS $$
     SELECT FI.food_id, FI.food_name, S.price, FI.cuisine_type, FI.overall_rating, FI.availability_status, FI.is_deleted, FI.quantity
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

    --trigger when choosen total order cost < min order
 CREATE OR REPLACE FUNCTION notify_minorder_not_met() RETURNS TRIGGER AS $$
 DECLARE
    minorderprice DECIMAL;
 BEGIN
    SELECT R.min_order_price INTO minorderprice
    FROM  Restaurants R
    WHERE R.rid = NEW.rid;
    IF  NEW.order_cost < minorderprice THEN
        RAISE EXCEPTION 'ordered cost is less than minimum order cost of %', minorderprice;
    END IF;
    RETURN NEW;
 END;
 $$ LANGUAGE PLPGSQL;
 DROP TRIGGER IF EXISTS notify_minorder_not_met ON FoodOrder CASCADE;
 CREATE TRIGGER notify_minorder_not_met
  BEFORE INSERT
  ON FoodOrder
  FOR EACH ROW
  EXECUTE FUNCTION notify_minorder_not_met();

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


--e (i) run this function first
 --function to activate riders that are working NOW
CREATE OR REPLACE FUNCTION activate_riders()
RETURNS VOID AS $$
BEGIN
  UPDATE Riders R
  SET working = TRUE
  WHERE R.rider_id IN (SELECT WWS.rider_id
                      FROM WeeklyWorkSchedule WWS
                      WHERE WWS.start_hour = (SELECT EXTRACT(HOUR FROM current_timestamp))
                      AND WWS.day%7 = (SELECT EXTRACT(DOW FROM current_timestamp))
                      AND WWS.week =  (SELECT EXTRACT('day' from date_trunc('week', current_timestamp) - date_trunc('week', date_trunc('month',  current_timestamp))) / 7 + 1 )
                      AND WWS.month = (SELECT EXTRACT(MONTH FROM current_timestamp))
                      AND WWS.year = (SELECT EXTRACT(YEAR FROM current_timestamp))
                      );
   UPDATE Riders R
   SET working = FALSE
   WHERE R.rider_id NOT IN (SELECT WWS.rider_id
                      FROM WeeklyWorkSchedule WWS
                      WHERE WWS.start_hour = (SELECT EXTRACT(HOUR FROM current_timestamp))
                      AND WWS.day%7 = (SELECT EXTRACT(DOW FROM current_timestamp))
                      AND WWS.week =  (SELECT EXTRACT('day' from date_trunc('week', current_timestamp) - date_trunc('week', date_trunc('month',  current_timestamp))) / 7 + 1 )
                      AND WWS.month = (SELECT EXTRACT(MONTH FROM current_timestamp))
                      AND WWS.year = (SELECT EXTRACT(YEAR FROM current_timestamp))
                      );
END
 $$ LANGUAGE PLPGSQL;



--e (ii)
 --create new foodorder, create new delivery, update order count
 --returns orderid and deliveryid as a tuple
 --currentorder is a 2d array which consist of the { {foodid,quantity}, {foodid2,quantity} }

CREATE OR REPLACE FUNCTION update_order_count(currentorder INTEGER[][], customer_uid INTEGER, restaurant_id INTEGER, have_credit BOOLEAN, total_order_cost DECIMAL, delivery_location VARCHAR(100), delivery_fee DECIMAL)
 RETURNS VOID AS $$
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

      --check for promo


      INSERT INTO Delivery(order_id, rider_id, delivery_cost, location, ongoing)
      VALUES (orderid,
              (SELECT CASE WHEN (SELECT R.rider_id FROM Riders R WHERE R.working = TRUE AND R.is_delivering = FALSE ORDER BY random() LIMIT 1) IS NOT NULL
                       THEN (SELECT R.rider_id FROM Riders R WHERE R.working = TRUE AND R.is_delivering = FALSE  ORDER BY random() LIMIT 1)
                       ELSE (SELECT R.rider_id FROM Riders R WHERE R.working = TRUE ORDER BY random() LIMIT 1)
                       END),
              delivery_fee,
              delivery_location,
              TRUE) --flat fee of 5 for delivery cost
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

       UPDATE Customers C
       SET points = points + CAST(floor(total_order_cost/5) AS INTEGER) --Gain 1 reward point every $5 spent
       WHERE C.uid = customer_uid;

 END
 $$ LANGUAGE PLPGSQL;

 --e(iii)
 -- get delivery_id and food_id
 CREATE OR REPLACE FUNCTION get_ids(customer_uid INTEGER, restaurant_id INTEGER, total_order_cost DECIMAL)
 RETURNS TABLE (
    orderid INTEGER,
    deliveryid INTEGER
    ) AS $$
        SELECT D.order_id, D.delivery_id
        FROM Delivery D join FoodOrder FO on FO.order_id = D.order_id
        WHERE FO.uid = customer_uid
        AND FO.rid = restaurant_id
        AND FO.order_cost = total_order_cost
        ORDER BY D.delivery_id DESC
        LIMIT 1;
      $$ LANGUAGE SQL;

 -- 5 most recent Location
 CREATE OR REPLACE FUNCTION most_recent_location(input_customer_id INTEGER)
 RETURNS TABLE (
  recentlocations VARCHAR
 ) AS $$
     SELECT D.location
     FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id
     WHERE FO.uid = input_customer_id
     ORDER BY D.delivery_end_time desc
     LIMIT 5;
 $$ LANGUAGE SQL;

  -- 5 most recent Location
 CREATE OR REPLACE FUNCTION most_recent_location(input_customer_id INTEGER)
 RETURNS TABLE (
  recentlocations VARCHAR
 ) AS $$
     SELECT D.location
     FROM Delivery D join FoodOrder FO on D.order_id = FO.order_id
     WHERE FO.uid = input_customer_id
     ORDER BY D.delivery_end_time desc
     LIMIT 5;
 $$ LANGUAGE SQL;

---- apply delivery promo IF HAVE REWARD POINTS, USE TO OFFSET (USE REWARD BUTTON)
CREATE OR REPLACE FUNCTION apply_delivery_promo(input_customer_id INTEGER, delivery_cost INTEGER)
RETURNS VOID AS $$
declare 
    points_check INTEGER;
begin
    SELECT points
    FROM Customers C 
    WHERE C.uid = input_customer_id
    INTO points_check;

    IF (points_check = 0) THEN 
        RAISE EXCEPTION 'You have no points to be deducted';
    END IF;
    IF (points_check >= delivery_cost) THEN
        UPDATE Customers
        SET points = (points - delivery_cost)
        WHERE uid = input_customer_id;
    ELSIF (points_check < delivery_cost) THEN 
        UPDATE Customers
        SET points = 0
        WHERE uid = input_customer_id;
    END IF;
end
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
    SET quantity = new_quantity
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

------ RESTAURANT STAFF ------

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

CREATE OR REPLACE FUNCTION filter_riders_table_by_month(input_month INTEGER, input_year INTEGER)
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
FROM riders_table() as curr_table
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

CREATE OR REPLACE FUNCTION filter_location_table_by_month(input_month INTEGER, input_year INTEGER, input_location VARCHAR)
RETURNS TABLE (
    delivery_location VARCHAR,
    month INTEGER,
    year INTEGER,
    count BIGINT,
    hour VARCHAR
) AS $$
BEGIN
    IF input_location = 'all' THEN
    RETURN QUERY
    SELECT * 
    FROM location_table() as curr_table
    WHERE curr_table.month = input_month
    AND curr_table.year = input_year;
    ELSE 
    RETURN QUERY
    SELECT * 
    FROM location_table() as curr_table
    WHERE curr_table.month = input_month
    AND curr_table.year = input_year
    AND curr_table.delivery_location = input_location;
    END IF;
END;
$$ LANGUAGE PLPGSQL;
------ FDS MANAGER -------
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

-- for WWS
-- --c)
CREATE OR REPLACE FUNCTION get_weekly_statistics(input_rider_id INTEGER, input_week INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    week INTEGER,
    month INTEGER,
    year INTEGER,
    base_salary DECIMAL, --weekly
    total_commission BIGINT,
    total_num_orders BIGINT,
    total_num_hours_worked BIGINT
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
        SELECT input_week, input_month, input_year, salary_base, (count(D.delivery_end_time) * initial_commission), count(*), SUM(end_hour - start_hour)
        FROM Riders R join Delivery D on D.rider_id = R.rider_id
        join WeeklyWorkSchedule WWS on WWS.rider_id = D.rider_id
        WHERE input_rider_id = D.rider_id
        AND (SELECT EXTRACT('day' from date_trunc('week', D.delivery_end_time) - date_trunc('week', date_trunc('month',  D.delivery_end_time))) / 7 + 1 ) = input_week --take in user do manipulation
        AND (SELECT EXTRACT(MONTH FROM D.delivery_end_time)) = input_month
        AND (SELECT EXTRACT(YEAR FROM D.delivery_end_time)) = input_year
        AND D.ongoing = False
    );
end
$$ LANGUAGE PLPGSQL;

-- -- --d)
-- -- -- get previous monthly salaries  --for month
CREATE OR REPLACE FUNCTION get_monthly_statistics(input_rider_id INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    month INTEGER,
    year INTEGER,
    base_salary DECIMAL, --weekly
    total_commission BIGINT,
    total_num_orders BIGINT,
    total_num_hours_worked BIGINT
) AS $$
    SELECT input_month, input_year, R.base_salary * 4, count(delivery_id) * R.commission, count(*), SUM(end_hour - start_hour)
    FROM Riders R join MonthlyWorkSchedule MWS on R.rider_id = MWS.rider_id
    join Delivery D on D.rider_id = MWS.rider_id
    join WeeklyWorkSchedule WWS on WWS.rider_id = MWS.rider_id
    WHERE input_rider_id = D.rider_id
    AND (SELECT EXTRACT(MONTH FROM D.delivery_end_time)) = input_month
    AND (SELECT EXTRACT(YEAR FROM D.delivery_end_time)) = input_year
    AND D.ongoing = False
    GROUP BY R.rider_id;
$$ LANGUAGE SQL;



--e)
-- Allow Part Time riders to see their weekly work schedule
CREATE OR REPLACE FUNCTION get_WWS(input_rider_id INTEGER, input_week INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    day INTEGER,
    week INTEGER,
    month INTEGER,
    year INTEGER,
    starthour INTEGER,
    endhour INTEGER
) AS $$
    SELECT day, week, month, year, start_hour, end_hour
    FROM WeeklyWorkSchedule WWS
    WHERE WWS.rider_id = input_rider_id
    AND WWS.week = input_week
    AND WWS.month = input_month
    AND WWS.year = input_year;
$$ LANGUAGE SQL;
 
 --f)
 -- Allow FULL TIME RIDERS to see their monthly work schedule
CREATE OR REPLACE FUNCTION get_MWS(input_rider_id INTEGER, input_month INTEGER, input_year INTEGER)
RETURNS TABLE (
    day INTEGER,
    week INTEGER,
    month INTEGER,
    year INTEGER,
    starthour INTEGER,
    endhour INTEGER
) AS $$
    SELECT day, week, month, year, start_hour, end_hour
    FROM WeeklyWorkSchedule WWS
    WHERE WWS.rider_id = input_rider_id
    AND WWS.month = input_month
    AND WWS.year = input_year;
$$ LANGUAGE SQL;



  --g)
  --Update WWS and MWS for full timer
 --Shift 1: 10am to 2pm and 3pm to 7pm.
 --Shift 2: 11am to 3pm and 4pm to 8pm.
 --Shift 3: 12pm to 4pm and 5pm to 9pm.
 --Shift 4: 1pm to 5pm and 6pm to 10pm.
  CREATE OR REPLACE FUNCTION update_fulltime_WWS(riderid INTEGER, WWSyear INTEGER, WWSmonth INTEGER, workingdays INTEGER, day1shift INTEGER, day2shift INTEGER, day3shift INTEGER, day4shift INTEGER, day5shift INTEGER)
  RETURNS VOID AS $$
  DECLARE
    day1 INTEGER;
    day2 INTEGER;
    day3 INTEGER;
    day4 INTEGER;
    day5 INTEGER;
  BEGIN
    IF (workingdays = 1) THEN
      day1 = 1;
      day2 = 2;
      day3 = 3;
      day4 = 4;
      day5 = 5;
    ELSIF (workingdays = 2) THEN
      day1 = 2;
      day2 = 3;
      day3 = 4;
      day4 = 5;
      day5 = 6;
    ELSIF (workingdays = 3) THEN
      day1 = 3;
      day2 = 4;
      day3 = 5;
      day4 = 6;
      day5 = 7;
    ELSIF (workingdays = 4) THEN
      day1 = 4;
      day2 = 5;
      day3 = 6;
      day4 = 7;
      day5 = 1;
    ELSIF (workingdays = 5) THEN
      day1 = 5;
      day2 = 6;
      day3 = 7;
      day4 = 1;
      day5 = 2;
    ELSIF (workingdays = 6) THEN
      day1 = 6;
      day2 = 7;
      day3 = 1;
      day4 = 2;
      day5 = 3;
    ELSE
      day1 = 7;
      day2 = 1;
      day3 = 2;
      day4 = 3;
      day5 = 4;
    END IF;
    IF (day1shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day1, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day1, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day1, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day1, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day1, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day1, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day1, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day1, 4, WWSmonth, WWSyear, 1);
    ELSIF (day1shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day1, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day1, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day1, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day1, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day1, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day1, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day1, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day1, 4, WWSmonth, WWSyear, 2);
    ELSIF (day1shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day1, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day1, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day1, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day1, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day1, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day1, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day1, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day1, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day1, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day1, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day1, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day1, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day1, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day1, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day1, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day1, 4, WWSmonth, WWSyear, 4);
    END IF;
    IF (day2shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day2, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day2, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day2, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day2, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day2, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day2, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day2, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day2, 4, WWSmonth, WWSyear, 1);
    ELSIF (day2shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day2, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day2, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day2, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day2, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day2, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day2, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day2, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day2, 4, WWSmonth, WWSyear, 2);
    ELSIF (day2shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day2, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day2, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day2, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day2, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day2, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day2, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day2, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day2, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day2, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day2, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day2, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day2, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day2, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day2, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day2, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day2, 4, WWSmonth, WWSyear, 4);
    END IF;
    IF (day3shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day3, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day3, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day3, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day3, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day3, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day3, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day3, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day3, 4, WWSmonth, WWSyear, 1);
    ELSIF (day3shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day3, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day3, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day3, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day3, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day3, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day3, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day3, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day3, 4, WWSmonth, WWSyear, 2);
    ELSIF (day3shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day3, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day3, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day3, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day3, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day3, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day3, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day3, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day3, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day3, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day3, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day3, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day3, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day3, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day3, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day3, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day3, 4, WWSmonth, WWSyear, 4);
    END IF;
        IF (day4shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day4, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day4, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day4, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day4, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day4, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day4, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day4, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day4, 4, WWSmonth, WWSyear, 1);
    ELSIF (day4shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day4, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day4, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day4, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day4, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day4, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day4, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day4, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day4, 4, WWSmonth, WWSyear, 2);
    ELSIF (day4shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day4, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day4, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day4, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day4, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day4, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day4, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day4, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day4, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day4, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day4, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day4, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day4, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day4, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day4, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day4, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day4, 4, WWSmonth, WWSyear, 4);
    END IF;
        IF (day5shift = 1) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day5, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day5, 1, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day5, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day5, 2, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day5, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day5, 3, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 10, 14, day5, 4, WWSmonth, WWSyear, 1);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 15, 19, day5, 4, WWSmonth, WWSyear, 1);
    ELSIF (day5shift = 2) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day5, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day5, 1, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day5, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day5, 2, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day5, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day5, 3, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 11, 15, day5, 4, WWSmonth, WWSyear, 2);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 16, 20, day5, 4, WWSmonth, WWSyear, 2);
    ELSIF (day5shift = 3) THEN
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day5, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day5, 1, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day5, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day5, 2, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day5, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day5, 3, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 12, 16, day5, 4, WWSmonth, WWSyear, 3);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 17, 21, day5, 4, WWSmonth, WWSyear, 3);
    ELSE
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day5, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day5, 1, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day5, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day5, 2, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day5, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day5, 3, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 13, 17, day5, 4, WWSmonth, WWSyear, 4);
      INSERT INTO WeeklyWorkSchedule VALUES (DEFAULT, riderid, 18, 22, day5, 4, WWSmonth, WWSyear, 4);
    END IF;

  END
  $$ LANGUAGE PLPGSQL;






-- -- for WWS
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




-- to determine which is the delivery that needs to be found now

-------------- rider delivery process ----------------
-- departing to pick food button
CREATE OR REPLACE FUNCTION update_departure_time(input_rider_id INTEGER, input_delivery_id INTEGER)
RETURNS VOID AS $$
    UPDATE Delivery D SET departure_time = CURRENT_TIMESTAMP, ongoing = TRUE
    WHERE D.rider_id = input_rider_id
    AND D.delivery_id = input_delivery_id;
$$ LANGUAGE SQL;

-- reached restaurant button
CREATE OR REPLACE FUNCTION update_collected_time(input_rider_id INTEGER, input_delivery_id INTEGER)
RETURNS VOID AS $$
    UPDATE Delivery D SET collected_time = CURRENT_TIMESTAMP
    WHERE D.rider_id = input_rider_id
    AND D.delivery_id = input_delivery_id;
$$ LANGUAGE SQL;

-- delivery start-time button
CREATE OR REPLACE FUNCTION update_delivery_start(input_rider_id INTEGER, input_delivery_id INTEGER)
RETURNS VOID AS $$
    UPDATE Delivery D SET delivery_start_time = CURRENT_TIMESTAMP
    WHERE D.rider_id = input_rider_id
    AND D.delivery_id = input_delivery_id;
$$ LANGUAGE SQL;

 --when rider clicks completed button
 --foodorder status change to done
  --change ongoing to false in Delivery
  CREATE OR REPLACE FUNCTION update_done_status(input_rider_id INTEGER, input_delivery_id INTEGER)
  RETURNS VOID AS $$
  BEGIN 
      UPDATE FoodOrder
      SET completion_status = TRUE
      WHERE order_id = ( SELECT D.order_id FROM Delivery D WHERE D.delivery_id = input_delivery_id AND D.rider_id = input_rider_id);
 
      UPDATE Delivery
      SET ongoing = FALSE,
          delivery_end_time = CURRENT_TIMESTAMP,
          time_for_one_delivery = (SELECT EXTRACT(EPOCH FROM (current_timestamp - D.delivery_start_time)) FROM Delivery D WHERE D.delivery_id = input_delivery_id)/60::DECIMAL
      WHERE delivery_id = input_delivery_id
      AND rider_id = input_rider_id;
  END
  $$ LANGUAGE PLPGSQL;

-------------- rider delivery process ----------------



------ RIDERS ------
