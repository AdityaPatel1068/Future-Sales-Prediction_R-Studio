# Install Packages 
install.packages("readr")
install.packages("httr")





#load Libraries
library(readr)
library(httr)




# Load datasets into R

## the dataset will be pulled from Github for easy and fast access
### Define the URLs for the datasets
item_categories_url <- "https://github.com/AdityaPatel1068/Future-Sales-Prediction_R-Studio/raw/main/Dataset/item_categories.csv"
items_url <- "https://github.com/AdityaPatel1068/Future-Sales-Prediction_R-Studio/raw/main/Dataset/items.csv"
sales_train_url <- "https://github.com/AdityaPatel1068/Future-Sales-Prediction_R-Studio/raw/main/Dataset/sales_train.csv"
sample_submission_url <- "https://github.com/AdityaPatel1068/Future-Sales-Prediction_R-Studio/raw/main/Dataset/sample_submission.csv"
shops_url <- "https://github.com/AdityaPatel1068/Future-Sales-Prediction_R-Studio/raw/main/Dataset/shops.csv"
test_url <- "https://github.com/AdityaPatel1068/Future-Sales-Prediction_R-Studio/raw/main/Dataset/test.csv"

### variables with the value
item_categories <- read_csv(url(item_categories_url)) #supplemental information about the items categories.
items <- read_csv(url(items_url)) # supplemental information about the items/products.
sales_train <- read_csv(url(sales_train_url)) #the training set. Daily historical data from January 2013 to October 2015.
sample_submission <- read_csv(url(sample_submission_url)) #a sample submission file in the correct format.
shops <- read_csv(url(shops_url)) #supplemental information about the shops.
test <- read_csv(url(test_url)) #the test set. You need to forecast the sales for these shops and products for November 2015.


# Display the training set
knitr::kable(sales_train, format = "markdown")

