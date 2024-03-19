# R Project Future Sales

We will be predicting the most profitable days for items in specific shops. For example, determining the best day to sell soap, anticipating higher business on that particular day.

## Files

We have four CSV files:
- **Sales_train**: The training set. Daily historical data from January 2013 to October 2015.
- **Items**: Supplemental information about the items/products.
- **Item_categories**: Supplemental information about the item categories.
- **Shops**: Supplemental information about the shops.

## Machine Learning

We will be using a decision tree classifier to predict item sales per shop. Considering 60 shops and 22,170 unique items, we will utilize features such as days, item price, and item count (sold) to make predictions.

### Pre-Processing of Dataset

Before performing machine learning tasks, we will manipulate outliers:
- Identifying outliers in item price and item count per day.
- Designating high-priced items with low sales counts as unwanted or luxury products.

Converting the date column to the correct date format and finding corresponding weekdays.

### Develop a Decision Tree Model

The model aims to identify days with high sales. It takes shop ID and item ID as input and predicts the sales day. This information aids in inventory management, discount planning, and overall business strategy.

## Testing

### Run a Test Model

Synthetic test data will be generated to identify item IDs given shop ID and item ID.

## Visualization

### Generate Visual Graphs

To be added

## Inferences
To be done



## UML Diagrams

```mermaid
classDiagram
    Sales_train <|-- Shop
    Sales_train <|-- Item
    Sales_train <|-- Item_categories
    Sales_train : Date
    Sales_train : Date_block_num
    Sales_train: Day
    Sales_train: Shop_id
    Sales_train: Item_id
    Sales_train: Item_Price
    Sales_train: Item_count_day
     
    class Shop{
      Shop_name
      Shop_id
    }
    class Item{
     item_id 
     item_category_id 
     item_name
    }
    class Item_categories{
	item_category_name
	 item_category_id    }
