-- section 4 

use mavenfuzzyfactory;

-- assignment 1 (20)
select 
utm_source,
utm_campaign,
http_referer,
count(distinct website_session_id) as number_of_sessions
from website_sessions
where created_at < '2012-04-12'
group by 
	utm_source,
	utm_campaign,
	http_referer
order by number_of_sessions DESC;

-- assignment 2 (22)

SELECT
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id),
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS CVR
FROM website_sessions 
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';
    
-- assignment 3 (25)

SELECT 
	MIN(DATE(created_at)) as week_start,
    count(DISTINCT website_session_id) as sessions

FROM website_sessions 

WHERE website_sessions.created_at < '2012-05-10'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	    week(created_at),
        year(created_at);  
        
-- assignment 4 (27)

SELECT
   device_type,
   COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
   COUNT(DISTINCT orders.order_id) as oreders,
   COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS CVR
   -- CVR = conversion rate
FROM website_sessions 
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
group by device_type;

-- assignment 5 (29)

SELECT 
	MIN(DATE(created_at)) as week_start,
    COUNT(DISTINCT website_session_id) as total_sessions,
	COUNT(DISTINCT CASE WHEN device_type LIKE '%desktop%' THEN website_session_id ELSE NULL END) as dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type LIKE '%mobile%' THEN website_session_id ELSE NULL END) as mob_sessions

FROM website_sessions 

WHERE website_sessions.created_at < '2012-06-09'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	    week(created_at),
        year(created_at);  
