create database project;
use project;
desc maindata;	
select * from maindata;

# Renaming the Column Headers
 alter table maindata rename column `Carrier_Group_ID` to Airline_ID;
 alter table maindata rename column `%Carrier Group ID` to Carrier_Group_ID;
 alter table maindata rename column `%unique carrier code` to Unique_Carrier_Code;
ALTER TABLE maindata RENAME COLUMN `%Unique Carrier Entity Code` TO unique_carrier_entity_code;
ALTER TABLE maindata RENAME COLUMN `%Region Code` TO region_code;
ALTER TABLE maindata RENAME COLUMN `%Origin Airport ID` TO origin_airport_id;
ALTER TABLE maindata RENAME COLUMN `%Origin Airport Sequence ID` TO origin_airport_sequence_id;
ALTER TABLE maindata RENAME COLUMN `%Origin Airport Market ID` TO origin_airport_market_id;
ALTER TABLE maindata RENAME COLUMN `%Origin World Area Code` TO origin_world_area_code;
ALTER TABLE maindata RENAME COLUMN `%Destination Airport ID` TO destination_airport_id;
ALTER TABLE maindata RENAME COLUMN `%Destination Airport Sequence ID` TO destination_airport_sequence_id;
ALTER TABLE maindata RENAME COLUMN `%Destination Airport Market ID` TO destination_airport_market_id;
ALTER TABLE maindata RENAME COLUMN `%Destination World Area Code` TO destination_world_area_code;
ALTER TABLE maindata RENAME COLUMN `%Aircraft Group ID` TO aircraft_group_id;
ALTER TABLE maindata RENAME COLUMN `%Aircraft Type ID` TO aircraft_type_id;
ALTER TABLE maindata RENAME COLUMN `%Aircraft Configuration ID` TO aircraft_configuration_id;
ALTER TABLE maindata RENAME COLUMN `%Distance Group ID` TO distance_group_id;
ALTER TABLE maindata RENAME COLUMN `%Service Class ID` TO service_class_id;
ALTER TABLE maindata RENAME COLUMN `%Datasource ID` TO datasource_id;

ALTER TABLE maindata RENAME COLUMN `# Departures Scheduled` TO departures_scheduled;
ALTER TABLE maindata RENAME COLUMN `# Departures Performed` TO departures_performed;
ALTER TABLE maindata RENAME COLUMN `# Payload` TO payload;
ALTER TABLE maindata RENAME COLUMN `Distance` TO distance;
ALTER TABLE maindata RENAME COLUMN `# Available Seats` TO available_seats;
ALTER TABLE maindata RENAME COLUMN `# Transported Passengers` TO transported_passengers;
ALTER TABLE maindata RENAME COLUMN `# Transported Freight` TO transported_freight;
ALTER TABLE maindata RENAME COLUMN `# Transported Mail` TO transported_mail;
ALTER TABLE maindata RENAME COLUMN `# Ramp-To-Ramp Time` TO ramp_to_ramp_time;
ALTER TABLE maindata RENAME COLUMN `# Air Time` TO air_time;

ALTER TABLE maindata RENAME COLUMN `Unique Carrier` TO unique_carrier;
ALTER TABLE maindata RENAME COLUMN `Carrier Code` TO carrier_code;
ALTER TABLE maindata RENAME COLUMN `Carrier Name` TO carrier_name;
ALTER TABLE maindata RENAME COLUMN `Origin Airport Code` TO origin_airport_code;
ALTER TABLE maindata RENAME COLUMN `Origin City` TO origin_city;
ALTER TABLE maindata RENAME COLUMN `Origin State Code` TO origin_state_code;
ALTER TABLE maindata RENAME COLUMN `Origin State FIPS` TO origin_state_fips;
ALTER TABLE maindata RENAME COLUMN `Origin State` TO origin_state;
ALTER TABLE maindata RENAME COLUMN `Origin Country Code` TO origin_country_code;
ALTER TABLE maindata RENAME COLUMN `Origin Country` TO origin_country;

ALTER TABLE maindata RENAME COLUMN `Destination Airport Code` TO destination_airport_code;
ALTER TABLE maindata RENAME COLUMN `Destination City` TO destination_city;
ALTER TABLE maindata RENAME COLUMN `Destination State Code` TO destination_state_code;
ALTER TABLE maindata RENAME COLUMN `Destination State FIPS` TO destination_state_fips;
ALTER TABLE maindata RENAME COLUMN `Destination State` TO destination_state;
ALTER TABLE maindata RENAME COLUMN `Destination Country Code` TO destination_country_code;
ALTER TABLE maindata RENAME COLUMN `Destination Country` TO destination_country;

ALTER TABLE maindata RENAME COLUMN `Year` TO year;
ALTER TABLE maindata RENAME COLUMN `Month (#)` TO month;
ALTER TABLE maindata RENAME COLUMN `Day` TO day;

ALTER TABLE maindata RENAME COLUMN `From - To Airport Code` TO from_to_airport_code;
ALTER TABLE maindata RENAME COLUMN `From - To Airport ID` TO from_to_airport_id;
ALTER TABLE maindata RENAME COLUMN `From - To City` TO from_to_city;
ALTER TABLE maindata RENAME COLUMN `From - To State Code` TO from_to_state_code;
ALTER TABLE maindata RENAME COLUMN `From - To State` TO from_to_state;

 #1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)
/*
 A.Year
   B.Monthno
   C.Monthfullname
   D.Quarter(Q1,Q2,Q3,Q4)
   E. YearMonth ( YYYY-MMM)
   F. Weekdayno
   G.Weekdayname
   H.FinancialMOnth
   I. Financial Quarter 
 */
select * from maindata;

alter table maindata add column date date;
update maindata set date = concat(year,'-',month,'-',day);

select date,
year(date) as Year,
month(date) as Month,
monthname(date) as Monthname,
concat('Q-',Quarter(date)) as Quarter,
date_format(date,'%y - %m') as Yy_Mm,
weekday(date)+1 as WeekDay,
dayname(date) as DayName from maindata;


select distinct monthname(date),case 
when month>=4 then month-3
else month+9 end as Financial_Month from maindata order by 2;




select distinct monthname(date),case 
when month(date) in (4,5,6) then 'Q1'
when month(date) in (7,8,9) then 'Q2'
when month(date) in (10,11,12) then 'Q3'
else 'Q4' end as Financial_Quarter from maindata order by 2;

#Find the load Factor percentage  yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

select year,round((sum(transported_passengers)/sum(available_seats))*100,2) as Load_Factor from maindata group by 1 order by 2 desc;

select year,month,round((sum(transported_passengers)/sum(available_seats))*100,2) as Load_factor from maindata group by 1,2 order by 1,2;

select year,concat('Q-',quarter(date)) as Quarter,round((sum(transported_passengers)/sum(available_seats))*100,2) as Load_Factor from maindata group by 1,2 order by 1;


#Find the load Factor percentage  on carrier name basis
select carrier_name , round((sum(transported_passengers)/sum(available_seats))*100,2) as Load_factor from maindata group by 1 order by 2 desc;


# Identify Top 10 Carrier Names based passengers preference 
select carrier_name, sum(transported_passengers) as No_of_Passengers from maindata group by 1 order by 2 desc limit 10;


# Display top Routes ( from-to City) based on Number of Flights 

select from_to_city,count(airline_id) as No_of_flights from maindata group by 1 order by 2 desc;

#Identify the how much load factor is occupied on Weekdays vs Weekend.
select case
when dayname(date) in ('Saturday','Sunday') then 'Weekend'
else 'Weekday' end as day_type, round((sum(transported_passengers)/sum(available_seats))*100,1) as occupancy from maindata
 group by day_type order by occupancy;


#Identify number of flights based on Distance groups
desc maindata;
select distance_group_id,count(airline_id) as No_of_flights from maindata group by 1 order by 2 desc;