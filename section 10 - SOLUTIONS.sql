use mavenfuzzyfactory;
-- DROP TEMPORARY TABLE IF EXISTS new_vs_repeated_channels;



-- ASSIGNMENT 1 (91)

CREATE TEMPORARY TABLE new_n_repeated_sesss
SELECT 
	new_sessions.user_id, 
    new_sessions.website_session_id AS new_sessions,
	website_sessions.website_session_id AS repeated_sessions
    
FROM (

SELECT 
	user_id, 
    website_session_id
    
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-01'
	AND is_repeat_session = 0) AS new_sessions
    
LEFT JOIN website_sessions
ON new_sessions.user_id = website_sessions.user_id
	AND is_repeat_session = 1
    AND new_sessions.website_session_id < website_sessions.website_session_id
    AND created_at BETWEEN '2014-01-01' AND '2014-11-01';


SELECT * FROM new_n_repeated_sesss; -- QA

SELECT 
	count_repeat_sess,
	COUNT(DISTINCT user_id) AS users

FROM (
SELECT 
	user_id,
    COUNT(DISTINCT new_sessions) AS count_new_sess,
    COUNT(DISTINCT repeated_sessions) AS count_repeat_sess

FROM new_n_repeated_sesss

GROUP BY   1) AS COUNTS

GROUP BY   1;

-- ASSIGNMENT 2 (93)

CREATE TEMPORARY TABLE created_at_sessions
SELECT 
	new_sessions.user_id, 
    MIN(new_sessions.website_session_id) AS new_sessions,
    MIN(new_sessions.created_at) AS first_sess_created,
	MIN(website_sessions.website_session_id) AS repeated_sessions,
    MIN(website_sessions.created_at) AS second_sess_created
    
FROM (

SELECT 
	user_id, 
    website_session_id,
    created_at
    
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-03'
	AND is_repeat_session = 0) AS new_sessions
    
LEFT JOIN website_sessions
ON new_sessions.user_id = website_sessions.user_id
	AND is_repeat_session = 1
    AND new_sessions.website_session_id < website_sessions.website_session_id
    AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-03'
GROUP BY 1;

SELECT * FROM created_at_sessions; -- QA 


SELECT 
	AVG(datediff(second_sess_created,first_sess_created)) AS avg_days_first_to_second,
    MIN(datediff(second_sess_created,first_sess_created)) AS min_days_first_to_second,
    MAX(datediff(second_sess_created,first_sess_created)) AS max_days_first_to_second

FROM created_at_sessions;

-- ASSIGNMENT 3 (95)


SELECT 
    CASE 
        WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search' 
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
        WHEN utm_campaign = 'brand' THEN 'paid brand' 
        WHEN utm_campaign = 'nonbrand' THEN 'paid nonbrand'
        WHEN utm_source = 'socialbook' THEN 'paid social'
    END AS marketing_categories,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeated_sessions
FROM website_sessions
WHERE created_at > '2014-01-01' AND created_at < '2014-11-05'
GROUP BY 1;

-- ASSIGNMENT 4 (97)

SELECT 
	is_repeat_session,
    website_sessions.website_session_id
    
FROM website_sessions
WHERE	website_sessions.created_at > '2014-01-01' AND website_sessions.created_at < '2014-01-08';
    
SELECT 
	is_repeat_session,
    COUNT(DISTINCT sess_n_repeat_sess.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) /  COUNT(DISTINCT sess_n_repeat_sess.website_session_id) AS convertion_rate,
	SUM(price_usd) / COUNT(DISTINCT sess_n_repeat_sess.website_session_id) AS rev_per_session
FROM (

SELECT 
	is_repeat_session,
    website_session_id,
    created_at
    
FROM website_sessions
WHERE	website_sessions.created_at > '2014-01-01' AND website_sessions.created_at < '2014-11-08'
 ) AS sess_n_repeat_sess
 
 LEFT JOIN orders
 ON sess_n_repeat_sess.website_session_id = orders.website_session_id
 WHERE	sess_n_repeat_sess.created_at > '2014-01-01' AND sess_n_repeat_sess.created_at < '2014-11-08'
 GROUP BY 1;


SELECT 
	is_repeat_session,
    website_sessions.website_session_id
    
FROM website_sessions
WHERE	website_sessions.created_at > '2014-01-01' AND website_sessions.created_at < '2014-01-08';
   
   
-- the same results but more simple query
SELECT 
	is_repeat_session,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT order_id) /  COUNT(DISTINCT website_sessions.website_session_id) AS convertion_rate,
	SUM(price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
    
FROM website_sessions
 LEFT JOIN orders
 ON website_sessions.website_session_id = orders.website_session_id
 WHERE	website_sessions.created_at > '2014-01-01' AND website_sessions.created_at < '2014-11-08'
 GROUP BY 1;
