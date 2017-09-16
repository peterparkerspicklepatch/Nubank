
# coding: utf-8

# In[64]:

#grab the packages you'll need
from bs4 import BeautifulSoup
import requests
import pandas as pd


# In[30]:

#create 'static' pieces
soccer_url = "http://footballdatabase.com/league-scores-tables/italy-serie-a-2012-13"
req = requests.get(soccer_url_placehold) #open page
soup = BeautifulSoup(req.content, "lxml") #make into soup object


# In[31]:

soup.find_all('tr')[0].find_all('th')


# In[32]:

column_headers = [th.getText() for th in soup.find_all('tr')[0].find_all('th')]


# In[33]:

column_headers


# In[73]:

#create 'static' pieces
years = ["2012-13", "2013-14", "2014-15", "2015-16", "2016-17"]
soccer_url_placehold = "http://footballdatabase.com/league-scores-tables/italy-serie-a-{years}"
standings_df = pd.DataFrame()


# In[74]:

# create for loop to grab table, add to df, and loop over years
for year in years:
    soccer_url = soccer_url_placehold.format(years = years) #subs in years
    req = requests.get(soccer_url) #open page
    soup = BeautifulSoup(req.content, "lxml") #make into soup object
    
    table_rows = soup.findAll('tr')[1:] #grab table data rather then header
    team_data = [[td.getText() for td in table_rows[i].findAll('td')] #for each tr give me the td stuff
              for i in range(len(table_rows))]

    year_df = pd.DataFrame(team_data) #put that tr stuff into a dataframe
    year_df.insert(0, 'year', year) #add a column called year, uses object we defined earlier
    standings_df = standings_df.append(year_df, ignore_index=True) #add to larger dataframe


# In[76]:

#moment of truth
standings_df.head()
