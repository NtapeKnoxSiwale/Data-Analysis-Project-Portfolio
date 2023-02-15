/*
 Nashville Housing Data Cleaning
 */

SELECT *
FROM nashvile_housing_data;

-- SalesDate formatting
SELECT SaleDate, CONVERT(SaleDate, date) AS New_SalesDate
FROM nashvile_housing_data;

ALTER TABLE nashvile_housing_data
    MODIFY SaleDate DATE;
UPDATE nashvile_housing_data
SET SaleDate = STR_TO_DATE(SaleDate, '%Y-%m-%d');

-- Property Address
SELECT *
FROM nashvile_housing_data
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT nhd1.ParcelID, nhd1.PropertyAddress, nhd2.ParcelID, nhd2.PropertyAddress
FROM nashvile_housing_data nhd1
         JOIN nashvile_housing_data nhd2
              ON nhd1.ParcelID = nhd2.ParcelID
                  AND nhd1.UniqueID <> nhd2.UniqueID
WHERE nhd1.PropertyAddress IS NULL;

UPDATE Nashville_Housing.nashvile_housing_data nhd1
    LEFT JOIN nashvile_housing_data nhd2 ON nhd1.ParcelID = nhd2.ParcelID
        AND nhd1.UniqueID <> nhd2.UniqueID
SET nhd1.PropertyAddress = nhd2.PropertyAddress
WHERE nhd1.PropertyAddress IS NULL;

-- Splitting the Addresses

# PropertyAddress
SELECT PropertyAddress,
       SUBSTRING_INDEX(PropertyAddress, ',', 1)  AS Address,
       SUBSTRING_INDEX(PropertyAddress, ',', -1) AS City
FROM nashvile_housing_data;

ALTER TABLE nashvile_housing_data
    ADD PropertySplitAddress nvarchar(255);

UPDATE nashvile_housing_data
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

ALTER TABLE nashvile_housing_data
    ADD PropertySplitCity nvarchar(255);

UPDATE nashvile_housing_data
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

/*
#Delete the columns previously created
ALTER TABLE nashvile_housing_data
    DROP COLUMN Address;
ALTER TABLE nashvile_housing_data
    DROP COLUMN City;

# For Deleting the PropertyAddress Column
ALTER TABLE nashvile_housing_data
    DROP COLUMN City;
   */

# OwnerAddress
SELECT OwnerAddress,
       SUBSTRING_INDEX(OwnerAddress, ',', 1)                           AS Address,
       SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
       SUBSTRING_INDEX(OwnerAddress, ',', -1)                          AS State
FROM nashvile_housing_data;

ALTER TABLE nashvile_housing_data
    ADD OwnerSplitAddress nvarchar(255);

UPDATE nashvile_housing_data
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE nashvile_housing_data
    ADD OwnerSplitCity nvarchar(255);

UPDATE nashvile_housing_data
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE nashvile_housing_data
    ADD OwnerSplitState nvarchar(255);

UPDATE nashvile_housing_data
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT *
FROM nashvile_housing_data;

-- SoldAsVacant
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvile_housing_data
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
       CASE
           WHEN SoldAsVacant = 'Y' THEN 'Yes'
           WHEN SoldAsVacant = 'N' THEN 'No'
           ELSE SoldAsVacant
           END
FROM nashvile_housing_data;

UPDATE nashvile_housing_data
SET SoldAsVacant = CASE
                       WHEN SoldAsVacant = 'Y' THEN 'Yes'
                       WHEN SoldAsVacant = 'N' THEN 'No'
                       ELSE SoldAsVacant
    END;

-- Removing Duplicates
WITH row_num_CTE AS (SELECT UniqueID,
                            ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
                     FROM nashvile_housing_data)
DELETE nhd
FROM nashvile_housing_data nhd
         INNER JOIN row_num_CTE rnC ON nhd.UniqueID = rnC.UniqueID
WHERE row_num > 1;

/* Checking
WITH row_num_CTE AS (SELECT *,
                            ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
                     FROM nashvile_housing_data)
SELECT *
FROM row_num_CTE
WHERE row_num > 1;*/

-- Removing Unused Columns
SELECT *
FROM nashvile_housing_data;

ALTER TABLE nashvile_housing_data
    DROP PropertyAddress,
    DROP OwnerAddress,
    DROP TaxDistrict;
