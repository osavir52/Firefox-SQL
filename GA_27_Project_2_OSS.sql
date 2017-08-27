SELECT * FROM events limit 1 ;
select * from survey limit 100 ;
select * from users limit 1 ;

--DEMOGRAPHICS
--How many years have dedicated users been using firefox?
SELECT 
    CASE
        WHEN q1='0' THEN '0-3months'
        WHEN q1='1' THEN '3-6months'
        WHEN q1='2' THEN '6months-1year'
        WHEN q1='3' THEN '1-2years'
        WHEN q1='4' THEN '2-3years'
        WHEN q1='5' THEN '3-5years'
        ELSE 'more_than_5years'
    END
    ,COUNT(q1)
FROM survey
WHERE 
    user_id is not null 
    AND q4 = '0'OR q4 = '1'
GROUP BY 1
ORDER BY 2 desc;
--Result: the dedicated user base consists of mainly people who have been using Firefox 3 or more years

--Total users who primarily or exclusively use Firefox
select count(q4) 
from survey 
where q4 = '0' or q4 = '1' ;

select
	100*(sub.work_coding/(sub.work_coding+sub.work_not_coding+sub.school+sub.personal+sub.communication+sub.socializing+sub.entertainment))
	,100*(sub.work_not_coding/(sub.work_coding+sub.work_not_coding+sub.school+sub.personal+sub.communication+sub.socializing+sub.entertainment))
	,100*(sub.school/(sub.work_coding+sub.work_not_coding+sub.school+sub.personal+sub.communication+sub.socializing+sub.entertainment))
	,100*(sub.personal/(sub.work_coding+sub.work_not_coding+sub.school+sub.personal+sub.communication+sub.socializing+sub.entertainment))
	,100*(sub.communication/(sub.work_coding+sub.work_not_coding+sub.school+sub.personal+sub.communication+sub.socializing+sub.entertainment))
	,100*(sub.socializing/(sub.work_coding+sub.work_not_coding+sub.school+sub.personal+sub.communication+sub.socializing+sub.entertainment))
	,100*(sub.entertainment/(sub.work_coding+sub.work_not_coding+sub.school+sub.personal+sub.communication+sub.socializing+sub.entertainment))
from (Select
	case
		when q11 like '%0%' then 'work_coding'
		when q11 like '%1%' then 'work_not_coding'
		when q11 like '%2%' then 'school'
		when q11 like '%3%' then 'personal'
		when q11 like '%4%' then 'communication'
		when q11 like '%5%' then 'socializing'
		when q11 like '%6%' then 'entertainment'
		else 'other'
	end
		,count(q11)
FROM
	survey
WHERE
	(q4 = '0' or q4 = '1') and q11 is not null 
GROUP BY 1
ORDER BY 2 desc) sub 
;

Select
	case
		when q11 like '%0%' then 'work_coding'
		when q11 like '%1%' then 'work_not_coding'
		when q11 like '%2%' then 'school'
		when q11 like '%3%' then 'personal'
		when q11 like '%4%' then 'communication'
		when q11 like '%5%' then 'socializing'
		when q11 like '%6%' then 'entertainment'
		else 'other'
	end
		,count(q11)
		, to_char((count(*) * 100.0
                         / sum(count(*)) OVER ()), 'FM990.00" %"') AS percent
FROM
	survey
WHERE
	(q4 = '0' or q4 = '1') and q11 is not null 
GROUP BY 1
ORDER BY 2 desc

--USAGE
select
	a.user_id
	,a.data1
	,a.data2
from
	events a
left join
	survey b
	on a.user_id=b.user_id
where
	a.event_code = 26
	and (b.q4 = '0' or b.q4 = '1')
group by 1,2,3
limit 100;

select
	user_id
	,data1 as windows
	,data2 as tabs
from
	events a
where
	event_code = 26
	and data2 > 2
group by 1,2,3

select
	distinct user_id
	,left(data1,3)::integer as windows
	,data2::integer as tabs
from
	events
where
	data1 like '%windows%' and data2 is not null
group by 1,2,3
order by 3 desc ;

select count(distinct user_id) from events where data1 like '%windows%' and data2 is not null

select a.windows::numeric from
(select
	case
		when data1 like '%wind%' then translate(data1, 'windows', '')
		else ''
	end as windows
from
	events
where
	data1 is not null) a
limit 10 ;

SELECT 
    user_id
    , substring(data1 FROM '[0-9]+')::numeric windows_numeric
    , data1 as windows_text
    , substring(data2 FROM '[0-9]+')::NUMERIC tabs_numeric
    , data2 as tabs_text
FROM events
WHERE event_code='26'
ORDER BY 2 desc
LIMIT 20;


SELECT 
	user_id
	, SUM(substring(data1 FROM '[0-9]+')::NUMERIC) as total_windows
	, SUM(substring(data2 FROM '[0-9]+')::NUMERIC) as total_tabs
	, (SUM(substring(data2 FROM '[0-9]+')::NUMERIC) / SUM(substring(data1 FROM '[0-9]+')::NUMERIC) )::NUMERIC(6,2) as average_session_tabs_per_window
	,(
		select
			count(*)
		from
			events
		where
			event_code = 2
		group by user_id
		) as browser_shutdowns
	,(
		select
			count(*)
		from
			events
		where
			event_code = 3
		group by user_id
		) as browser_restarts
FROM events
WHERE (event_code='26') AND (substring(data1 FROM '[0-9]+')::NUMERIC>0) 
GROUP BY 1
ORDER BY 4 desc ;







select
	user_id
	,count(*) as browser_shutdowns
from
	events
where
	event_code = 2
group by user_id

DROP TABLE IF EXISTS browser_events;

CREATE TEMP TABLE browser_events as             
SELECT 1000010 as subcustomer_id, '24' as sub_length,'F' as gender UNION ALL
SELECT 1000073 as subcustomer_id, '12' as sub_length,  'F' as gender UNION ALL
SELECT 1000025 as subcustomer_id, '12' as sub_length,'M' as gender UNION ALL
SELECT 1000029 as subcustomer_id, '6' as sub_length, 'M' as gender UNION ALL
SELECT 1000091 as subcustomer_id, 'Expired' as sub_length,'M' as gender UNION ALL    
SELECT 1000123 as subcustomer_id, 'Expired' as sub_length, 'F' as gender;


SELECT 
    a.*
    , b.*
FROM events a
LEFT JOIN survey b
    ON a.user_id=b.user_id --joins two tables
WHERE (a.user_id is not null AND b.user_id is not null) --removes null users
AND (b.q4 = '0' or b.q4 = '1') --primarily firefox users
AND (b.q11 LIKE '%0%' OR b.q11 LIKE '%1%' OR b.q11 LIKE '%2%')  --limits activities to work coding, work non-coding, school (most popular activites)
AND (b.q12 LIKE '%0%')
LIMIT 20;

select
	a.user_id
	,SUM(substring(a.data1 FROM '[0-9]+')::NUMERIC) as total_windows
	,SUM(substring(a.data2 FROM '[0-9]+')::NUMERIC) as total_tabs
	,SUM(substring(a.data2 FROM '[0-9]+')::NUMERIC) / SUM(substring(a.data1 FROM '[0-9]+')::NUMERIC)::NUMERIC as average_session_tabs_per_window
FROM
	events a
left join
	survey b
	on a.user_id=b.user_id
where
	(a.user_id is not null AND b.user_id is not null) --removes null users
AND (b.q4 = '0' or b.q4 = '1') --primarily firefox users
AND (b.q11 LIKE '%0%' OR b.q11 LIKE '%1%' OR b.q11 LIKE '%2%')  --limits activities to work coding, work non-coding, school (most popular activites)
AND (b.q12 LIKE '%0%')
AND (substring(a.data1 FROM '[0-9]+')::NUMERIC <> 0)
AND (substring(a.data2 FROM '[0-9]+')::NUMERIC <> 0)
AND (substring(a.data2 FROM '[0-9]+')::NUMERIC <> 0)
AND (a.event_code='26')
group by 1
order by 4 desc;

\