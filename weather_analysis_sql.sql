SELECT * FROM weather.weather_dataset;
SELECT COUNT(*) FROM weather_dataset;

-- 1.Give the count of the minimum number of days for the time when temperature reduced

SELECT COUNT(*) FROM (SELECT Date,Temperature,LAG(Temperature)
OVER(ORDER BY Date) as prev_temp
FROM weather_dataset)t 
WHERE Temperature<prev_temp;

-- 2.Find the temperature as Cold / hot by using the case and avg of values of the given data set

SELECT 
    date,
    AVG(Temperature) AS avg_temp,
    CASE
        WHEN Temperature > 25 THEN 'HOT'
        ELSE 'COLD'
    END AS HOTorCOLD
FROM 
    weather.weather_dataset
GROUP BY 
	date;
    
----


SELECT 
  date,
  AVG(temperature),
  CASE
    WHEN AVG(Temperature) < 25 THEN 'Cold'
    WHEN AVG(Temperature) >= 25 THEN 'Hot'
  END AS Temperature_Category
FROM weather_dataset
group by date ;
    

USE weather;


-- 3.Can you check for all 4 consecutive days when the temperature was below 30 Fahrenheit
-- SELECT Date, Temperature FROM (select date, temperature,sum(case when temperature < 30 then 1 else 0 end )over 
-- (order by date rows between 3 preceding and current row) as below_30_count from weather.weather_dataset) t where below_30_count = 4;

CREATE TEMPORARY TABLE T1 SELECT date, temperature,
		SUM(CASE WHEN temperature < 30 THEN 1 ELSE 0 END )
        OVER (ORDER BY date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW ) AS below_30_count 
  FROM weather.weather_dataset;
  SELECT date,temperature FROM T1 WHERE below_30_count = 4;
  
-- 4.Can you find the maximum number of days for which temperature dropped

 SELECT COUNT(*) FROM (SELECT Date,Temperature,LAG(Temperature)
OVER(ORDER BY Date) as prev_temp
FROM weather_dataset)t 
WHERE Temperature<prev_temp;

SELECT MAX(count_days) FROM (
SELECT t1.date,t1.temperature,
(
SELECT COUNT(*)
FROM weather.weather_dataset t2
WHERE t2.date < t1.date AND t2.Temperature < t1.temperature
) AS count_days 
FROM weather.weather_dataset t1
) AS temp_diff
WHERE Temperature <(
SELECT Temperature FROM weather.weather_dataset t2
WHERE t2.date < temp_diff.date
ORDER BY date DESC
LIMIT 1
);




-- 5. Can you find the average humidity from the dataset
-- ( Note should contain the following clauses group by,order by  , daye

SELECT 
    AVG(avg_humidity) AS avg_of_avg_hum
FROM 
    (SELECT 
        date, AVG(`Average humidity (%)`) AS avg_humidity
     FROM 
         weather.weather_dataset
     GROUP BY date
     ORDER BY date) AS derivedtable;
     
     
     
-- 6.Use the GROUP BY clause on the Date column and make a query to fetch details for average windspeed 
-- ( which is now windspeed done in task 3 )   
  
  
SELECT 
    date, `Average windspeed (mph)` AS avg_wind_speed
FROM 
    weather.weather_dataset
GROUP BY date , `Average windspeed (mph)`
LIMIT 25;    


-- 7.Please add the data in the dataset for 2034 and 2035 as well as forecast predictions for these years 

-- ( NOTE: data consistency and uniformity should be maintained )

-- 8. If the maximum gust speed increases from 55mph , fetch the details for the next 4 days 
SELECT
    *
FROM weather.weather_dataset
WHERE 
   date >= (
       SELECT MIN(date)
       FROM weather.weather_dataset
       WHERE `Maximum gust speed (mph)` >= 55
       )
       AND date <= (
         SELECT MIN(date) + INTERVAL 4 DAY 
         FROM weather.weather_dataset
         WHERE `Maximum gust speed (mph)` >=55
       );
       
       
       
-- 9.Find the number of days when the temperature went below 0 degrees Celsius        

SELECT 
    COUNT(temperature) AS number_of_days 
FROM 
    (SELECT 
        date,temperature
     FROM 
         weather.weather_dataset
     WHERE 
         Temperature < 0) AS temp;
         
         
-- 10. Create another table with a "foreign key" relation with the existing given data set.

ALTER TABLE weather.weather_dataset ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST; 

CREATE TABLE weather.order_or (
    orderid INT NOT NULL,
    ordernumber INT NOT NULL,
    id int,
    PRIMARY KEY (orderid),
    FOREIGN KEY (id) REFERENCES weather.weather_dataset(id)
    );