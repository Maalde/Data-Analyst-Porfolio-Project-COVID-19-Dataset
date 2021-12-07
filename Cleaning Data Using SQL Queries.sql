SELECT TOP (100) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfoLioProject].[dbo].[NashvilleHousingData ]


/*
  Cleanign Housing Data in SQL Queries
  */

-- Standardise Data Format

SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortfoLioProject.dbo.[NashvilleHousingData ]

UPDATE [NashvilleHousingData ]
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE PortfoLioProject.dbo.NashvilleHousingData
ADD ConvertedSaleDate DATE; 
GO

UPDATE [NashvilleHousingData ]
SET ConvertedSaleDate = CONVERT(date,SaleDate)
GO


--- Populate Property Address Data

SELECT *
FROM PortfoLioProject.dbo.[NashvilleHousingData ]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT one.ParcelID,one.PropertyAddress,two.ParcelID,two.PropertyAddress, ISNULL(one.PropertyAddress,two.PropertyAddress)
FROM PortfoLioProject.dbo.[NashvilleHousingData ] one
JOIN PortfoLioProject.dbo.[NashvilleHousingData ] two
ON one.ParcelID = two.ParcelID
AND one.UniqueID <> two.UniqueID
WHERE one.PropertyAddress IS NULL

-------------------------------------------------------------------------------------

UPDATE one 
SET PropertyAddress  = ISNULL(one.PropertyAddress,two.PropertyAddress)
FROM PortfoLioProject.dbo.[NashvilleHousingData ] one
JOIN PortfoLioProject.dbo.[NashvilleHousingData ] two
ON one.ParcelID = two.ParcelID
AND one.UniqueID <> two.UniqueID
WHERE one.PropertyAddress IS NULL

/* 

Breaking out address into several columns

*/

SELECT PropertyAddress
FROM PortfoLioProject.dbo.[NashvilleHousingData ]
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as City
FROM PortfoLioProject.dbo.[NashvilleHousingData ]

ALTER TABLE PortfoLioProject.dbo.NashvilleHousingData
ADD SplitPropertyAddress NVARCHAR(50); 
GO

UPDATE [NashvilleHousingData ]
SET SplitPropertyAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)
GO

ALTER TABLE PortfoLioProject.dbo.NashvilleHousingData
ADD SplitPropertyCity NVARCHAR(50); 
GO

UPDATE [NashvilleHousingData ]
SET SplitPropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))
GO


SELECT *
FROM PortfoLioProject.dbo.[NashvilleHousingData ]

---- This can be done in another form using PARSENAME. See below using OwnerAddress column


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM PortfoLioProject.dbo.[NashvilleHousingData ]

--- add column names


ALTER TABLE PortfoLioProject.dbo.NashvilleHousingData
ADD SplitOwnerAddress NVARCHAR(50); 
GO

UPDATE [NashvilleHousingData ]
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
GO

ALTER TABLE PortfoLioProject.dbo.NashvilleHousingData
ADD SplitOwnerCity NVARCHAR(50); 
GO

UPDATE [NashvilleHousingData ]
SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
GO


ALTER TABLE PortfoLioProject.dbo.NashvilleHousingData
ADD SplitOwnerState NVARCHAR(50); 
GO

UPDATE [NashvilleHousingData ]
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
GO

SELECT *
FROM PortfoLioProject.dbo.[NashvilleHousingData ]


/*
Transfrom Y and N to Yes and No in the 'SoldAsVacant' column
*/

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfoLioProject.dbo.[NashvilleHousingData ]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y'  THEN 'Yes'
WHEN SoldAsVacant = 'N'  THEN 'No'
ELSE SoldAsVacant
END 
FROM PortfoLioProject.dbo.[NashvilleHousingData ]

--- Updating the column and table 
UPDATE PortfoLioProject.dbo.[NashvilleHousingData ]
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y'  THEN 'Yes'
WHEN SoldAsVacant = 'N'  THEN 'No'
ELSE SoldAsVacant
END 


SELECT SoldAsVacant
FROM PortfoLioProject.dbo.[NashvilleHousingData ]


/* 
Removing duplicates using CTE 
*/

-- CTE
WITH RowNumberCTE AS(
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        ORDER BY 
        UniqueID) row_num

FROM PortfoLioProject.dbo.[NashvilleHousingData ]
)

SELECT *
FROM RowNumberCTE
WHERE row_num >1 
ORDER by PropertyAddress


/* 
Deleting columns that are not useful(PropertyAddress, SaleDate,OwnerAddress,TaxDistrict)
*/

SELECT *
FROM PortfoLioProject.dbo.[NashvilleHousingData ]

ALTER TABLE PortfoLioProject.dbo.NashvilleHousingData
DROP COLUMN  PropertyAddress, SaleDate,OwnerAddress,TaxDistrict
GO

