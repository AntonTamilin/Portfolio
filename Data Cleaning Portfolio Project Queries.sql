/*
Cleaning Data in SQL Queries
*/


SELECT *
FROM Project.dbo.Borough_of_Manhattan


--------------------------------------------------------------------

-- Standardize Date Format

SELECT sale_date, CONVERT(Date, sale_date)
FROM Project.dbo.Borough_of_Manhattan

UPDATE Project.dbo.Borough_of_Manhattan
SET sale_date = CONVERT(Date,sale_date)

-- The previous approach did not yield the desired results
-- Trying an alternative method:

ALTER TABLE Project.dbo.Borough_of_Manhattan
ALTER COLUMN sale_date DATE

UPDATE Project.dbo.Borough_of_Manhattan
SET sale_date = CONVERT(date, sale_date)

--------------------------------------------------------------------

-- Standardize column values:

UPDATE Project.dbo.Borough_of_Manhattan
SET neighborhood = LOWER(neighborhood),
    building_class_category = UPPER(building_class_category),
    address = UPPER(address);


SELECT *
FROM Project.dbo.Borough_of_Manhattan

--------------------------------------------------------------------

-- Remove apartment number from the address and add it to the apartment_number column

SELECT 
    CASE
        WHEN CHARINDEX(',', address) > 0 THEN LTRIM(RTRIM(SUBSTRING(address, CHARINDEX(',', address) + 1, LEN(address))))
        ELSE ''
    END AS apartment_number,
    CASE
        WHEN CHARINDEX(',', address) > 0 THEN LTRIM(RTRIM(SUBSTRING(address, 1, CHARINDEX(',', address) - 1)))
        ELSE address
    END AS new_address
FROM Project.dbo.Borough_of_Manhattan;


-- Update the table

UPDATE Project.dbo.Borough_of_Manhattan
SET
    apartment_number = CASE
        WHEN CHARINDEX(',', address) > 0 THEN LTRIM(RTRIM(SUBSTRING(address, CHARINDEX(',', address) + 1, LEN(address))))
        ELSE apartment_number
    END,
    address = CASE
        WHEN CHARINDEX(',', address) > 0 THEN LTRIM(RTRIM(SUBSTRING(address, 1, CHARINDEX(',', address) - 1)))
        ELSE address
    END;



SELECT *
FROM Project.dbo.Borough_of_Manhattan

--------------------------------------------------------------------

--Remove Duplicates


--Taking address, sale_price, and sale_date to see if there are duplicates in the data.

SELECT address, sale_price, sale_date, COUNT(*) AS DuplicateCount
FROM Project.dbo.Borough_of_Manhattan
GROUP BY address, sale_price, sale_date
HAVING COUNT(*) > 1;

--Let's examine the data more closely using JOIN as a subquery 

SELECT tabl.*
FROM Project.dbo.Borough_of_Manhattan AS tabl
JOIN (
    SELECT address, sale_price, sale_date
    FROM Project.dbo.Borough_of_Manhattan
    GROUP BY address, sale_price, sale_date
    HAVING COUNT(*) > 1
) AS subq
ON tabl.address = subq.address AND tabl.sale_price = subq.sale_price AND tabl.sale_date = subq.sale_date;

-- We can observe that the dataset contains numerous duplicates.
-- The majority of duplicates occur when the address, sale_price, and sale_date are identical, with the only difference being the apartment_number,
-- which can be either "23A" or "23B". These entries can be treated as duplicates since they represent a single purchase.


-- Removing duplicates from a table using JOIN:

DELETE FROM Project.dbo.Borough_of_Manhattan
FROM Project.dbo.Borough_of_Manhattan
JOIN (
    SELECT address, sale_price, sale_date
    FROM Project.dbo.Borough_of_Manhattan
    GROUP BY address, sale_price, sale_date
    HAVING COUNT(*) > 1
) AS duplicates
ON Project.dbo.Borough_of_Manhattan.address = duplicates.address
    AND Project.dbo.Borough_of_Manhattan.sale_price = duplicates.sale_price
    AND Project.dbo.Borough_of_Manhattan.sale_date = duplicates.sale_date;



SELECT *
FROM Project.dbo.Borough_of_Manhattan


--------------------------------------------------------------------

-- Searching for exceptionally high selling prices

-- We are aware that New York is known for its high cost of living.
-- However, it is important to note that extremely high prices are typically associated with commercial real estate or entire buildings, rather than individual apartments.
-- Therefore, we are limiting our search in the database to apartments with a sale price of no more than $60 million.


-- Replacing unrealistically prices with NULL

UPDATE Project.dbo.Borough_of_Manhattan
SET sale_price = NULL
WHERE sale_price > 60000000

--------------------------------------------------------------------

-- Checking and Counting records with missing values

SELECT COUNT(*) AS MissingCount
FROM Project.dbo.Borough_of_Manhattan
WHERE address IS NULL OR sale_date IS NULL OR sale_price IS NULL;

-- Removing NULL's

DELETE FROM Project.dbo.Borough_of_Manhattan
WHERE address IS NULL OR sale_date IS NULL OR sale_price IS NULL;


SELECT *
FROM Project.dbo.Borough_of_Manhattan

--------------------------------------------------------------------

-- Removing Unused Columns
-- Since the "easement" column does not contain reliable information, it has been decided to remove it.

Select *
From Project.dbo.Borough_of_Manhattan


ALTER TABLE Project.dbo.Borough_of_Manhattan
DROP COLUMN easement


