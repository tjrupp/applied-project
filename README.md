Applied Project 

Final Project of Minor Digital Science of University of Innsbruck

Is Update-frequency and content 
connected top App success?
An Analysis of productivity Apps in Google’s Play Store

Run files in order:

Step 1: Clone git repository

Step 2: Download database and JSON-Files (Running it on your own will take
a long time)

    https://fileshare.uibk.ac.at/d/12bc1fe752bc4dcf9d52/
    
Step 3:
To install needed python modules run

    pip install -r requirements.txt
    

Step 4:
List of Scripts (run in numeric order):

    0_requirements.R

installs and loads needed R packages, if not yet installed (M1)


    1_PlayStore_reviews.py

downloads reviews in JSON format and saves in folder reviews_JSON (M1/M2)


    2_PlayStore_apps.py

downloads app details in JSON format and saves in folder app_JSON (M1/M2)


    3_save_reviews.R

converts reviews from JSON to dataframe and saves in SQLite database (M2)


    4_save_app_details.R 

converts app details from JSON to dataframe and saves in SQLite database (M2)


    5_save_patchnotes.R

extracts patchnotes from textfiles in folder Patchnotes_Apps and stores in 
database (M2/M3)


    6_save_names.R

extract app names from filenames and store in database (M2/M3)


    7_review_sentiment.R

get review sentiment per review and sentence, mean for reviews with multiple 
sentences (M2)


    8_app_age.R

compute app age in days and store in database (M1/M2)


    9_update_frequency.R

compute update_frequency for each app in mean days between updates and 
corresponding standard deviation (M1/M2)


    10_mean_ratings.R

compute mean ratings of reviews per app (M1/M2)


    11_mean_sentiment.R
 
compute mean sentiment of reviews per app (M1/M2)
 
 
    12_combine_tables.R
  
combine tables for better overview (M1)
  
  
    13_Analysis.R

data analysis part, connection of update_frequency and app success measures,
exploratory analysis and visualization (M1/M3)
   
   
    14_LDA_reviews.py
   
conduct LDA of reviews (takes a very long time, is stored in database already)
(M3)
   
   
    15_LDA_patchnotes.py
    
conduct LDA of patchnotes (much quicker, if you want to test the code I advise
of using this, method is the same mostly) (M3)

    
    16_Analysis_LDA.R

analysis and visualisation of LDA results (M3)
