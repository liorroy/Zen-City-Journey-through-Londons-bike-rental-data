-- Zen City's Journey through London's bike rental data


--Data Cleaning & Data Wrangling:


SELECT
*
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
LIMIT 1000;


SELECT
COUNT(*)
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`; --49015


SELECT
COUNT(DISTINCT rental_id)
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`; --49015


SELECT
*
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
LIMIT 1000;


SELECT
COUNT(*)
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`; --795




SELECT
COUNT(DISTINCT id)
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`; --795


--Check if we have duplicate station id's:
SELECT
id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
GROUP BY id
HAVING COUNT(id) > 1; --no


--num of bikes:
SELECT COUNT(DISTINCT bike_id)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`; --11185


--Checking if the values in column duration are correct:
SELECT rental_id
FROM
(
SELECT
rental_id,
duration,
TIMESTAMP_DIFF(end_date, start_date, SECOND) AS calculated_difference
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`)
WHERE duration != calculated_difference; --there are no issues in terms of duration


--Checking if we have invalid rides in terms of station, rides that are in stations which have already been removed:
SELECT *
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
end_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL)
OR
start_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL); --127 invalid rides that must be removed


--Check if we have 2 stations with the same location:
SELECT latitude, longitude, COUNT(*)
FROM
(
SELECT
id, latitude, longitude
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`)
GROUP BY latitude, longitude
HAVING COUNT(*) > 1; --No!




--Handle station names with double spaces:


SELECT
name,
replace (name,'  ',' ')
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE INSTR(name,'  ') > 0 ; --3 stations that should be fixed




--Outliers in terms of ride duration:
-- Assuming outlier values are outside the range of mean +/- 3 standard deviations.
SELECT *
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
duration >=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
+ 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
OR
duration <=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
- 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new` ); --112 outliers


--Check for stations that exists in the rides table but not in the stations table:
SELECT
DISTINCT r.end_station_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
LEFT JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS e
ON r.end_station_id = e.id
WHERE e.id IS NULL; --15 invalid stations


--There are 774 rides that are invalid in terms of invalid ending station:
SELECT rental_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE end_station_id IN
(SELECT
DISTINCT r.end_station_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
LEFT JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS e
ON r.end_station_id = e.id
WHERE e.id IS NULL);


--Check for nulls in new table
SELECT DISTINCT bike_model,end_station_logical_terminal,start_station_logical_terminal,end_station_priority_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new`; -- all this columns are irrelevant


--Check values in column Locked:
SELECT DISTINCT locked
FROM`data-analysis-389112.Project_Google.cycle_stations_pro`; --all stations are unlocked!


--Check for duration miss calculation
SELECT rental_id
FROM
(
SELECT
rental_id,
duration,
TIMESTAMP_DIFF(end_date, start_date, SECOND) AS calculated_difference
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`)
WHERE duration != calculated_difference; --Duration values are valid!


-- Ensure data integrity for the "start_station_id" and"end_station_id" columns?
SELECT COUNT(*) AS missing_station_id_count
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE start_station_id IS NULL OR end_station_id IS NULL; --there are no rows with null values for those columns


--The cte + Staistics:
--Used Inner Join to remove the 15 ending stations that appear in ride table but are missing from the station table (*removed 774)
--Overall removed 1013 rides (We also removed outliers, and the 127 that pass through stations that have already been removed = installed is false or there is a value for the removal date column), we returned - 48002 rides:
WITH table_cleaned AS
(SELECT
rental_id, bike_id, duration AS duration_in_seconds, duration / 60 AS duration_in_minutes,
start_date, EXTRACT(MONTH FROM start_date) start_month, EXTRACT(DAYOFWEEK FROM start_date) start_dayofweek,EXTRACT(HOUR FROM start_date) start_hour, start_station_id, replace (s.name,'  ',' ') starting_name, s.docks_count starting_dock_count,
ST_GEOGPOINT (s.longitude, s.latitude) starting_geo_point,
end_date, EXTRACT(MONTH FROM end_date) end_month, EXTRACT(DAYOFWEEK FROM end_date) end_dayofweek,EXTRACT(HOUR FROM end_date) end_hour, end_station_id, replace (e.name ,'  ',' ')ending_name, e.docks_count ending_dock_count,
ST_GEOGPOINT(e.longitude, e. latitude) ending_geo_point,
ROUND(ST_DISTANCE(ST_GEOGPOINT(s.longitude, s.latitude), ST_GEOGPOINT(e.longitude, e.latitude))) / 1000 AS trip_distance_km
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS s
ON r.start_station_id = s.id
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS e
ON r.end_station_id = e.id
WHERE
rental_id NOT IN (-- remove invalid stations
SELECT rental_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
end_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL)
OR
start_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL))
AND
rental_id NOT IN (-- remove outliers
SELECT rental_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
duration >=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
+ 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
OR
duration <=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
- 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new` )))
SELECT
ROUND(AVG(trip_distance_km),2) as avg_distance_km,
APPROX_QUANTILES(trip_distance_km, 2)[OFFSET(1)] AS median_trip_distance_km,
ROUND(MIN(trip_distance_km),2) as min_distance_km,
ROUND(MAX(trip_distance_km),2) as max_distance_km,
ROUND(AVG(duration_in_minutes),2) as avg_duration_minutes,
APPROX_QUANTILES(duration_in_minutes, 2)[OFFSET(1)] AS median_duration_minutes,
ROUND(MIN(duration_in_minutes),2) as min_duration_minutes,
ROUND(MAX(duration_in_minutes),2) as max_duration_minutes
FROM table_cleaned;

--Basic Statistics to start the presentaion:
WITH table_cleaned AS
(SELECT
rental_id, bike_id, duration AS duration_in_seconds, duration / 60 AS duration_in_minutes,
start_date, EXTRACT(MONTH FROM start_date) start_month, EXTRACT(DAYOFWEEK FROM start_date) start_dayofweek,EXTRACT(HOUR FROM start_date) start_hour, start_station_id, replace (s.name,'  ',' ') starting_name, s.docks_count starting_dock_count,
ST_GEOGPOINT (s.longitude, s.latitude) starting_geo_point,
end_date, EXTRACT(MONTH FROM end_date) end_month, EXTRACT(DAYOFWEEK FROM end_date) end_dayofweek,EXTRACT(HOUR FROM end_date) end_hour, end_station_id, replace (e.name ,'  ',' ')ending_name, e.docks_count ending_dock_count,
ST_GEOGPOINT(e.longitude, e. latitude) ending_geo_point,
ROUND(ST_DISTANCE(ST_GEOGPOINT(s.longitude, s.latitude), ST_GEOGPOINT(e.longitude, e.latitude))) / 1000 AS trip_distance_km
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS s
ON r.start_station_id = s.id
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS e
ON r.end_station_id = e.id
WHERE
rental_id NOT IN (
SELECT rental_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
end_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL)
OR
start_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL))
AND
rental_id NOT IN (
SELECT rental_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
duration >=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
+ 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
OR
duration <=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
- 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new` )))


SELECT
starting_name,
COUNT(*) / 1000 AS total_rides_per_station_in_thousands,
ROUND(AVG(trip_distance_km),2) AS AVG_AIRlength_distance,
ROUND((SUM(trip_distance_km) * 0.249) / 1000, 2) AS total_CO2_saved_by_station_in_ton,
APPROX_QUANTILES(duration_in_minutes, 2)[OFFSET(1)] AS median_duration_minutes
FROM table_cleaned
GROUP BY starting_name
ORDER BY AVG_AIRlength_distance;



--First Question: Does the distance from the center of London have an affect on the utilization of the station?
--London city center location: (latitude and longitude values) https://www.findlatitudeandlongitude.com/l/London+city+centre/5715707/


--First of all, here are all the stations that exist but have had no rides during Q1 of 2021:
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE id NOT IN(
SELECT DISTINCT s.id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro` AS s
JOIN
`data-analysis-389112.Project_Google.cycle_hire_new` AS r
ON s.id = r.start_station_id OR s.id = r.end_station_id);--there are 27 stations that have no usage.



--The average distance from London city center of the 27 stations that have no rides:
SELECT AVG(distance_from_london_center_in_km) AS average_distance_from_london_center_in_km
FROM
(
SELECT *, ST_GEOGPOINT(longitude, latitude) AS geo_point, ROUND(ST_DISTANCE(ST_GEOGPOINT(longitude, latitude), ST_GEOGPOINT(-0.1277, 51.507391))) / 1000 AS distance_from_london_center_in_km
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE id NOT IN(
SELECT DISTINCT s.id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro` AS s
JOIN
`data-analysis-389112.Project_Google.cycle_hire_new` AS r
ON s.id = r.start_station_id OR s.id = r.end_station_id));--5.68 km


--Now, let’s find the average distance from London city center of the top 27 stations (by the number of rides during Q1 2021):
--The subquery: *select the top 27 stations by the num of rides:
SELECT end_station_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
GROUP BY end_station_id
ORDER BY COUNT(*) DESC
LIMIT 28)
--The query:
SELECT AVG(distance_from_london_center_in_km) AS average_distance_from_london_center_in_km
FROM
(
SELECT *, ST_GEOGPOINT(longitude, latitude) AS geo_point, ROUND(ST_DISTANCE(ST_GEOGPOINT(longitude, latitude), ST_GEOGPOINT(-0.1277, 51.507391))) / 1000 AS distance_from_london_center_in_km
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE id IN(
SELECT end_station_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
GROUP BY end_station_id
ORDER BY COUNT(*) DESC
LIMIT 28)); --2.35 km


--Next, we visualized our results using BigQuery Geo Viz: a web tool for visualization of geospatial data in BigQuery using Google Maps APIs.
https://cloud.google.com/bigquery/docs/geospatial-get-started


--For GeoViz:
--For each of the 54 (27 worst + 27 best) stations, we will return it id, name, geopoint and distance from the center of London
*Using UNION ALL i've also added the Center of London as a point
*I couldn’t use the CTE for this query because we're also checking for the 27 worst station’s without any rides, which means they won’t show up (i’m using inner JOIN and not an OUTER (left / right) JOIN:
SELECT id, name, ST_GEOGPOINT(longitude, latitude) AS geo_point, ROUND(ST_DISTANCE(ST_GEOGPOINT(longitude, latitude), ST_GEOGPOINT(-0.1277, 51.507391))) / 1000 AS distance_from_london_center_in_km, "Top 27 Stations" AS type
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE id IN(
SELECT end_station_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
GROUP BY end_station_id
ORDER BY COUNT(*) DESC
LIMIT 28)


UNION ALL


SELECT id, name, ST_GEOGPOINT(longitude, latitude) AS geo_point, ROUND(ST_DISTANCE(ST_GEOGPOINT(longitude, latitude), ST_GEOGPOINT(-0.1277, 51.507391))) / 1000 AS distance_from_london_center_in_km, "The 27 empty stations" AS type
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE id NOT IN(
SELECT DISTINCT s.id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro` AS s
JOIN
`data-analysis-389112.Project_Google.cycle_hire_new` AS r
ON s.id = r.start_station_id OR s.id = r.end_station_id)


UNION ALL


SELECT 0, "London city center", ST_GEOGPOINT(-0.1277, 51.507391) AS geo_point, ROUND(ST_DISTANCE(ST_GEOGPOINT(-0.1277, 51.507391), ST_GEOGPOINT(-0.1277, 51.507391))) / 1000 AS distance_from_london_center_in_km, "London city center";

  --Second Question: Find the best and worst Starting stations in terms of average amount of daily rides, the average duration of those rides, and the dock count of each station(Multivariate)
--Using our findings we are able to find the differences in utilization between each of the 6 starting stations:
WITH table_cleaned AS
(SELECT
rental_id, bike_id, duration AS duration_in_seconds, duration / 60 AS duration_in_minutes,
start_date, EXTRACT(MONTH FROM start_date) start_month, EXTRACT(DAYOFWEEK FROM start_date) start_dayofweek,EXTRACT(HOUR FROM start_date) start_hour, start_station_id, replace (s.name,'  ',' ') starting_name, s.docks_count starting_dock_count,
ST_GEOGPOINT (s.longitude, s.latitude) starting_geo_point,
end_date, EXTRACT(MONTH FROM end_date) end_month, EXTRACT(DAYOFWEEK FROM end_date) end_dayofweek,EXTRACT(HOUR FROM end_date) end_hour, end_station_id, replace (e.name ,'  ',' ')ending_name, e.docks_count ending_dock_count,
ST_GEOGPOINT(e.longitude, e. latitude) ending_geo_point,
ROUND(ST_DISTANCE(ST_GEOGPOINT(s.longitude, s.latitude), ST_GEOGPOINT(e.longitude, e.latitude))) / 1000 AS trip_distance_km
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS s
ON r.start_station_id = s.id
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS e
ON r.end_station_id = e.id
WHERE
rental_id NOT IN (
SELECT rental_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
end_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL)
OR
start_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL))
AND
rental_id NOT IN (
SELECT rental_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
duration >=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
+ 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
OR
duration <=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
- 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new` )))
,
--another CTE to get the geoPoint for each starting station:
geo_for_each_starting_station AS
(SELECT
start_station_id,
ST_GEOGPOINT (MAX(s.longitude), MAX(s.latitude)) starting_geo_point,
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS s
ON r.start_station_id = s.id
GROUP BY start_station_id
)
SELECT the_table.*, starting_geo_point
FROM
(
SELECT
start_station_id,
starting_name,
ROUND(AVG(SUM_daily_rides_minutes_per_station) / AVG(count_rides),2) AS AVG_ride_duration_per_ride_daily_minutes, --the calculation is = the average total duration per each day / the average number of rides per each day
ROUND(AVG(count_rides),2) AS AVG_daily_ride, --the average daily number of rides
MAX(docks_count) AS dock_count --because were using GROUP BY we must aggregate, MAX has no effect because the value for docks_count will be the same for each row with this station id
FROM(
SELECT
table_cleaned.start_station_id,
starting_name,
SUM(duration_in_minutes) AS SUM_daily_rides_minutes_per_station,
starting_dock_count AS docks_count,
EXTRACT(DAY FROM start_date) DAY_start,
EXTRACT(MONTH FROM start_date) MONTH_start,
COUNT(*) AS count_rides
FROM table_cleaned
GROUP BY start_station_id,starting_name,DAY_start,MONTH_start, docks_count --Group by each starting station and day -> we want to calculate daily values
ORDER BY start_station_id,MONTH_start,DAY_start DESC)
GROUP BY start_station_id,starting_name --Group by each starting station
) AS the_table
JOIN geo_for_each_starting_station --So we can get the GeoPoint for each starting station (each row)
ON the_table.start_station_id = geo_for_each_starting_station.start_station_id;





--Third Question: Analyze rental patterns by day of the week and hour
--The first query will return the total number of rides for each day of the week and time of day:
WITH table_cleaned AS
(SELECT
rental_id, bike_id, duration AS duration_in_seconds, duration / 60 AS duration_in_minutes,
start_date, EXTRACT(MONTH FROM start_date) start_month, EXTRACT(DAYOFWEEK FROM start_date) start_dayofweek,EXTRACT(HOUR FROM start_date) start_hour, start_station_id, replace (s.name,'  ',' ') starting_name, s.docks_count starting_dock_count,
ST_GEOGPOINT (s.longitude, s.latitude) starting_geo_point,
end_date, EXTRACT(MONTH FROM end_date) end_month, EXTRACT(DAYOFWEEK FROM end_date) end_dayofweek,EXTRACT(HOUR FROM end_date) end_hour, end_station_id, replace (e.name ,'  ',' ')ending_name, e.docks_count ending_dock_count,
ST_GEOGPOINT(e.longitude, e. latitude) ending_geo_point,
ROUND(ST_DISTANCE(ST_GEOGPOINT(s.longitude, s.latitude), ST_GEOGPOINT(e.longitude, e.latitude))) / 1000 AS trip_distance_km
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS s
ON r.start_station_id = s.id
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS e
ON r.end_station_id = e.id
WHERE
rental_id NOT IN (
SELECT rental_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
end_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL)
OR
start_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL))
AND
rental_id NOT IN (
SELECT rental_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
duration >=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
+ 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
OR
duration <=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
- 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new` )))


SELECT
start_dayofweek, --+1 beacuse the date value is in UTC, and London is one hour ahead:
COUNT(CASE WHEN start_hour+1 IN (6,7,8,9,10,11,12) THEN 1 END) AS Morning,
COUNT(CASE WHEN start_hour+1 IN (13,14,15,16,17,18) THEN 1 END) AS Afternoon,
COUNT(CASE WHEN start_hour+1 IN (19,20,21,22) THEN 1 END) AS Evening,
COUNT(CASE WHEN start_hour+1 IN (23,0,1,2,3,4,5) THEN 1 END) AS Night
FROM --Morning - 6 to 12 am, Afternoon - 1 to 6 pm, Evening - 7 to 10 pm, night - 11 pm to 5 am
table_cleaned
GROUP BY start_dayofweek
ORDER BY start_dayofweek;

--The second query will return the average ride duration in minutes for each day of the week and time of day:
WITH table_cleaned AS
(SELECT
rental_id, bike_id, duration AS duration_in_seconds, duration / 60 AS duration_in_minutes,
start_date, EXTRACT(MONTH FROM start_date) start_month, EXTRACT(DAYOFWEEK FROM start_date) start_dayofweek,EXTRACT(HOUR FROM start_date) start_hour, start_station_id, replace (s.name,'  ',' ') starting_name, s.docks_count starting_dock_count,
ST_GEOGPOINT (s.longitude, s.latitude) starting_geo_point,
end_date, EXTRACT(MONTH FROM end_date) end_month, EXTRACT(DAYOFWEEK FROM end_date) end_dayofweek,EXTRACT(HOUR FROM end_date) end_hour, end_station_id, replace (e.name ,'  ',' ')ending_name, e.docks_count ending_dock_count,
ST_GEOGPOINT(e.longitude, e. latitude) ending_geo_point,
ROUND(ST_DISTANCE(ST_GEOGPOINT(s.longitude, s.latitude), ST_GEOGPOINT(e.longitude, e.latitude))) / 1000 AS trip_distance_km
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS s
ON r.start_station_id = s.id
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS e
ON r.end_station_id = e.id
WHERE
rental_id NOT IN (
SELECT rental_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
end_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL)
OR
start_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL))
AND
rental_id NOT IN (
SELECT rental_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
duration >=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
+ 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
OR
duration <=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
- 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new` )))


SELECT
start_dayofweek, --+1 beacuse the date value is in UTC, and London is one hour ahead:
ROUND(AVG(CASE WHEN start_hour+1 IN (6,7,8,9,10,11,12) THEN duration_in_minutes END),2) AS Morning,
ROUND(AVG(CASE WHEN start_hour+1 IN (13,14,15,16,17,18) THEN duration_in_minutes END),2) AS Afternoon,
ROUND(AVG(CASE WHEN start_hour+1 IN (19,20,21,22) THEN duration_in_minutes END),2) AS Evening,
ROUND(AVG(CASE WHEN start_hour+1 IN (23,0,1,2,3,4,5) THEN duration_in_minutes END),2) AS Night,
--Morning - 6 to 12 am, Afternoon - 1 to 6 pm, Evening - 7 to 10 pm, night - 11 pm to 5 am
FROM
table_cleaned
GROUP BY start_dayofweek
ORDER BY start_dayofweek;



--Prediction: Predict how many rentals will be made in the next month (April 2021) in “Albert Gate, Hyde Park” bike station.
--Albert Gate, Hyde Park - ID: 303
--For station - Albert Gate, Hyde Park, return the number of rides per each day in Q1 2021:
WITH table_cleaned AS
(SELECT
rental_id, bike_id, duration AS duration_in_seconds, duration / 60 AS duration_in_minutes,
start_date, EXTRACT(MONTH FROM start_date) start_month, EXTRACT(DAYOFWEEK FROM start_date) start_dayofweek,EXTRACT(HOUR FROM start_date) start_hour, start_station_id, replace (s.name,' ',' ') starting_name, s.docks_count starting_dock_count,
ST_GEOGPOINT (s.longitude, s.latitude) starting_geo_point,
end_date, EXTRACT(MONTH FROM end_date) end_month, EXTRACT(DAYOFWEEK FROM end_date) end_dayofweek,EXTRACT(HOUR FROM end_date) end_hour, end_station_id, replace (e.name ,' ',' ') ending_name, e.docks_count ending_dock_count,
ST_GEOGPOINT(e.longitude, e. latitude) ending_geo_point,
ROUND(ST_DISTANCE(ST_GEOGPOINT(s.longitude, s.latitude), ST_GEOGPOINT(e.longitude, e.latitude))) / 1000 AS trip_distance_km
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS s
ON r.start_station_id = s.id
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS e
ON r.end_station_id = e.id
WHERE
rental_id NOT IN (
SELECT rental_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
end_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL)
OR
start_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL))
AND
rental_id NOT IN (
SELECT rental_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
duration >=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
+ 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
OR
duration <=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
- 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new` )))
SELECT
EXTRACT(DATE FROM start_date) AS day, COUNT(*) AS num_of_rides
FROM
table_cleaned
WHERE start_station_id IN(
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE name LIKE '%Albert Gate, Hyde Park%')
GROUP BY day
ORDER BY day;

--Query for the number of rides in the staion for each month:
WITH table_cleaned AS
(SELECT
rental_id, bike_id, duration AS duration_in_seconds, duration / 60 AS duration_in_minutes,
start_date, EXTRACT(MONTH FROM start_date) start_month, EXTRACT(DAYOFWEEK FROM start_date) start_dayofweek,EXTRACT(HOUR FROM start_date) start_hour, start_station_id, s.name starting_name, s.docks_count starting_dock_count,
ST_GEOGPOINT (s.longitude, s.latitude) starting_geo_point,
end_date, EXTRACT(MONTH FROM end_date) end_month, EXTRACT(DAYOFWEEK FROM end_date) end_dayofweek,EXTRACT(HOUR FROM end_date) end_hour, end_station_id, e.name ending_name, e.docks_count ending_dock_count,
ST_GEOGPOINT(e.longitude, e. latitude) ending_geo_point,
ROUND(ST_DISTANCE(ST_GEOGPOINT(s.longitude, s.latitude), ST_GEOGPOINT(e.longitude, e.latitude))) / 1000 AS trip_distance_km
FROM `data-analysis-389112.Project_Google.cycle_hire_new` AS r
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS s
ON r.start_station_id = s.id
JOIN `data-analysis-389112.Project_Google.cycle_stations_pro` AS e
ON r.end_station_id = e.id
WHERE
rental_id NOT IN (
SELECT rental_id
FROM
`data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
end_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL)
OR
start_station_id IN (
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE installed = false OR removal_date IS NOT NULL))
AND
rental_id NOT IN (
SELECT rental_id
FROM `data-analysis-389112.Project_Google.cycle_hire_new`
WHERE
duration >=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
+ 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
OR
duration <=
(SELECT
AVG(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new`)
- 3 * (SELECT STDDEV(duration)
FROM `data-analysis-389112.Project_Google.cycle_hire_new` )))
SELECT
start_month, COUNT(*) AS num_of_rides
FROM
table_cleaned
WHERE start_station_id IN(
SELECT id
FROM
`data-analysis-389112.Project_Google.cycle_stations_pro`
WHERE name LIKE '%Albert Gate, Hyde Park%')
GROUP BY start_month
ORDER BY start_month;


--We will move this table to sheets, and download is as an excel file so we could load it into gretl - a statistical package able to run a linear regression (ordinary least squares (OLS) model): 
The equation: num_of_rides = α + β1 * time + β2 * time ^ 2

now, we use of model to predict - forecast the next 30 days: the month of April 2020:

(with a significance level of α = 0.01 -> 1-α = 99%)

now, all that’s left is to sum the predicted values of April 2021 and we’ll receive an answer: 8,836 rides during April 2021!



