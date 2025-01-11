## Objective
The primary goal of this project is to create a data warehouse for The Look e-commerce platform, focusing on storing and analyzing sales-related data to support business insights and decision-making.

## Libraries
- pyspark
- findspark
- pandas 
- pyspark.sql (SparkSession)
- pyspark.sql.functions (col, sum, concat, lit, when, to_date)
- sqlalchemy (create_engine)

## Dataset
The dataset used in this project is sourced from the Google BigQuery database: thelook_ecommerce. This publicly available dataset can be accessed here.

## Data Modeling

To create a data warehouse design that organizes sales data into Fact and Dimension tables.

1. Understand the Sales Business Process
- The data warehouse focuses exclusively on sales-related data from the e-commerce platform. The sales process includes customer purchases, product details, transaction dates, and store information.

2. Design the Fact Table(s)

- Fact tables store measurable data related to sales transactions.
- If necessary, multiple fact tables can be created to support complex analyses.
3. Create Dimension Tables

- Dimension tables store descriptive attributes for the facts, such as customer, product, store, and time details.
4. Choose Schema Type

- The data warehouse will use a Star, Snowflake, or Galaxy schema based on the complexity of relationships and analysis requirements.

## Extract
1. Data Retrieval
Extract the required data from the BigQuery database based on the Fact and Dimension tables designed.

2. Save to CSV
Query results for each table are saved as .csv files.

3. SQL Queries

- Store SQL queries in a dedicated file (<extraction_queries.sql>).
- Annotate each query to describe its purpose (e.g., extracting customer data, sales data, etc.).
4. Load into PySpark

- Import the .csv files into PySpark DataFrames for further processing.

## Transform
1. Data Cleaning and Transformation
- Perform data cleaning and transformations to align with the Fact and Dimension table designs.
- Example tasks:
- 1. Handling missing values.
- 2. Converting data types.
- 3. Standardizing formats (e.g., currency, date).
     
2. Implementation
- Use PySpark for efficient processing of large datasets.

## Load
1. Create the Data Warehouse Schema
- Design and implement the database schema in PostgreSQL based on the Fact and Dimension table structure.
- Use a DDL script (<datawarehouse_ddl_<name>.sql>) to create the database and tables.
2. Load Data into Tables

- Load the cleaned and transformed data from PySpark into the respective Fact and Dimension tables in the PostgreSQL database.
3. Tools

- Use sqlalchemy connectors to interact with PostgreSQL programmatically.

## Conclusion
This project demonstrates a complete ETL pipeline, from data extraction to warehouse implementation, for The Look e-commerce platform. The resulting data warehouse enables efficient sales analysis and business decision-making. Future enhancements may include automating the pipeline and adding more data sources for a holistic business view.
