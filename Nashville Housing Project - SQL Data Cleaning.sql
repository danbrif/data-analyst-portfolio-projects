/*

NASHVILLE HOUSING DATA CLEANING SQL QUERIES

TOOLS: SQL Server Management Studio (SSMS)
DATASET: https://docs.google.com/spreadsheets/d/1Z-bo2S5UleNm7eBaUwo_jz1doI4qepYE/edit?usp=sharing&ouid=103602607309867126936&rtpof=true&sd=true

*/

SELECT *
FROM PortfolioProject..Nashville




-------------------------------------------------------------------------------------------
-- STANDARDIZE DATE FORMAT

UPDATE Nashville
SET SaleDate = CONVERT(Date, SaleDate)

--If above query doesn't work properly, try below:

ALTER TABLE Nashville
ADD SaleDateConverted Date;

UPDATE Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)



SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..Nashville




-------------------------------------------------------------------------------------------
-- POPULATE PROPERTY ADDRESS DATA

SELECT * 
FROM PortfolioProject..Nashville
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville a
JOIN PortfolioProject..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville a
JOIN PortfolioProject..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL




-------------------------------------------------------------------------------------------
-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY, STATE)


--(1) PROPERTY ADDRESS

SELECT PropertyAddress
FROM PortfolioProject..Nashville
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject..Nashville


ALTER TABLE Nashville
ADD RealtyAddress nvarchar(255);

UPDATE Nashville
SET RealtyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville
ADD City nvarchar(255);

UPDATE Nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




--(2) OWNER ADDRESS

SELECT OwnerAddress
FROM PortfolioProject..Nashville

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..Nashville


ALTER TABLE Nashville
ADD Owner_Address nvarchar(255);

UPDATE Nashville
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville
ADD Owner_City nvarchar(255);

UPDATE Nashville
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville
ADD Owner_State nvarchar(255);

UPDATE Nashville
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




SELECT *
FROM PortfolioProject..Nashville




-------------------------------------------------------------------------------------------
-- CHANGE (Y) & (N) to (Yes) & (No) in "Sold as Vacant" COLUMN

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..Nashville


UPDATE PortfolioProject..Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END




-------------------------------------------------------------------------------------------
-- REMOVE DUPLICATES

WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM PortfolioProject..Nashville
)

--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY ParcelID

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY ParcelID




-------------------------------------------------------------------------------------------
-- DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict




-------------------------------------------------------------------------------------------
-- Creating View to Store Data for Visualizations

CREATE VIEW NashvilleHousing as
SELECT *
FROM PortfolioProject..Nashville



