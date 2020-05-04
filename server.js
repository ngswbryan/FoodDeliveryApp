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
        response.status(400).json({ error: "invalid values" });
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

const getTopFive = (request, response) => {
  const rid = request.query.rid;
  pool.query(
    "SELECT * FROM generate_top_five($1);",
    [rid],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getTotalCost = (request, response) => {
  const rid = request.query.rid;
  const month = request.query.month;
  const year = request.query.year;
  pool.query(
    "SELECT * FROM generate_total_cost_of_orders($1, $2, $3);",
    [month, year, rid],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getTotalOrders = (request, response) => {
  const rid = request.query.rid;
  const month = request.query.month;
  const year = request.query.year;
  pool.query(
    "SELECT * FROM generate_total_num_of_orders($1, $2, $3);",
    [month, year, rid],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const updateFoodItem = (request, response) => {
  const fid = request.params.fid;
  const rid = request.query.rid;
  const { food_name, food_price, quantity, cuisine_type } = request.body;

  console.log(fid);
  console.log(rid);
  console.log(food_price);

  pool.query(
    "select update_food($1, $2, $3, $4, $5, $6);",
    [fid, rid, food_name, quantity, food_price, cuisine_type],
    (error) => {
      if (error) {
        throw error;
      }
      response
        .status(200)
        .json({ status: "success", message: "food updated." });
    }
  );
};

const getCampaigns = (request, response) => {
  const rid = request.params.rid;

  pool.query(
    "SELECT * FROM generate_all_my_promos($1);",
    [rid],
    (error, results) => {
      if (error) {
        throw error;
      }
      response.status(200).json(results.rows);
    }
  );
};

const addCampaign = (request, response) => {
  const rid = request.params.rid;
  const { description, discount, start, end } = request.body;

  pool.query(
    "select add_promo($1, $2, $3, $4, $5);",
    [rid, discount, description, start, end],
    (error) => {
      if (error) {
        throw error;
      }
      response.status(201).json({ status: "success", message: "User added." });
    }
  );
};

const deleteCampaign = (request, response) => {
  const rid = request.params.rid;
  pool.query(
    "DELETE from PromotionalCampaign P where P.promo_id = $1;",
    [rid],
    (error) => {
      if (error) {
        throw error;
      }
      response
        .status(200)
        .json({ status: "success", message: "campaign deleted." });
    }
  );
};

app.route("/test").get(getFoodItems);

app
  .route("/staff/campaigns/:rid")
  .get(getCampaigns)
  .post(addCampaign)
  .delete(deleteCampaign);

app
  .route("/users")
  // GET endpoint
  .get(getUsers)
  // POST endpoint
  .post(addUser);

app.route("/staff/menu/:fid").patch(updateFoodItem);

app.route("/users/:username").get(getUserByUsername);

app.route("/staff/:uid").get(getStaffByUsername);

app.route("/staff/menu").post(addMenuItem).patch(deleteMenuItem);

app.route("/staff/reports/orders").get(getTotalOrders);

app.route("/staff/reports/cost").get(getTotalCost);

app.route("/staff/reports/top").get(getTopFive);

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
