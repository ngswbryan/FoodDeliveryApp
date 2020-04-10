--function test for a
-- SELECT new_customers(5, 2018);

--function test for b
-- SELECT total_orders(5, 2018);

--function test for c
-- SELECT total_cost(5, 2018);

--function test for d
-- SELECT customers_table();

--function test for e
-- SELECT filterByMonth(5, 2018);

--function test for 
-- SELECT match_to_uid('jess10');

--function test for f
-- SELECT filter_by_uid('lance');

--function test for g
-- SELECT riders_table(true);

--function test for h
--SELECT location_table();

--customer (a)
--SELECT past_delivery_ratings(1);

--(b)
--SELECT past_food_reviews(1);

--(c)
--SELECT list_of_restaurant();

--(d)
-- SELECT list_of_fooditems(1);

--(e)
SELECT update_order_count(ARRAY[ [1,1],[3,1] ], 1, 2, false, 59.3, 'korea');

--(f)AND R.is_delivering = FALSE
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
