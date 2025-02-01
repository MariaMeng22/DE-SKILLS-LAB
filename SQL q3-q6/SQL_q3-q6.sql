-- QUESTION 3

SELECT
COUNT(
	CASE WHEN (a.trip_distance <= 1)
	THEN 1
	END) AS "up-to-1-mile",
COUNT(
	CASE WHEN (a.trip_distance >1 and a.trip_distance <=3)
	THEN 1
	END) AS "1-3-mile",
COUNT(
	CASE WHEN (a.trip_distance >3 and a.trip_distance <= 7)
	THEN 1
	END
) AS "3-7-mile",
COUNT(
	CASE WHEN (a.trip_distance >7 and a.trip_distance <=10)
	THEN 1
	END
) AS "7-10-mile",
COUNT(
	CASE WHEN (a.trip_distance >10)
	THEN 1
	END
) AS "over-10-mile"
FROM public.green_data a
WHERE 
CAST(lpep_pickup_datetime AS DATE) >= '2019-10-01'
AND CAST(lpep_pickup_datetime AS DATE) < '2019-11-01'
AND CAST(lpep_dropoff_datetime AS DATE) >= '2019-10-01'
AND CAST(lpep_dropoff_datetime AS DATE) < '2019-11-01'
;

-- QUESTION 1 Alternatively

SELECT
    SUM(CASE 
            WHEN trip_distance <= 1 THEN 1
            ELSE 0
        END) AS "Up to 1 mile",
    SUM(CASE 
            WHEN trip_distance > 1 AND trip_distance <= 3 THEN 1
            ELSE 0
        END) AS "1 to 3 miles",
    SUM(CASE 
            WHEN trip_distance > 3 AND trip_distance <= 7 THEN 1
            ELSE 0
        END) AS "3 to 7 miles",
    SUM(CASE 
            WHEN trip_distance > 7 AND trip_distance <= 10 THEN 1
            ELSE 0
        END) AS "7 to 10 miles",
    SUM(CASE 
            WHEN trip_distance > 10 THEN 1
            ELSE 0
        END) AS "Over 10 miles"
FROM 
    public.greendata
WHERE 
    CAST(lpep_pickup_datetime AS DATE) >= '2019-10-01'
    AND CAST(lpep_pickup_datetime AS DATE) < '2019-11-01'
    AND CAST(lpep_dropoff_datetime AS DATE) >= '2019-10-01'
    AND CAST(lpep_dropoff_datetime AS DATE) < '2019-11-01';
	
--Q3-Answer:
-- +--------------+----------------+
-- | segment      | num_trips      |
-- |--------------+----------------+
-- | Up to 1 mile | 104,802        |
-- | 1~3 miles    | 198,924        |
-- | 3~7 miles    | 109,603        |
-- | 7~10 miles   | 27,678         |
-- | 10+ miles    | 35,189         |

--Q4
SELECT 
    CAST(lpep_pickup_datetime AS DATE) AS pickup_date, 
    MAX(trip_distance) AS longest_trip
FROM 
    green_data
GROUP BY
    CAST(lpep_pickup_datetime AS DATE)    --lpep_pickup_datetime::date
ORDER BY
	longest_trip desc
LIMIT 1
;

--Q4-Answer
-- +-----------------------+----------------+
-- | pickup_date           | longest_trip   |
-- +-----------------------+----------------+
-- | 2019-10-31            | 515.89         |

--Q5
SELECT  
	b."Zone",
    COUNT(a."PULocationID") AS pickup_time
FROM 
    public.green_data a
JOIN
	public.zone b ON a."PULocationID" = b."LocationID"
WHERE
	--SUM(a.total_amount) > 13000
	CAST(a.lpep_pickup_datetime AS DATE) = '2019-10-18'
GROUP BY
    b."Zone"
HAVING SUM(a.total_amount) > 13000
ORDER BY
	pickup_time desc
;
--Q5-Answer:
-- +-----------------------+----------------------+
-- | zone                  | pickup_time          |
-- +-----------------------+----------------------+
-- | East Harlem North     | 1236                 |
-- | East Harlem South     | 1101                 |
-- | Morningside Heights   | 764                  |


--Q6
------if it is compared to max_tip_amount among the individual ride
SELECT 
    b."Zone" as pickup_zone,
    c."Zone" as dropoff_zone,
    MAX(a."tip_amount") AS largest_tip
FROM 
    public.green_data a
JOIN
	public.zone b ON a."PULocationID" = b."LocationID"
JOIN
	public.zone c ON a."DOLocationID" = c."LocationID"
	
WHERE
	CAST(a.lpep_pickup_datetime AS DATE) >= '2019-10-01'
	AND CAST(a.lpep_pickup_datetime AS DATE) < '2019-11-01'
	AND b."Zone" = 'East Harlem North'
GROUP BY
    b."Zone", c."Zone"
ORDER BY largest_tip desc
;

--Q5-Answer:
-- +-------------------+---------------------+------------+
-- | pickup_zone       | dropoff_zone        | largest_tip|
-- |-------------------+---------------------+------------|
-- | East Harlem North | JFK Airport         | 87.3       |



------if it is compared to total_tip_amount for that location
SELECT 
    a."DOLocationID", c."Zone" as dropoff_zone,
    SUM(a."tip_amount") AS largest_sum_tip
FROM 
    public.green_data a
JOIN
	public.zone b ON a."PULocationID" = b."LocationID"
JOIN
	public.zone c ON a."DOLocationID" = c."LocationID"
	
WHERE
	CAST(a.lpep_pickup_datetime AS DATE) >= '2019-10-01'
	AND CAST(a.lpep_pickup_datetime AS DATE) < '2019-11-01'
	AND b."Zone" = 'East Harlem North'
GROUP BY
    a."DOLocationID",c."Zone"
ORDER BY largest_sum_tip desc
;
