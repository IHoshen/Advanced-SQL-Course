use mavenfuzzyfactory;

-- assignment 1 (54)

SELECT 
	MIN(DATE(created_at)) as week_start,
	COUNT(DISTINCT CASE WHEN utm_source LIKE '%gsearch%'  THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source LIKE '%bsearch%' THEN website_session_id ELSE NULL END) as bsearch_sessions

FROM website_sessions 

WHERE website_sessions.created_at > '2012-08-22'
	AND website_sessions.created_at < '2012-11-29'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	    week(created_at),
        year(created_at);  
        
-- assignment 2 (56)

SELECT 
    utm_source,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN device_type LIKE '%mobile%' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type LIKE '%mobile%' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS percentage_of_mobile_traffic

FROM website_sessions 

WHERE website_sessions.created_at > '2012-08-22'
	AND website_sessions.created_at < '2012-11-30'
    AND utm_campaign = 'nonbrand'
GROUP BY 
        utm_source;  

-- assignment 3 (58)

SELECT 
	website_sessions.device_type,
    website_sessions.utm_source,
    COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
	COUNT(DISTINCT orders.order_id) AS orderse,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rt
    
FROM website_sessions 
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id

WHERE website_sessions.created_at > '2012-08-22'
	AND website_sessions.created_at < '2012-9-18'
    AND utm_campaign = 'nonbrand'
GROUP BY 
        website_sessions.device_type, website_sessions.utm_source;
        
-- assignment 4 (60)

SELECT 
	MIN(DATE(website_sessions.created_at)) as week_start,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type LIKE '%desktop%' AND website_sessions.utm_source LIKE '%gsearch%' THEN website_sessions.website_session_id ELSE NULL END) AS g_desktop_sess,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type LIKE '%desktop%' AND website_sessions.utm_source LIKE '%bsearch%' THEN website_sessions.website_session_id ELSE NULL END) AS b_desktop_sess,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type LIKE '%desktop%' AND website_sessions.utm_source LIKE '%bsearch%' THEN website_sessions.website_session_id 
    ELSE NULL END) / COUNT(DISTINCT CASE WHEN website_sessions.device_type LIKE '%desktop%' AND website_sessions.utm_source LIKE 
    '%gsearch%' THEN website_sessions.website_session_id ELSE NULL END) AS b_ptc_g_dtop,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type LIKE '%mobile%' AND website_sessions.utm_source LIKE '%gsearch%' THEN website_sessions.website_session_id ELSE NULL END) g_mobile_sess,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type LIKE '%mobile%' AND website_sessions.utm_source LIKE '%bsearch%' THEN website_sessions.website_session_id ELSE NULL END) AS b_mobile_sess,
	COUNT(DISTINCT CASE WHEN website_sessions.device_type LIKE '%mobile%' AND website_sessions.utm_source LIKE '%bsearch%' THEN website_sessions.website_session_id 
    ELSE NULL END) / COUNT(DISTINCT CASE WHEN website_sessions.device_type LIKE '%mobile%' AND website_sessions.utm_source LIKE 
    '%gsearch%' THEN website_sessions.website_session_id ELSE NULL END) AS b_ptc_g_mob

FROM website_sessions 
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id

WHERE website_sessions.created_at > '2012-11-04'
	AND website_sessions.created_at < '2012-12-22'
    AND utm_campaign = 'nonbrand'

GROUP BY 
	    week(website_sessions.created_at),
        year(website_sessions.created_at);
        

-- assignment 5 (63)

/* Finding all unique values in a column
SELECT utm_campaign
FROM website_sessions
GROUP BY utm_campaign;
*/

SELECT
        year(created_at) AS yr,
		month(created_at) AS mo,
        COUNT(DISTINCT CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS nonbrand,
        COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) AS brand,
	    COUNT(DISTINCT CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT 
        CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
        COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) AS direct,
        COUNT(DISTINCT CASE WHEN channel_group = 'direct_type_in' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT 
        CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS direct_pct_of_nonbrand,
	    COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END) AS organic,
        COUNT(DISTINCT CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT 
        CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand
	
FROM(
SELECT
	website_session_id,
    created_at,
    CASE
    WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
    WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
    WHEN utm_campaign = 'brand' THEN 'paid_brand'
    WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
END AS channel_group

FROM website_sessions

WHERE website_sessions.created_at < '2012-12-23' )
AS sessions_w_channel_group

GROUP BY 
	    month(website_sessions.created_at),
        year(website_sessions.created_at);


