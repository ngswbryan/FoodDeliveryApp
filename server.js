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
  pool.query("SELECT * FROM restaurants", (error, results) => {
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
  pool.query("select location_table();", (error, results) => {
    if (error) {
      throw error;
    }
    response.status(200).json(results.rows);
  });
};

const getRiders = (request, response) => {
  pool.query("select location_table();", (error, results) => {
    if (error) {
      throw error;
    }
    response.status(200).json(results.rows);
  });
};

const getCustomers = (request, response) => {
  pool.query("select customers_table();", (error, results) => {
    if (error) {
      throw error;
    }
    response.status(200).json(results.rows);
  });
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


app
  .route("/users")
  // GET endpoint
  .get(getUsers)
  // POST endpoint
  .post(addUser);

app.route("/users/:username").get(getUserByUsername);

app.route("/restaurants").get(getRestaurants);

app.route("/manager").get(getManagerStats);

app.route("/manager/orders").get(getManagerStatsOrder);

app.route("/manager/cost").get(getManagerStatsCost);

app.route("/manager/location").get(getLocation);

app.route("/manager/riders").get(getRiders);

app.route("/manager/customers").get(getCustomers);

// Start server
app.listen(process.env.PORT || 3002, () => {
  console.log(`Server listening`);
});
