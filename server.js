const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const { pool } = require("./config");

const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());

var distDir = __dirname + "/dist/";
app.use(express.static(distDir));

const getUsers = (request, response) => {
  pool.query("SELECT * FROM users", (error, results) => {
    if (error) {
      throw error;
    }
    response.status(200).json(results.rows);
  });
};

const getRestaurants = (request, response) => {
  pool.query("select list_of_restaurant()", (error, results) => {
    if (error) {
      throw error;
    }
    response.status(200).json(results.rows);
  });
};

const getManagerStats = (request, response) => {
  const month = request.query.month;
  const year = request.query.year;
  pool.query(
    "select new_customers($1, $2);",
    [month, year],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getManagerStatsOrder = (request, response) => {
  const month = request.query.month;
  const year = request.query.year;
  pool.query(
    "select total_orders($1, $2);",
    [month, year],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getManagerStatsCost = (request, response) => {
  const month = request.query.month;
  const year = request.query.year;
  pool.query("select total_cost($1, $2);", [month, year], (error, results) => {
    if (error) {
      throw error;
    }
    response.status(200).json(results.rows);
  });
};

const getLocation = (request, response) => {
  const month = request.query.month;
  const year = request.query.year;
  const location = request.query.location;
  pool.query(
    "select filter_location_table_by_month($1, $2, $3);",
    [month, year, location],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getRiders = (request, response) => {
  const month = request.query.month;
  const role = request.query.role;
  const year = request.query.year;
  pool.query(
    "select filter_riders_table_by_month($1, $2, $3);",
    [month, year, role],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getCustomers = (request, response) => {
  const month = request.query.month;
  const year = request.query.year;
  pool.query(
    "select filterByMonth($1, $2);",
    [month, year],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getUserByUsername = (request, response) => {
  const username = request.params.username;
  pool.query(
    `SELECT * FROM users where username = '${username}'`,
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getStaffByUsername = (request, response) => {
  const uid = request.params.uid;
  pool.query(
    `SELECT * FROM RestaurantStaff where uid = '${uid}'`,
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getPastDeliveryRating = (request, response) => {
  const uid = request.params.uid;
  console.log(uid);
  pool.query("select past_delivery_ratings($1);", [uid], (error, results) => {
    if (error) {
      throw error;
    }
    response.status(200).json(results.rows);
  });
};

const getPastFoodReviews = (request, response) => {
  const uid = request.params.uid;
  console.log(uid);
  pool.query("select past_food_reviews($1);", [uid], (error, results) => {
    if (error) {
      throw error;
    }
    response.status(200).json(results.rows);
  });
};

const getListOfFoodItem = (request, response) => {
  const rid = request.params.rid;
  console.log(rid);
  pool.query(
    "select * from list_of_fooditems($1);",
    [rid],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const addUser = (request, response) => {
  const {
    name,
    username,
    password,
    user_role,
    rider_type,
    restaurant_name,
  } = request.body;

  pool.query(
    "select create_user($1, $2, $3, $4, $5, $6);",
    [name, username, password, user_role, rider_type, restaurant_name],
    (error) => {
      if (error) {
        throw error;
      }
      response.status(201).json({ status: "success", message: "User added." });
    }
  );
};

const addMenuItem = (request, response) => {
  const {
    name,
    price,
    cuisine_type,
    quantity,
    availability,
    rid,
  } = request.body;

  pool.query(
    "select add_menu_item($1, $2, $3, $4, $5, $6);",
    [name, price, cuisine_type, rid, quantity, availability],
    (error) => {
      if (error) {
        throw error;
      }
      response.status(201).json({ status: "success", message: "food added." });
    }
  );
};

const deleteMenuItem = (request, response) => {
  const fname = request.query.fname;
  const rid = request.query.rid;

  console.log(fname);
  console.log(rid);

  pool.query("select delete_menu_item($1, $2);", [fname, rid], (error) => {
    if (error) {
      throw error;
    }
    response.status(200).json({ status: "success", message: "food deleted." });
  });
};

const getFoodItems = (request, response) => {
  pool.query("SELECT * FROM fooditem", (error, results) => {
    if (error) {
      throw error;
    }
    response.status(200).json(results.rows);
  });
};

app.route("/test").get(getFoodItems);

app
  .route("/users")
  // GET endpoint
  .get(getUsers)
  // POST endpoint
  .post(addUser);

app.route("/users/:username").get(getUserByUsername);

app.route("/staff/:uid").get(getStaffByUsername);

app.route("/staff/menu").post(addMenuItem).patch(deleteMenuItem);

app.route("/restaurants").get(getRestaurants);

app.route("/manager").get(getManagerStats);

app.route("/manager/orders").get(getManagerStatsOrder);

app.route("/manager/cost").get(getManagerStatsCost);

app.route("/manager/location").get(getLocation);

app.route("/manager/riders").get(getRiders);

app.route("/manager/customers").get(getCustomers);

app.route("/users/rating/:uid").get(getPastDeliveryRating);

app.route("/users/reviews/:uid").get(getPastFoodReviews);

app.route("/users/restaurant/:rid").get(getListOfFoodItem);

// Start server
app.listen(process.env.PORT || 3002, () => {
  console.log(`Server listening`);
});
