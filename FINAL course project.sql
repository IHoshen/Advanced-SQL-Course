use mavenfuzzyfactory;
DROP TEMPORARY TABLE IF EXISTS sess_n_first_pageview;

-- Q1

SELECT 
	year(website_sessions.created_at) AS yr,
    quarter(website_sessions.created_at) AS qr, 
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt
    
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2;

-- Even though the first quarter of 2015 is not yet overת
-- we see that the take-off ratio between sessions to orders is still increasing!

-- Q2

SELECT 
	year(website_sessions.created_at) AS yr,
    quarter(website_sessions.created_at) AS qr, 
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt,
    SUM(price_usd) / COUNT(DISTINCT order_id) AS rev_per_order,
    SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
    
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2;

-- Q3

SELECT 
 	year(website_sessions.created_at) AS yr,
    quarter(website_sessions.created_at) AS qr,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END) AS organic_search_orders, 
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END) AS direct_type_in_orders,
    COUNT(DISTINCT CASE  WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) AS branded_search_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN order_id ELSE NULL END) AS Gsearch_nonbrand_orders,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN order_id ELSE NULL END) AS Bsearch_nonbrand_orders
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id

GROUP BY 1,2;

--  Q4

SELECT 
 	year(website_sessions.created_at) AS yr,
    quarter(website_sessions.created_at) AS qr,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_covn_rt, 
	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN order_id ELSE NULL END)
		/ COUNT(DISTINCT  CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_conv_rt,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS branded_search_conv_rt,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS Gsearch_nonbrand_conv_rt,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN order_id ELSE NULL END)
		/ COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' AND utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS Bsearch_nonbrand_conv_rt
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id

GROUP BY 1,2
ORDER BY 1,2;

/* notes of major improvements:
All parameters are on the rise from year to year.
All the parameters make a jump in the index between the 4th quarter of the previous year
and the 1st quarter of the following year.
*/

-- Q5

-- A less convenient view
SELECT 
 	year(created_at) AS yr,
    month(created_at) AS mo,
    product_id AS product_id,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) AS margin
FROM order_items
GROUP BY 1,2,3;


SELECT 
 	year(created_at) AS yr,
    month(created_at) AS mo,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin,

	SUM(CASE WHEN product_id = 1  THEN price_usd ELSE NULL END) AS product_1_revenue, 	
	SUM(CASE WHEN product_id = 2  THEN price_usd ELSE NULL END) AS product_2_revenue,
    SUM(CASE WHEN product_id = 3  THEN price_usd ELSE NULL END) AS product_3_revenue,
    SUM(CASE WHEN product_id = 4  THEN price_usd ELSE NULL END) AS product_4_revenue,
    
    SUM(CASE WHEN product_id = 1  THEN price_usd - cogs_usd ELSE NULL END) AS product_1_margin,
    SUM(CASE WHEN product_id = 2  THEN price_usd - cogs_usd ELSE NULL END) AS product_2_margin,
    SUM(CASE WHEN product_id = 3  THEN price_usd - cogs_usd ELSE NULL END) AS product_3_margin,
    SUM(CASE WHEN product_id = 4  THEN price_usd - cogs_usd ELSE NULL END) AS product_4_margin

FROM order_items
GROUP BY 1,2;

/* notes of major improvements:
A jump on all products in the holiday seasonץ
*/


-- Q6

CREATE TEMPORARY TABLE sess_n_first_pageview
SELECT 
	created_at,
    website_session_id,
    website_pageview_id 
    
FROM website_pageviews
WHERE pageview_url = '/products';

SELECT * FROM sess_n_first_pageview;


SELECT 
	year(sess_n_first_pageview.created_at) AS yr,
    month(sess_n_first_pageview.created_at) AS mo,
	COUNT(DISTINCT sess_n_first_pageview.website_session_id) AS sessions_to_product_page,
	COUNT(DISTINCT website_pageviews.website_session_id) AS click_to_next_pageview,
    COUNT(DISTINCT website_pageviews.website_session_id) 
     / COUNT(DISTINCT sess_n_first_pageview.website_session_id) AS clickthrough_rt,
	COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT sess_n_first_pageview.website_session_id) AS products_to_order_rt
    
FROM sess_n_first_pageview
LEFT JOIN website_pageviews
ON  sess_n_first_pageview.website_session_id = website_pageviews.website_session_id
	AND sess_n_first_pageview.website_pageview_id < website_pageviews.website_pageview_id
LEFT JOIN orders
ON orders.website_session_id  = sess_n_first_pageview.website_session_id	
GROUP BY 1,2;


-- Q8

-- finding max date
SELECT MAX(created_at)
FROM website_sessions;
 -- 2015-03-19 
 
 SELECT
    primary_product_id,
    COUNT(DISTINCT orders.order_id) AS orders,
--    order_items.product_id AS cross_sell_product,
    COUNT(DISTINCT order_items.order_id) AS number_of_cross_sells,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN orders.order_id ELSE NULL END) AS x_sell_p1,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN orders.order_id ELSE NULL END) / 
		COUNT(DISTINCT orders.order_id) AS x_sell_p1_rt,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN orders.order_id ELSE NULL END) AS X_sell_p2,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN orders.order_id ELSE NULL END) / 
		COUNT(DISTINCT orders.order_id) AS x_sell_p2_rt,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN orders.order_id ELSE NULL END) AS X_sell_p3,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN orders.order_id ELSE NULL END) / 
		COUNT(DISTINCT orders.order_id) AS x_sell_p3_rt,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN orders.order_id ELSE NULL END) AS X_sell_p4,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN orders.order_id ELSE NULL END) / 
		COUNT(DISTINCT orders.order_id) AS x_sell_p4_rt
FROM orders
 LEFT JOIN order_items
 ON orders.order_id = order_items.order_id
	AND order_items.is_primary_item = 0
 WHERE orders.created_at > '2014-12-05' 
GROUP BY 1;
 
 



