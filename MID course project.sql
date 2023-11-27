use mavenfuzzyfactory;

-- Q1 

SELECT
	year(website_sessions.created_at),
	month(website_sessions.created_at),
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions, 
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
        AND utm_source = 'gsearch'
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY year(website_sessions.created_at),
		 month(website_sessions.created_at);


-- Q2

SELECT
	year(website_sessions.created_at),
	month(website_sessions.created_at),
	COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_order,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS nonbrand_order
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
        AND website_sessions.utm_source = 'gsearch'
WHERE website_sessions.created_at < '2012-11-27' 
GROUP BY year(website_sessions.created_at),
		 month(website_sessions.created_at);
         
-- Q3

SELECT
	year(website_sessions.created_at) AS yr,
	month(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN device_type LIKE '%desktop%' THEN website_sessions.website_session_id ELSE NULL END) as dtop_sessions,
	COUNT(DISTINCT CASE WHEN device_type LIKE '%desktop%' THEN orders.order_id ELSE NULL END) as dtop_orders,
    COUNT(DISTINCT CASE WHEN device_type LIKE '%mobile%' THEN website_sessions.website_session_id ELSE NULL END) as mob_sessions,
    COUNT(DISTINCT CASE WHEN device_type LIKE '%mobile%' THEN orders.order_id ELSE NULL END) as mob_orders

FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
WHERE website_sessions.created_at < '2012-11-27' 
GROUP BY year(website_sessions.created_at),
		 month(website_sessions.created_at);
         
-- Q4

SELECT DISTINCT
    utm_source,
    utm_campaign,
    http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27';

SELECT
	year(website_sessions.created_at) AS yr,
	month(website_sessions.created_at) AS mo,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS g_search_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS b_search_paid_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id

WHERE website_sessions.created_at < '2012-11-27' 
GROUP BY year(website_sessions.created_at),
		 month(website_sessions.created_at);

-- Q5

SELECT 
	year(website_sessions.created_at) AS yr,
	month(website_sessions.created_at) AS mo,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conversion_rate
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id

WHERE website_sessions.created_at < '2012-11-27' 
GROUP BY year(website_sessions.created_at),
		 month(website_sessions.created_at);
         
-- Q6

SELECT MIN(website_pageview_id) AS first_pv
FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- fisrt pageview: 23504

CREATE TEMPORARY TABLE fisrt_pageview_for_sess
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_id
FROM website_pageviews
INNER JOIN website_sessions
ON website_pageviews.website_session_id = website_sessions.website_session_id
	AND website_sessions.created_at < '2012-07-28'
	AND website_pageviews.website_pageview_id >=23504
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'

GROUP BY website_pageviews.website_session_id;


CREATE TEMPORARY TABLE sess_w_landing
SELECT
	fisrt_pageview_for_sess.website_session_id, 
    website_pageviews.pageview_url AS landing_page
FROM fisrt_pageview_for_sess
	LEFT JOIN website_pageviews
		ON fisrt_pageview_for_sess.min_pv_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');


CREATE TEMPORARY TABLE sess_w_orders
SELECT 
	sess_w_landing.website_session_id, 
    sess_w_landing.landing_page,
    orders.order_id
FROM sess_w_landing
	LEFT JOIN orders
		ON sess_w_landing.website_session_id = orders.website_session_id;


SELECT 
	landing_page,
    COUNT(DISTINCT website_session_id) AS sessions, 
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS conv_rate
FROM sess_w_orders
GROUP BY landing_page;

SELECT
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand' 
	AND pageview_url = '/home'
    AND website_sessions.created_at < '2012-11-27';

-- max website_session_id = 17145

SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
	AND website_session_id> 17145
    AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand';
    
-- sessions_since_test = 22972

-- Q6 

CREATE TEMPORARY TABLE sessions_level_made_it_falgged
SELECT
	website_session_id,
    MAX(homepage) AS saw_homepage,
    MAX(custom_lander) AS saw_custom_lander,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM(
SELECT
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
	CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id

WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at < '2012-07-28'
    AND website_sessions.created_at > '2012-06-19'

ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at
    ) AS pageview_level
GROUP BY website_session_id;
    
    
SELECT 
	CASE 
    WHEN saw_homepage = 1 THEN 'saw_homepage'
    WHEN saw_custom_lander THEN 'saw_custon_lander'
END AS segment,

	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart, 
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM sessions_level_made_it_falgged
GROUP BY 1;
    
    
SELECT 
	CASE 
    WHEN saw_homepage = 1 THEN 'saw_homepage'
    WHEN saw_custom_lander THEN 'saw_custon_lander'
END AS segment,    
    
    COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS lander_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rt,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_click_rt, 
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rt,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM sessions_level_made_it_falgged
GROUP BY 1;    


-- Q8 

SELECT
		billing_version_seen,
        COUNT(DISTINCT website_session_id) AS sessions,
        SUM(price_usd) / COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM (
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id,
    orders.price_usd

FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id

WHERE website_pageviews.created_at > '2012-09-10'
	AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing' ,'/billing-2')
    ) AS billing_pageviews_n_order_data
GROUP BY 1;

SELECT
	COUNT(website_session_id) AS billing_session_past_month
FROM website_pageviews
WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2')
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27'