use mavenfuzzyfactory;


SELECT 
	is_repeat_session,
	CASE 
    WHEN COUNT(user_id) = 2 THEN website_session_id 

FROM website_sessions

WHERE created_at BETWEEN '2014-01-01' AND '2014-11-01' 

GROUP BY 1;