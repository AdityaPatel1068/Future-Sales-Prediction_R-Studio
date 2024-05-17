# Load necessary libraries
library(lubridate)    # For date manipulation
library(dplyr)        # For data manipulation
library(readr)        # For reading data
library(httr)         # For HTTP requests
library(forecast)     # For time series forecasting
library(ggplot2)      # For data visualization
library(coefplot)     # For coefficient plots
library(reshape2)     # For reshaping data
library(randomForest) # For random forest modeling
library(cowplot)   
library(tidyr)



# Load datasets into R
## Data pulled from Github for easy access
sales_train_url <- "https://github.com/AdityaPatel1068/Future-Sales-Prediction_R-Studio/raw/main/Dataset/sales_train.csv"
test_url <- "https://github.com/AdityaPatel1068/Future-Sales-Prediction_R-Studio/raw/main/Dataset/test.csv"

# Read datasets
sales_train_raw <- read_csv(url(sales_train_url))     # Training set: daily historical data from Jan 2013 to Oct 2015
test <- read_csv(url(test_url))                       # Test set: forecast sales for Nov 2015



# Data Manipulation
## Drop 'date' from sales_train as we will use Date Blocks
sales_train <- subset(sales_train_raw, select = -c(date))

## Modify 'ID' column to 'date_block_num' and fill it with 34 in the test dataset
test$date_block_num <- 34
test <- subset(test, select = -ID)

# Calculate correlation matrix
correlation_matrix_unclean <- cor(sales_train[c("shop_id", "item_id", "item_price", "item_cnt_day")])

# Convert correlation matrix to long format for plotting
correlation_unclean <- melt(correlation_matrix_unclean)

# Plot the heatmap of correlation matrix before outlier removal
ggplot(data = correlation_unclean, aes(Var1, Var2, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "red", high = "black", mid = "white", midpoint = 0, limit = c(-1,1), space = "Lab", name = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 10, hjust = 1)) +
  labs(title = "Heatmap of Correlation Matrix Unclean")

head(sales_train)



# Function to identify and remove outliers using quartiles
remove_outliers <- function(x) {
  Q1 <- quantile(x, 0.25)
  Q3 <- quantile(x, 0.75)
  IQR <- Q3 - Q1
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  x_filtered <- ifelse(x >= lower_bound & x <= upper_bound, x, NA)
  return(x_filtered)
}



# we group dat by date_block_num, shop_id, and item_id and then clean it at every shop and the item level



# Group the data by date_block_num, shop_id, and item_id and remove outliers
cleaned_data <- sales_train %>%
  group_by(date_block_num, shop_id, item_id) %>%
  summarise(item_price_cleaned = list(remove_outliers(item_price)),
            item_cnt_day_cleaned = list(remove_outliers(item_cnt_day))) %>%
  unnest(cols = c(item_price_cleaned, item_cnt_day_cleaned)) %>%
  na.omit()

head(cleaned_data)


# Calculate correlation matrix
correlation_matrix_clean <- cor(cleaned_data[c("shop_id", "item_id", "item_price_cleaned", "item_cnt_day_cleaned")])
correlation_clean <- melt(correlation_matrix_clean)


# Plot the heatmap of correlation matrix before outlier removal
ggplot(data = correlation_clean, aes(Var1, Var2, fill = value)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "red", high = "black", mid = "white", midpoint = 0, limit = c(-1,1), space = "Lab", name = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 10, hjust = 1)) +
  labs(title = "Heatmap of Correlation Matrix clean")





# Set seed for reproducibility
set.seed(42)


# Split the cleaned dataset into training and test sets (e.g., 80% training, 20% test)
train_index <- sample(1:nrow(cleaned_data), 0.8 * nrow(cleaned_data))
train_data <- cleaned_data[train_index, ]
test_data <- cleaned_data[-train_index, ]

# Fit linear regression model
model1 <- lm(cbind(item_cnt_day_cleaned, item_price_cleaned) ~ ., data = train_data)

# Predict item_cnt_day and item_price using the trained model for both training and test data
predicted_item_cnt_day_train <- predict(model1, newdata = train_data)[, 1]
predicted_item_price_train <- predict(model1, newdata = train_data)[, 2]
predicted_item_cnt_day_test <- predict(model1, newdata = test_data)[, 1]
predicted_item_price_test <- predict(model1, newdata = test_data)[, 2]

# Calculate RMSE for item_cnt_day and item_price for both training and test data
rmse_item_cnt_day_train <- sqrt(mean((train_data$item_cnt_day_cleaned - predicted_item_cnt_day_train)^2))
rmse_item_price_train <- sqrt(mean((train_data$item_price_cleaned - predicted_item_price_train)^2))
rmse_item_cnt_day_test <- sqrt(mean((test_data$item_cnt_day_cleaned - predicted_item_cnt_day_test)^2))
rmse_item_price_test <- sqrt(mean((test_data$item_price_cleaned - predicted_item_price_test)^2))

# Print RMSE for item_cnt_day and item_price for both training and test data
cat("Training RMSE for item_cnt_day:", rmse_item_cnt_day_train, "\n")
cat("Training RMSE for item_price:", rmse_item_price_train, "\n")
cat("Test RMSE for item_cnt_day:", rmse_item_cnt_day_test, "\n")
cat("Test RMSE for item_price:", rmse_item_price_test, "\n")




# Make predictions using linear regression model
predictions1 <- predict(model1, newdata = test)

# Create dataframe with original test data and predictions
predicted_data1 <- data.frame(date_block_num = test$date_block_num, shop_id = test$shop_id, item_id = test$item_id, predicted_item_cnt_day = predictions1)

# Print random 10 rows from cleaned_data
colnames(cleaned_data) <- c("date_block_num", "shop_id", "item_id", "predicted_item_cnt_day", "predicted_item_price")
num_rows <- nrow(cleaned_data)
random_indices <- sample(num_rows, 10, replace = FALSE)
random_rows <- cleaned_data[random_indices, ]
print(random_rows)





# ARIMA model

# Convert 'date' to Date type with format "YYYY-MM-DD"
sales_train_raw$date <- as.Date(sales_train_raw$date, format = "%d.%m.%Y")

# Calculate daily total sales and aggregate (ensuring data is sorted by date)
sales_train_arima <- sales_train_raw %>%
  mutate(total_sales = item_price * item_cnt_day) %>%
  select(-c(date_block_num, shop_id, item_id ,item_price ,item_cnt_day)) %>%
  arrange(date) %>%
  group_by(date) %>%
  summarise(total_daily_sales = sum(total_sales))


# Plot historical sales data
plot_sales <- ggplot(data = sales_train_arima, aes(x = date, y = total_daily_sales)) +
  geom_line(color = "blue") +
  xlab("Date") +
  ylab("Total Sales") +
  ggtitle("Historical Sales Data")
print(plot_sales)




# Define start and end dates
start_date <- as.Date("2013-01-01")
end_date <- as.Date("2015-10-31")



# Fit ARIMA model
sales_ts <- ts(sales_train_arima$total_daily_sales, start = start_date, end = end_date, frequency = 1)
arima_model <- auto.arima(sales_ts, seasonal = TRUE)  # Automatically select the best ARIMA model





# Generate sales forecast for the next 30 days
forecast_sales <- forecast(arima_model, h = 30)


# Plot the forecast
plot(forecast_sales)



# Plot the forecast with more details
plot(forecast_sales, 
     main = "Sales Forecast for Next 30 Days", 
     xlab = "Date", 
     ylab = "Sales", 
     xlim = c(start_date, end_date + 30), 
     ylim = c(0, max(forecast_sales$upper) * 1.1), 
     type = "l", 
     col = "blue")

# Add a legend
legend("topleft", 
       legend = c("Forecast", "95% Confidence Interval"), 
       col = c("blue", "red"), 
       lty = c(1, 2), 
       cex = 0.8)
  
