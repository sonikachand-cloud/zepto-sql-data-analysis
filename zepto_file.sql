--Database and Table Creation

CREATE DATABASE zepto_SQL;

CREATE TABLE Zepto1( 
    sku_id SERIAL PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(8,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INT,
    discountedSellingPrice NUMERIC(8,2),
    weightInGms INT,
    outOfStock BOOLEAN,
    quantity INT
);

SELECT * FROM zepto1;


--Data Validation and Cleaning

-- Count total rows
SELECT COUNT(*) AS total_rows FROM Zepto1;

--Check Null Values
SELECT COUNT(*) AS total_rows,
	COUNT(category) AS category_filled,
	COUNT(name) AS name_filled,
	COUNT(mrp) AS mrp_filled,
	COUNT(discountPercent) AS discount_filled,
	COUNT(availableQuantity) AS available_quantity_filled,
	COUNT(discountedSellingPrice) AS selling_price_filled,
	COUNT(weightInGms) AS weight_filled,
	COUNT(outOfStock) AS stock_status_filled,
	COUNT(quantity) AS quantity_filled
FROM zepto1;

--Check Invalid Prices
SELECT * FROM Zepto1
WHERE mrp<=0
OR discountedSellingPrice<=0;

-- Remove the record with invalid price identified during validation
Delete From zepto1
WHERE sku_id=3607;

--Convert paise to rupees
UPDATE zepto1
SET mrp=mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;

--Check invalid discount
SELECT discountPercent FROM zepto1
WHERE discountPercent<0 OR discountPercent>100;

-- Sellling price greater than MRP
SELECT discountedSellingPrice,mrp FROM Zepto1
WHERE discountedSellingPrice>mrp;

--Invalid weight
Select * FROM zepto1
WHERE weightInGms<=0; 

-- Update 0 weightingms to null
UPDATE zepto1
SET weightInGms = NULL
WHERE weightInGms <= 0;

Select * FROM zepto1
WHERE weightInGms IS NULL; 

-- Invalid quantities
SELECT availableQuantity,quantity FROM zepto1
WHERE availableQuantity<0 OR quantity<0;


-- KPIs

--How much discount is being offered on products on average?
SELECT 
ROUND(AVG(discountPercent),2) AS avg_discount_per
FROM zepto1;

--Average Selling Price
SELECT
    ROUND(AVG(discountedsellingprice), 2) AS average_selling_price
FROM zepto1;

--Inventory Value at Current Selling Price
SELECT ROUND(SUM(discountedsellingprice * availablequantity),2)
	AS inventory_value
FROM zepto1;

--Total Inventory Weight
SELECT
    SUM(weightInGms * availablequantity) AS total_inventory_weight_gms
FROM zepto1
WHERE outofstock = FALSE
AND weightInGms IS NOT NULL;


--Business Analysis

-- 1. What are the top 10 products with the highest discount percentage?
SELECT name,mrp,discountedSellingPrice,discountPercent
FROM zepto1
ORDER BY discountPercent DESC 
LIMIT 10;

--2. What are the products with high MRP but out of stock?
SELECT DISTINCT name,mrp,discountedSellingPrice 
FROM zepto1
WHERE outOfStock IS TRUE
ORDER BY mrp DESC
LIMIT 10;

--3. What is the estimated inventory value for each category?
SELECT category,
	ROUND(SUM(discountedSellingPrice * availablequantity),2)
	AS inventory_value
FROM zepto1
WHERE outofstock IS FALSE
GROUP BY category
ORDER BY inventory_value DESC;


--4. Which products have an MRP greater than ₹500 and a discount below 10%?
SELECT name,mrp,discountpercent
FROM zepto1
WHERE mrp>500 and discountpercent<10;

--5. Which products offer the lowest price per gram?
SELECT name, ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto1
WHERE weightInGms IS NOT NULL
AND weightInGms>0
ORDER BY price_per_gram 
LIMIT 10;


--6. What is the average discount percentage for each product category?
SELECT category,ROUND(AVG(discountpercent),2) as avg_discount_percent
FROM zepto1
GROUP BY category;

--7. Which product categories have an average discount percentage greater than 10%?
SELECT category,ROUND(AVG(discountpercent),3) AS avg_discount_percent
FROM zepto1
GROUP BY category
HAVING AVG(discountPercent) > 10;


--8. What percentage of the product assortment is currently in stock?
SELECT
    COUNT(*) AS total_product_records,
    SUM(CASE WHEN outOfStock = FALSE THEN 1 ELSE 0 END) AS in_stock_skus,
    ROUND(
        100.0 * SUM(CASE WHEN outOfStock = FALSE THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS in_stock_percentage
FROM zepto1;

--9. Which categories have the highest number of unique products?
SELECT 
    category,
    COUNT(DISTINCT name) AS product_count
FROM zepto1
GROUP BY category
ORDER BY product_count DESC;

--10.Which products have the highest estimated inventory value?
SELECT sku_id,
       name,
       ROUND(discountedSellingPrice * availableQuantity, 2) AS inventory_value
FROM zepto1
WHERE outOfStock IS FALSE
ORDER BY inventory_value DESC
LIMIT 10;

--Business Insights
1. Strong overall product availability:
   The dataset contains 3,731 product records, of which 3,278 are in stock, giving an overall in-stock availability of 87.86%.
   This indicates generally good product availability, while the remaining out-of-stock SKUs represent opportunities to 
   improve inventory management.

2. Fruits & Vegetables have the highest average discounts:
   Fruits & Vegetables have the highest average discount of 15.46%, followed by Meats, Fish & Eggs at 11.03%.
   These categories have relatively higher discounts, which could indicate a stronger promotional focus.

3. High-value inventory is led by a few products:
   Borges Extra Light Olive Oil has the highest inventory value at ₹8,394 per SKU, followed by
   Praakritik Natural Desi Gir Cow A2 Ghee at ₹7,830 and Saffola Gold at ₹7,440. These products may require careful inventory monitoring
   because they have relatively high inventory value per SKU.

4. Cooking Essentials and Munchies have the largest product assortment:
   Cooking Essentials and Munchies have the highest number of unique products, with 478 products each.
   This indicates a broad product assortment in these categories and suggests that effective inventory planning in these categories
   could have a significant operational impact.

5. High discounts present promotional opportunities:
   Products such as Dukes Waffy Chocolate, Orange, and Strawberry Wafers have discounts of 51%, while several other products
   have discounts around 50%. These highly discounted products could support promotional strategies 
   for price-sensitive customers, although their profitability should also be monitored.