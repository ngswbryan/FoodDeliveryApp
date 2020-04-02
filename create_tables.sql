-- ENTITIES

CREATE TABLE Users (
    uid SERIAL PRIMARY KEY,
    name VARCHAR(100),
    username VARCHAR(100),
    password VARCHAR(100),
    role_type VARCHAR(100),
    date_joined INTEGER,
    UNIQUE(username)
);

CREATE TABLE Riders (
    rider_id INTEGER REFERENCES Users(uid)
        ON DELETE CASCADE,
    rating FLOAT,
    working INTEGER, --to know if he's free or not
    base_salary FLOAT, --in terms of monthly
    rider_type BOOLEAN, --pt or ft
    UNIQUE(rider_id)
);

CREATE TABLE Restaurants (
    rid INTEGER PRIMARY KEY,
    rname VARCHAR(100),
    min_order FLOAT,
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
    order_id INTEGER PRIMARY KEY,
    rid INTEGER REFERENCES Restaurants NOT NULL,
    total_cost FLOAT NOT NULL,
    order_date DATE,
    date_time TIMESTAMP NOT NULL,
    status VARCHAR(100),
    UNIQUE(order_id)
);

CREATE TABLE FoodItem (
    food_id INTEGER PRIMARY KEY, 
    rid INTEGER REFERENCES Restaurants
        ON DELETE CASCADE,
    cuisine_type VARCHAR(100),
    food_name VARCHAR(100),
    quantity INTEGER,
    overall_rating FLOAT,
    ordered_count INTEGER,
    availability_status BOOLEAN
);

CREATE TABLE PromotionalCampaign (
    promo_id INTEGER PRIMARY KEY,
    discount INTEGER,
    description VARCHAR(100),
    start_date DATE,
    end_date DATE
);

CREATE TABLE WeeklyWorkSchedule (
    wws_id SERIAL PRIMARY KEY,
    rider_id INTEGER references Riders(rider_id),
    start_hour INTEGER,
    end_hour INTEGER,
    day INTEGER,
    week INTEGER,
    month INTEGER
    -- CHECK(end_hour - start_hour <= 4),
    -- CHECK(start_hour <= 22),
    -- CHECK(start_hour >= 10),
    -- CHECK(end_hour <= 22),
    -- CHECK(end_hour >= 10)
);

CREATE TABLE MonthlyWorkSchedule (
    mws_id INTEGER PRIMARY KEY,
    rider_id INTEGER REFERENCES Riders(rider_id), 
    firstWWS INTEGER,
    secondWWS INTEGER,
    thirdWWS INTEGER,
    fourthWWS INTEGER 
);

-- for WWS
CREATE OR REPLACE FUNCTION checkWWS()
  RETURNS trigger AS $$
BEGIN
   IF (NEW.start_hour > 22 OR NEW.start_hour < 10) AND (NEW.end_hour > 22 AND NEW.end_hour < 10) THEN
       RAISE EXCEPTION 'Time interval has to be between 1000 - 2200';
   END IF;
   RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_WWS
  BEFORE UPDATE OF start_hour, end_hour OR INSERT
  ON WeeklyWorkSchedule
  FOR EACH ROW
  EXECUTE PROCEDURE checkWWS();
-- for WWS



--ENTITIES


--RELATIONSHIPS

-- CREATE TABLE PTFollows (

-- )

-- CREATE TABLE FTFollows (

-- )

CREATE TABLE Orders (
    order_id INTEGER REFERENCES FoodOrder(order_id) NOT NULL,
    have_credit_card BOOLEAN,
    PRIMARY KEY(order_id),
    UNIQUE(order_id)
);

CREATE TABLE Sells (
    rid INTEGER REFERENCES Restaurants(rid) NOT NULL, 
    food_id INTEGER REFERENCES FoodItem(food_id) NOT NULL,
    price FLOAT NOT NULL,
    PRIMARY KEY(rid, food_id)
);

CREATE TABLE Receives (
    order_id INTEGER REFERENCES FoodOrder(order_id),
    promo_id INTEGER REFERENCES PromotionalCampaign(promo_id)
);

CREATE TABLE Delivery (
    delivery_id INTEGER,
    order_id INTEGER REFERENCES Orders(order_id),
    uid INTEGER REFERENCES Customers(uid),
    rider_id INTEGER REFERENCES Riders(rider_id),
    cost FLOAT NOT NULL,
    delivery_start_time TIMESTAMP NOT NULL,
    delivery_end_time TIMESTAMP NOT NULL,
    time_for_one_delivery INTEGER,
    location VARCHAR(100),
    delivery_rating INTEGER, 
    food_review varchar(100),
    ongoing BOOLEAN,
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



-- --POPULATING DATA
-- INSERT INTO Restaurants VALUES (1, 'kfc', 5.0);
-- INSERT INTO Restaurants VALUES (2, 'mac', 4.0);

-- INSERT INTO FoodItem VALUES (1, 1, 'asian', 'chicken rice', 20, 1);
-- INSERT INTO FoodItem VALUES (2. 2, 'western', 'pork chop', 15, 1);

-- INSERT INTO PromotionalCampaign values (100, 20, 'this is discount 1', '22-01-2018', '23-02-2018');  



