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
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json(results.rows);
  });
};

const getRestaurants = (request, response) => {
  pool.query("select list_of_restaurant()", (error, results) => {
    if (error) {
      response.status(400).json(error.message);
      return;
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
        response.status(400).json(error.message);
        return;
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
        response.status(400).json(error.message);
        return;
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
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json(results.rows);
  });
};

const getLocation = (request, response) => {
  const month = request.query.month;
  const year = request.query.year;
  const location = request.query.location;
  pool.query(
    "select * from filter_location_table_by_month($1, $2, $3);",
    [month, year, location],
    (error, results) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getRiders = (request, response) => {
  const month = request.query.month;
  const year = request.query.year;
  pool.query(
    "select * from filter_riders_table_by_month($1, $2);",
    [month, year],
    (error, results) => {
      if (error) {
        response.status(400).json(error.message);
        return;
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
        response.status(400).json(error.message);
        return;
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
        response.status(400).json(error.message);
        return;
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
        response.status(400).json(error.message);
        return;
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
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json(results.rows);
  });
};

const getPastFoodReviews = (request, response) => {
  const uid = request.params.uid;
  console.log(uid);
  pool.query("select past_food_reviews($1);", [uid], (error, results) => {
    if (error) {
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json(results.rows);
  });
};

const getMostRecentLocation = (request, response) => {
  const uid = request.params.uid;
  pool.query("select most_recent_location($1)", [uid], (error, results) => {
    if (error) {
      response.status(400).json(error.message);
      return;
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
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getRewardBalance = (request, response) => {
  const uid = request.params.uid;
  pool.query("select reward_balance($1);", [uid], (error, results) => {
    if (error) {
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json(results.rows);
  });
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
        response.status(400).json(error.message);
        return;
      }
      response.status(201).json({ status: "success", message: "User added." });
    }
  );
};

const updateOrderCount = (request, response) => {
  const {
    currentorder,
    customer_uid,
    restaurant_id,
    have_credit,
    total_order_cost,
    delivery_location,
    delivery_fee, //discounted
  } = request.body;

  pool.query(
    "select update_order_count($1, $2, $3, $4, $5, $6, $7);",
    [
      currentorder,
      customer_uid,
      restaurant_id,
      have_credit,
      total_order_cost,
      delivery_location,
      delivery_fee,
    ],
    (error) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response
        .status(201)
        .json({ status: "success", message: "updated order count " });
    }
  );
};

const applyDeliveryPromo = (request, response) => {
  const {
    uid,
    delivery_cost, //5
  } = request.body;

  pool.query(
    "select apply_delivery_promo($1, $2)",
    [uid, delivery_cost],
    (error) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response
        .status(201)
        .json({ status: "success", message: " delivery promo applied. " });
    }
  );
};

const activateRiders = (request, response) => {
  pool.query("select activate_riders();", (error) => {
    if (error) {
      response.status(400).json(error.message);
      return;
    }
    response
      .status(201)
      .json({ status: "success", message: "riders activated. " });
  });
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
        response.status(400).json(error.message);
        return;
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
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json({ status: "success", message: "food deleted." });
  });
};

const getFoodItems = (request, response) => {
  pool.query("SELECT * FROM fooditem", (error, results) => {
    if (error) {
      response.status(400).json(error.message);
      return;
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
        response.status(400).json(error.message);
        return;
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
        response.status(400).json(error.message);
        return;
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
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getFoodandDeliveryID = (request, response) => {
  const uid = request.params.uid;
  const rid = request.params.rid;
  const total_order_cost = request.params.total_order_cost;

  pool.query(
    "select * from get_ids($1, $2, $3);",
    [uid, rid, total_order_cost],
    (error, results) => {
      if (error) {
        console.log(error);
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getRiderName = (request, response) => {
  const did = request.params.did;

  pool.query("select * from rider_name($1);", [did], (error, results) => {
    if (error) {
      console.log(error);
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json(results.rows);
  });
};

const getRiderRating = (request, response) => {
  const did = request.params.did;

  pool.query("select * from rider_rating($1);", [did], (error, results) => {
    if (error) {
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json(results.rows);
  });
};

const getDeliveryTimings = (request, response) => {
  const did = request.params.did; 

  pool.query(
    "select * from delivery_timings($1)",
    [did],
    (error, results) => {
      if (error) {
        throw error; 
      }
      response.status(200).json(results.rows);
    }
  )
}

//returns boolean
const checkIfCompleted = (request, response) => {
  const did = request.params.did; 

  pool.query(
    "select * from delivery where delivery.delivery_id = ($1) and delivery.ongoing = FALSE;",
    [did],
    (error, results) => {
      if (error) {
        throw error; 
      }
      response.status(200).json(results.rows);

const getEndTime = (request, response) => {
  const did = request.params.did;

  pool.query("select * from delivery_endtime($1)", [did], (error, results) => {
    if (error) {
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json(results.rows);
  });
};

const foodReviewUpdate = (request, response) => {
  const { foodreview, deliveryid } = request.body;

  pool.query(
    "select food_review_update($1, $2);",
    [foodreview, deliveryid],
    (error) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response
        .status(201)
        .json({ status: "success", message: "updated food review." });
    }
  );
};

const updateDeliveryRating = (request, response) => {
  const { deliveryid, deliveryrating } = request.body;

  pool.query(
    "select update_delivery_rating($1, $2)",
    [deliveryid, deliveryrating],
    (error) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response
        .status(201)
        .json({ status: "success", message: "updated delivery rating." });
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
        response.status(400).json(error.message);
        return;
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
        response.status(400).json(error.message);
        return;
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
        response.status(400).json({ error: "invalid values" });
        return;
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
        response.status(400).json(error.message);
        return;
      }
      response
        .status(200)
        .json({ status: "success", message: "campaign deleted." });
    }
  );
};

const getCurrentJob = (request, response) => {
  const rid = request.params.rid;

  pool.query("SELECT * FROM get_current_job($1);", [rid], (error, results) => {
    if (error) {
      response.status(400).json(error.message);
      return;
    }
    response.status(200).json(results.rows);
  });
};

const getCurrentDelivery = (request, response) => {
  const did = request.params.did;

  pool.query(
    "SELECT * from delivery where delivery_id = $1;",
    [did],
    (error, results) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getWeeklyStats = (request, response) => {
  const rid = request.params.rid;
  const week = request.query.week;
  const month = request.query.month;
  const year = request.query.year;

  pool.query(
    "SELECT * FROM get_weekly_statistics($1, $2, $3, $4);",
    [rid, month, week, year],
    (error, results) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getMonthlyStats = (request, response) => {
  const rid = request.params.rid;
  const month = request.query.month;
  const year = request.query.year;

  pool.query(
    "SELECT * FROM get_monthly_statistics($1, $2, $3);",
    [rid, month, year],
    (error, results) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getWWS = (request, response) => {
  const rid = request.params.rid;
  const week = request.query.week;
  const month = request.query.month;
  const year = request.query.year;

  console.log(rid);
  console.log(week);
  console.log(month);
  console.log(year);

  pool.query(
    "SELECT * FROM get_WWS($1, $2, $3, $4);",
    [rid, week, month, year],
    (error, results) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getMWS = (request, response) => {
  const rid = request.params.rid;
  const month = request.query.month;
  const year = request.query.year;

  pool.query(
    "SELECT * FROM get_MWS($1, $2, $3);",
    [rid, month, year],
    (error, results) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const getRiderType = (request, response) => {
  const rid = request.params.rid;

  pool.query(
    "SELECT R.rider_type FROM Riders R where R.rider_id = $1;",
    [rid],
    (error, results) => {
      if (error) {
        response.status(400).json(error.message);
        return;
      }
      response.status(200).json(results.rows);
    }
  );
};

const updateMWS = (request, response) => {
  const rid = request.params.rid;
  const month = request.query.month;
  const year = request.query.year;
  const { days, shift1, shift2, shift3, shift4, shift5 } = request.body;

  pool.query(
    "select update_fulltime_WWS($1, $2, $3, $4, $5, $6, $7, $8, $9);",
    [rid, year, month, days, shift1, shift2, shift3, shift4, shift5],
    (error) => {
      if (error) {
        response.status(400).json({ error: "invalid values" });
        return;
      }
      response.status(201).json({ status: "success", message: "User added." });
    }
  );
};

const updateWWS = async (request, response) => {
  const { command } = request.body;

  let commandarr = command.split(";");
  try {
    await pool.query("BEGIN");
    for (let i = 0; i < commandarr.length; i++) {
      await pool.query(commandarr[i]);
      console.log("executing queries");
    }
    console.log("done executing queries");
    await pool.query("COMMIT");
    response.status(200).json({ status: "success", message: "food updated." });
  } catch (error) {
    try {
      await pool.query("ROLLBACK");
    } catch (rollbackError) {
      console.log("A rollback error occurred:", rollbackError);
    }
    console.log("An error occurred:", error);
    response.status(400).json({ error: "invalid values" });
    return error;
  } finally {
    return;
  }
};

const updateDeparture = (request, response) => {
  const did = request.query.did;
  const rid = request.query.rid;

  console.log("reached");
  console.log(rid);
  console.log(did);

  pool.query("select update_departure_time($1, $2);", [rid, did], (error) => {
    if (error) {
      response.status(400).json({ error: "invalid values" });
      return;
    }
    response.status(200).json({ status: "success", message: "food updated." });
  });
};

const updateCollected = (request, response) => {
  const did = request.query.did;
  const rid = request.query.rid;

  pool.query("select update_collected_time($1, $2);", [rid, did], (error) => {
    if (error) {
      response.status(400).json({ error: "invalid values" });
      return;
    }
    response.status(200).json({ status: "success", message: "food updated." });
  });
};

const updateDelivery = (request, response) => {
  const did = request.query.did;
  const rid = request.query.rid;

  console.log("reached");

  pool.query("select update_delivery_start($1, $2);", [rid, did], (error) => {
    if (error) {
      response.status(400).json({ error: "invalid values" });
      return;
    }
    response.status(200).json({ status: "success", message: "food updated." });
  });
};

const updateDone = (request, response) => {
  const did = request.query.did;
  const rid = request.query.rid;

  pool.query("select update_done_status($1, $2);", [rid, did], (error) => {
    if (error) {
      response.status(400).json({ error: "invalid values" });
      return;
    }
    response.status(200).json({ status: "success", message: "food updated." });
  });
};

app.route("/test").get(getFoodItems);

app
  .route("/staff/campaigns/:rid")
  .get(getCampaigns)
  .post(addCampaign)
  .delete(deleteCampaign);

app.route("/staff/menu/:fid").patch(updateFoodItem);
app.route("/staff/reports/orders").get(getTotalOrders);
app.route("/staff/reports/cost").get(getTotalCost);
app.route("/staff/reports/top").get(getTopFive);

app.route("/riders/delivery/departure").patch(updateDeparture);

app.route("/riders/delivery/collected").patch(updateCollected);

app.route("/riders/delivery/delivery").patch(updateDelivery);

app.route("/riders/delivery/done").patch(updateDone);

app.route("/riders/job/:rid").get(getCurrentJob);

app.route("/riders/delivery/:did").get(getCurrentDelivery);

app.route("/riders/weeklystats/:rid").get(getWeeklyStats);

app.route("/riders/monthlystats/:rid").get(getMonthlyStats);

app.route("/riders/wws/:rid").get(getWWS);

app.route("/riders/mws/:rid").get(getMWS).post(updateMWS);

app.route("/riders/type/:rid").get(getRiderType);

app.route("/riders/wws/draft").post(updateWWS);

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

app.route("/users/restaurant/order").post(updateOrderCount);

app.route("/users/restaurant/order/activate").post(activateRiders);

app.route("/users/restaurant/order/recent/:uid").get(getMostRecentLocation);

app.route("/users/restaurant/order/rewards/:uid").get(getRewardBalance);

app.route("/users/restaurant/order/promo").post(applyDeliveryPromo);

app
  .route("/users/restaurant/order/:uid/:rid/:total_order_cost")
  .get(getFoodandDeliveryID);

app.route("/users/restaurant/order/ridername/:did").get(getRiderName);

app.route("/users/restaurant/order/riderrating/:did").get(getRiderRating);

app.route("/users/restaurant/order/deliverytimings/:did").get(getDeliveryTimings);

app.route("/users/restaurant/order/endtime/:did").get(getEndTime);

app.route("/users/restaurant/order/foodreviewupdate").post(foodReviewUpdate);

app.route("/users/restaurant/order/deliveryrating").post(updateDeliveryRating);

app.route("/users/restaurant/order/ifcompleted/:did").get(checkIfCompleted);

// Start server
app.listen(process.env.PORT || 3002, () => {
  console.log(`Server listening`);
});
