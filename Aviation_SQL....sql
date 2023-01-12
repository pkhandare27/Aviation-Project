
SET SQL_SAFE_UPDATES = 0;

CREATE TABLE DATA_1 (
	FlightDate DATE,
    DayOfWeek INT,
    AirlineID INT,
    TailNum VARCHAR(15),
    OriginCityName VARCHAR(50),
    DestCityName VARCHAR(50),
    DepDel15 INT);
    
    SELECT * FROM project.data_1;
    
Show variables like "local_infile";

Set global local_infile = 1;

SHOW VARIABLES LIKE "secure_file_priv";

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Req_data1.csv"
into table data_1
fields terminated by ','
ENCLOSED by '"'
 LINES TERMINATED by '\n'
ignore 1 rows;


CREATE TABLE DATA_2 (
    AirlineID INT,
    TailNum VARCHAR(15),
    Cancelled INT,
    Diverted INT,
    AirTime INT,
    Distance INT);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Req_data2.csv"
into table data_2
fields terminated by ','
ENCLOSED by '"'
 LINES TERMINATED by '\n'
ignore 1 rows;

-- -----------------------------------------------------------------------------------------------------------------------------------------------

SELECT FlightDate ,DayOfWeek, 
      CASE WHEN DayOfWeek = "1" then "Monday" 
       WHEN DayofWeek = "2" then "Tuesday"
	   WHEN DayofWeek = "3" then "Wednesday"
		WHEN DayofWeek = "4" then "Thursday"
		WHEN DayofWeek = "5" then "Friday"
		WHEN DayofWeek = "6" then "Saturday"
        else  "Sunday"
        end as day_name 
		from data_1;

    SELECT * FROM project.data_1;
    
  -- ------------   Add column Day_name ------------
  
alter table data_1 add column day_name VARCHAR (10) as (
CASE WHEN DayOfWeek = "1" then "Monday" 
       WHEN DayofWeek = "2" then "Tuesday"
	   WHEN DayofWeek = "3" then "Wednesday"
		WHEN DayofWeek = "4" then "Thursday"
		WHEN DayofWeek = "5" then "Friday"
		WHEN DayofWeek = "6" then "Saturday"
        else  "Sunday"
		end)
        ;
        
-- ------------   Add column WEEKDAY_WEEKEND ------------

alter table data_1 add column WEEKDAY_WEEKEND VARCHAR (10) as(
CASE WHEN day_name = "Monday" then "Weekday"
WHEN day_name = "Tuesday" then "Weekday"
WHEN day_name = "Wednesday" then "Weekday"
WHEN day_name = "Thursday" then "Weekday"
WHEN day_name = "Friday" then "Weekday"
else "Weekend" 
end
);

-- -------------------------------------- KPI- 1  Weekday Vs Weekend total flights -------------------------------------
-- ---------Count of total Weekday Flights
SELECT COUNT(*) AS 'total_weekday'
from data_1
where WEEKDAY_WEEKEND = "Weekday";

-- --------Count of total Weekend Flights
SELECT COUNT(*) AS 'total_weekend'
from data_1
where WEEKDAY_WEEKEND = "Weekend";

-- ---------------------------- KPI-2 Number of cancelled flights for Honolulu, HI (OriginCityName) ----------------------------


SELECT OriginCityName , DepDel15,
count(*) 
from data_1
WHERE OriginCityName LIKE "Honolulu, HI"
group by DepDel15 
HAVING DepDel15 ='1';


-- -------------- KPI-3 Week wise statistics of arrival of flights from Manchester and departure of flights to Manchester   ---------

-- we create Date_ column here (which having only day from the date)
 alter table data_1 add column Date_ INT as (
 extract(DAY FROM FlightDate)
 );
 
 -- We create here Week_no column which having Week number based on date ie. Week-1,Week-2.....
 alter table data_1 add column Week_no VARCHAR (10) as (
CASE WHEN Date_ < "8"   then "Week-1" 
       WHEN Date_ < "15"   then "Week-2"
	   WHEN  Date_ < "22"   then "Week-3"
		WHEN  Date_ <   "29"   then "Week-4"
        else  "Week-5"
		end)
        ;
        
SELECT * FROM project.data_1;

select Week_no, OriginCityName,
count(*)
from data_1
Where OriginCityName LIKE "Manchester, NH" 
group by Week_no;

select Week_no, DestCityName,
count(*)
from data_1
Where DestCityName LIKE "Manchester, NH" 
group by Week_no;


-- ---------------------------- KPI-4 Total distance covered by N190AA on 20th January with AirTime as 50 ------------------------

Select data_2.TailNum, data_1.FlightDate, data_2.AirTime, data_2.Distance 
from data_1 INNER JOIN data_2
on data_1.TailNum = data_2.TailNum;
-- -------------

Select data_2.TailNum, data_1.FlightDate, data_2.AirTime, sum(Distance)
from data_1 INNER JOIN data_2
on data_1.TailNum = data_2.TailNum
where data_2.TailNum ="N190AA" and data_1.FlightDate  = "2017-01-20" and  data_2.AirTime = "50";
-- -------------------

Select data_2.TailNum, data_1.FlightDate, sum(Distance),data_1.OriginCityName,data_2.AirTime
from data_1 INNER JOIN data_2
on data_1.TailNum = data_2.TailNum
where data_2.TailNum ="N190AA" and data_1.FlightDate  = "2017-01-20"  and data_2.AirTime = "50"
group by OriginCityName;
-- --------------------

Select data_2.TailNum, data_1.FlightDate, sum(Distance),data_1.OriginCityName
from data_1 INNER JOIN data_2
on data_1.TailNum = data_2.TailNum
where data_2.TailNum ="N190AA" and data_1.FlightDate  = "2017-01-20" 
group by OriginCityName;

-- --------------------------

-- ------------------------

Select data_2.TailNum, data_1.FlightDate, sum(Distance),AirTime
from data_1 INNER JOIN data_2
on data_1.TailNum = data_2.TailNum
where data_2.TailNum ="N190AA" and data_1.FlightDate  = "2017-01-20"  and data_2.AirTime = "50"
;


Select data_2.TailNum, data_1.FlightDate, sum(Distance) as total_dist
from data_1 INNER JOIN data_2
on data_1.TailNum = data_2.TailNum
where data_2.TailNum ="N190AA" and data_1.FlightDate  = "2017-01-20";