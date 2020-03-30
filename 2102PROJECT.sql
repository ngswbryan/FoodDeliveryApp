-- ENTITIES

CREATE TABLE Users (
    uid  SERIAL PRIMARY KEY,
    name VARCHAR(100),
    username VARCHAR(100) UNIQUE,
    password VARCHAR(100),
    user_role VARCHAR(100)
);

CREATE TABLE PartTimeDeliveryRider (
    uid INTEGER REFERENCES Users
        ON DELETE CASCADE,
    weekly_salary FLOAT,
    UNIQUE(uid)
);

CREATE TABLE FullTimeDeliveryRider (
    uid INTEGER REFERENCES Users
        ON DELETE CASCADE,
    monthly_salary FLOAT,
    UNIQUE(uid)
);

CREATE TABLE RestaurantStaff (
    uid INTEGER REFERENCES Users
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

CREATE TABLE Restaurants (
    rid INTEGER PRIMARY KEY,
    rname VARCHAR(100),
    min_order FLOAT,
    unique(rid)
);

CREATE TABLE FoodOrder (
    order_id INTEGER PRIMARY KEY,
    rid INTEGER REFERENCES Restaurants NOT NULL,
    total_price FLOAT NOT NULL,
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
    availability_status INTEGER
);

CREATE TABLE PromotionalCampaign (
    promo_id INTEGER PRIMARY KEY,
    discount INTEGER,
    description VARCHAR(100),
    start_date DATE,
    end_date DATE
);

CREATE TABLE Report (
    uid INTEGER REFERENCES FDSManager,
    report_id INTEGER PRIMARY KEY,
    description VARCHAR(100),
    report_date DATE
);

CREATE TABLE WeeklyWorkSchedule (
    wws_id INTEGER PRIMARY KEY,
    rider_id INTEGER references PartTimeDeliveryRider(uid),
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

CREATE TABLE MonthlyWorkSchedule (
    mws_id INTEGER PRIMARY KEY,
    rider_id INTEGER REFERENCES FullTimeDeliveryRider(uid), 
    firstWWS INTEGER,
    secondWWS INTEGER,
    thirdWWS INTEGER,
    fourthWWS INTEGER 
);



--ENTITIES


--RELATIONSHIPS

-- CREATE TABLE PTFollows (

-- )

-- CREATE TABLE FTFollows (

-- )

CREATE TABLE Orders (
    uid INTEGER REFERENCES Customers(uid) NOT NULL,
    order_id INTEGER REFERENCES FoodOrder(order_id) NOT NULL,
    payment_method INTEGER NOT NULL,
    UNIQUE(order_id)
);

CREATE TABLE Sells (
    rid INTEGER REFERENCES Restaurants(rid) NOT NULL, 
    food_id INTEGER REFERENCES FoodItem(food_id) NOT NULL,
    price FLOAT NOT NULL
);

CREATE TABLE Receives (
    order_id INTEGER REFERENCES FoodOrder(order_id),
    promo_id INTEGER REFERENCES PromotionalCampaign(promo_id)
);

CREATE TABLE Delivery (
    delivery_id INTEGER,
    cost FLOAT,
    delivery_start_time TIME,
    delivery_end_time TIME,
    location VARCHAR(100),
    rating INTEGER, 
    UNIQUE(delivery_id)
);

CREATE TABLE Contain (
    order_id INTEGER REFERENCES FoodOrder(order_id),
    food_id INTEGER REFERENCES FoodItem(food_id)
);

--RELATIONSHIPS



