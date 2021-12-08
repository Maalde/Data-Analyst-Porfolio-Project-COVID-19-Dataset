#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import matplotlib
plt.style.use('ggplot')
from matplotlib.pyplot import figure
matplotlib.rcParams['figure.figsize'] = (12,8)
pd.options.mode.chained_assignment 


# ## Read CSV file as a pandas dataframe 

# In[2]:


music_data = pd.read_csv(r'movies.csv')
music_data.head(20)


# ## Searching for any missing data 

# In[3]:



for col in music_data.columns:
    missing_data = np.mean(music_data[col].isnull())
    print('{}-{}'.format(col,missing_data))


# ## Find out about data types in columns

# In[4]:


print(music_data.dtypes)


# ## Change data type of 'budget', 'gross' columns from float64 to int64

# In[5]:


music_data['budget'] = music_data['budget'].astype('Int64')
music_data['gross'] = music_data['gross'].astype('Int64')


# ##  Make a corrected 'year' column by seperating that into 4 seperate columns

# In[6]:


music_data_frame = music_data["released"].str.split(" ",n=3,expand = True) 
music_data_frame.rename(columns={0: "Month", 1: "day",2:"Year",3:"Country"}, inplace=True)
music_data['yearcorrect'] = music_data_frame['Year']


# In[7]:


music_data_frame


# ## Display the whole dataframe and sort them according to 'gross' column 

# In[8]:


pd.set_option('display.max_rows',None)
music_data.sort_values(by =['gross'], inplace = False, ascending =False)


# ## Drop duplicates by first sorting according to the company with the highest duplicates

# In[9]:


music_data['company'].drop_duplicates().sort_values(ascending =False)


# In[10]:


music_data.drop_duplicates()


# 
# ## Are there any outliers in the column of interest 'gross'? A box plot is used to determine if there is any 

# In[11]:



music_data.boxplot(column=['gross'])


# 5-6 points can be concluded as outliers in the box plot above.

# ### Find features that correlate with 'gross' feature or column
# ### Build a scatter and strip plot and compare features

# In[12]:


music_data['gross'] = music_data['gross'].astype('float')
music_data['budget'] = music_data['budget'].astype('float')


# In[13]:


plt.scatter(x= music_data['budget'], y = music_data['gross'],alpha=0.5)
plt.title('Budget vs Gross Earnings')
plt.xlabel('Gross Earnings')
plt.ylabel('Budget for Film')
plt.show()


# In[14]:


sns.stripplot(x="rating", y="gross", data=music_data)


# ## A regression plot is used to determine the relation between 'gross' column and any other column of interest. In the case below, 'budget' column or feature.

# In[15]:


sns.regplot(x="gross", y="budget", data=music_data, scatter_kws = {"color":"red"}, line_kws = {"color":"green"})


# ## Correlation  between features that have numerical data
# ## check person's correlation between 'budget and 'gross'

# In[16]:


music_data.corr(method ='pearson') #person, kendall, spearman


# In[17]:


music_data.corr(method ='spearman') #person, kendall, spearman


# In[18]:


music_data.corr(method ='kendall') #person, kendall, spearman


# ##### The is a high correlation between budget and gross

# ## Visualize correlation using correlation matrix and seaborn library

# In[19]:


correlation_matrix = music_data.corr(method ='pearson')
sns.heatmap(correlation_matrix, annot = True)
plt.title("Correlation matrix for Numeric Features")
plt.xlabel("Movie features")
plt.ylabel("Movie features")
plt.show()


# ## Create numeric values for all columns with categorical values and visualize with a correlation matrix

# In[20]:


music_data_numeric = music_data

for col_name in music_data_numeric.columns:
    if(music_data_numeric[col_name].dtype == 'object'):
        music_data_numeric[col_name] = music_data_numeric[col_name].astype('category')
        music_data_numeric[col_name] = music_data_numeric[col_name].cat.codes
music_data_numeric


# In[21]:


correlation_matrix = music_data_numeric.apply(lambda x: x.factorize()[0]).corr(method='pearson')
sns.heatmap(correlation_matrix, annot = True)
plt.title("Correlation matrix for All Features")
plt.xlabel("Movie features")
plt.ylabel("Movie features")
plt.show()


# ## Using factorize - this assigns a random numeric value for each unique categorical value
# 

# In[22]:



music_data.apply(lambda x: x.factorize()[0]).corr(method='pearson')


# ## Plot correlation matrix 

# In[23]:


correlation_matrix = music_data.apply(lambda x: x.factorize()[0]).corr(method='pearson')
sns.heatmap(correlation_matrix, annot = True)
plt.title("Correlation matrix for Movies")
plt.xlabel("Movie features")
plt.ylabel("Movie features")
plt.show()


# ## Print Correlation pairs for analysis 

# In[24]:


correlation_mat = music_data.apply(lambda x: x.factorize()[0]).corr()

corr_pairs = correlation_mat.unstack()

print(corr_pairs)


# ## Sort out correlation pairs using 'quicksort' method 

# In[25]:


sorted_pairs = corr_pairs.sort_values(kind="quicksort")

print(sorted_pairs)


# ## Take a look at the features that have a high correlation (> 0.5)
# 

# In[26]:



strong_pairs = sorted_pairs[abs(sorted_pairs) > 0.5]

print(strong_pairs)


# ##### Votes and budget has the highest correlation to gross earnings. Company has low correlation

# ## Looking at the top 15 companies by gross revenue
# 

# In[27]:



CompanyGrossSum = music_data.groupby(['company'])[["gross"]].sum()
CompanyGrossSumSorted = CompanyGrossSum.sort_values(['gross','company'], ascending = False)[:15]
CompanyGrossSumSorted = CompanyGrossSumSorted['gross'].astype('int64') 
CompanyGrossSumSorted


# In[ ]:





# In[ ]:




