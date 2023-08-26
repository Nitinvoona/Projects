-- Cleaning Data
 SELECT * FROM [Portfolio Project].dbo.NashvilleHousing

-- Standardize Data Format
 SELECT SaleDate,CAST(SaleDate AS date) FROM [Portfolio Project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE [Portfolio Project].dbo.NashvilleHousing 
SET SaleDateConverted = CAST(SaleDate AS date)

--Populate Property Address Data

SELECT *
FROM [Portfolio Project].dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
FROM [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns(Address,City,State)

SELECT Propertyaddress
FROM [Portfolio Project].dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].dbo.NashvilleHousing

-- Adding new columns to the table

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD PropertySplitAddress Nvarchar(255)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD PropertySplitCity Nvarchar(255)

-- Inserting the splitted data to the new columns

UPDATE [Portfolio Project].dbo.NashvilleHousing 
SET PropertySplitAddress  = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

UPDATE [Portfolio Project].dbo.NashvilleHousing 
SET PropertySplitCity  = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) 



SELECT OwnerAddress  FROM [Portfolio Project].dbo.NashvilleHousing 

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project].dbo.NashvilleHousing 


-- Adding new columns to the table

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing 
ADD OwnerSplitState Nvarchar(255)

-- Inserting the splitted data to the new columns

UPDATE [Portfolio Project].dbo.NashvilleHousing 
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 


UPDATE [Portfolio Project].dbo.NashvilleHousing 
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


UPDATE [Portfolio Project].dbo.NashvilleHousing 
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
FROM [Portfolio Project].dbo.NashvilleHousing

UPDATE [Portfolio Project].dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 

--Remove Duplicates

WITH row_numCTE AS(
SELECT *,ROW_NUMBER()OVER
(PARTITION BY 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference ORDER BY UniqueID) row_num
FROM [Portfolio Project].dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE FROM row_numCTE
WHERE row_num >1

-- Delete Unused Columns 

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN PropertyAddress , OwnerAddress,TaxDistrict

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate

-- Clean DataTable
SELECT * FROM [Portfolio Project].dbo.NashvilleHousing