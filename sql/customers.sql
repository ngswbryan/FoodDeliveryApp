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
