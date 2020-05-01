--customer
--(a)
  /**
     * Shows past ratings for the particular customer.
     *
     * @param customer_uid
     * @return orderid
     * @return rating
     * @return location
     */

--SELECT past_delivery_ratings(1);


--(b)
  /**
     * Shows past reviews written by the particular customer.
     *
     * @param customer_uid
     * @return orderid
     * @return restaurant name
     * @return review
     */

--SELECT past_food_reviews(1);

--(c)
  /**
     * List of restaurants
     *
     * @return restaurant_id
     * @return restaurant name
     * @return min order price
     */

--SELECT list_of_restaurant();

--(d)
  /**
     * Show available fooditem.
     *
     * @param restaurant id
     * @return foodname
     * @return price
     * @return cuisine
     * @return overall rating
     * @return availabilty
     */

--SELECT list_of_fooditems(1);

--(e)

--SELECT update_order_count(ARRAY[ [1,1],[3,1] ], 1, 2, false, 59.3, 'korea');

--(f)
--SELECT reward_balance(1);

--(g)
--SELECT rider_name(52);
--SELECT location(52);
--SELECT rider_rating(52);

--(h)
--SELECT update_done_status(5);


--i)
--SELECT delivery_endtime(5);
--SELECT food_review_update('very good', 5);
--SELECT update_delivery_rating(10,5);
