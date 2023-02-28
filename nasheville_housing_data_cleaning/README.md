# Data Cleaning with SQL

## Overview

This data cleaning project is to prepare a dataset for analysis by addressing missing values, outliers, inconsistencies, and other data quality issues. The dataset used is sourced from [AlexTheAnalyst](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx)

The dataset was cleaned using `DataGrip` and `MySQL`, and underwent a series of data transformations to enable analysis. Instructions for reproducing the data cleaning process using the [SQL Script](./nasheville_housing.sql).

The following was done in the script:

### 1. Changed the formatting of the `SalesDate` Column

The `SalesDate` column was converted from `text` to `date` format.

```sql
SELECT SaleDate, CONVERT(SaleDate, date) AS New_SalesDate
FROM nashvile_housing_data;

ALTER TABLE nashvile_housing_data
    MODIFY SaleDate DATE;
UPDATE nashvile_housing_data
SET SaleDate = STR_TO_DATE(SaleDate, '%Y-%m-%d');
```

### 2. Filled the `PropertyAddress` Column

The `PropertyAddress` column was filled with values by comparing the `ParcelID` column with other rows in the dataset.

```sql
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
```

### 3. Split the `PropertyAddress` and `OwnerAddress` Columns

The `PropertyAddress` and `OwnerAddress` columns were seperated into multiple columns to enable analysis.

```sql
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
```

```sql
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
```

### 4. Changed the values of the SoldAsVacant Column

The values of the SoldAsVacant column were standardized to "Yes" and "No" for consistency.

```sql
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
```

### 5. Removed Duplicate Data

Duplicate data was removed from the dataset using a common table expression (CTE) and an `INNER JOIN`.

```sql
WITH row_num_CTE AS (SELECT UniqueID,
                            ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
                     FROM nashvile_housing_data)
DELETE nhd
FROM nashvile_housing_data nhd
         INNER JOIN row_num_CTE rnC ON nhd.UniqueID = rnC.UniqueID
WHERE row_num > 1;
```

### 6. Deleted Unused Columns

Unused columns were removed from the dataset after the `PropertyAddress` and `OwnerAddress` columns were split and also the `TaxDistrict`.

```sql
SELECT *
FROM nashvile_housing_data;

ALTER TABLE nashvile_housing_data
    DROP PropertyAddress,
    DROP OwnerAddress,
    DROP TaxDistrict;
```

## Acknowledgements

This data cleaning project was developed with the guidance of the tutorial by [Alex the Analyst](https://www.youtube.com/channel/UC7cs8q-gJRlGwj4A8OmCmXg). The tutorial provided valuable insights and best practices for data cleaning, which were applied in this project. We acknowledge and appreciate Alex's contribution to the data science community.
