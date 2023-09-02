# Zen-City-s-Journey-through-London-s-bike-rental-data
Zen City's Journey through London's bike rental data

Introduction:
In the bustling city of Zen, the need for a sustainable & efficient transportation system led to
"Zen City", a bike rental company with a mission to promote eco-friendly commuting. Zen City
accumulated vast data about bike rentals and station utilization as it expanded its operations. To
gain deeper insights into their business and enhance their services, Zen City embarked on a
data-driven journey, and you will take part in it.

Data Description: The dataset contains the following columns:
 name: The name of the song

● duration: The duration of the song in seconds

● release_date: The date when the song was released

● album_name: The name of the album the song belongs to

● explicit: A boolean value indicating whether the song contains explicit content

● popularity: The popularity score of the song

● acousticness: A measure of the acoustic quality of the song

● danceability: A measure of how suitable the song is for dancing

● energy: A measure of the intensity and activity of the song

● instrumentalness: A measure of the instrumental content of the song

● liveness: A measure of the presence of a live audience in the recording

● loudness: The overall loudness of the song

● speechiness: A measure of the presence of spoken words in the song

● tempo: The tempo of the song in beats per minute

● time_signature: The time signature of the song


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
