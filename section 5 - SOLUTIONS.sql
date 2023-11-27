
use mavenfuzzyfactory;

-- section 5

-- assignment 1 (33)

SELECT 
	 pageview_url,
     COUNT(DISTINCT website_pageview_id) as pvs
FROM  website_pageviews	

WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY pvs DESC;

-- assignment 2 (35)

CREATE TEMPORARY TABLE first_pageview_per_session
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS first_pv -- pv= pageview
FROM  website_pageviews	

WHERE created_at < '2012-06-12'
GROUP BY website_session_id;

SELECT 
	COUNT(DISTINCT first_pageview_per_session.website_session_id) AS sessions,
	website_pageviews.pageview_url AS landing_page
FROM first_pageview_per_session LEFT JOIN  website_pageviews
	ON first_pageview_per_session.first_pv = website_pageviews.website_pageview_id
GROUP BY landing_page;

-- assignment 3 (38)

-- first_pv_per_session טבלה זמנית 1
CREATE TEMPORARY TABLE first_pv_per_session
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS first_pv -- pv= pageview
FROM  website_pageviews	

WHERE created_at < '2012-06-14'
GROUP BY website_session_id;

SELECT * FROM first_pv_per_session; -- QA

-- sessions_w_landing טבלה זמנית 2
CREATE TEMPORARY TABLE sessions_w_landing
SELECT 
	first_pv_per_session.website_session_id,
	website_pageviews.pageview_url
FROM first_pv_per_session LEFT JOIN  website_pageviews
	ON first_pv_per_session.first_pv = website_pageviews.website_pageview_id;
    
SELECT * FROM sessions_w_landing; -- QA

-- bounced_sessions_only טבלה זמנית 3

CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
	sessions_w_landing.website_session_id,
    sessions_w_landing.pageview_url,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = sessions_w_landing.website_session_id	

GROUP BY
	sessions_w_landing.website_session_id,
    sessions_w_landing.pageview_url
 HAVING 
	COUNT(website_pageviews.website_pageview_id) = 1;

SELECT * FROM bounced_sessions_only; -- QA

-- The Query Itself
SELECT 
	sessions_w_landing.pageview_url AS landing_page,
    COUNT(DISTINCT sessions_w_landing.website_session_id) AS sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions_only.website_session_id)/  COUNT(DISTINCT sessions_w_landing.website_session_id) AS bounce_rate
FROM sessions_w_landing LEFT JOIN bounced_sessions_only
	ON bounced_sessions_only.website_session_id = sessions_w_landing.website_session_id	

GROUP BY
    sessions_w_landing.pageview_url;
    
-- assignment 4 (40)

SELECT 
	created_at as first_created_at,
	MIN(website_pageview_id) AS first_pageview
FROM website_pageviews
WHERE pageview_url like '%/lander-1%'
	and created_at < '2012-06-28'
GROUP BY created_at
ORDER BY created_at ASC;

-- first_created_at = 2012-06-19, 00:35:54
-- first_pageview = 23504

-- finding sessions in /lander-1 & /home

CREATE TEMPORARY TABLE firts_test_pageview
SELECT
	website_pageviews.website_session_id,
	MIN(website_pageviews.website_pageview_id) as first_pv_id 
from website_pageviews
INNER JOIN website_sessions
ON website_pageviews.website_session_id = website_sessions.website_session_id
        AND website_sessions.created_at < '2012-07-28'
        AND website_pageviews.website_pageview_id > '23504'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;
        
SELECT * from firts_test_pageview; -- QA


CREATE TEMPORARY TABLE nonbrand_test_sess_w_lp 
-- sess = session\s , lp = landing pge
SELECT
	firts_test_pageview.website_session_id,
    website_pageviews.pageview_url as lp
FROM firts_test_pageview
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = firts_test_pageview.first_pv_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

SELECT * FROM nonbrand_test_sess_w_lp; -- QA 


CREATE TEMPORARY TABLE nonbrand_test_bounced_sess
SELECT
	nonbrand_test_sess_w_lp.website_session_id,
    nonbrand_test_sess_w_lp.lp,
    COUNT(website_pageviews.website_pageview_id) as count_pv -- pv = pageviews

FROM nonbrand_test_sess_w_lp
	LEFT JOIN website_pageviews
		ON nonbrand_test_sess_w_lp.website_session_id = website_pageviews.website_session_id

GROUP BY 	
	nonbrand_test_sess_w_lp.website_session_id,
    nonbrand_test_sess_w_lp.lp
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;

SELECT * FROM nonbrand_test_bounced_sess; -- QA

-- the query 
SELECT 
	nonbrand_test_sess_w_lp.lp,
    COUNT(DISTINCT nonbrand_test_sess_w_lp.website_session_id) AS sessions,
	COUNT(DISTINCT nonbrand_test_bounced_sess.website_session_id) AS bounced_sessions,
	COUNT(DISTINCT nonbrand_test_bounced_sess.website_session_id)/ COUNT(DISTINCT nonbrand_test_sess_w_lp.website_session_id) AS bounce_rate
FROM nonbrand_test_sess_w_lp
	LEFT JOIN nonbrand_test_bounced_sess
		ON nonbrand_test_sess_w_lp.website_session_id = nonbrand_test_bounced_sess.website_session_id
GROUP BY nonbrand_test_sess_w_lp.lp;

-- assignment 5 (42)

CREATE TEMPORARY TABLE week_start_pv_w_sess
SELECT 
	MIN(DATE(website_sessions.created_at)) as week_start,
    website_pageviews.website_session_id AS sessions,
	MIN(website_pageviews.website_pageview_id) as first_pv_id 
from website_pageviews
INNER JOIN website_sessions
ON website_pageviews.website_session_id = website_sessions.website_session_id
	AND website_sessions.created_at BETWEEN '2012-06-01' AND '2012-08-31'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
	    week(website_sessions.created_at),
        year(website_sessions.created_at),
        sessions;  

SELECT * FROM week_start_pv_w_sess; -- QA        
        
CREATE TEMPORARY TABLE nonbrand_week_start_sess_w_lp 
-- sess = session\s , lp = landing page
SELECT 
	week_start_pv_w_sess.week_start,
	week_start_pv_w_sess.sessions,
    website_pageviews.pageview_url AS lp
FROM week_start_pv_w_sess
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = week_start_pv_w_sess.first_pv_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

SELECT * FROM nonbrand_week_start_sess_w_lp; -- QA 


CREATE TEMPORARY TABLE nonbrand_week_start_bounced 
SELECT
	nonbrand_week_start_sess_w_lp.sessions,
    nonbrand_week_start_sess_w_lp.lp,
    COUNT(website_pageviews.website_pageview_id) as count_pv -- pv = pageviews

FROM nonbrand_week_start_sess_w_lp
	LEFT JOIN website_pageviews
		ON nonbrand_week_start_sess_w_lp.sessions = website_pageviews.website_session_id

GROUP BY 	
	nonbrand_week_start_sess_w_lp.sessions,
    nonbrand_week_start_sess_w_lp.lp
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;

SELECT * FROM nonbrand_week_start_bounced; -- QA


-- the query 
SELECT 
    MIN(nonbrand_week_start_sess_w_lp.week_start) AS week_start,
    COUNT(DISTINCT nonbrand_week_start_bounced.sessions) / COUNT(DISTINCT nonbrand_week_start_sess_w_lp.sessions) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN nonbrand_week_start_sess_w_lp.lp LIKE '%/home%' THEN nonbrand_week_start_sess_w_lp.sessions ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN nonbrand_week_start_sess_w_lp.lp LIKE '%/lander-1%' THEN nonbrand_week_start_sess_w_lp.sessions ELSE NULL END) AS lander_sessions
FROM nonbrand_week_start_sess_w_lp 
		LEFT JOIN nonbrand_week_start_bounced
			ON nonbrand_week_start_sess_w_lp.sessions = nonbrand_week_start_bounced.sessions
GROUP BY 
    YEARWEEK(nonbrand_week_start_sess_w_lp.week_start);

-- assignment 6 (45)

SELECT
	website_pageviews.pageview_url,
    website_sessions.website_session_id,
    website_pageviews.created_at AS pv_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
    
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'

WHERE website_pageviews.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart',
		'/shipping', '/billing', '/thank-you-for-your-order')
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at;


-- sub_query
CREATE TEMPORARY TABLE count_of_sess_by_url 
SELECT
    website_session_id,
	MAX(product_page) AS valid_product,
    MAX(mr_fuzzy_page) AS valid_mr_fuzzy,
    MAX(cart_page) AS valid_cart,
    MAX(shipping_page) AS valid_shipping,
    MAX(billing_page) AS valid_billing,
    MAX(thank_you_page) AS valid_thank_you
FROM(
SELECT
	website_pageviews.pageview_url,
    website_sessions.website_session_id,
    website_pageviews.created_at AS pv_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
    
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'

WHERE website_pageviews.pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart',
		'/shipping', '/billing', '/thank-you-for-your-order')
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at) AS cunt_sess_by_url
GROUP BY
	website_session_id;

SELECT * FROM count_of_sess_by_url; -- QA

-- total of sess per url 
SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN valid_product = 1 THEN website_session_id ELSE NULL END) AS sum_product_sess,
    COUNT(DISTINCT CASE WHEN valid_mr_fuzzy = 1 THEN website_session_id ELSE NULL END) AS sum_mr_fuzzy_sess,
    COUNT(DISTINCT CASE WHEN valid_cart = 1 THEN website_session_id ELSE NULL END) AS sum_cart_sess,
    COUNT(DISTINCT CASE WHEN valid_shipping = 1 THEN website_session_id ELSE NULL END) AS sum_shipping_sess,
    COUNT(DISTINCT CASE WHEN valid_billing = 1 THEN website_session_id ELSE NULL END) AS sum_billing_sess,
    COUNT(DISTINCT CASE WHEN valid_thank_you = 1 THEN website_session_id ELSE NULL END) AS sum_thank_you_sess
FROM count_of_sess_by_url;

--  conversion funnel
SELECT 
    COUNT(DISTINCT CASE WHEN valid_product = 1 THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT website_session_id) AS sum_lander_click_rate,
    COUNT(DISTINCT CASE WHEN valid_mr_fuzzy = 1 THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN valid_product = 1 THEN website_session_id ELSE NULL END) AS product_click_rate,
    COUNT(DISTINCT CASE WHEN valid_cart = 1 THEN website_session_id ELSE NULL END) /COUNT(DISTINCT CASE WHEN valid_mr_fuzzy = 1 THEN website_session_id ELSE NULL END) AS mr_fuzzy_click_rate,
    COUNT(DISTINCT CASE WHEN valid_shipping = 1 THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN valid_cart = 1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
    COUNT(DISTINCT CASE WHEN valid_billing = 1 THEN website_session_id ELSE NULL END)/  COUNT(DISTINCT CASE WHEN valid_shipping = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
    COUNT(DISTINCT CASE WHEN valid_thank_you = 1 THEN website_session_id ELSE NULL END)/ COUNT(DISTINCT CASE WHEN valid_billing = 1 THEN website_session_id ELSE NULL END) AS billing_click_rate
FROM count_of_sess_by_url;


-- assignment 7 (47)


SELECT 
	created_at as first_created_at,
	MIN(website_pageview_id) AS first_pageview
FROM website_pageviews
WHERE pageview_url like '%/billing-2%'
	and created_at < '2012-11-10'
GROUP BY created_at
ORDER BY created_at ASC
LIMIT 5;

-- first_created_at = 2012-09-10, 00:13:05
-- first_pageview of '/billing-2' = 53550

-- the sub query - both me & the instructor use ! 
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version,
    orders.order_id
FROM 
	website_pageviews
LEFT JOIN
	orders
ON website_pageviews.website_session_id = orders.website_session_id

WHERE website_pageviews.website_pageview_id >= 53550
    AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing', '/billing-2');

/* -- my solution -- not quite accurate
-- the nested query
CREATE TEMPORARY TABLE  orders_n_billings_vers
SELECT 
	website_session_id,
	CASE WHEN billing_version = '/billing' AND order_id IS NOT NULL THEN 1 ELSE 0 END AS billing_orders,
	CASE WHEN billing_version = '/billing-2' AND order_id IS NOT NULL THEN 1 ELSE 0 END AS billing_2_orders
FROM (
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version,
    orders.order_id
FROM 
	website_pageviews
LEFT JOIN
	orders
ON website_pageviews.website_session_id = orders.website_session_id

WHERE website_pageviews.website_pageview_id >= 53550
    AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing', '/billing-2')) AS billings_n_ord_id;

SELECT * FROM orders_n_billings_vers;

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN billing_orders = 1 THEN website_session_id ELSE NULL END) AS orders_for_billing,
    COUNT(DISTINCT CASE WHEN billing_2_orders = 1 THEN website_session_id ELSE NULL END) AS orders_for_billing_2,
    COUNT(DISTINCT CASE WHEN billing_orders = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS billing_to_order_rate,
	COUNT(DISTINCT CASE WHEN billing_2_orders = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS billing_to_order_rate
FROM orders_n_billings_vers;

*/


-- the right solution of the instructor

SELECT
	 billing_version, 
     COUNT(DISTINCT website_session_id) AS sessions,
     COUNT(DISTINCT order_id) AS orders,
     COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS billing_to_order_rate
FROM (
SELECT
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version,
    orders.order_id
FROM 
	website_pageviews
LEFT JOIN
	orders
ON website_pageviews.website_session_id = orders.website_session_id

WHERE website_pageviews.website_pageview_id >= 53550
    AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing', '/billing-2')) billings_n_ord_id

GROUP BY billing_version;
