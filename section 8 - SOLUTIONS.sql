use mavenfuzzyfactory;

-- assignment 1 (66)

SELECT 
	year(website_sessions.created_at) AS yr,
    month(website_sessions.created_at) AS mo,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders

FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id  

WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 
	year(website_sessions.created_at),
    month(website_sessions.created_at);
    
SELECT 
	MIN(DATE(website_sessions.created_at)) as week_start,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders

FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id  

WHERE website_sessions.created_at < '2013-01-01'
GROUP BY 
	yearweek(website_sessions.created_at);
    
-- assignment 2 (68)

SELECT
	DATE(created_at) AS created_at,
    weekday(created_at) AS wkday,
    hour(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3; 


SELECT 
	hr,
	round(AVG(case when wkday = 0 then website_sessions else null end),1) AS mon,
	round(AVG(case when wkday = 1 then website_sessions else null end),1) AS tue,
    round(AVG(case when wkday = 2 then website_sessions else null end),1) AS wed,
    round(AVG(case when wkday = 3 then website_sessions else null end),1) AS thu,
    round(AVG(case when wkday = 4 then website_sessions else null end),1) AS fri,
    round(AVG(case when wkday = 5 then website_sessions else null end),1) AS sat,
    round(AVG(case when wkday = 6 then website_sessions else null end),1) AS sun
FROM ( 
SELECT
	DATE(created_at) AS created_at,
    weekday(created_at) AS wkday,
    hour(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3) AS daily_hr_sess

GROUP BY hr; 
