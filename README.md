**Applied Project 

Tim Jonathan Rupp

Is Update-frequency and content 
connected top App success?
An Analysis of productivity Apps in Google’s Play Store**

Step 1: Clone git repository

Step 2: Download database and JSON-Files (Running it on your own will take
a long time)

    https://fileshare.uibk.ac.at/u/d/fe781cc27cfc4db2af11/
    
Step 3:
To install needed python modules run

    pip install -r requirements.txt
    

Step 4:
List of Scripts (run in numeric order):

    0_requirements.R

installs and loads needed R packages, if not yet installed


    1_PlayStore_reviews.py

downloads reviews in JSON format and saves in folder reviews_JSON


    2_PlayStore_apps.py

downloads app details in JSON format and saves in folder app_JSON


    3_save_reviews.R

converts reviews from JSON to dataframe and saves in SQLite database


    4_save_app_details.R 

converts app details from JSON to dataframe and saves in SQLite database


    5_save_patchnotes.R

extracts patchnotes from textfiles in folder Patchnotes_Apps and stores in
database


    6_save_names.R

extract app names from filenames and store in database


    7_review_sentiment.R

get review sentiment per review and sentence, mean for reviews with multiple 
sentences


    8_app_age.R

compute app age in days and store in database


    9_update_frequency.R

compute update_frequency for each app in mean days between updates and 
corresponding standard deviation


    10_mean_ratings.R

compute mean ratings of reviews per app


    11_mean_sentiment.R
 
compute mean sentiment of reviews per app
 
 
    12_combine_tables.R
  
combine tables for better overview
  
  
    13_Analysis.R

data analysis part, connection of update_frequency and app success measures,
exploratory analysis and visualization
   
   
    14_LDA_reviews.py
   
conduct LDA of reviews (takes a very long time, is stored in database already)
   
   
    15_LDA_patchnotes.py
    
conduct LDA of patchnotes (much quicker, if you want to test the code I advise
of using this, method is the same mostly)

    
    16_Analysis_LDA.R

analysis and visualisation of LDA results
