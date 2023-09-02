# Zen-City-s-Journey-through-London-s-bike-rental-data
Zen City's Journey through London's bike rental data

Introduction:
In the bustling city of Zen, the need for a sustainable & efficient transportation system led to
"Zen City", a bike rental company with a mission to promote eco-friendly commuting. Zen City
accumulated vast data about bike rentals and station utilization as it expanded its operations. To
gain deeper insights into their business and enhance their services, Zen City embarked on a
data-driven journey, and you will take part in it.

Data Description: The dataset contains the following columns:
- bigquery-public-data.london_bicycles.cycle_hire *filtered for Q1 2021 

[https://console.cloud.google.com/bigquery?ws=!1m5!1m4!4m3!1sbigquery-public-data!2slondon_bicycles!3scycle_hire
](url)


Field name & Description:

● id:
A unique identifier for each record in the dataset (for each station)

● installed:
Indicates whether a bike station is currently installed (TRUE) or not (FALSE)

● latitude:
The geographical latitude coordinate of the bike station's location

● locked:
Indicates the locking status of the bike station

● longitude:
The geographical longitude coordinate of the bike station's location

● name:
The name or identifier of the bike station

● bikes_count:
The number of available bikes at the bike station

● docks_count:
The total number of docking spaces available at the bike station

● nbEmptyDocks:
The number of empty docking spaces at the bike station

● temporary:
Indicates whether the bike station is temporary (TRUE) or permanent (FALSE)

● terminal_name:
The name or identifier of the terminal associated with the bike station

● install_date:
The date on which the bike station was installed

● removal_date:
The date on which the bike station was removed, if applicable


*These columns provide essential information about each bike station, including its location, availability, capacity, and installation details. Analyzing this data can offer insights into bike station utilization, availability trends, and spatial distribution.

- bigquery-public-data.london_bicycles.cycle_stations *not filtered for Q1 2021

[https://console.cloud.google.com/bigquery?ws=!1m5!1m4!4m3!1sbigquery-public-data!2slondon_bicycles!3scycle_stations
](url)


Field name & Description:

● rental_id:
A unique identifier for each bike rental transaction

● duration:
The duration of the bike trip in seconds. It represents the time the bike was rented until it was  returned

● duration_ms
The duration of the bike trip in milliseconds. This can provide more precise timing for analysis

● bike_id:
Identifier for the bike used in the rental

● bike_model:
The model of the bike that was rented

● end_date:
The timestamp indicating when the bike rental ended

● end_station_id:
The identifier of the station where the bike was returned at the end of the rental

● end_station_name:
The name of the station where the bike was returned

● start_date:
The timestamp indicating when the bike rental started

● start_station_id:
The identifier of the station where the bike was rented

● start_station_name:
The name of the station where the bike was rented

● end_station_logical_terminal:
The logical terminal associated with the end station

● start_station_logical_terminal:
The logical terminal associated with the start station

● end_station_priority_id:
An identifier indicating the priority of the end station


*These columns provide essential information about each bike rental (trip), including its starting and ending stations, the star and end date’s and the duration of the rental. Analyzing this data can offer insights into bike station utilization, availability trends, and spatial distribution.


Chapter 1: Facing the Business Topic

Goal: Optimize the business for more bike rentals in Q2 2021.
Q1 2021 is the business quarter number 1, starting in January & ending in March. Your data
describes these months only. Q2 2021 is the next quarter - April to June 2021, included.
Zen City has strategically positioned bike stations to facilitate rider accessibility. However, they
recognized the need to fine-tune their station placements, and their product features for
maximum efficiency. They set out to analyze rental patterns and station utilization to identify
underutilized & overcrowded stations, to get the maximum of the existing business.
You, as an analyst in the company, are asked to offer new ways to make Zen City more useful,
increase its user base, and aim for the target of increasing the bike rentals during next quarter.

Chapter 2: Data Exploration
To tackle these challenges, you got two key tables:
- The cycle_hire_new table contains information about each bike rental transaction.
- The cycle_stations_pro table provides information about each bike station's location
and capacity.
Suggested ways to think about the data:

- Can you identify any temporal patterns? seasonal trends?
- Are there any outliers or anomalies? How can you handle them?
- What is the average distance between the start and end stations?
- Can you identify popular bike routes?
- Can you identify any spatial clusters of bike stations?

Chapter 3: Hypothesis and Business Questions

After viewing the data, what are the business questions and directions of analysis you’d like to
perform? What kind of questions would you like to answer? What would be a valuable insight?
As these questions are addressed, Zen City can refine station placements, enhance bike
availability, and elevate customer experiences. By adapting their strategies based on these
insights, Zen City will be well-positioned to navigate the dynamic urban mobility landscape and
continue setting new benchmarks in the bike-sharing industry.

Chapter 4: Data Cleaning & Data Wrangling
Now, your goal is to get a dataset that’s ready to be analyzed.
We want to make sure we’ve got all of the necessary information clean and ready for analysis.
Your data cleaning will be done with a CTE. Some of the principles you’d like to take care of are:
1. Identify missing values.
2. Identify uncorrected data types.
3. Identify & treat nulls.
4. Identify & treat duplicates.
5. Identify & treat inconsistencies.
6. Take care of outliers.
7. Create new columns for better analysis.
8. Standardization.

Chapter 5: Data Analysis and Visualizations

Perform a data analysis on Zen City’s final dataset you just created.
Go through the univariate analysis, complete the picture you started to draw in the exploration
step. Understand the distributions and the behavior of the data. Continue with bivariate &
Multivariate analysis, study the interactions & correlations of the data.

Don’t forget to add a business sense to the analysis you perform, with the goal of the project in
mind. Don’t be afraid to involve domain knowledge in your way to drive the success of the bike
rental service.

Chapter 6: Predictions
Zen City has collected data on bike rentals for business Quarter number 1 (Jan-March). They're
interested in using this data to predict rental information. You are asked to do so, using all of the
statistical knowledge you acquired so far.
Prediction Question:
Predict how many rentals will be made in the next month (April 2021) in “Albert Gate,
Hyde Park” bike station.
