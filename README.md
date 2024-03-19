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
  ItemCategories {
    << (C, #FF7700) item_category_id >>
    item_category_name
  }
  ItemCategories --|> Item : item_category_id
  Item {
    << (C, #FF7700) item_id >>
    item_category_id
    item_name
  }
  SalesTrain {
    << (C, #FF7700) date >>
    date_block_num
    shop_id
    item_id
    item_price
    item_cnt_day
  }
  SalesTrain --> Item : item_id
  Shop {
    << (C, #FF7700) shop_id >>
    shop_name
  }

  }
