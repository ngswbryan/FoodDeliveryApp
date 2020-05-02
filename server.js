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

// Start server
app.listen(process.env.PORT || 3002, () => {
  console.log(`Server listening`);
});
