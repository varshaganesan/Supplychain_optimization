#checking the data after import.
SELECT * FROM supply_chain_data LIMIT 10;

#DATA_CLEANING
-- Checking for missing values
SELECT * 
FROM supply_chain_data
WHERE availability IS NULL;

SELECT *
FROM supply_chain_data
WHERE product_type IS NULL OR product_type = ''
OR sku IS NULL OR sku = ''
OR price IS NULL OR price = ''
ORDER BY product_type;
-- setting few blank price data to zero
UPDATE supply_chain_data
SET price = 0
WHERE Price IS NULL

-- Finding duplicates
-- Since there are no unique identifiers, using ROW NUMBER to find duplicates
WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER () OVER ( PARTITION BY product_type, sku, price, availability, products_sold, revenue, customer_demographics, stock_levels, lead_times, order_quantities, 
shipping_times, shipping_carriers, shipping_costs, supplier_name, location, lead_time, production_volumes, manufacturing_leadtime, manufacturing_costs, inspection_results, 
defect_rates, transportation_modes, routes, costs ) AS row_num
FROM supply_chain_data)
SELECT *
FROM duplicate_cte
WHERE row_num > 2;

-- Double checking by selecting an example from the results
SELECT *
FROM supply_chain_data
WHERE sku = 'SKU20';

-- Deleting duplicates from the dataset directly for this project. Best practice is to create a backup and delete from a staging table.
DELETE FROM supply_chain_data
WHERE sku IN 
(SELECT sku
    FROM supply_chain_data
    GROUP BY sku
    HAVING COUNT(*) > 1);
    
-- Making the data format uniform
UPDATE supply_chain_data
SET product_type = LOWER(product_type),
    customer_demographics = LOWER(customer_demographics);
    
-- Checking anomalies in pricings and other fields
SELECT *
FROM supply_chain_data
WHERE price < 0 OR costs < 0;

SELECT *
FROM supply_chain_data
WHERE defect_rates > 10 OR shipping_costs > 1000;

-- Noticed unnecessary spaces and hence removing them
SELECT location , TRIM(location)
FROM supply_chain_data;

UPDATE supply_chain_data
SET location = TRIM(location);

#Data Analysis
-- Finding out the shipping performance
-- Average shipping time by routes
SELECT routes, AVG(shipping_times) AS avg_shippingtime
FROM supply_chain_data
GROUP BY routes
ORDER BY avg_shippingTime DESC;

-- Finding the high cost shipping carriers
SELECT shipping_carriers, SUM(shipping_costs) AS total_shippingcost
FROM supply_chain_data
GROUP BY shipping_carriers
ORDER BY total_shippingcost DESC;

-- Finding the defect rates by product type
SELECT product_type, AVG(defect_rates) AS avg_defectrate
FROM supply_chain_data
GROUP BY product_type
ORDER BY avg_defectrate DESC;

-- Finding the revenue by location and top performing transport modes
SELECT location, SUM(revenue) AS total_revenue
FROM supply_chain_data
GROUP BY location
ORDER BY total_revenue DESC;

SELECT transportation_modes, SUM(revenue) AS revenue_mode
FROM supply_chain_data
GROUP BY transportation_modes
ORDER BY revenue_mode DESC;

-- Exporting as csv for dashboard







