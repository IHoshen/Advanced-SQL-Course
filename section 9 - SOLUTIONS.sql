-- section 9

use mavenfuzzyfactory;
-- DROP TEMPORARY TABLE IF EXISTS count_of_sess_by_url;

-- assignment 1 (72)

SELECT 
	year(created_at) AS yr,
    month(created_at) AS mo,
    COUNT(DISTINCT order_id) AS num_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
    
FROM orders

WHERE created_at < ' 2013-01-04'
GROUP BY 1,2;

-- assignment 2 (74)


SELECT
	year(website_sessions.created_at) AS yr,
    month(website_sessions.created_at) AS mo,
    COUNT(DISTINCT order_id) AS orders,
	COUNT(DISTINCT order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt,
    SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id) revenue_per_sess,
    COUNT(DISTINCT CASE WHEN primary_product_id = 1 THEN website_sessions.website_session_id ELSE NULL END) AS product_1_orders,
    COUNT(DISTINCT CASE WHEN primary_product_id = 2 THEN website_sessions.website_session_id ELSE NULL END) AS product_2_orders
    
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id 

WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2013-04-01'
GROUP BY 1,2;

-- assignment 3 (77)

CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
    CASE
	WHEN created_at < '2013-01-06' THEN 'pre_product_2'
	WHEN created_at >= '2013-01-06' THEN 'post_product_2'
	ELSE NULL END AS time_period

FROM website_pageviews

WHERE created_at < '2013-04-06' 
	AND created_at > '2012-10-06'
	AND pageview_url = '/products';
    

SELECT * FROM products_pageviews; -- QA

CREATE TEMPORARY TABLE sessions_w_next_pageview
SELECT
	products_pageviews.time_period,
    products_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
    
FROM products_pageviews
LEFT JOIN website_pageviews
ON products_pageviews.website_session_id = website_pageviews.website_session_id
AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
GROUP BY 1,2;

SELECT * FROM sessions_w_next_pageview;

CREATE TEMPORARY TABLE sessions_w_pageview_url
SELECT
	sessions_w_next_pageview.time_period,
    sessions_w_next_pageview.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url

FROM sessions_w_next_pageview
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id = sessions_w_next_pageview.min_next_pageview_id;

SELECT * FROM sessions_w_pageview_url;

SELECT
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_page,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) / 
		COUNT(DISTINCT website_session_id) AS pct_w_next_page,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mr_fuzzy,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN
		website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_to_mr_fuzzy,
	COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_love_bear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN
		website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_to_love_bear
FROM sessions_w_pageview_url
GROUP BY time_period;
	

-- assignment 4 (79)

CREATE TEMPORARY TABLE sessoins_seeing_product_page
SELECT
	website_session_id,
    website_pageview_id,
    pageview_url AS product_page_seen

FROM website_pageviews

WHERE created_at < '2013-04-10'
	AND created_at > '2013-01-06'
    AND pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear');
    
SELECT * FROM sessoins_seeing_product_page; -- QA 


-- finding the url's to build the funnel
SELECT DISTINCT
	website_pageviews.pageview_url

FROM sessoins_seeing_product_page
LEFT JOIN website_pageviews
ON sessoins_seeing_product_page.website_session_id = website_pageviews.website_session_id 
AND sessoins_seeing_product_page.website_pageview_id < website_pageviews.website_pageview_id;


-- subquery
SELECT 
	sessoins_seeing_product_page.website_session_id,
    sessoins_seeing_product_page.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page

FROM sessoins_seeing_product_page
LEFT JOIN website_pageviews
ON sessoins_seeing_product_page.website_session_id = website_pageviews.website_session_id 
AND sessoins_seeing_product_page.website_pageview_id < website_pageviews.website_pageview_id

ORDER BY 
	sessoins_seeing_product_page.website_session_id,
    website_pageviews.created_at;


CREATE TEMPORARY TABLE session_product_level_made_id_flags
SELECT
	website_session_id,
    CASE
    WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
    WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
    END AS product_seen,
	MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
	MAX(billing_page) AS billing_made_it,
    MAX(thank_you_page) AS thank_you_made_it
    
FROM(
SELECT 
	sessoins_seeing_product_page.website_session_id,
    sessoins_seeing_product_page.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page

FROM sessoins_seeing_product_page
LEFT JOIN website_pageviews
ON sessoins_seeing_product_page.website_session_id = website_pageviews.website_session_id 
AND sessoins_seeing_product_page.website_pageview_id < website_pageviews.website_pageview_id

ORDER BY 
	sessoins_seeing_product_page.website_session_id,
    website_pageviews.created_at) 
    AS pageview_level 

GROUP BY website_session_id,
	CASE
    WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
    WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
    END;
    
SELECT * FROM session_product_level_made_id_flags; -- QA
    
-- final output 1
SELECT
	product_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thank_you_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thank_you_page

FROM session_product_level_made_id_flags
GROUP BY product_seen;


-- final output 2 - click rates
SELECT
	product_seen,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id 
		ELSE NULL END) / COUNT(DISTINCT website_session_id) AS product_page_click_rt,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id 
		ELSE NULL END) / COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id 
		ELSE NULL END) AS cart_click_rt, 
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id 
		ELSE NULL END) / COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id 
        ELSE NULL END) AS shipping_click_rt,
	COUNT(DISTINCT CASE WHEN thank_you_made_it = 1 THEN website_session_id 
		ELSE NULL END) / COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id 
		ELSE NULL END) AS billing_click_rt

FROM session_product_level_made_id_flags
GROUP BY product_seen;


-- assignment 5 (82)

CREATE TEMPORARY TABLE time_period_urls
SELECT
	website_session_id,
	website_pageview_id,
    created_at,
    CASE
	WHEN created_at < '2013-09-25' THEN 'A.pre_corss_sell'
	WHEN created_at >= '2013-09-25' THEN 'B.post_corss_sell'
	ELSE NULL END AS time_period

FROM website_pageviews

WHERE created_at > '2013-08-25' 
	AND created_at < '2013-10-25'
    AND pageview_url = '/cart';

SELECT * FROM time_period_urls; -- QA


CREATE TEMPORARY TABLE sess_next_pageview
SELECT
	time_period_urls.time_period,
    time_period_urls.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
    
FROM time_period_urls
LEFT JOIN website_pageviews
ON time_period_urls.website_session_id = website_pageviews.website_session_id
AND website_pageviews.website_pageview_id > time_period_urls.website_pageview_id
GROUP BY 1,2;

SELECT * FROM sess_next_pageview; -- QA 


CREATE TEMPORARY TABLE sess_next_pageview_url
SELECT
	sess_next_pageview.time_period,
    sess_next_pageview.website_session_id,
    website_pageviews.pageview_url AS next_pageview_url

FROM sess_next_pageview
LEFT JOIN website_pageviews
ON website_pageviews.website_pageview_id = sess_next_pageview.min_next_pageview_id;

SELECT * FROM sess_next_pageview_url; -- QA 


CREATE TEMPORARY TABLE sess_n_orders
SELECT
	sess_next_pageview_url.time_period,
    sess_next_pageview_url.website_session_id,
	sess_next_pageview_url.next_pageview_url,
    orders.order_id,
    orders.items_purchased,
    orders.price_usd 
    
FROM sess_next_pageview_url
LEFT JOIN orders
ON orders.website_session_id = sess_next_pageview_url.website_session_id;

SELECT * FROM sess_n_orders; -- QA

SELECT
	time_period,
    COUNT(DISTINCT website_session_id) AS cart_sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS click_throughs,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id 
		ELSE NULL END) / COUNT(DISTINCT website_session_id)AS cart_ctr,
	COUNT(DISTINCT CASE WHEN items_purchased IS NOT NULL THEN website_session_id 
		ELSE NULL END) / COUNT(DISTINCT CASE WHEN order_id IS NOT NULL THEN website_session_id 
		ELSE NULL END) products_per_orders,
    AVG(price_usd) AS aov,
    SUM(price_usd) / COUNT(DISTINCT website_session_id) AS rev_per_cart_sessions
    
FROM sess_n_orders
GROUP BY 1;


-- assignment 6 (84)

SELECT
    CASE
	WHEN  website_sessions.created_at < '2013-12-12' THEN 'A.pre_birthday_bear'
	WHEN  website_sessions.created_at >= '2013-12-12' THEN 'B.post_birthday_bear'
	ELSE NULL END AS time_period,
	
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT orders.order_id) AS orders,
	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt,
	SUM(orders.price_usd) / COUNT(DISTINCT orders.order_id) AS aov, -- average order value 
	SUM(orders.items_purchased) / COUNT(DISTINCT orders.order_id) AS products_per_order,
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
    
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id

WHERE  website_sessions.created_at > '2013-11-12' 
	AND  website_sessions.created_at < '2014-01-12'
GROUP BY 1;



-- assignment 7 (87)

SELECT 
	year(order_items.created_at) AS yr,
	month(order_items.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_orders,
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_item_refunds.order_item_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_refund_rt,
	
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_orders,
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_item_refunds.order_item_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_refund_rt,
	
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_orders,
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_item_refunds.order_item_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p3_refund_rt,
	
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_orders,
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_item_refunds.order_item_id ELSE NULL END) 
		/ COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_refund_rt
        
FROM order_items
LEFT JOIN order_item_refunds
ON order_items.order_item_id = order_item_refunds.order_item_id 

WHERE order_items.created_at BETWEEN '2012-03-01' AND '2014-10-15'
GROUP BY 1,2;







